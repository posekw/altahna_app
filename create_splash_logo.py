from PIL import Image

def add_padding(image_path, output_path, padding_factor=0.6, bg_color="#ae8a72"):
    """
    Adds padding to an image by placing it in the center of a larger background.
    Or strictly speaking, shrinks the image and places it on a background of the same size.
    
    padding_factor: The ratio of the new image size to the original content size. 
                    e.g. 0.5 means the logo content will be 50% of the width.
    """
    try:
        img = Image.open(image_path).convert("RGBA")
        width, height = img.size
        
        # New size could be same as old size, just content shrunk
        # scaling content down
        new_width = int(width * padding_factor)
        new_height = int(height * padding_factor)
        
        # Resize original image
        img_resized = img.resize((new_width, new_height), Image.Resampling.LANCZOS)
        
        # Create background image
        # Using the original size as the canvas size
        background = Image.new('RGBA', (width, height), bg_color)
        
        # Calculate position to center
        x_offset = (width - new_width) // 2
        y_offset = (height - new_height) // 2
        
        # Paste resized image onto background
        background.paste(img_resized, (x_offset, y_offset), img_resized)
        
        # Save
        background.save(output_path)
        print(f"Successfully created padded image at {output_path}")
        
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    # Padding factor 0.5 means the logo is 50% of the total width/height.
    # This gives plenty of space for the circle mask.
    add_padding("altahna Icon v2.jpg", "splash_logo.png", padding_factor=0.5, bg_color="#ae8a72")
