#!/usr/bin/env bash
#
# 首次生成 release.keystore（仅运行一次）
#
# 重要：生成的 keystore 文件**不入 git**（在 .gitignore 中）
#       请妥善保管（密码管理器推荐）
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANDROID_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
KEYSTORE_DIR="$ANDROID_DIR/keystore"
KEYSTORE="$KEYSTORE_DIR/release.keystore"

# Java
if [ -z "$JAVA_HOME" ]; then
    if [ -d "/Applications/Android Studio.app/Contents/jbr/Contents/Home" ]; then
        export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
    else
        echo "❌ 未找到 Java"
        exit 1
    fi
fi

mkdir -p "$KEYSTORE_DIR"

if [ -f "$KEYSTORE" ]; then
    echo "⚠️  keystore 已存在: $KEYSTORE"
    read -p "覆盖？(y/N) " answer
    if [ "$answer" != "y" ]; then
        echo "已取消"
        exit 0
    fi
    rm "$KEYSTORE"
fi

# 默认密码（用户应改）
STORE_PASS="${KEYSTORE_PASSWORD:-changeit}"
KEY_PASS="${KEY_PASSWORD:-changeit}"
ALIAS="${KEY_ALIAS:-release}"

echo "▶️  生成 keystore..."
echo "   alias: $ALIAS"
echo "   storepass: $STORE_PASS"
echo "   keypass: $KEY_PASS"
echo "   validity: 10000 days (27+ years)"
echo "   dname: CN=Piao, OU=Personal, O=Finance, L=Beijing, S=Beijing, C=CN"

"$JAVA_HOME/bin/keytool" -genkey -v \
    -keystore "$KEYSTORE" \
    -alias "$ALIAS" \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -storepass "$STORE_PASS" \
    -keypass "$KEY_PASS" \
    -dname "CN=Piao, OU=Personal, O=Finance, L=Beijing, S=Beijing, C=CN"

echo ""
echo "✅ keystore 已生成: $KEYSTORE"
echo ""
echo "⚠️  重要："
echo "   1. 此 keystore 不入 git（已在 .gitignore 屏蔽）"
echo "   2. 请把 keystore 文件 + 密码保存到密码管理器"
echo "   3. 下次 build APK：export KEYSTORE_PASSWORD=... && ./scripts/build-release-apk.sh"
