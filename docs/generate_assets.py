#!/usr/bin/env python3
"""Generate screenshot drop-in slots for the README. Does not touch the official app icon."""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent
SHOTS = ROOT / "screenshots"

NAVY_DEEP = (8, 18, 28, 255)
TEAL = (45, 212, 191, 255)
TEAL_DIM = (20, 184, 166, 255)
INK = (226, 232, 240, 255)
MUTED = (148, 163, 184, 255)
LINE = (45, 212, 191, 70)
DASH = (94, 234, 212, 160)


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    candidates = [
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" if bold else "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
        "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf" if bold else "/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf",
        "/usr/share/fonts/truetype/freefont/FreeSansBold.ttf" if bold else "/usr/share/fonts/truetype/freefont/FreeSans.ttf",
    ]
    for c in candidates:
        if Path(c).exists():
            return ImageFont.truetype(c, size)
    return ImageFont.load_default()


def dashed_round_rect(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], radius: int, fill=None) -> None:
    x0, y0, x1, y1 = box
    draw.rounded_rectangle(box, radius=radius, outline=DASH, width=3)
    if fill:
        draw.rounded_rectangle((x0 + 3, y0 + 3, x1 - 3, y1 - 3), radius=max(8, radius - 2), fill=fill)


def camera_glyph(draw: ImageDraw.ImageDraw, cx: int, cy: int, scale: int = 1) -> None:
    w, h = 54 * scale, 36 * scale
    box = (cx - w // 2, cy - h // 2, cx + w // 2, cy + h // 2)
    draw.rounded_rectangle(box, radius=8 * scale, outline=TEAL, width=3)
    draw.ellipse((cx - 10 * scale, cy - 10 * scale, cx + 10 * scale, cy + 10 * scale), outline=TEAL, width=3)
    draw.rectangle((cx + 12 * scale, cy - h // 2 - 6 * scale, cx + 22 * scale, cy - h // 2 + 2 * scale), outline=TEAL, width=2)


def make_placeholder(
    path: Path,
    size: tuple[int, int],
    title: str,
    caption: str,
    filename: str,
    kind: str = "wide",
) -> None:
    w, h = size
    img = Image.new("RGBA", (w, h), NAVY_DEEP)
    draw = ImageDraw.Draw(img, "RGBA")

    for x in range(0, w, 40):
        draw.line((x, 0, x, h), fill=(30, 41, 59, 80), width=1)
    for y in range(0, h, 40):
        draw.line((0, y, w, y), fill=(30, 41, 59, 80), width=1)

    pad = 36 if kind != "mobile" else 28
    frame = (pad, pad, w - pad, h - pad)
    dash_fill = (15, 23, 42, 230)
    radius = 28 if kind != "mobile" else 40
    dashed_round_rect(draw, frame, radius, fill=dash_fill)

    if kind == "mobile":
        nx0, ny0 = w // 2 - 48, pad + 14
        draw.rounded_rectangle((nx0, ny0, nx0 + 96, ny0 + 10), radius=5, fill=(45, 212, 191, 90))
        inner = (pad + 18, pad + 36, w - pad - 18, h - pad - 28)
        draw.rounded_rectangle(inner, radius=24, outline=LINE, width=2)
        cx, cy = w // 2, int(h * 0.42)
    elif kind == "desktop":
        inner = (pad + 28, pad + 44, w - pad - 28, h - pad - 56)
        draw.rounded_rectangle(inner, radius=12, outline=LINE, width=2)
        by = pad + 22
        for i, color in enumerate(((248, 113, 113, 200), (250, 204, 21, 200), (52, 211, 153, 200))):
            bx = pad + 44 + i * 22
            draw.ellipse((bx, by, bx + 12, by + 12), fill=color)
        draw.rectangle((w // 2 - 40, h - pad - 8, w // 2 + 40, h - pad + 6), fill=TEAL_DIM)
        cx, cy = w // 2, int(h * 0.42)
    else:
        inner = (pad + 22, pad + 22, w - pad - 22, h - pad - 22)
        draw.rounded_rectangle(inner, radius=18, outline=LINE, width=2)
        cx, cy = w // 2, int(h * 0.40)

    camera_glyph(draw, cx, cy - 8, scale=2 if kind != "mobile" else 1)

    title_font = font(36 if kind != "mobile" else 28, bold=True)
    cap_font = font(18 if kind != "mobile" else 15)
    file_font = font(15)

    def center_text(text: str, y: int, fnt, fill) -> None:
        bbox = draw.textbbox((0, 0), text, font=fnt)
        tw = bbox[2] - bbox[0]
        draw.text(((w - tw) / 2, y), text, font=fnt, fill=fill)

    center_text(title, cy + 56, title_font, INK)
    center_text(caption, cy + 104, cap_font, MUTED)
    center_text(f"Replace this file → {filename}", h - pad - (48 if kind != "mobile" else 64), file_font, TEAL)

    img.convert("RGB").save(path, "PNG", optimize=True)


def main() -> None:
    SHOTS.mkdir(parents=True, exist_ok=True)
    specs = [
        ("01-desktop.png", (1600, 1000), "Desktop vault", "Drop a macOS / Windows / Linux screenshot here", "desktop"),
        ("02-mobile.png", (720, 1480), "Mobile vault", "Drop an Android or iOS screenshot here", "mobile"),
        ("03-vault.png", (1440, 900), "Vault & collections", "Logins, folders, search, and tags", "wide"),
        ("04-entry.png", (1440, 900), "Entry detail", "Password, TOTP, passkey, or card", "wide"),
        ("05-autofill.png", (1440, 900), "Autofill & passkeys", "System provider or browser extension", "wide"),
        ("06-sync.png", (1440, 900), "Self-hosted sync", "Settings → Data → Self-hosted server", "wide"),
    ]
    for name, size, title, caption, kind in specs:
        make_placeholder(SHOTS / name, size, title, caption, name, kind)


if __name__ == "__main__":
    main()
