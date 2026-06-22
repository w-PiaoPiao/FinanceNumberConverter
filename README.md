# 财务大写转换 App

> 阿拉伯数字 → 中文财务大写金额 · 跨平台（iOS + Android + HarmonyOS）

![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20Android%20%7C%20HarmonyOS-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![Kotlin](https://img.shields.io/badge/Kotlin-2.0-purple)
![ArkTS](https://img.shields.io/badge/ArkTS-5.0.0-00B5E2)
![SwiftUI](https://img.shields.io/badge/SwiftUI-iOS%2017+-blue)
![Compose](https://img.shields.io/badge/Jetpack%20Compose-Material%203-green)
![License](https://img.shields.io/badge/license-MIT-brightgreen)
![Tests](https://img.shields.io/badge/tests-145%20passed-success)

一个简洁的财务大写金额转换工具，源自日常填写发票/合同/收据时需要手写"壹贰叁"的痛点。

## ✨ 功能

- 🧮 实时转换：输入阿拉伯数字，一键得到中文财务大写
- 📋 一键复制：转换结果直接复制到剪贴板
- 🕐 历史记录：最近 10 条转换，方便复用
- 🚫 输入校验：实时检查非法字符、超大数、超过 2 位小数
- 🎨 极简 UI：Premium Utilitarian Minimalism 风格（克制、留白、暖白底）

## 📱 平台支持

| 平台 | 最低版本 | 目标版本 | 状态 |
| --- | --- | --- | --- |
| **iOS** | iOS 17.0 | iOS 17.0+ | ✅ 完成 |
| **Android** | Android 10 (API 29) | Android 15 (API 35) | ✅ 完成 |
| **HarmonyOS NEXT** | API 12 (5.0.0) | API 12 (5.0.0) | 🚧 上架准备中 |

## 🛠 技术栈

### iOS
- Swift 5.9+ / SwiftUI
- Xcode 15+
- XCTest 单元测试（49/49 ✅）
- XcodeGen（工程文件生成）

### Android
- Kotlin 2.0+ / Jetpack Compose
- Material 3
- Gradle 8.10 + AGP 8.7
- JUnit 4 单元测试（48/48 ✅）

### HarmonyOS NEXT
- ArkTS 5.0.0 / ArkUI（Stage 模型）
- DevEco Studio 5.0+
- Hvigor 构建系统
- Hypium 单元测试（48/48 ✅）

## 📁 项目结构

```
FinanceNumberConverter/
├── docs/                          # 共享项目文档
├── dev-logs/                      # 共享开发日志
├── FinanceNumberConverter/        # iOS Xcode 工程
│   ├── project.yml                # XcodeGen 配置
│   └── Sources/                   # Swift 源码
├── android/                       # Android Gradle 工程
│   ├── docs/                      # Android 文档
│   ├── dev-logs/                  # Android 日志
│   ├── scripts/                   # 构建脚本
│   ├── app/                       # 主模块
│   └── keystore/                  # release.keystore（不入 git）
├── harmony/                       # HarmonyOS NEXT 工程
│   ├── docs/                      # Harmony 文档 + 发布指南
│   ├── dev-logs/                  # Harmony 日志
│   ├── entry/                     # 主模块（ArkTS 源码）
│   ├── AppScope/                  # App 配置
│   └── release.p12 / .p7b         # 签名证书（不入 git）
├── docs/                          # 共享项目文档
│   ├── privacy-policy.md          # 隐私政策（三端共用）
│   └── ...                        # 需求/技术/设计/开发/测试
├── AGENTS.md                      # opencode 项目级指引
├── README.md                      # 本文件
└── LICENSE                         # MIT 协议
```

## 🚀 快速开始

### iOS

```bash
cd FinanceNumberConverter
xcodegen generate
open FinanceNumberConverter.xcodeproj
# 在 Xcode 中选模拟器 → Cmd+R 运行
```

详见 [`docs/04-开发执行步骤.md`](./docs/04-开发执行步骤.md)。

### Android

```bash
# 1. 首次：生成 keystore
cd android
./scripts/generate-keystore.sh

# 2. 构建 Release APK
export KEYSTORE_PASSWORD=changeit
./scripts/build-release-apk.sh

# 输出：app/build/outputs/apk/release/app-release.apk
```

详见 [`android/docs/06-APK打包指南.md`](./android/docs/06-APK打包指南.md) 和 [`android/docs/07-真机安装指南.md`](./android/docs/07-真机安装指南.md)。

### HarmonyOS NEXT

```bash
# 1. 首次：DevEco Studio 打开 harmony/，生成签名证书
#    Build → Generate Key and CSR → harmony/release.p12（不入 git）

# 2. 在 AGC 创建 Profile，下载 harmony/release.p7b

# 3. 配置 harmony/build-profile.json5 的 signingConfigs

# 4. 编译 Release HAP
#    DevEco Studio → Build → Build Hap(s)
#    产物：entry/build/default/outputs/default/entry-default-signed.hap
```

详见 [`harmony/docs/release-checklist.md`](./harmony/docs/release-checklist.md) 和 [`harmony/docs/signing-config.md`](./harmony/docs/signing-config.md)。

## 🧪 测试

| 平台 | 框架 | 用例数 | 状态 |
| --- | --- | --- | --- |
| iOS | XCTest | 49 | ✅ 100% |
| Android | JUnit 4 | 48 | ✅ 100% |
| HarmonyOS | Hypium | 48 | ✅ 100% |

覆盖 `docs/05-测试用例.md` A 段（基本转换）+ B 段（输入校验）。

## 🧠 核心算法

按"亿 / 万 / 个"三段处理整数，每段内部按"仟/佰/拾/个"处理，段与段之间按需补"零"。

- iOS 实现：`FinanceNumberConverter/Sources/FinanceNumberConverter/NumberConverter.swift`
- Android 实现：`android/app/src/main/kotlin/.../NumberConverter.kt`

详细规则参考 [国标 GB/T 12402-2000](https://openstd.samr.gov.cn/) 简化版。

## 🔐 隐私

- 完整隐私政策：[`docs/privacy-policy.md`](./docs/privacy-policy.md)
- 三端统一：iOS / Android / HarmonyOS 共用同一份政策
- 核心承诺：**不收集任何用户数据**，**不联网**，**不集成第三方 SDK**

## 📜 协议

本项目采用 **MIT License** — 详见 [LICENSE](./LICENSE)。

## 🙏 致谢

- **设计灵感**：minimalist-ui 风格（克制、文档化、暖白底）
- **生成工具**：[XcodeGen](https://github.com/yonaskolb/XcodeGen)、[Jetpack Compose](https://developer.android.com/jetpack/compose)
- **AI 辅助**：[opencode](https://opencode.ai)

---

**Designed by Piao with opencode**
