from PIL import Image
import sys

def get_bg_color(image_path):
    try:
        img = Image.open(image_path)
        # Get color of top-left pixel (usually background)
        pixel = img.getpixel((0, 0))
        # Convert to Hex
        if len(pixel) == 3:
            r, g, b = pixel
            hex_color = "#{:02x}{:02x}{:02x}".format(r, g, b)
        else:
            r, g, b, a = pixel
            hex_color = "#{:02x}{:02x}{:02x}".format(r, g, b)
        
        print(f"Detected Background Color: {hex_color}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    get_bg_color("altahna Icon v2.jpg")
