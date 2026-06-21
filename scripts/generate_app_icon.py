#!/usr/bin/env python3
"""
生成财务大写转换 App 的 App Icon (1024x1024)
设计风格：Premium Utilitarian Minimalism
- 暖白底
- 居中巨大的"壹"字
- 下方小字"金额转换"
"""

from PIL import Image, ImageDraw, ImageFont

# === 画布 ===
SIZE = 1024
BG_COLOR = (242, 240, 235)        # 暖白 #F2F0EB（与 App 内 UI 背景同色）
TEXT_COLOR = (26, 26, 26)         # 近黑 #1A1A1A
SUB_COLOR = (142, 142, 147)       # 灰 #8E8E93（与 iOS secondaryLabel 同色）
LINE_COLOR = (217, 214, 208)      # 暖灰分割线

# === 字体路径 ===
FONT_HIRAGINO = "/System/Library/Fonts/Hiragino Sans GB.ttc"
FONT_ARIAL = "/Library/Fonts/Arial Unicode.ttf"


def get_font(path: str, size: int, index: int = 0) -> ImageFont.FreeTypeFont:
    """加载字体（ttc 用 index 选择子字体）"""
    return ImageFont.truetype(path, size, index=index)


def main() -> None:
    img = Image.new("RGB", (SIZE, SIZE), BG_COLOR)
    draw = ImageDraw.Draw(img)

    # === 主元素：大"壹"字 ===
    # 字号 580（约占 56% 高度），垂直居中略偏上
    main_font_size = 580
    main_font = get_font(FONT_HIRAGINO, main_font_size, index=0)
    main_text = "壹"
    bbox = draw.textbbox((0, 0), main_text, font=main_font)
    main_w = bbox[2] - bbox[0]
    main_h = bbox[3] - bbox[1]
    main_x = (SIZE - main_w) // 2 - bbox[0]
    # 垂直居中（不再偏移）
    main_y = (SIZE - main_h) // 2 - bbox[1]
    draw.text((main_x, main_y), main_text, fill=TEXT_COLOR, font=main_font)

    # 计算"壹"字底部
    main_bottom = main_y + bbox[3]  # bbox[3] 是文字底部（相对坐标）

    # === 分割线 ===
    line_w = 100
    line_h = 2
    line_x = (SIZE - line_w) // 2
    line_y = main_bottom + 70
    draw.rectangle(
        [line_x, line_y, line_x + line_w, line_y + line_h],
        fill=LINE_COLOR,
    )

    # === 副标题 ===
    sub_font_size = 60
    sub_font = get_font(FONT_ARIAL, sub_font_size)
    sub_text = "金额大写转换"
    sub_bbox = draw.textbbox((0, 0), sub_text, font=sub_font)
    sub_w = sub_bbox[2] - sub_bbox[0]
    sub_h = sub_bbox[3] - sub_bbox[1]
    sub_x = (SIZE - sub_w) // 2 - sub_bbox[0]
    sub_y = line_y + line_h + 50
    draw.text((sub_x, sub_y), sub_text, fill=SUB_COLOR, font=sub_font)

    # === 保存 ===
    out_path = "/Users/yizhiwang/Desktop/opencode/第一个ios项目/FinanceNumberConverter/Sources/FinanceNumberConverter/Assets.xcassets/AppIcon.appiconset/icon-1024.png"
    img.save(out_path, "PNG", optimize=True)
    print(f"✅ 已生成 App Icon: {out_path}")
    print(f"   尺寸: {SIZE}x{SIZE}, '壹'字高: {main_h}px, 副标题高: {sub_h}px")


if __name__ == "__main__":
    main()
