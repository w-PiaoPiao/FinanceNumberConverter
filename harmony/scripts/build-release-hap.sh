#!/usr/bin/env bash
# build-release-hap.sh
# 一键编译鸿蒙 Release HAP（带签名）
#
# 前置：~/.zshrc 已 export FNC_KEYSTORE_PASSWORD 和 FNC_KEY_ALIAS_PASSWORD
#
# 用法：./scripts/build-release-hap.sh

set -euo pipefail

# ============== 配置 ==============
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HARMONY_DIR="$(dirname "$SCRIPT_DIR")"
HAP_NAME="entry-default-signed.hap"
HAP_PATH="$HARMONY_DIR/entry/build/default/outputs/default/$HAP_NAME"

# ============== 颜色 ==============
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ok()   { echo -e "${GREEN}✅ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
err()  { echo -e "${RED}❌ $1${NC}" >&2; }

# ============== 前置检查 ==============
echo "=== 鸿蒙 Release HAP 编译脚本 ==="
echo ""

# 1. 检查环境变量
# 如果当前 shell 没加载（bash 脚本不会自动 source .zshrc），尝试加载
if [[ -z "${FNC_KEYSTORE_PASSWORD:-}" ]]; then
  for rc in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.bash_profile"; do
    if [[ -f "$rc" ]] && grep -q "FNC_KEYSTORE_PASSWORD" "$rc" 2>/dev/null; then
      # shellcheck disable=SC1090
      source "$rc" 2>/dev/null || true
      break
    fi
  done
fi

if [[ -z "${FNC_KEYSTORE_PASSWORD:-}" ]]; then
  err "环境变量 FNC_KEYSTORE_PASSWORD 未设置"
  err "请在 ~/.zshrc 加："
  err "  export FNC_KEYSTORE_PASSWORD=你的密钥库密码"
  err "  export FNC_KEY_ALIAS_PASSWORD=你的别名密码"
  err ""
  err "加完后跑：source ~/.zshrc"
  exit 1
fi

if [[ -z "${FNC_KEY_ALIAS_PASSWORD:-}" ]]; then
  err "环境变量 FNC_KEY_ALIAS_PASSWORD 未设置"
  exit 1
fi
ok "环境变量已加载（密码不在日志中明文显示）"

# 设置 DevEco Studio SDK 路径（命令行 build 需要）
if [[ -z "${DEVECO_SDK_HOME:-}" ]]; then
  for candidate in \
    "/Applications/DevEco-Studio.app/Contents/sdk" \
    "$HOME/Library/Huawei/Sdk"; do
    if [[ -d "$candidate" ]]; then
      export DEVECO_SDK_HOME="$candidate"
      ok "设置 DEVECO_SDK_HOME=$candidate"
      break
    fi
  done
fi

# 设置 JAVA_HOME（签名工具需要 JBR，DevEco Studio 自带）
if [[ -z "${JAVA_HOME:-}" ]] || [[ ! -x "${JAVA_HOME}/bin/java" ]]; then
  for candidate in \
    "/Applications/DevEco-Studio.app/Contents/jbr/Contents/Home" \
    "/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home" \
    "/opt/homebrew/opt/openjdk@17"; do
    if [[ -x "$candidate/bin/java" ]]; then
      export JAVA_HOME="$candidate"
      # 关键：把 java 加到 PATH 最前面，否则 hvigor 内部签名工具找不到
      export PATH="$JAVA_HOME/bin:$PATH"
      ok "设置 JAVA_HOME=$candidate"
      ok "PATH 已更新，java 优先用：$(which java)"
      break
    fi
  done
fi

# 2. 检查签名文件
for f in release.p12 release.p7b; do
  if [[ ! -f "$HARMONY_DIR/$f" ]]; then
    err "缺少签名文件：$HARMONY_DIR/$f"
    err "请先参考 docs/release-checklist.md 准备签名证书"
    exit 1
  fi
done
ok "签名文件就位 (p12 + p7b)"

# 3. 检查 hvigorw
HVIGORW="$HARMONY_DIR/hvigorw"
if [[ ! -x "$HVIGORW" ]]; then
  # 尝试找 DevEco Studio 自带的 hvigorw
  HVIGORW_PATH=$(find /Applications/DevEco-Studio.app -name "hvigorw.js" 2>/dev/null | head -1)
  if [[ -z "$HVIGORW_PATH" ]]; then
    err "找不到 hvigorw 脚本"
    err "请在 DevEco Studio 终端里跑此脚本"
    exit 1
  fi
  warn "使用 DevEco Studio 内置 hvigor: $HVIGORW_PATH"
  HVIGORW="node $HVIGORW_PATH"
fi

# ============== 清理旧产物 ==============
echo ""
echo "=== 清理旧产物 ==="
if [[ -d "$HARMONY_DIR/entry/build" ]]; then
  rm -rf "$HARMONY_DIR/entry/build"
  ok "已清理 entry/build/"
fi
if [[ -d "$HARMONY_DIR/build" ]]; then
  rm -rf "$HARMONY_DIR/build"
  ok "已清理 build/"
fi

# ============== 编译 ==============
echo ""
echo "=== 开始编译 Release HAP ==="
cd "$HARMONY_DIR"
# 先停掉旧的 daemon（daemon 会缓存环境变量）
$HVIGORW --stop-daemon 2>/dev/null || true
$HVIGORW clean --mode module -p product=default assembleHap --analyze=normal --parallel --incremental --daemon

# ============== 验证产物 ==============
echo ""
echo "=== 验证产物 ==="
if [[ ! -f "$HAP_PATH" ]]; then
  err "编译失败：未找到 $HAP_PATH"
  exit 1
fi

HAP_SIZE=$(ls -lh "$HAP_PATH" | awk '{print $5}')
ok "HAP 生成成功！"
ok "路径：$HAP_PATH"
ok "大小：$HAP_SIZE"

# ============== 验证签名 ==============
echo ""
echo "=== 验证签名 ==="
# V2 签名工具不写 META-INF，而是嵌入在 .pages.info 或 module.json
# 通过 build log 中的 "sign app success" 判断
BUILD_LOG="$HARMONY_DIR/.hvigor/outputs/build-logs/build.log"
if [[ -f "$BUILD_LOG" ]] && grep -q "sign app success" "$BUILD_LOG"; then
  ok "签名验证通过（build log 含 'sign app success'）"
  # 也检查文件大小合理性
  if [[ -f "$HAP_PATH" ]]; then
    TMP_DIR=$(mktemp -d)
    unzip -q "$HAP_PATH" -d "$TMP_DIR"
    if [[ -f "$TMP_DIR/.pages.info" ]]; then
      ok "V2 签名标志文件存在：.pages.info"
    fi
    rm -rf "$TMP_DIR"
  fi
else
  warn "未发现 sign app success 标记，请检查 build log"
fi

# ============== 收尾 ==============
echo ""
ok "全部完成！"
echo "下一步："
echo "  1. 模拟器跑一下 HAP 验证（adb install）"
echo "  2. 上传 AGC 提交审核"
echo "  3. 详见 docs/release-checklist.md"
