import sys
from PIL import Image

def find_dark_blue(image_path):
    try:
        with Image.open(image_path) as img:
            img = img.convert('RGB')
            colors = list(img.getdata())
            # Find any pixel that has high blue, low red/green
            for r, g, b in set(colors):
                if b > 40 and r < 50 and g < 50:
                    print(f"Found dark blue: #{r:02x}{g:02x}{b:02x}")
                    return
            # If not, let's just print the 5 most common colors
            from collections import Counter
            most_common = Counter(colors).most_common(5)
            print("Most common colors:")
            for (r,g,b), count in most_common:
                print(f"#{r:02x}{g:02x}{b:02x} : {count}")
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    find_dark_blue("assets/images/ufit_icon_new.png")
