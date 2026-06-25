# 截图归档说明

> 本目录存放上架 AppGallery 用的应用截图。
> 最后更新：2026-06-24

## AGC 严格规格（必须满足）

| 设备类型 | 数量 | 最低尺寸 | 宽高比 | 格式 |
| --- | --- | --- | --- | --- |
| **手机/平板** | 3~5 张 | **1080 × 1920 px** | **9 : 16** | PNG/JPG/JPEG（≤ 5 MB），WEBP（≤ 200 KB）|
| **PC/2in1** | 3~5 张 | **1920 × 1080 px** | **16 : 9** | PNG/JPG/JPEG（≤ 5 MB），WEBP（≤ 200 KB）|

不满足规格 AGC 会弹"图片尺寸不符合要求"并拒绝上传。

## 目录结构

```
docs/screenshots/
├── README.md                  # 本文件
├── AGENT-SCREENSHOT-GUIDE.md  # 截屏步骤详细指南
├── 01~05-*.png                # ⚠️ 旧版原始截图（仅供参考，规格可能不符）
├── raw/                       # ⭐ 重截的原始截图（手机+PC 共用）
│   ├── 01~05-*.png            #   手机/平板版
│   └── Screenshot_*.png       #   PC/2in1 版
└── AGC-ready/                 # ⭐ 归一化后的 AGC 上传图
    ├── 1~5.jpg                #   手机/平板（1080×1920）
    └── PC/
        └── 1~5.jpg            #   PC/2in1（1920×1080）
```

## 标准流程

```bash
# 1. 在 DevEco Studio 模拟器截 5 张手机图（详见 AGENT-SCREENSHOT-GUIDE.md）
# 2. 在 PC 模拟器截 5 张 PC 图
# 3. 全部放进 raw/ 目录
cp /path/to/your/01-empty-state.png docs/screenshots/raw/
# ... 其他 4 张手机图同理
cp /path/to/your/Screenshot_*.png docs/screenshots/raw/
# ... 其他 4 张 PC 图同理

# 4. 跑归一化脚本（手机版）
python3 scripts/fix-screenshots-for-agc.py --device phone

# 5. 跑归一化脚本（PC 版）
python3 scripts/fix-screenshots-for-agc.py --device pc

# 6. 验收 AGC-ready/ 里的 10 张 JPG（手机 5 + PC 5）
open docs/screenshots/AGC-ready/

# 7. 一次性上传 AGC
# 手机/平板：AGC → 应用介绍 → 拖入 1.jpg ~ 5.jpg
# PC/2in1：AGC → 切换到 PC/2in1 标签 → 拖入 PC/1.jpg ~ PC/5.jpg
```

## 5 张图场景

| #   | 文件名                | 场景                          | 截取步骤                                                |
| --- | --------------------- | ----------------------------- | ------------------------------------------------------- |
| 1   | `01-empty-state.png`  | 主页面空状态（¥ + 提示文字）  | 启动 App → 不输入 → 截图                                |
| 2   | `02-typing.png`       | 输入数字 + 提示文字           | 输入 `1234.56` → 未点击转换 → 截图                     |
| 3   | `03-result.png`       | 转换结果 + 复制按钮           | 输入 `1234.56` → 点「转换为大写」→ 页面置顶 → 截图     |
| 4   | `04-history.png`      | 历史记录                       | 多转几次后 → 页面置顶 → 截图                            |
| 5   | `05-clear-dialog.png` | 清除确认对话框                | 点「清除」→ 弹出对话框 → 截图                           |

## 配套脚本

| 脚本 | 用途 | 状态 |
| --- | --- | --- |
| `scripts/fix-screenshots-for-agc.py --device phone` | raw/01-05.png → 1080×1920 9:16 JPG | **推荐** |
| `scripts/fix-screenshots-for-agc.py --device pc` | raw/Screenshot_*.png → 1920×1080 16:9 JPG | **推荐** |
| `scripts/rename-screenshots.py` | 旧版：raw → AGC-ready 重命名复制 | **已废弃** |

## 详细截屏步骤

见 [`AGENT-SCREENSHOT-GUIDE.md`](./AGENT-SCREENSHOT-GUIDE.md)

---

**Designed by Piao with opencode**
