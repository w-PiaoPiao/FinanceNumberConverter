# 06 · APK 打包指南

> 项目：阿拉伯数字 → 中文大写金额转换 App（Android 端）
> 文档版本：v1.0
> 最后更新：2026-06-21

## 1. 快速打包（3 步）

### 1.1 首次：生成 keystore

```bash
cd android
./scripts/generate-keystore.sh
```

**输出**：`android/keystore/release.keystore`（2.7KB，**不入 git**）

**密码默认**：`changeit`（生产环境**务必修改**）

⚠️ **必须保存到密码管理器**（1Password / Bitwarden / Keychain）。

### 1.2 每次：构建 Release APK

```bash
export KEYSTORE_PASSWORD=changeit
export KEY_ALIAS=release
export KEY_PASSWORD=changeit
./scripts/build-release-apk.sh
```

或者一次性：
```bash
KEYSTORE_PASSWORD=changeit KEY_ALIAS=release KEY_PASSWORD=changeit ./scripts/build-release-apk.sh
```

**输出**：`android/app/build/outputs/apk/release/app-release.apk`（40MB，含 Material Icons Extended）

### 1.3 验证 APK

```bash
/Users/yizhiwang/Library/Android/sdk/build-tools/36.1.0/apksigner verify --verbose \
  app/build/outputs/apk/release/app-release.apk
```

**期望输出**：
```
Verifies
Verified using v2 scheme (APK Signature Scheme v2): true
```

## 2. 手动打包（不用脚本）

```bash
cd android

# 1. 设置环境变量
export KEYSTORE_PASSWORD=changeit
export KEY_ALIAS=release
export KEY_PASSWORD=changeit

# 2. 设置 Java（首次）
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
export PATH="$JAVA_HOME/bin:$PATH"

# 3. Build
./gradlew clean assembleRelease

# 4. 输出
ls app/build/outputs/apk/release/
# → app-release.apk (40MB)
```

## 3. 重新生成 keystore（仅必要时）

⚠️ **警告**：重新生成 keystore = 之前签名的 APK 全部**不能升级**（签名不一致）

```bash
# 备份当前 keystore
cp android/keystore/release.keystore ~/Desktop/release.keystore.bak

# 重新生成
./scripts/generate-keystore.sh
# 回答 y 覆盖
```

**应用升级策略**：
- 同一 keystore 签名的 APK 可以覆盖安装（升级）
- 不同 keystore 签名的 APK 必须先卸载才能装

## 4. 修改默认密码

如果你已经用默认密码 `changeit` 签名了 APK，但想换密码：

```bash
# 1. 改 keystore 密码
keytool -storepasswd -keystore release.keystore
# 提示输入旧密码（changeit），新密码

# 2. 改 key 密码
keytool -keypasswd -alias release -keystore release.keystore
# 提示输入 keystore 密码 + key 旧密码 + 新密码

# 3. 用新密码 build
KEYSTORE_PASSWORD=新密码 KEY_PASSWORD=新密码 ./scripts/build-release-apk.sh
```

## 5. CI/CD 集成（可选）

在 GitHub Actions / GitLab CI 中：

```yaml
# GitHub Actions 示例
- name: Build APK
  env:
    KEYSTORE_PASSWORD: ${{ secrets.KEYSTORE_PASSWORD }}
    KEY_ALIAS: ${{ secrets.KEY_ALIAS }}
    KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}
  run: ./scripts/build-release-apk.sh

- name: Upload APK
  uses: actions/upload-artifact@v4
  with:
    name: app-release
    path: android/app/build/outputs/apk/release/app-release.apk
```

**密钥管理**：把 keystore 文件和密码存到 CI 的 Secrets / Variables。

## 6. APK 输出位置

| 类型 | 路径 | 大小 | 用途 |
| --- | --- | --- | --- |
| Debug | `android/app/build/outputs/apk/debug/app-debug.apk` | ~23MB | 开发调试 |
| Release | `android/app/build/outputs/apk/release/app-release.apk` | ~40MB | 真机安装 |
| Release Unsigned | `android/app/build/outputs/apk/release/app-release-unsigned.apk` | ~40MB | 重新签名用 |

## 7. 故障排查

| 错误 | 原因 | 解决 |
| --- | --- | --- |
| `SDK location not found` | `local.properties` 缺失 | 创建 `local.properties` 写入 `sdk.dir=/Users/yizhiwang/Library/Android/sdk` |
| `JAVA_HOME not set` | 未配置 Java | `export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"` |
| `keystore was tampered with, or password was incorrect` | 密码错误 | 重新 export 正确密码 |
| `Entry already exists` | alias 重复 | 重新生成 keystore（先删旧） |
| `Failed to install the following Android SDK packages` | build-tools 缺失 | 打开 Android Studio SDK Manager 安装 |

## 8. 下一步

APK 生成后看 **`07-真机安装指南.md`**（针对安卓 15/16 国产手机优化）。
