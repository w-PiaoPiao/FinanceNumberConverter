#!/usr/bin/env bash
#
# 一键构建 Release APK
#
# 用法：
#   ./scripts/build-release-apk.sh
#
# 前置：
#   1. 已安装 Android Studio（JBR 自带 Java 21）
#   2. 已生成 keystore（首次：./scripts/generate-keystore.sh）
#   3. 已设置环境变量 KEYSTORE_PASSWORD / KEY_ALIAS / KEY_PASSWORD
#

set -e

# ===== 路径 =====
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANDROID_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# ===== Java（JBR from Android Studio） =====
if [ -z "$JAVA_HOME" ]; then
    if [ -d "/Applications/Android Studio.app/Contents/jbr/Contents/Home" ]; then
        export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
        echo "ℹ️  使用 Android Studio 自带 JBR: $JAVA_HOME"
    else
        echo "❌ 未找到 Java。请设置 JAVA_HOME 或安装 Android Studio"
        exit 1
    fi
fi

# ===== Keystore 检查 =====
KEYSTORE="$ANDROID_DIR/keystore/release.keystore"
if [ ! -f "$KEYSTORE" ]; then
    echo "❌ 未找到 keystore: $KEYSTORE"
    echo "   请先运行：./scripts/generate-keystore.sh"
    exit 1
fi

# ===== 环境变量检查 =====
if [ -z "$KEYSTORE_PASSWORD" ]; then
    echo "⚠️  KEYSTORE_PASSWORD 未设置，使用默认值 'changeit'"
    export KEYSTORE_PASSWORD="changeit"
fi
if [ -z "$KEY_ALIAS" ]; then
    export KEY_ALIAS="release"
fi
if [ -z "$KEY_PASSWORD" ]; then
    export KEY_PASSWORD="changeit"
fi

# ===== Build =====
cd "$ANDROID_DIR"
echo "▶️  开始构建 Release APK..."
./gradlew clean assembleRelease

# ===== 输出 =====
APK="$ANDROID_DIR/app/build/outputs/apk/release/app-release.apk"
if [ -f "$APK" ]; then
    SIZE=$(du -h "$APK" | cut -f1)
    echo ""
    echo "✅ 构建成功！"
    echo "   APK: $APK"
    echo "   大小: $SIZE"
    echo ""
    echo "📱 接下来："
    echo "   1. 把 APK 传到安卓手机（USB / 微信 / 邮件）"
    echo "   2. 在手机上点击 APK 安装（需开启'未知来源'）"
    echo "   3. 详细文档：./android/docs/07-真机安装指南.md"
else
    echo "❌ 构建失败，APK 未生成"
    exit 1
fi
