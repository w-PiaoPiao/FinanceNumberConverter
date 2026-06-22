# 财务大写转换 App

> 阿拉伯数字 → 中文财务大写金额 · 跨平台（iOS + Android）

![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20Android-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![Kotlin](https://img.shields.io/badge/Kotlin-2.0-purple)
![SwiftUI](https://img.shields.io/badge/SwiftUI-iOS%2017+-blue)
![Compose](https://img.shields.io/badge/Jetpack%20Compose-Material%203-green)
![License](https://img.shields.io/badge/license-MIT-brightgreen)
![Tests](https://img.shields.io/badge/tests-97%20passed-success)

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

## 🧪 测试

| 平台 | 框架 | 用例数 | 状态 |
| --- | --- | --- | --- |
| iOS | XCTest | 49 | ✅ 100% |
| Android | JUnit 4 | 48 | ✅ 100% |

覆盖 `docs/05-测试用例.md` A 段（基本转换）+ B 段（输入校验）。

## 🧠 核心算法

按"亿 / 万 / 个"三段处理整数，每段内部按"仟/佰/拾/个"处理，段与段之间按需补"零"。

- iOS 实现：`FinanceNumberConverter/Sources/FinanceNumberConverter/NumberConverter.swift`
- Android 实现：`android/app/src/main/kotlin/.../NumberConverter.kt`

详细规则参考 [国标 GB/T 12402-2000](https://openstd.samr.gov.cn/) 简化版。

## 📜 协议

本项目采用 **MIT License** — 详见 [LICENSE](./LICENSE)。

## 🙏 致谢

- **设计灵感**：minimalist-ui 风格（克制、文档化、暖白底）
- **生成工具**：[XcodeGen](https://github.com/yonaskolb/XcodeGen)、[Jetpack Compose](https://developer.android.com/jetpack/compose)
- **AI 辅助**：[opencode](https://opencode.ai)

---

**Designed by Piao with opencode**
