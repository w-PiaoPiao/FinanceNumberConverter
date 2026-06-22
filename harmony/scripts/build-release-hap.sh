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
TMP_DIR=$(mktemp -d)
unzip -q "$HAP_PATH" -d "$TMP_DIR"
if [[ -d "$TMP_DIR/META-INF" ]]; then
  SIGN_FILES=$(ls "$TMP_DIR/META-INF/" | grep -E "\.(SF|RSA|DSA|EC)$" | wc -l | tr -d ' ')
  if [[ "$SIGN_FILES" -ge 2 ]]; then
    ok "签名验证通过（META-INF 有 $SIGN_FILES 个签名文件）"
  else
    warn "未发现预期签名文件（可能是 debug 签名？$SIGN_FILES 个）"
  fi
else
  warn "未发现 META-INF 目录，HAP 未签名！"
fi
rm -rf "$TMP_DIR"

# ============== 收尾 ==============
echo ""
ok "全部完成！"
echo "下一步："
echo "  1. 模拟器跑一下 HAP 验证（adb install）"
echo "  2. 上传 AGC 提交审核"
echo "  3. 详见 docs/release-checklist.md"
