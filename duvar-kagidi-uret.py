#!/usr/bin/env python3
"""Tokyo Night duvar kağıdı üretici (gece şehri, neon ufuk, yazısız). Gerekli: python3 + Pillow.
Kullanım: python3 duvar-kagidi-uret.py [genişlik yükseklik]   (varsayılan 3840 2160)
          ONLY=turkuaz python3 duvar-kagidi-uret.py         -> sadece birini üret
Çıktı: bu dosyanın yanındaki duvar-kagitlari/ klasörü. Renkler ve tohum: TEMALAR.
"""
import math, os, random, sys
from PIL import Image, ImageChops, ImageDraw, ImageFilter

BASE = os.path.dirname(os.path.abspath(__file__))
W, H = (int(sys.argv[1]), int(sys.argv[2])) if len(sys.argv) == 3 else (3840, 2160)
S = W / 3840

# Tokyo Night paleti
BG = (26, 27, 38)
NIGHT = (11, 12, 22)
BLUE, CYAN, PURPLE = (122, 162, 247), (125, 207, 255), (187, 154, 247)
GREEN, TEAL, ORANGE = (158, 206, 106), (115, 218, 202), (255, 158, 100)
RED, YELLOW, BLUE1 = (247, 118, 142), (224, 175, 104), (42, 195, 222)

# anahtar: (ana ışıltı, ikinci ışıltı, pencere ışıkları, tohum)
TEMALAR = {
    "mavi-mor": (BLUE, PURPLE, [CYAN, YELLOW, PURPLE, BLUE], 7),
    "mavi":        (BLUE, BLUE1, [CYAN, BLUE, YELLOW], 11),
    "mor-turuncu": (PURPLE, ORANGE, [ORANGE, RED, PURPLE, YELLOW], 23),
    "turkuaz":     (TEAL, GREEN, [GREEN, TEAL, CYAN], 37),
}


def mix(a, b, t):
    return tuple(int(x + (y - x) * t) for x, y in zip(a, b))


def glow(size, cx, cy, rx, ry, color, strength):
    """Yumuşak elips ışıltı (düşük çözünürlükte üretip büyütür)."""
    k = 8
    w, h = max(2, size[0] // k), max(2, size[1] // k)
    m = Image.new("L", (w, h), 0)
    d = ImageDraw.Draw(m)
    steps = 40
    for i in range(steps):
        t = i / steps
        a = int(255 * strength * (t ** 1.8))
        d.ellipse([(cx - rx * (1 - t)) / k, (cy - ry * (1 - t)) / k,
                   (cx + rx * (1 - t)) / k, (cy + ry * (1 - t)) / k], fill=a)
    m = m.filter(ImageFilter.GaussianBlur(3)).resize(size, Image.BICUBIC)
    layer = Image.new("RGB", size, color)
    return ImageChops.multiply(layer, Image.merge("RGB", (m, m, m)))


def sky(c1, c2):
    img = Image.new("RGB", (W, H))
    px = []
    hor = 0.80
    top, mid, low = NIGHT, mix(mix(BG, c1, 0.42), c2, 0.12), (13, 13, 21)
    col = []
    for y in range(H):
        t = y / H
        if t < hor:
            u = (t / hor) ** 1.6
            col.append(mix(top, mid, u))
        else:
            u = (t - hor) / (1 - hor)
            col.append(mix(mid, low, min(1, u * 1.4)))
    strip = Image.new("RGB", (1, H))
    strip.putdata(col)
    return strip.resize((W, H))


def stars(img, rnd):
    d = ImageDraw.Draw(img)
    for _ in range(int(320 * S + 60)):
        x, y = rnd.random() * W, (rnd.random() ** 1.5) * H * 0.55
        r = rnd.choice([0.8, 1, 1, 1.4, 2]) * S * 1.6
        b = rnd.randint(90, 230)
        tint = mix((b, b, b), (200, 210, 255), 0.4)
        d.ellipse([x - r, y - r, x + r, y + r], fill=tint)


def skyline(rnd, base_y, hmin, hmax, wmin, wmax, color, lights, light_p):
    """Bir bina katmanı (RGBA) + pencere ışıkları katmanı (RGB)."""
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    lit = Image.new("RGB", (W, H), (0, 0, 0))
    d, dl = ImageDraw.Draw(layer), ImageDraw.Draw(lit)
    x = -rnd.random() * wmax
    while x < W:
        bw = rnd.uniform(wmin, wmax)
        bh = rnd.uniform(hmin, hmax) * (0.55 + 0.45 * math.sin(x / W * math.pi) + rnd.uniform(-0.15, 0.2))
        top = base_y - bh
        d.rectangle([x, top, x + bw, H], fill=color + (255,))
        if rnd.random() < 0.25:  # anten
            ax = x + bw * rnd.uniform(0.3, 0.7)
            d.rectangle([ax - 2 * S, top - bh * 0.15, ax + 2 * S, top], fill=color + (255,))
            if rnd.random() < 0.6:
                c = rnd.choice(lights)
                r = 4 * S
                dl.ellipse([ax - r, top - bh * 0.15 - r, ax + r, top - bh * 0.15 + r], fill=c)
        if light_p > 0:  # pencereler
            cw, chh, gap = 7 * S, 10 * S, 9 * S
            yy = top + 14 * S
            col_light = rnd.choice(lights)
            while yy < min(H, base_y + 260 * S) - chh:
                xx = x + 10 * S
                while xx < x + bw - 10 * S - cw:
                    if rnd.random() < light_p:
                        c = col_light if rnd.random() < 0.7 else rnd.choice(lights)
                        dl.rectangle([xx, yy, xx + cw, yy + chh], fill=mix((0, 0, 0), c, rnd.uniform(0.45, 0.95)))
                    xx += cw + gap
                yy += chh + gap
        if light_p > 0 and rnd.random() < 0.16:  # neon tabela
            c = rnd.choice(lights)
            nx = x + bw * rnd.uniform(0.15, 0.85)
            dl.rectangle([nx - 3 * S, top + bh * 0.12, nx + 3 * S, top + bh * rnd.uniform(0.35, 0.6)], fill=c)
        x += bw + rnd.uniform(0, 14 * S)
    return layer, lit


def uret(anahtar):
    c1, c2, lights, seed = TEMALAR[anahtar]
    rnd = random.Random(seed)
    img = sky(c1, c2)
    img = ImageChops.screen(img, glow((W, H), W * 0.5, H * 0.84, W * 0.85, H * 0.36, c1, 0.85))
    img = ImageChops.screen(img, glow((W, H), W * 0.78, H * 0.78, W * 0.40, H * 0.30, c2, 0.55))
    img = ImageChops.screen(img, glow((W, H), W * 0.18, H * 0.80, W * 0.35, H * 0.22, c2, 0.30))
    stars(img, rnd)
    # ay
    mx, my, mr = W * 0.78, H * 0.22, H * 0.034
    img = ImageChops.screen(img, glow((W, H), mx, my, mr * 5, mr * 5, mix(c2, (255, 255, 255), 0.3), 0.30))
    ImageDraw.Draw(img).ellipse([mx - mr, my - mr, mx + mr, my + mr], fill=mix((235, 238, 255), c2, 0.18))
    base = H * 0.88
    all_lit = Image.new("RGB", (W, H), (0, 0, 0))
    katmanlar = [
        (base - H * 0.03, H * 0.07, H * 0.17, W * 0.016, W * 0.04, mix(mix(BG, c1, 0.30), c2, 0.10), 0.0),
        (base + H * 0.01, H * 0.07, H * 0.21, W * 0.022, W * 0.055, mix((19, 20, 33), c1, 0.10), 0.03),
        (base + H * 0.07, H * 0.05, H * 0.20, W * 0.03, W * 0.08, (10, 10, 17), 0.035),
    ]
    for by, hmin, hmax, wmin, wmax, color, lp in katmanlar:
        layer, lit = skyline(rnd, by, hmin, hmax, wmin, wmax, color, lights, lp)
        rgba = img.convert("RGBA")
        rgba.alpha_composite(layer)
        img = rgba.convert("RGB")
        img = ImageChops.add(img, lit)
        all_lit = ImageChops.add(all_lit, lit)
    # pencere ışıklarının parlaması
    small = all_lit.resize((W // 6, H // 6), Image.BILINEAR).filter(ImageFilter.GaussianBlur(5))
    small = small.point(lambda p: min(255, p * 2))
    img = ImageChops.screen(img, small.resize((W, H), Image.BICUBIC))
    # yerdeki sis / yansıma
    img = ImageChops.screen(img, glow((W, H), W * 0.5, H * 1.02, W * 0.8, H * 0.14, c1, 0.18))
    # kenar kararması
    v = Image.new("L", (W // 8, H // 8), 0)
    dv = ImageDraw.Draw(v)
    for i in range(30):
        t = i / 30
        dv.ellipse([-W / 8 * 0.25 * (1 - t), -H / 8 * 0.35 * (1 - t), W / 8 * (1 + 0.25 * (1 - t)), H / 8 * (1 + 0.35 * (1 - t))],
                   fill=int(255 * t))
    v = v.filter(ImageFilter.GaussianBlur(6)).resize((W, H), Image.BICUBIC).point(lambda p: 150 + p * 105 // 255)
    img = ImageChops.multiply(img, Image.merge("RGB", (v, v, v)))
    os.makedirs(f"{BASE}/duvar-kagitlari", exist_ok=True)
    img.save(f"{BASE}/duvar-kagitlari/tokyo-night-{anahtar}.png", optimize=True)
    print(f"tokyo-night-{anahtar}.png")


if __name__ == "__main__":
    only = os.environ.get("ONLY")
    for k in TEMALAR:
        if not only or k == only:
            uret(k)
