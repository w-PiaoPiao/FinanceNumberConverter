# DevEco Studio AGC 截屏指南

> 本文档是 `harmony/docs/screenshots/README.md` 的补充。
> 最后更新：2026-06-25

## AGC 严格规格（重要）

上传 AppGallery Connect 的截图**必须**满足：

| 设备类型 | 数量 | 最低尺寸 | 宽高比 | 格式 |
| --- | --- | --- | --- | --- |
| **手机/平板** | 3~5 张 | **1080 × 1920 px** | **9 : 16** | PNG/JPG/JPEG（≤ 5 MB），WEBP（≤ 200 KB）|
| **PC/2in1** | 3~5 张 | **1920 × 1080 px** | **16 : 9** | 同上 |

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

放好 PNG 后跑：

```bash
cd harmony

# 手机/平板版（默认 9:16）
python3 scripts/fix-screenshots-for-agc.py --device phone

# PC/2in1 版（横版 16:9）
python3 scripts/fix-screenshots-for-agc.py --device pc
```

脚本会自动：
1. RGBA → RGB 白色底
2. 等比缩放（保证覆盖目标画布）
3. 按每张图的预设偏移裁剪到目标尺寸
4. 转 JPG（质量 90）
5. 验证文件 < 5 MB
6. 输出到 `harmony/docs/screenshots/AGC-ready/{N.jpg, PC/N.jpg}`

## 直接上传 AGC

- **手机/平板**：把 `AGC-ready/1.jpg` ~ `5.jpg` 拖到「手机/平板」标签的上传框
- **PC/2in1**：切换到「PC/2in1」标签，把 `AGC-ready/PC/1.jpg` ~ `5.jpg` 拖到上传框

> AGC → 我的应用 → 应用详情 → 应用介绍 → 素材管理 → 选择设备类型标签 → 上传图片

## 常见错误

| 错误 | 原因 | 解决 |
| --- | --- | --- |
| "图片尺寸不符合要求" | 宽高比 ≠ 9:16 (手机) / 16:9 (PC) 或尺寸不足 | 跑归一化脚本 |
| AGC 看不到缩略图 | 文件 > 5 MB | 降低 JPG 质量（修改脚本 JPG_QUALITY）|
| 截图带外框（手机） | 没关模拟器外框 | `⌘ + Shift + F` |
| PC 版带 Dock 任务栏 | 截全屏 | 归一化脚本会自动裁掉 Dock |

---

## PC/2in1 截屏特别说明

PC/2in1 版截屏和手机版**完全独立**，需要：

1. 在 DevEco Studio 启动 **PC 模拟器**（不是手机/平板）
2. 跑同样的 5 个状态（empty / typing / result / history / dialog）
3. 截图（DevEco 默认文件名是 `Screenshot_YYYY-MM-DDTHHMMSS.png`，脚本会自动按时间排序匹配）
4. 把 5 张 PC 图放进 `docs/screenshots/raw/`
5. 跑 `python3 scripts/fix-screenshots-for-agc.py --device pc`

**截图注意事项**：
- PC 模拟器通常有顶部状态栏（应用标题 + 控制按钮）和底部 Dock 任务栏
- 脚本会自动裁掉这些系统 UI，只保留 app 主体内容
- 如果截图是 3:2 比例（3120×2080 等），脚本会按 16:9 居中裁剪

---

**Designed by Piao with opencode**
