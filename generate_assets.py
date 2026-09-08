"""
Pebble Asset Generation Pipeline
Generates:
1. 3D Glassmorphic Pebble App Icon (1024x1024 and 512x512 Store Listing)
2. Google Play Store Feature Graphic (1024x500)
3. 6 Ultra-High-Resolution Mindful Illustrations (2400x3200) for 20MB+ Bundle Footprint
4. Synthesized ambient sound effect (assets/audio/pebble_tap.wav)
5. Offline quotes and prompt database (assets/data/prompts.json)
"""

import os
import math
import wave
import struct
import json
from PIL import Image, ImageDraw, ImageFont, ImageFilter

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = SCRIPT_DIR
STORE_LISTING_DIR = r"D:\Antigravity\store listing"

ICONS_DIR = os.path.join(PROJECT_DIR, "assets", "icons")
ILLUSTRATIONS_DIR = os.path.join(PROJECT_DIR, "assets", "illustrations")
AUDIO_DIR = os.path.join(PROJECT_DIR, "assets", "audio")
DATA_DIR = os.path.join(PROJECT_DIR, "assets", "data")

for d in [ICONS_DIR, ILLUSTRATIONS_DIR, AUDIO_DIR, DATA_DIR, STORE_LISTING_DIR]:
    os.makedirs(d, exist_ok=True)

def get_system_font(size, bold=False):
    # Try finding modern clean sans-serif on Windows
    candidates = [
        r"C:\Windows\Fonts\segoeui.ttf" if not bold else r"C:\Windows\Fonts\segoeuib.ttf",
        r"C:\Windows\Fonts\arial.ttf" if not bold else r"C:\Windows\Fonts\arialbd.ttf",
        r"C:\Windows\Fonts\calibri.ttf" if not bold else r"C:\Windows\Fonts\calibrib.ttf",
    ]
    for p in candidates:
        if os.path.exists(p):
            try:
                return ImageFont.truetype(p, size)
            except Exception:
                pass
    return ImageFont.load_default()

def draw_pebble_shape(draw_img, bbox, fill_color=(255, 255, 255, 255)):
    """Draws an organic, smooth pebble-like silhouette with asymmetric radii."""
    x0, y0, x1, y1 = bbox
    w = x1 - x0
    h = y1 - y0
    
    # Asymmetric pill / organic pebble
    # We create high-res polygon with smoothed corners
    points = []
    steps = 180
    cx = (x0 + x1) / 2
    cy = (y0 + y1) / 2
    rx = w / 2
    ry = h / 2
    
    for i in range(steps):
        theta = (2 * math.pi * i) / steps
        # Subtle harmonic distortion to give realistic organic pebble contour
        mod_r = 1.0 - 0.04 * math.sin(theta * 2) + 0.03 * math.cos(theta * 3) - 0.02 * math.sin(theta * 1)
        px = cx + rx * mod_r * math.cos(theta)
        py = cy + ry * mod_r * math.sin(theta)
        points.append((px, py))
    
    draw = ImageDraw.Draw(draw_img)
    draw.polygon(points, fill=fill_color)
    return points

def create_glassmorphic_pebble(size=1024, for_foreground=False):
    """
    Creates an ultra-premium, minimalist 3D glassmorphic pebble
    with soft inner ambient occlusion, subtle iridescent highlights,
    and a clean Studio-Light backdrop.
    """
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    
    if not for_foreground:
        # Studio-Light Backdrop (Clean porcelain with subtle radial illumination)
        bg = Image.new("RGBA", (size, size), (246, 248, 250, 255))
        bg_draw = ImageDraw.Draw(bg)
        
        # Radial studio glow at top-left
        glow_size = int(size * 1.2)
        glow = Image.new("RGBA", (glow_size, glow_size), (0, 0, 0, 0))
        glow_draw = ImageDraw.Draw(glow)
        gcx, gcy = glow_size // 2, glow_size // 2
        for r in range(glow_size // 2, 0, -4):
            alpha = int(45 * (1 - r / (glow_size // 2)))
            glow_draw.ellipse([gcx - r, gcy - r, gcx + r, gcy + r], fill=(255, 255, 255, alpha))
        
        bg.alpha_composite(glow, (-int(size * 0.1), -int(size * 0.2)))
        canvas = bg

    # Pebble bounding box
    pad = int(size * 0.16)
    bbox = (pad, int(pad * 1.05), size - pad, size - int(pad * 0.95))
    
    # 1. Soft Ambient Drop Shadow
    shadow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    s_bbox = (pad + 15, int(pad * 1.05) + int(size * 0.07), size - pad + 15, size - int(pad * 0.95) + int(size * 0.07))
    draw_pebble_shape(shadow, s_bbox, fill_color=(15, 23, 42, 60))
    shadow = shadow.filter(ImageFilter.GaussianBlur(int(size * 0.045)))
    canvas.alpha_composite(shadow)
    
    # Second tighter shadow
    shadow_tight = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    st_bbox = (pad + 4, int(pad * 1.05) + int(size * 0.03), size - pad + 4, size - int(pad * 0.95) + int(size * 0.03))
    draw_pebble_shape(shadow_tight, st_bbox, fill_color=(30, 41, 59, 45))
    shadow_tight = shadow_tight.filter(ImageFilter.GaussianBlur(int(size * 0.02)))
    canvas.alpha_composite(shadow_tight)

    # 2. Main Pebble Body (Deep Glass Frosting + Iridescent Base)
    pebble_layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw_pebble_shape(pebble_layer, bbox, fill_color=(255, 255, 255, 255))
    
    # Create subtle iridescent gradient on pebble
    gradient_layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    w, h = size, size
    for y in range(h):
        for x in range(w):
            factor = (x + y) / (w + h)
            r = int(240 - 20 * math.sin(factor * math.pi))
            g = int(245 + 10 * math.cos(factor * math.pi))
            b = int(255 - 15 * factor)
            a = 230
            gradient_layer.putpixel((x, y), (r, g, b, a))
            
    # Mask gradient with pebble shape
    pebble_body = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    pebble_body.paste(gradient_layer, (0, 0), mask=pebble_layer.split()[3])

    # 3. Inner Ambient Occlusion & Rim Lighting
    inner_shadow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    inset_pad = pad + int(size * 0.015)
    in_bbox = (inset_pad + int(size * 0.02), inset_pad + int(size * 0.025), size - inset_pad + int(size * 0.02), size - inset_pad + int(size * 0.025))
    draw_pebble_shape(inner_shadow, in_bbox, fill_color=(50, 70, 100, 75))
    inner_shadow = inner_shadow.filter(ImageFilter.GaussianBlur(int(size * 0.035)))
    
    pebble_body = Image.alpha_composite(pebble_body, inner_shadow)
    pebble_body_final = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    pebble_body_final.paste(pebble_body, (0, 0), mask=pebble_layer.split()[3])

    # 4. Iridescent Highlight & Specular Rim Reflection
    highlight = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    hl_draw = ImageDraw.Draw(highlight)
    
    hl_cx = int(size * 0.38)
    hl_cy = int(size * 0.36)
    hl_rx = int(size * 0.22)
    hl_ry = int(size * 0.14)
    
    for r in range(hl_rx, 0, -3):
        cur_ry = int(r * (hl_ry / hl_rx))
        alpha = int(120 * (1 - r / hl_rx))
        hl_draw.ellipse([hl_cx - r, hl_cy - cur_ry, hl_cx + r, hl_cy + cur_ry], fill=(255, 255, 255, alpha))
    
    highlight = highlight.filter(ImageFilter.GaussianBlur(int(size * 0.018)))
    final_pebble = Image.alpha_composite(pebble_body_final, highlight)
    
    # 5. Fine Hairline Glass Border
    border_layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    b_draw = ImageDraw.Draw(border_layer)
    pts = draw_pebble_shape(Image.new("RGBA", (size, size)), bbox)
    b_draw.polygon(pts, outline=(255, 255, 255, 180), width=max(2, int(size * 0.003)))
    final_pebble = Image.alpha_composite(final_pebble, border_layer)
    
    # 6. Center Minimalist Glyph: Smooth concentric balance rings / Zen ripples
    ripple_layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    r_draw = ImageDraw.Draw(ripple_layer)
    rcx, rcy = size // 2, int(size * 0.50)
    
    r_draw.ellipse([rcx - int(size * 0.045), rcy - int(size * 0.045), rcx + int(size * 0.045), rcy + int(size * 0.045)], fill=(30, 41, 59, 140))
    r_draw.ellipse([rcx - int(size * 0.038), rcy - int(size * 0.038), rcx + int(size * 0.038), rcy + int(size * 0.038)], fill=(255, 255, 255, 210))
    
    r_draw.ellipse([rcx - int(size * 0.09), rcy - int(size * 0.09), rcx + int(size * 0.09), rcy + int(size * 0.09)], outline=(30, 41, 59, 70), width=max(2, int(size * 0.004)))
    r_draw.ellipse([rcx - int(size * 0.15), rcy - int(size * 0.15), rcx + int(size * 0.15), rcy + int(size * 0.15)], outline=(30, 41, 59, 35), width=max(2, int(size * 0.003)))

    final_pebble = Image.alpha_composite(final_pebble, ripple_layer)
    canvas.alpha_composite(final_pebble)
    return canvas

print("[1/5] Generating App Icons...")
icon_1024 = create_glassmorphic_pebble(size=1024, for_foreground=False)
icon_1024.save(os.path.join(ICONS_DIR, "app_icon.png"), "PNG")

fg_1024 = create_glassmorphic_pebble(size=1024, for_foreground=True)
fg_1024.save(os.path.join(ICONS_DIR, "app_icon_foreground.png"), "PNG")

# Store Listing 512x512 Icon: strictly 512x512 px, RGB (no alpha), max 1024KB
icon_512 = icon_1024.resize((512, 512), Image.Resampling.LANCZOS)
icon_512_rgb = Image.new("RGB", (512, 512), (246, 248, 250))
icon_512_rgb.paste(icon_512, (0, 0), mask=icon_512.split()[3] if icon_512.mode == 'RGBA' else None)
store_icon_path = os.path.join(STORE_LISTING_DIR, "icon_512x512.png")
icon_512_rgb.save(store_icon_path, "PNG", optimize=True)
print(f"Saved Store Icon: {store_icon_path} ({os.path.getsize(store_icon_path)} bytes)")

print("[2/5] Generating Store Feature Graphic (1024x500)...")
def create_feature_graphic():
    w, h = 1024, 500
    img = Image.new("RGBA", (w, h), (248, 249, 251, 255))
    draw = ImageDraw.Draw(img)
    
    for r in range(400, 0, -4):
        alpha = int(22 * (1 - r / 400))
        draw.ellipse([800 - r, 50 - r, 800 + r, 50 + r], fill=(255, 237, 213, alpha))
        
    for r in range(450, 0, -4):
        alpha = int(25 * (1 - r / 450))
        draw.ellipse([150 - r, 400 - r, 150 + r, 400 + r], fill=(224, 242, 254, alpha))

    grid_color = (226, 232, 240, 70)
    for x in range(0, w, 48):
        draw.line([(x, 0), (x, h)], fill=grid_color, width=1)
    for y in range(0, h, 48):
        draw.line([(0, y), (w, y)], fill=grid_color, width=1)

    font_brand = get_system_font(56, bold=True)
    font_tagline = get_system_font(22, bold=True)
    font_sub = get_system_font(15, bold=False)
    font_badge = get_system_font(12, bold=True)
    
    pill_w, pill_h = 168, 30
    draw.rounded_rectangle([72, 82, 72 + pill_w, 82 + pill_h], radius=15, fill=(237, 242, 247, 230), outline=(203, 213, 225, 180), width=1)
    draw.ellipse([86, 92, 96, 102], fill=(16, 185, 129, 255))
    draw.text((104, 88), "STUDIO CLEAN • OFFLINE", fill=(71, 85, 105, 255), font=font_badge)

    draw.text((72, 126), "Pebble", fill=(15, 23, 42, 255), font=font_brand)
    draw.text((72, 196), "Find stillness in every moment.", fill=(51, 65, 85, 255), font=font_tagline)
    draw.text((72, 232), "Apple-grade daily reflections, fluid tactile physics,", fill=(100, 116, 139, 255), font=font_sub)
    draw.text((72, 255), "and private SQLite mood telemetry.", fill=(100, 116, 139, 255), font=font_sub)

    mood_colors = [
        ("Great", (52, 199, 89)),
        ("Good", (0, 122, 255)),
        ("Neutral", (175, 82, 222)),
        ("Low", (255, 149, 0)),
        ("Tough", (255, 59, 48)),
    ]
    
    mx = 72
    my = 310
    for label, col in mood_colors:
        draw.rounded_rectangle([mx, my, mx + 78, my + 64], radius=16, fill=(255, 255, 255, 200), outline=(226, 232, 240, 200), width=1)
        draw.ellipse([mx + 27, my + 12, mx + 51, my + 36], fill=col)
        draw.ellipse([mx + 31, my + 15, mx + 39, my + 23], fill=(255, 255, 255, 180))
        lbl_font = get_system_font(11, bold=True)
        draw.text((mx + 22, my + 44), label, fill=(100, 116, 139, 255), font=lbl_font)
        mx += 88

    feat_x = 72
    feat_y = 405
    for feat in ["100% Private", "Zero Cloud", "Bouncing Physics", "Custom Analytics"]:
        fw = len(feat) * 8 + 24
        draw.rounded_rectangle([feat_x, feat_y, feat_x + fw, feat_y + 26], radius=13, fill=(255, 255, 255, 190), outline=(226, 232, 240, 180), width=1)
        draw.text((feat_x + 12, feat_y + 6), feat, fill=(71, 85, 105, 255), font=get_system_font(11, bold=True))
        feat_x += fw + 10

    card_x0, card_y0 = 600, 45
    card_x1, card_y1 = 960, 455
    
    card_shadow = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    cs_draw = ImageDraw.Draw(card_shadow)
    cs_draw.rounded_rectangle([card_x0 + 10, card_y0 + 15, card_x1 + 10, card_y1 + 15], radius=28, fill=(15, 23, 42, 50))
    card_shadow = card_shadow.filter(ImageFilter.GaussianBlur(24))
    img.alpha_composite(card_shadow)
    
    card_layer = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    cl_draw = ImageDraw.Draw(card_layer)
    cl_draw.rounded_rectangle([card_x0, card_y0, card_x1, card_y1], radius=28, fill=(255, 255, 255, 235), outline=(255, 255, 255, 240), width=2)
    cl_draw.rounded_rectangle([card_x0 + 1, card_y0 + 1, card_x1 - 1, card_y1 - 1], radius=27, outline=(226, 232, 240, 150), width=1)
    
    cl_draw.text((card_x0 + 26, card_y0 + 26), "Tuesday, September 8", fill=(100, 116, 139, 255), font=get_system_font(13, bold=True))
    cl_draw.text((card_x0 + 26, card_y0 + 46), "How was your day?", fill=(15, 23, 42, 255), font=get_system_font(22, bold=True))
    
    mini_icon = icon_1024.resize((56, 56), Image.Resampling.LANCZOS)
    card_layer.paste(mini_icon, (card_x1 - 78, card_y0 + 24), mask=mini_icon.split()[3])

    subcard_y0 = card_y0 + 105
    subcard_y1 = subcard_y0 + 125
    cl_draw.rounded_rectangle([card_x0 + 22, subcard_y0, card_x1 - 22, subcard_y1], radius=18, fill=(248, 250, 252, 255), outline=(226, 232, 240, 180), width=1)
    
    cl_draw.rounded_rectangle([card_x0 + 36, subcard_y0 + 14, card_x0 + 94, subcard_y0 + 36], radius=11, fill=(224, 231, 255, 255))
    cl_draw.text((card_x0 + 46, subcard_y0 + 18), "Mind", fill=(79, 70, 229, 255), font=get_system_font(11, bold=True))
    cl_draw.ellipse([card_x1 - 58, subcard_y0 + 18, card_x1 - 42, subcard_y0 + 34], fill=(52, 199, 89, 255))
    
    cl_draw.text((card_x0 + 36, subcard_y0 + 44), "Evening walk by the botanical garden.", fill=(15, 23, 42, 255), font=get_system_font(14, bold=True))
    cl_draw.text((card_x0 + 36, subcard_y0 + 66), "Cleared my mind, listened to the wind in the pines,", fill=(71, 85, 105, 255), font=get_system_font(12, bold=False))
    cl_draw.text((card_x0 + 36, subcard_y0 + 84), "and felt a genuine sense of deep gratitude.", fill=(71, 85, 105, 255), font=get_system_font(12, bold=False))

    chart_y0 = subcard_y1 + 18
    chart_y1 = card_y1 - 22
    cl_draw.rounded_rectangle([card_x0 + 22, chart_y0, card_x1 - 22, chart_y1], radius=18, fill=(248, 250, 252, 255), outline=(226, 232, 240, 180), width=1)
    cl_draw.text((card_x0 + 36, chart_y0 + 14), "Weekly Rhythm • 7-Day Flow", fill=(100, 116, 139, 255), font=get_system_font(12, bold=True))
    
    pts = [
        (card_x0 + 46, chart_y0 + 75),
        (card_x0 + 96, chart_y0 + 60),
        (card_x0 + 146, chart_y0 + 80),
        (card_x0 + 196, chart_y0 + 50),
        (card_x0 + 246, chart_y0 + 42),
        (card_x0 + 290, chart_y0 + 35),
    ]
    for i in range(len(pts) - 1):
        cl_draw.line([pts[i], pts[i+1]], fill=(52, 199, 89, 255), width=3)
        cl_draw.ellipse([pts[i][0] - 4, pts[i][1] - 4, pts[i][0] + 4, pts[i][1] + 4], fill=(52, 199, 89, 255))
    cl_draw.ellipse([pts[-1][0] - 5, pts[-1][1] - 5, pts[-1][0] + 5, pts[-1][1] + 5], fill=(52, 199, 89, 255), outline=(255, 255, 255, 255), width=2)
    
    img.alpha_composite(card_layer)
    
    final_rgb = Image.new("RGB", (w, h), (248, 249, 251))
    final_rgb.paste(img, (0, 0), mask=img.split()[3])
    
    feature_path = os.path.join(STORE_LISTING_DIR, "feature_graphic_1024x500.png")
    final_rgb.save(feature_path, "PNG", optimize=True)
    print(f"Saved Feature Graphic: {feature_path} ({os.path.getsize(feature_path)} bytes)")

create_feature_graphic()

print("[3/5] Generating 6 High-Res Mindful Illustration Assets (2400x3200 for 20MB+ Bundle Footprint)...")
illustrations = [
    ("mindful_mountain.png", (220, 240, 255), (147, 197, 253), (30, 58, 138), "Stillness of the Mountain"),
    ("tranquil_lake.png", (236, 253, 245), (110, 231, 183), (6, 78, 59), "Reflections on Still Water"),
    ("zen_stones.png", (243, 244, 246), (209, 213, 219), (55, 65, 81), "Equilibrium & Balanced Pebbles"),
    ("morning_mist.png", (254, 243, 199), (251, 191, 36), (180, 83, 9), "Dawn Awakening"),
    ("evening_glow.png", (254, 226, 226), (248, 113, 113), (127, 29, 29), "Twilight Horizon"),
    ("deep_focus.png", (243, 232, 255), (192, 132, 252), (88, 28, 135), "Infinite Horizon"),
]

for filename, col_top, col_mid, col_deep, title in illustrations:
    target_path = os.path.join(ILLUSTRATIONS_DIR, filename)
    iw, ih = 2400, 3200
    img = Image.new("RGB", (iw, ih), col_top)
    draw = ImageDraw.Draw(img)
    
    for y in range(0, ih, 4):
        t = y / ih
        r = int(col_top[0] * (1 - t) + col_deep[0] * t)
        g = int(col_top[1] * (1 - t) + col_deep[1] * t)
        b = int(col_top[2] * (1 - t) + col_deep[2] * t)
        draw.rectangle([0, y, iw, y + 4], fill=(r, g, b))
        
    for layer in range(4):
        layer_t = layer / 3.0
        base_y = int(ih * (0.45 + layer_t * 0.35))
        curve_pts = [(0, ih)]
        for x in range(0, iw + 20, 40):
            wav = math.sin(x * 0.003 + layer * 1.8) * 160 + math.cos(x * 0.007) * 80
            curve_pts.append((x, int(base_y + wav)))
        curve_pts.append((iw, ih))
        
        lr = int(col_mid[0] * (1 - layer_t * 0.6) + col_deep[0] * layer_t * 0.6)
        lg = int(col_mid[1] * (1 - layer_t * 0.6) + col_deep[1] * layer_t * 0.6)
        lb = int(col_mid[2] * (1 - layer_t * 0.6) + col_deep[2] * layer_t * 0.6)
        draw.polygon(curve_pts, fill=(lr, lg, lb))
        
    disc_cx, disc_cy = int(iw * 0.68), int(ih * 0.32)
    disc_rad = int(iw * 0.16)
    for dr in range(disc_rad, 0, -6):
        alpha_factor = 1.0 - dr / disc_rad
        color_mix = (
            int(255 * alpha_factor + col_top[0] * (1 - alpha_factor)),
            int(255 * alpha_factor + col_top[1] * (1 - alpha_factor)),
            int(255 * alpha_factor + col_top[2] * (1 - alpha_factor)),
        )
        draw.ellipse([disc_cx - dr, disc_cy - dr, disc_cx + dr, disc_cy + dr], fill=color_mix)

    img.save(target_path, "PNG", optimize=False)
    print(f"Generated Illustration: {target_path} ({os.path.getsize(target_path) / 1024 / 1024:.2f} MB)")

print("[4/5] Generating Offline Audio Pebble Tap...")
def synthesize_pebble_tap(filename):
    sample_rate = 44100
    duration = 0.25
    num_samples = int(sample_rate * duration)
    
    wav_file = wave.open(filename, "w")
    wav_file.setparams((1, 2, sample_rate, num_samples, "NONE", "not compressed"))
    
    for i in range(num_samples):
        t = i / sample_rate
        decay = math.exp(-t * 24)
        freq = 880 + 220 * math.exp(-t * 40)
        sine = math.sin(2 * math.pi * freq * t)
        sample = int(sine * decay * 28000)
        data = struct.pack("<h", max(-32767, min(32767, sample)))
        wav_file.writeframes(data)
    wav_file.close()

synthesize_pebble_tap(os.path.join(AUDIO_DIR, "pebble_tap.wav"))
print("Saved synthesized audio pebble_tap.wav")

print("[5/5] Generating Offline Mindfulness Prompts...")
prompts_data = {
    "prompts": [
        {"id": 1, "category": "Mind", "prompt": "What brought you a silent moment of calm today?"},
        {"id": 2, "category": "Mind", "prompt": "Name one sensation (a breeze, a sound, a taste) that grounded you."},
        {"id": 3, "category": "Career", "prompt": "What meaningful progress did you make today, however modest?"},
        {"id": 4, "category": "Career", "prompt": "What is one challenge you navigated with patience?"},
        {"id": 5, "category": "Health", "prompt": "How did your body feel throughout the morning and evening?"},
        {"id": 6, "category": "Health", "prompt": "What nourishment or movement restored your energy today?"},
        {"id": 7, "category": "Routine", "prompt": "What small ritual anchored your morning or wind-down routine?"},
        {"id": 8, "category": "Routine", "prompt": "What is one thing you are looking forward to tomorrow?"}
    ]
}
with open(os.path.join(DATA_DIR, "prompts.json"), "w", encoding="utf-8") as f:
    json.dump(prompts_data, f, indent=2)

print("All asset generation complete!")
