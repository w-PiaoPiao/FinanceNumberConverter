# DevEco Studio AGC 截屏指南

> 本文档是 `harmony/docs/screenshots/README.md` 的补充。
> 最后更新：2026-06-24

## AGC 严格规格（重要）

上传 AppGallery Connect 的截图**必须**满足：

| 项 | 要求 |
| --- | --- |
| 数量 | 3~5 张 |
| 最低尺寸 | **1080 × 1920 px** |
| 宽高比 | **9 : 16** |
| 格式 | PNG / JPG / JPEG（≤ 5 MB），WEBP（≤ 200 KB） |

**不满足规格会被 AGC 拒绝**（弹窗"图片尺寸不符合要求"）。

## DevEco Studio 模拟器截屏步骤

### 1. 选择合适的模拟器

- 推荐：**P40 / Mate 50 / Nova 9**（屏幕比例 9:19.5，接近 9:16）
- 模拟器分辨率建议 ≥ 1080 × 2340（脚本会自动裁剪到 1080 × 1920）

### 2. 关闭手机外框（关键！）

带外框的窗口截图宽度会缩小（约 562 px），**直接不满足 AGC 最低宽度**。

关闭方法（二选一）：
- 菜单：`View → Toolbar → Hide Device Frame`
- 快捷键：`⌘ + Shift + F`（macOS）

### 3. 5 张截图的操作步骤

| # | 文件 | 状态 | 步骤 |
| --- | --- | --- | --- |
| 1 | `01-empty-state.png` | 空状态 | 启动 App → **不要输入** → 等 ¥ + 提示出现 → 截图 |
| 2 | `02-typing.png` | 输入中 | 点击输入框 → 输入 `1234.56` → **不要点转换** → 截图 |
| 3 | `03-result.png` | 转换结果 | 输入 `1234.56` → 点「转换为大写」→ **页面不要滚动** → 截图 |
| 4 | `04-history.png` | 历史记录 | 多转几次（输入 3 个不同数字）→ **页面不要滚动，保持顶部** → 截图 |
| 5 | `05-clear-dialog.png` | 清除对话框 | 点「清除」→ 弹出对话框 → 截图 |

**关键提醒**：
- 4、5 截屏前**先把页面滚到最顶部**（下滑一下内容或重新进入页面），保证标题"财务大写转换"在视口内
- 否则裁剪后 4、5 会缺少主标题（虽然 AGC 仍会通过，但视觉效果差）

### 4. 截图快捷键

- 模拟器窗口聚焦时按 `⌘ + S`（macOS）
- 或 DevEco 菜单 `Tools → Take Screenshot`

### 5. 保存路径

把 5 张 PNG 直接放到：

```
harmony/docs/screenshots/raw/
├── 01-empty-state.png
├── 02-typing.png
├── 03-result.png
├── 04-history.png
└── 05-clear-dialog.png
```

文件命名**严格**按上表（脚本按文件名顺序处理）。

## 归一化处理

放好 5 张 PNG 后跑：

```bash
cd harmony
python3 scripts/fix-screenshots-for-agc.py
```

脚本会自动：
1. RGBA → RGB 白色底
2. 等比缩放（保证短边 = 1920px）
3. 按每张图的预设偏移裁剪到 **1080 × 1920**
4. 转 JPG（质量 90）
5. 验证文件 < 5 MB
6. 输出到 `harmony/docs/screenshots/AGC-ready/1.jpg` ~ `5.jpg`

## 直接上传 AGC

把 `AGC-ready/1.jpg` ~ `5.jpg` 一次性拖到 AGC 上传框：

> AGC → 我的应用 → 应用详情 → 应用介绍 → 应用介绍截图 → 上传图片

## 常见错误

| 错误 | 原因 | 解决 |
| --- | --- | --- |
| "图片尺寸不符合要求" | 宽高比 ≠ 9:16 或宽 < 1080 | 跑归一化脚本 |
| AGC 看不到缩略图 | 文件 > 5 MB | 降低 JPG 质量（修改脚本 JPG_QUALITY） |
| 截图带外框 | 没关模拟器外框 | `⌘ + Shift + F` |

---

**Designed by Piao with opencode**
