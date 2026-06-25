#!/usr/bin/env python3
"""
fix-screenshots-for-agc.py
将 docs/screenshots/raw/ 下的截图归一化为 AGC 严格规格。

AGC 规格（来自 AGC 上传页面提示）：
- 数量：3~5 张
- 最低尺寸：1080×1920px
- 宽高比：9:16
- 格式：PNG/JPG/JPEG（≤5MB），WEBP（≤200KB）
- 输出：docs/screenshots/AGC-ready/N.jpg (N=1..5)

处理流程：
1. 读取 raw/*.png（按 01-05 顺序）
2. RGBA → RGB 白色底
3. 等比缩放到"短边 = 1920"（保证覆盖整个 1080×1920 画布）
4. 居中裁剪到 1080×1920（裁掉上下，不裁左右）
5. 保存为 JPG（质量 90，optimize=True）
6. 验证文件大小 < 5MB
"""

import os
import sys
from pathlib import Path
from PIL import Image

# ===== 路径配置 =====
SCRIPT_DIR = Path(__file__).parent
PROJECT_ROOT = SCRIPT_DIR.parent
RAW_DIR = PROJECT_ROOT / "docs" / "screenshots" / "raw"
OUT_DIR = PROJECT_ROOT / "docs" / "screenshots" / "AGC-ready"

# ===== AGC 规格 =====
TARGET_W = 1080
TARGET_H = 1920
TARGET_ASPECT = TARGET_W / TARGET_H  # 9/16 = 0.5625
MAX_SIZE_BYTES = 5 * 1024 * 1024  # 5MB
JPG_QUALITY = 90

# ===== 输入文件顺序 =====
# vertical_offset 单位：px（缩放后的坐标）
# > 0 = 向上偏移（少裁顶部，多裁底部）→ 保留更多顶部内容
# < 0 = 向下偏移（多裁顶部，少裁底部）→ 保留更多底部内容
# 0   = 居中裁剪
INPUT_FILES = [
    ("01-empty-state.png", +200),
    ("02-typing.png",      +150),
    ("03-result.png",         0),
    ("04-history.png",      +50),
    ("05-clear-dialog.png", +50),
]


def normalize_one(src_path: Path, dst_path: Path, vertical_offset: int = 0) -> tuple[int, int, int]:
    """
    把单张 PNG 归一化为 1080×1920 JPG。
    vertical_offset > 0 向上偏移（保留更多顶部）
    vertical_offset < 0 向下偏移（保留更多底部）
    返回：(最终宽, 最终高, 文件大小字节数)
    """
    img = Image.open(src_path)
    # RGBA → RGB 白色底
    if img.mode in ("RGBA", "LA") or (img.mode == "P" and "transparency" in img.info):
        background = Image.new("RGB", img.size, (255, 255, 255))
        background.paste(img, mask=img.split()[-1] if img.mode in ("RGBA", "LA") else None)
        img = background
    elif img.mode != "RGB":
        img = img.convert("RGB")

    src_w, src_h = img.size
    src_aspect = src_w / src_h

    # 等比缩放：保证"短边 = 1920"
    # 1) 若原图比例 < 9:16（偏窄长），按宽缩放 → 高变长 → 裁上下
    # 2) 若原图比例 > 9:16（偏宽矮），按高缩放 → 宽变长 → 裁左右
    if src_aspect < TARGET_ASPECT:
        # 偏窄长：按 TARGET_W 缩放
        new_w = TARGET_W
        new_h = round(src_h * (TARGET_W / src_w))
    else:
        # 偏宽矮：按 TARGET_H 缩放
        new_h = TARGET_H
        new_w = round(src_w * (TARGET_H / src_h))

    img_resized = img.resize((new_w, new_h), Image.LANCZOS)

    # 居中裁剪到 1080×1920，可按图片单独微调 vertical_offset
    left = (new_w - TARGET_W) // 2
    top = (new_h - TARGET_H) // 2 + vertical_offset
    # 边界保护
    top = max(0, min(top, new_h - TARGET_H))
    img_cropped = img_resized.crop((left, top, left + TARGET_W, top + TARGET_H))

    # 保存 JPG
    dst_path.parent.mkdir(parents=True, exist_ok=True)
    img_cropped.save(
        dst_path,
        format="JPEG",
        quality=JPG_QUALITY,
        optimize=True,
        subsampling=2,  # 4:2:0，体积更小
    )

    return TARGET_W, TARGET_H, dst_path.stat().st_size


def main() -> int:
    if not RAW_DIR.exists():
        print(f"❌ 源目录不存在：{RAW_DIR}")
        print("   请先把 5 张 PNG 截图放进 raw/ 目录")
        return 1

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    # 清理旧产物
    for old in OUT_DIR.glob("*.jpg"):
        old.unlink()
    for old in OUT_DIR.glob("*.png"):
        old.unlink()

    print(f"📐 目标规格：{TARGET_W}×{TARGET_H} (9:16) JPG, ≤{MAX_SIZE_BYTES // 1024 // 1024}MB")
    print(f"📂 源目录：{RAW_DIR}")
    print(f"📂 输出目录：{OUT_DIR}\n")

    total = 0
    failed = []
    for idx, (src_name, vertical_offset) in enumerate(INPUT_FILES, start=1):
        src = RAW_DIR / src_name
        dst = OUT_DIR / f"{idx}.jpg"

        if not src.exists():
            print(f"⚠️  缺失：{src_name}")
            failed.append(src_name)
            continue

        try:
            w, h, size = normalize_one(src, dst, vertical_offset)
            size_kb = size / 1024
            ok = "✅" if size <= MAX_SIZE_BYTES else "❌"
            print(f"{ok} {src_name} → {dst.name}  ({w}×{h}, {size_kb:.1f} KB, offset={vertical_offset:+d})")
            total += 1
        except Exception as e:
            print(f"❌ {src_name} 处理失败：{e}")
            failed.append(src_name)

    print(f"\n共 {total}/5 张已就绪 → {OUT_DIR}")
    if failed:
        print(f"⚠️  失败/缺失：{', '.join(failed)}")
        return 1
    if total < 3:
        print("⚠️  AGC 要求 3~5 张，不足 3 张")
        return 1

    print("🚀 可直接上传 AGC")
    return 0


if __name__ == "__main__":
    sys.exit(main())
