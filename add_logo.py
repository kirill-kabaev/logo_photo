# add_logo.py
# pip install pillow

import argparse
from pathlib import Path
from PIL import Image, ImageOps
import tkinter as tk
from tkinter import filedialog, messagebox

LOGO_DIR = Path("logo")
LOGO_GLOB = ("*.png", "*.PNG")

# коэффициент по умолчанию (≈13% от высоты фото)
DEFAULT_LOGO_RATIO = 0.13

# поддерживаемые форматы
IMAGE_EXTS = {".jpg", ".jpeg", ".png", ".webp", ".bmp", ".tif", ".tiff"}


def find_logo_png() -> Path:
    for pattern in LOGO_GLOB:
        logos = sorted(LOGO_DIR.glob(pattern))
        if logos:
            return logos[0]
    raise FileNotFoundError(f"PNG logo not found in folder {LOGO_DIR.resolve()}")


def load_logo_rgba(path: Path) -> Image.Image:
    logo = Image.open(path)
    return ImageOps.exif_transpose(logo).convert("RGBA")


def resize_logo_for_image(logo_rgba: Image.Image, base_w: int, base_h: int, ratio: float) -> Image.Image:
    """Масштабируем логотип так, чтобы его большая сторона занимала ratio от высоты фото."""
    target_size = int(base_h * ratio)

    w, h = logo_rgba.size
    scale = target_size / max(w, h)
    target_w = int(w * scale)
    target_h = int(h * scale)

    return logo_rgba.resize((target_w, target_h), Image.LANCZOS)


def place_logo_bottom_right(img: Image.Image, logo_rgba: Image.Image, ratio: float) -> Image.Image:
    """Ставим логотип в нижний правый угол без отступов."""
    img = ImageOps.exif_transpose(img)
    base_w, base_h = img.size

    logo_resized = resize_logo_for_image(logo_rgba, base_w, base_h, ratio)
    lw, lh = logo_resized.size

    x = base_w - lw
    y = base_h - lh

    base = img.convert("RGBA")
    base.alpha_composite(logo_resized, dest=(x, y))
    return base


def process_all(pic_dir: Path, ratio: float):
    # выходная папка = соседняя с постфиксом "_logo"
    out_dir = pic_dir.parent / (pic_dir.name + "_logo")
    out_dir.mkdir(parents=True, exist_ok=True)

    logo_path = find_logo_png()
    logo_rgba = load_logo_rgba(logo_path)

    for path in sorted(pic_dir.iterdir()):
        if path.is_file() and path.suffix.lower() in IMAGE_EXTS:
            try:
                with Image.open(path) as im:
                    result = place_logo_bottom_right(im, logo_rgba, ratio)

                    # имя файла с постфиксом "_logo"
                    stem = path.stem + "_logo"
                    out_path = out_dir / f"{stem}{path.suffix}"

                    ext = path.suffix.lower()
                    if ext in {".jpg", ".jpeg"}:
                        result.convert("RGB").save(out_path, quality=95, subsampling=0, optimize=True)
                    else:
                        result.save(out_path)

                print(f"OK: {path.name} → {out_path}")
            except Exception as e:
                print(f"Error for {path.name}: {e}")


# ---------------- GUI ----------------
def run_gui():
    root = tk.Tk()
    root.title("Add Logo to Images")

    src_var = tk.StringVar(value="")
    ratio_var = tk.DoubleVar(value=DEFAULT_LOGO_RATIO)

    def browse_src():
        folder = filedialog.askdirectory()
        if folder:
            src_var.set(folder)

    def start():
        pic_dir = Path(src_var.get())
        ratio = ratio_var.get()
        if not pic_dir.exists():
            messagebox.showerror("Error", f"Source folder not found: {pic_dir}")
            return
        process_all(pic_dir, ratio)
        out_dir = pic_dir.parent / (pic_dir.name + "_logo")
        messagebox.showinfo("Done", f"Processing complete!\nResults saved to {out_dir}")

    # UI
    tk.Label(root, text="Source folder:").grid(row=0, column=0, sticky="w")
    tk.Entry(root, textvariable=src_var, width=40).grid(row=0, column=1)
    tk.Button(root, text="Browse", command=browse_src).grid(row=0, column=2)

    tk.Label(root, text="Logo size ratio:").grid(row=1, column=0, sticky="w")
    tk.Scale(root, variable=ratio_var, from_=0.05, to=0.3, resolution=0.01,
             orient="horizontal", length=200).grid(row=1, column=1)

    tk.Button(root, text="Start", command=start, bg="green", fg="white").grid(row=2, column=1, pady=10)

    # отключаем кнопку "Start", если путь пуст
    def validate_start(*args):
        start_button_state = tk.NORMAL if src_var.get() else tk.DISABLED
        start_button.config(state=start_button_state)

    start_button = tk.Button(root, text="Start", command=start, bg="green", fg="white")
    start_button.grid(row=2, column=1, pady=10)
    src_var.trace_add("write", validate_start)
    validate_start()

    root.mainloop()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Add logo to images.")
    parser.add_argument("-s", "--src", type=str, help="Path to source images folder (REQUIRED)")
    parser.add_argument("-r", "--ratio", type=float, help="Logo size ratio relative to height (default: 0.17)")
    parser.add_argument("--gui", action="store_true", help="Launch graphical interface")
    args = parser.parse_args()

    if args.gui:
        run_gui()
    else:
        if not args.src:
            raise SystemExit("Error: --src is required in CLI mode. Use --gui for graphical mode.")
        pic_dir = Path(args.src)
        ratio = args.ratio if args.ratio else DEFAULT_LOGO_RATIO

        if not pic_dir.exists():
            raise FileNotFoundError(f"Source folder not found: {pic_dir.resolve()}")

        process_all(pic_dir, ratio)