#!/usr/bin/env python3
"""
rename-screenshots.py
⚠️ 已废弃（2026-06-24）：本脚本只做文件重命名，不做尺寸/比例归一化，
AGC 严格规格（1080×1920 9:16 JPG ≤5MB）由新脚本处理。

新脚本：scripts/fix-screenshots-for-agc.py
详见：docs/screenshots/AGENT-SCREENSHOT-GUIDE.md

保留本脚本仅作历史参考，请勿继续使用。
--- 旧逻辑 ---
将 harmony/docs/screenshots/ 下的截图批量重命名为 AGC 要求的格式。
AGC 要求：1.jpg, 2.jpg, 3.jpg ... (JPG/PNG，5 张以内)
"""

import os
import shutil
import sys
from pathlib import Path

SRC_DIR = Path(__file__).parent.parent / "docs" / "screenshots"
OUT_DIR = SRC_DIR / "AGC-ready"

# AGC 期望的 5 张截图场景（按 iOS/Android 通用要求）
EXPECTED = [
    ("01-empty-state.png", "1.png"),
    ("02-typing.png", "2.png"),
    ("03-result.png", "3.png"),
    ("04-history.png", "4.png"),
    ("05-clear-dialog.png", "5.png"),
]


def main() -> None:
    src = SRC_DIR
    out = OUT_DIR

    if not src.exists():
        print(f"❌ 源目录不存在：{src}")
        sys.exit(1)

    out.mkdir(parents=True, exist_ok=True)

    found = 0
    for src_name, out_name in EXPECTED:
        src_file = src / src_name
        if not src_file.exists():
            print(f"⚠️  缺失：{src_name}")
            continue
        out_file = out / out_name
        shutil.copy2(src_file, out_file)
        print(f"✅ {src_name} → {out_name}")
        found += 1

    print(f"\n共 {found}/5 张已就绪 → {out}")
    if found < 5:
        print("⚠️  请补全缺失的截图")
    else:
        print("🚀 可直接上传 AGC")


if __name__ == "__main__":
    main()
