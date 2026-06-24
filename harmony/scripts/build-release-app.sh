#!/usr/bin/env bash
# build-release-app.sh
# 一键编译鸿蒙 Release APP（上架 AGC 用的 .app 包）
#
# 说明：AGC 的"软件包管理"实际要求上传 .app 格式（App Pack），而不是单个 .hap。
# 本脚本会先调用 build-release-hap.sh 生成签名 HAP，再用 DevEco SDK 的 app_packing_tool.jar
# 把 HAP + pack.info 打包成 .app。
#
# 用法：./scripts/build-release-app.sh

set -euo pipefail

# ============== 配置 ==============
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HARMONY_DIR="$(dirname "$SCRIPT_DIR")"
HAP_NAME="entry-default-signed.hap"
APP_NAME="FinanceNumberConverter.app"
HAP_PATH="$HARMONY_DIR/entry/build/default/outputs/default/$HAP_NAME"
PACK_INFO_PATH="$HARMONY_DIR/entry/build/default/outputs/default/pack.info"
APP_PATH="$HARMONY_DIR/entry/build/default/outputs/default/$APP_NAME"

# ============== 颜色 ==============
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ok()   { echo -e "${GREEN}✅ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
err()  { echo -e "${RED}❌ $1${NC}" >&2; }

# ============== 前置检查 ==============
echo "=== 鸿蒙 Release APP 打包脚本 ==="
echo ""

# 1. 先跑 HAP 编译脚本
HAP_BUILD_SCRIPT="$SCRIPT_DIR/build-release-hap.sh"
if [[ ! -x "$HAP_BUILD_SCRIPT" ]]; then
  err "找不到 HAP 编译脚本：$HAP_BUILD_SCRIPT"
  exit 1
fi

ok "开始编译 Release HAP..."
"$HAP_BUILD_SCRIPT"

# 2. 检查 HAP 与 pack.info 产物
if [[ ! -f "$HAP_PATH" ]]; then
  err "HAP 产物不存在：$HAP_PATH"
  exit 1
fi
ok "HAP 产物已就绪：$HAP_PATH"

if [[ ! -f "$PACK_INFO_PATH" ]]; then
  err "pack.info 不存在：$PACK_INFO_PATH"
  err "请确认 build-release-hap.sh 是否正常生成该文件"
  exit 1
fi
ok "pack.info 已就绪：$PACK_INFO_PATH"

# 3. 定位 app_packing_tool.jar
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

PACKING_TOOL=""
if [[ -n "${DEVECO_SDK_HOME:-}" ]]; then
  PACKING_TOOL=$(find "$DEVECO_SDK_HOME" -name "app_packing_tool.jar" 2>/dev/null | head -1)
fi

if [[ -z "$PACKING_TOOL" ]] || [[ ! -f "$PACKING_TOOL" ]]; then
  err "找不到 app_packing_tool.jar"
  err "请确认 DevEco Studio 已安装，或手动设置 DEVECO_SDK_HOME"
  exit 1
fi
ok "找到打包工具：$PACKING_TOOL"

# 4. 定位 Java（DevEco Studio 自带 JBR）
if [[ -z "${JAVA_HOME:-}" ]] || [[ ! -x "${JAVA_HOME}/bin/java" ]]; then
  for candidate in \
    "/Applications/DevEco-Studio.app/Contents/jbr/Contents/Home" \
    "/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home" \
    "/opt/homebrew/opt/openjdk@17"; do
    if [[ -x "$candidate/bin/java" ]]; then
      export JAVA_HOME="$candidate"
      export PATH="$JAVA_HOME/bin:$PATH"
      break
    fi
  done
fi

if [[ -z "${JAVA_HOME:-}" ]] || [[ ! -x "${JAVA_HOME}/bin/java" ]]; then
  err "找不到可用的 Java 运行时"
  exit 1
fi
ok "使用 Java：$JAVA_HOME"

# ============== 打包 APP ==============
echo ""
echo "=== 开始打包 .app ==="
rm -f "$APP_PATH"

# 注意：此 SDK 版本的 app_packing_tool 命令行参数为 --mode app
"$JAVA_HOME/bin/java" -jar "$PACKING_TOOL" \
  --mode app \
  --hap-path "$HAP_PATH" \
  --pack-info-path "$PACK_INFO_PATH" \
  --out-path "$APP_PATH"

if [[ ! -f "$APP_PATH" ]]; then
  err "打包失败：未找到 $APP_PATH"
  exit 1
fi

APP_SIZE=$(ls -lh "$APP_PATH" | awk '{print $5}')
ok ".app 生成成功！"
ok "路径：$APP_PATH"
ok "大小：$APP_SIZE"

# ============== 验证 APP 内容 ==============
echo ""
echo "=== 验证 APP 内容 ==="
TMP_DIR=$(mktemp -d)
unzip -q "$APP_PATH" -d "$TMP_DIR"
if [[ -f "$TMP_DIR/$HAP_NAME" ]] && [[ -f "$TMP_DIR/pack.info" ]]; then
  ok ".app 内包含 HAP 与 pack.info，结构正确"
else
  warn ".app 内容异常，请检查"
fi
rm -rf "$TMP_DIR"

# ============== 收尾 ==============
echo ""
ok "全部完成！"
echo "下一步："
echo "  1. 在 AGC → 软件包管理 → 上传 $APP_NAME"
echo "  2. 继续填写应用信息、截图、隐私政策 URL"
echo "  3. 提交审核"
echo ""
echo "注意：AGC 上传对话框显示"APP format"，请直接选择 .app 文件，不要选 .hap。"
