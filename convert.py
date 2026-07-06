import sys
from svglib.svglib import svg2rlg
from reportlab.graphics import renderPM

def convert_svg_to_png(svg_path, png_path):
    try:
        drawing = svg2rlg(svg_path)
        renderPM.drawToFile(drawing, png_path, fmt="PNG")
        print(f"Successfully converted {svg_path} to {png_path}")
    except Exception as e:
        print(f"Failed to convert: {e}")
        sys.exit(1)

if __name__ == "__main__":
    convert_svg_to_png("assets/images/ufit_icon.svg", "assets/images/ufit_icon.png")
