#!/usr/bin/env bash
# setup-signing.sh
# 配置鸿蒙签名环境变量（首次使用）
#
# 用法：./scripts/setup-signing.sh
# 之后用 source ~/.zshrc 生效

set -euo pipefail

ZSHRC="$HOME/.zshrc"
MARKER_START="# >>> FinanceNumberConverter HarmonyOS signing >>>"
MARKER_END="# <<< FinanceNumberConverter HarmonyOS signing <<<"

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
ok()   { echo -e "${GREEN}✅ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
err()  { echo -e "${RED}❌ $1${NC}" >&2; }

echo "=== 鸿蒙签名环境变量配置 ==="
echo ""

# 检查是否已配置
if grep -q "$MARKER_START" "$ZSHRC" 2>/dev/null; then
  warn "检测到 zshrc 中已有 FinanceNumberConverter 配置："
  echo ""
  sed -n "/$MARKER_START/,/$MARKER_END/p" "$ZSHRC"
  echo ""
  read -r -p "是否覆盖？(y/N) " overwrite
  if [[ ! "$overwrite" =~ ^[Yy]$ ]]; then
    ok "已跳过，配置不变"
    exit 0
  fi
  # 删除旧的
  # macOS sed 需要 -i ''
  sed -i '' "/$MARKER_START/,/$MARKER_END/d" "$ZSHRC"
  ok "已删除旧配置"
fi

# 提示输入密码
echo ""
echo "请输入签名密码（输入时不显示）："
read -r -s -p "  密钥库密码 (FNC_KEYSTORE_PASSWORD): " KS_PWD
echo ""
read -r -s -p "  别名密码 (FNC_KEY_ALIAS_PASSWORD, 直接回车同上): " KA_PWD
echo ""
KA_PWD=${KA_PWD:-$KS_PWD}

# 追加到 zshrc
cat >> "$ZSHRC" << EOF

$MARKER_START
export FNC_KEYSTORE_PASSWORD="$KS_PWD"
export FNC_KEY_ALIAS_PASSWORD="$KA_PWD"
$MARKER_END
EOF

ok "已写入 $ZSHRC"

# 立即生效
source "$ZSHRC"

# 验证
echo ""
echo "=== 验证 ==="
if [[ -n "${FNC_KEYSTORE_PASSWORD:-}" ]] && [[ -n "${FNC_KEY_ALIAS_PASSWORD:-}" ]]; then
  ok "环境变量已生效"
  ok "FNC_KEYSTORE_PASSWORD: ${#FNC_KEYSTORE_PASSWORD} 字符"
  ok "FNC_KEY_ALIAS_PASSWORD: ${#FNC_KEY_ALIAS_PASSWORD} 字符"
else
  err "环境变量未生效，请手动 source $ZSHRC"
  exit 1
fi

echo ""
ok "配置完成！"
echo "现在可以跑：./scripts/build-release-hap.sh"
