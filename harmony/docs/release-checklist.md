# 鸿蒙 AppGallery 上架 Checklist

> 最后更新：2026-06-22
> 完成每项后打钩 ✅，遇到问题在「问题记录」一节追加。

## 一、前置（开发者侧）— 1~3 天

- [ ] **已注册华为开发者账号**（已完成）
  - 网址：https://developer.huawei.com
- [ ] **完成实名认证**（个人：身份证 + 人脸）
- [ ] **签署协议**
  - 华为开发者服务协议
  - 应用上架协议
- [ ] **开通 HarmonyOS 应用上架权益**
  - AGC → 管理中心 → 我的权益 → HarmonyOS 应用 → 申请
  - 预计 1-3 个工作日审核

## 二、本地准备（项目侧）— 半天

### 2.1 bundleName 改名
- [x] `com.example.financenumberconverter` → `com.piao.financenumberconverter`
  - 文件：`harmony/AppScope/app.json5`

### 2.2 隐私政策
- [x] `docs/privacy-policy.md` 已写好
- [ ] 替换邮箱为你的真实邮箱
- [ ] 部署到可访问的 URL（推荐 GitHub Pages）：
  ```bash
  # 在 GitHub 仓库 Settings → Pages → 选 main 分支 /docs 文件夹
  # 访问：https://w-PiaoPiao.github.io/FinanceNumberConverter/privacy-policy.html
  # 注意：需要把 .md 改成 .html 或在 docs 目录加 index.html
  ```

### 2.3 截图准备

> ⚠️ **AGC 严格规格**：
> - 手机/平板：1080×1920px，9:16，JPG/PNG ≤ 5MB
> - PC/2in1：1920×1080px，16:9，JPG/PNG ≤ 5MB
> 不满足会弹"图片尺寸不符合要求"并拒绝。

#### 2.3.1 手机/平板版
- [ ] 启动 DevEco Studio 模拟器（推荐 P40 / Mate 50）
- [ ] **关闭手机外框**：`⌘+Shift+F`（关键！带外框会被压缩到 562px 宽，直接不合格）
- [ ] 截 5 张图放进 `harmony/docs/screenshots/raw/`（详见 `docs/screenshots/AGENT-SCREENSHOT-GUIDE.md`）

#### 2.3.2 PC/2in1 版
- [ ] 启动 DevEco Studio PC 模拟器
- [ ] 截 5 张图放进 `harmony/docs/screenshots/raw/`（DevEco 默认命名 `Screenshot_*.png`）

#### 2.3.3 归一化处理
- [ ] 跑归一化脚本：
  ```bash
  cd harmony
  python3 scripts/fix-screenshots-for-agc.py --device phone
  python3 scripts/fix-screenshots-for-agc.py --device pc
  ```
- [ ] 确认 `AGC-ready/` 下有 1.jpg ~ 5.jpg（1080×1920 9:16）
- [ ] 确认 `AGC-ready/PC/` 下有 1.jpg ~ 5.jpg（1920×1080 16:9）
- [ ] 全部文件 < 5MB

### 2.4 App 图标
- [x] `harmony/entry/src/main/resources/base/media/app_icon.png` 已生成
  - 暖白底 + "壹"字 + "金额大写转换"
  - 1024×1024 PNG

### 2.5 应用描述文案
- [ ] **应用名称**（≤ 30 字）：财务大写转换
- [ ] **一句话介绍**（≤ 17 字）：阿拉伯数字秒转中文财务大写金额
- [ ] **应用简介**（≤ 80 字）：
  ```
  阿拉伯数字秒转中文财务大写金额。
  填写发票、合同、收据的随身利器。
  ```
- [ ] **应用描述**（500 字以内）：
  ```
  还在为手写"壹仟贰佰叁拾肆元伍角陆分"而头疼？
  财务大写转换 App，帮你 1 秒搞定！
  
  【核心功能】
  • 实时转换：输入阿拉伯数字，立刻得到规范的中文财务大写
  • 一键复制：转换结果直接复制到剪贴板
  • 历史记录：自动保存最近 10 次转换，方便复用
  • 智能校验：自动识别非法字符、超大数、超过 2 位小数
  
  【适用场景】
  • 填写发票 / 收据
  • 起草合同 / 协议
  • 财务报销单
  • 银行业务单据
  
  【设计理念】
  • 极简 UI，专注功能
  • 完全离线，所有计算在设备本地完成
  • 不收集任何用户数据
  • 100% 离线运行，无网络请求
  
  Designed by Piao · Powered by opencode
  ```
- [ ] **应用分类**：工具 → 效率 / 金融理财
- [ ] **标签**：财务、金额、大写、转换、发票

### 2.6 签名证书

> ⚠️ **签名证书至关重要，丢失就只能重新签名重新上架（用户收不到更新）！**
> 建议至少备份到 2 个不同位置（U 盘 + 云盘）。

- [ ] **生成 p12 证书**
  - DevEco Studio → Build → Generate Key and CSR
  - 路径：`harmony/release.p12`（**不入 git**）
  - 密码：自己设，建议 16 位以上
  - 别名：fnc
  - 有效期：25 年
  - 算法：SHA256withECDSA / RSA 2048

- [ ] **生成 CSR**
  - 同上一步同时生成
  - 输出：`harmony/release.csr`

- [ ] **在 AGC 创建 Profile**（后面步骤）

### 2.7 编译 Release HAP / APP
- [ ] 修改 `harmony/build-profile.json5` 的 `signingConfigs`（参见 `harmony/docs/signing-config.md`）
- [ ] 方式 A（推荐）：直接运行一键脚本
  ```bash
  cd harmony
  ./scripts/build-release-app.sh
  ```
- [ ] 方式 B（DevEco Studio UI）：
  - Build → Build Hap(s) / APP(s) → Build APP(s)
  - 产物路径：`harmony/entry/build/default/outputs/default/FinanceNumberConverter.app`
- [ ] 验证产物大小（一般 1-5 MB）

## 三、AGC 提交（开发者侧）— 30 分钟

### 3.1 创建应用
- [ ] AGC → 我的应用 → 新建 HarmonyOS 应用
- [ ] 包名：`com.piao.financenumberconverter`
- [ ] 设备：手机 + 平板

### 3.2 上传 APP
- [ ] 软件包管理 → 上传软件包
- [ ] 选择 **APP 格式** 的编译产物：`entry-default/outputs/default/FinanceNumberConverter.app`
- [ ] 注意：AGC 上架要求上传 `.app`（App Pack），不是单个 `.hap`；若文件选择框中 `.hap` 呈灰色无法选中，即说明当前入口要求 `.app`

### 3.3 填写应用信息
- [ ] 应用名称、简介、描述（用 2.5 准备的文案）
- [ ] 应用分类
- [ ] 标签
- [ ] 应用图标
- [ ] 截图 3-5 张（手机/平板版：从 `AGC-ready/` 取 1.jpg ~ 5.jpg，规格 **1080×1920 9:16 JPG**）
- [ ] 截图 3-5 张（PC/2in1 版：从 `AGC-ready/PC/` 取 1.jpg ~ 5.jpg，规格 **1920×1080 16:9 JPG**）

### 3.4 隐私与权限
- [ ] 隐私政策 URL
- [ ] 权限说明：
  - `ohos.permission.READ_PASTEBOARD` / `WRITE_PASTEBOARD`：用于"一键复制"功能

### 3.5 提交审核
- [ ] 检查所有必填项
- [ ] 勾选"我已阅读并同意..."
- [ ] 点「提交审核」

## 四、等待审核

- 审核时间：**1-3 个工作日**（新号首次可能 5-7 天）
- 状态查看：AGC → 我的应用 → 应用详情 → 审核状态
- 邮件通知到注册邮箱

## 五、发布后

- [ ] 分享给朋友试
- [ ] 关注用户评论
- [ ] 数据分析（AGC 后台）

## 六、问题记录

> 遇到问题追加在这里。

| 日期       | 问题                     | 解决                          |
| ---------- | ------------------------ | ----------------------------- |
| 2026-06-22 | （暂无）                 |                               |

---

**Designed by Piao with opencode**
