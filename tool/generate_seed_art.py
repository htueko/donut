#!/usr/bin/env python3
"""Generate flat-style seed artwork for the J'Donuts demo."""
import math
import os
from PIL import Image, ImageDraw

OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "seed", "images")
os.makedirs(OUT, exist_ok=True)

DOUGH = (232, 178, 106)
DOUGH_DARK = (214, 158, 84)


def donut(path, glaze, size=160):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    c = size // 2
    d.ellipse((8, 8, size - 8, size - 8), fill=DOUGH, outline=DOUGH_DARK, width=4)
    d.ellipse((20, 20, size - 20, size - 20), fill=glaze)
    d.ellipse((size // 2 - 18, size // 2 - 18, size // 2 + 18, size // 2 + 18), fill=(0, 0, 0, 0))
    sprinkle_colors = [(255, 255, 255), (255, 214, 102), (116, 198, 157), (157, 78, 221)]
    for i in range(14):
        angle = i * (2 * math.pi / 14) + 0.3
        r = 46 + (i % 3) * 6
        x = c + r * math.cos(angle)
        y = c + r * math.sin(angle)
        if math.hypot(x - c, y - c) < 34:
            continue
        d.line((x - 5, y - 2, x + 5, y + 2), fill=sprinkle_colors[i % 4], width=3)
    img.save(path)


def banner(path, top, bottom, accent, size=(640, 320)):
    w, h = size
    img = Image.new("RGB", size, top)
    d = ImageDraw.Draw(img)
    for y in range(h):
        t = y / h
        d.line((0, y, w, y), fill=tuple(int(a + (b - a) * t) for a, b in zip(top, bottom)))
    d.ellipse((w - 200, -60, w + 60, 200), fill=accent)
    d.ellipse((-80, h - 140, 140, h + 80), fill=accent)
    img.save(path)


def shop(path, base, awning, size=(240, 180)):
    w, h = size
    img = Image.new("RGB", size, (255, 248, 241))
    d = ImageDraw.Draw(img)
    d.rectangle((20, 60, w - 20, h - 10), fill=base, outline=base)
    for i in range(6):
        x0 = 20 + i * (w - 40) / 6
        d.rectangle((x0, 40, x0 + (w - 40) / 12, 64), fill=awning)
    d.rectangle((w // 2 - 30, h - 80, w // 2 + 30, h - 10), fill=(255, 255, 255))
    d.rectangle((30, 84, w - 30, 108), fill=(255, 255, 255))
    d.ellipse((w // 2 - 8, h - 56, w // 2 + 8, h - 40), fill=awning)
    img.save(path)


def avatar(path, size=128):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.ellipse((0, 0, size, size), fill=(255, 209, 102))
    d.ellipse((size // 2 - 10, size // 3, size // 2 + 10, size // 3 + 46), fill=(67, 48, 43))
    d.ellipse((size // 2 - 26, size // 2 - 6, size // 2 - 8, size // 2 + 12), fill=(67, 48, 43))
    d.ellipse((size // 2 + 8, size // 2 - 6, size // 2 + 26, size // 2 + 12), fill=(67, 48, 43))
    d.arc((size // 2 - 16, size // 2 + 10, size // 2 + 16, size // 2 + 34), 20, 160, fill=(67, 48, 43), width=4)
    img.save(path)


if __name__ == "__main__":
    donut(f"{OUT}/donut_coconut.png", (255, 255, 255))
    donut(f"{OUT}/donut_chocolate.png", (107, 66, 38))
    donut(f"{OUT}/donut_strawberry.png", (240, 98, 146))
    donut(f"{OUT}/donut_matcha.png", (139, 195, 74))
    donut(f"{OUT}/donut_caramel.png", (222, 149, 60))
    donut(f"{OUT}/donut_blueberry.png", (108, 92, 231))
    donut(f"{OUT}/donut_mango.png", (255, 183, 3))
    donut(f"{OUT}/donut_redvelvet.png", (176, 48, 48))
    donut(f"{OUT}/donut_original.png", (255, 236, 179))
    donut(f"{OUT}/donut_tiramisu.png", (141, 110, 99))
    banner(f"{OUT}/banner_specials.png", (229, 72, 122), (157, 78, 221), (255, 209, 102))
    banner(f"{OUT}/banner_new.png", (116, 198, 157), (46, 160, 120), (255, 255, 255))
    banner(f"{OUT}/banner_reward.png", (242, 166, 90), (229, 72, 122), (255, 236, 179))
    shop(f"{OUT}/shop_city.png", (255, 224, 178), (229, 72, 122))
    shop(f"{OUT}/shop_university.png", (255, 236, 179), (116, 198, 157))
    shop(f"{OUT}/shop_river.png", (215, 236, 244), (108, 92, 231))
    shop(f"{OUT}/shop_mandalay.png", (255, 218, 224), (242, 166, 90))
    avatar(f"{OUT}/avatar.png")
    print("generated", len(os.listdir(OUT)), "images")