#!/usr/bin/env python3
"""
fix-screenshots-for-agc.py
将 docs/screenshots/raw/ 下的截图归一化为 AGC 严格规格。

AGC 规格（来自 AGC 上传页面提示）：
- 数量：3~5 张
- 最低尺寸：1080×1920 (9:16) 或 1920×1080 (16:9)
- 格式：PNG/JPG/JPEG（≤5MB），WEBP（≤200KB）
- 输出：docs/screenshots/AGC-ready/N.jpg (手机/平板)
       docs/screenshots/AGC-ready/PC/N.jpg (PC/2in1)

处理流程：
1. 读取 raw/ 下的 PNG（按命名规则匹配）
2. RGBA → RGB 白色底
3. 等比缩放（保证覆盖目标画布）
4. 居中裁剪到目标尺寸
5. 保存为 JPG（质量 90）
6. 验证文件大小 < 5MB

用法：
  python3 fix-screenshots-for-agc.py            # 默认处理手机版
  python3 fix-screenshots-for-agc.py --device pc  # 处理 PC/2in1 版
"""

import argparse
import sys
from pathlib import Path
from PIL import Image

# ===== 路径配置 =====
SCRIPT_DIR = Path(__file__).parent
PROJECT_ROOT = SCRIPT_DIR.parent
RAW_DIR = PROJECT_ROOT / "docs" / "screenshots" / "raw"
AGC_READY_DIR = PROJECT_ROOT / "docs" / "screenshots" / "AGC-ready"

# ===== 通用配置 =====
MAX_SIZE_BYTES = 5 * 1024 * 1024  # 5MB
JPG_QUALITY = 90

# ===== 输入文件命名规则 =====
# 每种 device 一组：glob 模式 + 期望数量 + vertical_offset 列表
# vertical_offset 单位：px（缩放后的坐标）
# > 0 = 向上偏移（少裁顶部）→ 保留更多顶部
# < 0 = 向下偏移（多裁顶部）→ 保留更多底部
# 0   = 居中
DEVICES = {
    "phone": {
        "desc": "手机/平板（竖版 9:16）",
        "target_w": 1080,
        "target_h": 1920,
        "aspect": 9 / 16,
        "out_dir": AGC_READY_DIR,
        "files": [
            ("01-empty-state.png",  +200),
            ("02-typing.png",       +150),
            ("03-result.png",          0),
            ("04-history.png",       +50),
            ("05-clear-dialog.png",  +50),
        ],
    },
    "pc": {
        "desc": "PC/2in1（横版 16:9）",
        "target_w": 1920,
        "target_h": 1080,
        "aspect": 16 / 9,
        "out_dir": AGC_READY_DIR / "PC",
        "files": [
            ("Screenshot_2026-06-25T223418.png", 0),  # empty
            ("Screenshot_2026-06-25T223430.png", 0),  # typing
            ("Screenshot_2026-06-25T223434.png", 0),  # result
            ("Screenshot_2026-06-25T223456.png", 0),  # history
            ("Screenshot_2026-06-25T223503.png", 0),  # dialog
        ],
    },
}


def normalize_one(
    src_path: Path,
    dst_path: Path,
    target_w: int,
    target_h: int,
    target_aspect: float,
    vertical_offset: int = 0,
) -> tuple[int, int, int]:
    """
    把单张 PNG 归一化为 target_w × target_h JPG。
    vertical_offset > 0 向上偏移（保留更多顶部）
    vertical_offset < 0 向下偏移（保留更多底部）
    返回：(最终宽, 最终高, 文件大小字节数)
    """
    img = Image.open(src_path)
    if img.mode in ("RGBA", "LA") or (img.mode == "P" and "transparency" in img.info):
        background = Image.new("RGB", img.size, (255, 255, 255))
        background.paste(img, mask=img.split()[-1] if img.mode in ("RGBA", "LA") else None)
        img = background
    elif img.mode != "RGB":
        img = img.convert("RGB")

    src_w, src_h = img.size
    src_aspect = src_w / src_h

    # 等比缩放：保证覆盖整个目标画布
    if src_aspect < target_aspect:
        # 原图偏窄长：按 target_w 缩放
        new_w = target_w
        new_h = round(src_h * (target_w / src_w))
    else:
        # 原图偏宽矮：按 target_h 缩放
        new_h = target_h
        new_w = round(src_w * (target_h / src_h))

    img_resized = img.resize((new_w, new_h), Image.LANCZOS)

    # 居中裁剪到 target_w × target_h
    left = (new_w - target_w) // 2
    top = (new_h - target_h) // 2 + vertical_offset
    top = max(0, min(top, new_h - target_h))
    img_cropped = img_resized.crop((left, top, left + target_w, top + target_h))

    dst_path.parent.mkdir(parents=True, exist_ok=True)
    img_cropped.save(
        dst_path,
        format="JPEG",
        quality=JPG_QUALITY,
        optimize=True,
        subsampling=2,
    )

    return target_w, target_h, dst_path.stat().st_size


def process_device(device_name: str) -> int:
    cfg = DEVICES[device_name]
    target_w = cfg["target_w"]
    target_h = cfg["target_h"]
    target_aspect = cfg["aspect"]
    out_dir = cfg["out_dir"]
    aspect_label = (
        f"{target_w}:{target_h}"
        if target_w >= target_h
        else f"{target_w}:{target_h}"
    )
    aspect_str = (
        "16:9" if target_w > target_h else "9:16"
    )

    if not RAW_DIR.exists():
        print(f"❌ 源目录不存在：{RAW_DIR}")
        return 1

    out_dir.mkdir(parents=True, exist_ok=True)
    for old in out_dir.glob("*.jpg"):
        old.unlink()
    for old in out_dir.glob("*.png"):
        old.unlink()

    print(f"📱 设备：{cfg['desc']}")
    print(f"📐 目标规格：{target_w}×{target_h} ({aspect_str}) JPG, ≤{MAX_SIZE_BYTES // 1024 // 1024}MB")
    print(f"📂 源目录：{RAW_DIR}")
    print(f"📂 输出目录：{out_dir}\n")

    total = 0
    failed = []
    for idx, (src_name, vertical_offset) in enumerate(cfg["files"], start=1):
        src = RAW_DIR / src_name
        dst = out_dir / f"{idx}.jpg"

        if not src.exists():
            print(f"⚠️  缺失：{src_name}")
            failed.append(src_name)
            continue

        try:
            w, h, size = normalize_one(src, dst, target_w, target_h, target_aspect, vertical_offset)
            size_kb = size / 1024
            ok = "✅" if size <= MAX_SIZE_BYTES else "❌"
            print(f"{ok} {src_name} → {dst.name}  ({w}×{h}, {size_kb:.1f} KB, offset={vertical_offset:+d})")
            total += 1
        except Exception as e:
            print(f"❌ {src_name} 处理失败：{e}")
            failed.append(src_name)

    print(f"\n共 {total}/5 张已就绪 → {out_dir}")
    if failed:
        print(f"⚠️  失败/缺失：{', '.join(failed)}")
        return 1
    if total < 3:
        print("⚠️  AGC 要求 3~5 张，不足 3 张")
        return 1

    print("🚀 可直接上传 AGC")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(
        description="AGC 截图归一化工具（手机/PC 双规格）"
    )
    parser.add_argument(
        "--device",
        choices=list(DEVICES.keys()),
        default="phone",
        help="目标设备类型：phone（手机/平板 9:16）/ pc（PC/2in1 16:9），默认 phone",
    )
    args = parser.parse_args()
    return process_device(args.device)


if __name__ == "__main__":
    sys.exit(main())
