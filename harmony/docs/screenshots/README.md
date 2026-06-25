# 截图归档说明

> 本目录存放上架 AppGallery 用的应用截图。
> 最后更新：2026-06-24

## AGC 严格规格（必须满足）

| 项 | 要求 |
| --- | --- |
| 数量 | 3~5 张 |
| **最低尺寸** | **1080 × 1920 px** |
| **宽高比** | **9 : 16** |
| 格式 | PNG / JPG / JPEG（≤ 5 MB），WEBP（≤ 200 KB） |

不满足规格 AGC 会弹"图片尺寸不符合要求"并拒绝上传。

## 目录结构

```
docs/screenshots/
├── README.md                  # 本文件
├── AGENT-SCREENSHOT-GUIDE.md  # 截屏步骤详细指南
├── 01~05-*.png                # ⚠️ 旧版原始截图（仅供参考，规格可能不符）
├── raw/                       # ⭐ 重截的原始截图（建议放这里）
│   ├── 01-empty-state.png
│   ├── 02-typing.png
│   ├── 03-result.png
│   ├── 04-history.png
│   └── 05-clear-dialog.png
└── AGC-ready/                 # ⭐ 归一化后的 AGC 上传图
    ├── 1.jpg   (1080×1920)
    ├── 2.jpg
    ├── 3.jpg
    ├── 4.jpg
    └── 5.jpg
```

## 标准流程

```bash
# 1. 在 DevEco Studio 模拟器截 5 张图（详见 AGENT-SCREENSHOT-GUIDE.md）
# 2. 放进 raw/ 目录
cp /path/to/your/01-empty-state.png docs/screenshots/raw/
# ... 其他 4 张同理

# 3. 跑归一化脚本
python3 scripts/fix-screenshots-for-agc.py

# 4. 验收 AGC-ready/ 里的 5 张 JPG
open docs/screenshots/AGC-ready/

# 5. 一次性上传 AGC
# AGC → 应用介绍 → 应用介绍截图 → 拖入 1.jpg ~ 5.jpg
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
| `scripts/fix-screenshots-for-agc.py` | raw → 1080×1920 9:16 JPG | **推荐** |
| `scripts/rename-screenshots.py` | 旧版：raw → AGC-ready 重命名复制 | **已废弃** |

## 详细截屏步骤

见 [`AGENT-SCREENSHOT-GUIDE.md`](./AGENT-SCREENSHOT-GUIDE.md)

---

**Designed by Piao with opencode**
