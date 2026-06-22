# scripts/generate_app_icon.py
# 与 iOS / Android 共用同一设计：暖白底 + "壹"字

from PIL import Image, ImageDraw, ImageFont

SIZE = 1024
BG_COLOR = (242, 240, 235)        # 暖白 #F2F0EB
TEXT_COLOR = (26, 26, 26)         # 近黑 #1A1A1A
LINE_COLOR = (217, 214, 208)      # 暖灰分割线
SUB_COLOR = (142, 142, 147)       # 灰

FONT_HIRAGINO = "/System/Library/Fonts/Hiragino Sans GB.ttc"
FONT_ARIAL = "/Library/Fonts/Arial Unicode.ttf"


def get_font(path, size, index=0):
    return ImageFont.truetype(path, size, index=index)


def main():
    img = Image.new("RGB", (SIZE, SIZE), BG_COLOR)
    draw = ImageDraw.Draw(img)

    # "壹"字
    main_font = get_font(FONT_HIRAGINO, 580, index=0)
    main_text = "壹"
    bbox = draw.textbbox((0, 0), main_text, font=main_font)
    main_w = bbox[2] - bbox[0]
    main_h = bbox[3] - bbox[1]
    main_x = (SIZE - main_w) // 2 - bbox[0]
    main_y = (SIZE - main_h) // 2 - bbox[1]
    draw.text((main_x, main_y), main_text, fill=TEXT_COLOR, font=main_font)
    main_bottom = main_y + bbox[3]

    # 分割线
    line_w = 100
    line_h = 2
    line_x = (SIZE - line_w) // 2
    line_y = main_bottom + 70
    draw.rectangle([line_x, line_y, line_x + line_w, line_y + line_h], fill=LINE_COLOR)

    # 副标题
    sub_font = get_font(FONT_ARIAL, 60)
    sub_text = "金额大写转换"
    sub_bbox = draw.textbbox((0, 0), sub_text, font=sub_font)
    sub_w = sub_bbox[2] - sub_bbox[0]
    sub_x = (SIZE - sub_w) // 2 - sub_bbox[0]
    sub_y = line_y + line_h + 50
    draw.text((sub_x, sub_y), sub_text, fill=SUB_COLOR, font=sub_font)

    out_path = "/Users/yizhiwang/Desktop/opencode/FinanceNumberConverter/harmony/entry/src/main/resources/base/media/app_icon.png"
    img.save(out_path, "PNG", optimize=True)
    print(f"OK {out_path}")


if __name__ == "__main__":
    main()
