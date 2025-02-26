import os
import imageio
from PIL import Image
import numpy as np

# Set the output video filename and path
filename = "output.mp4"
filepath = os.path.join(os.getcwd(), filename)

# Directory containing the images
image_dir = "dataset"

# Display time per image in seconds
display_time = 3.0  # You can change it to 5.0 for 5 seconds

# Video frame rate (can be adjusted as needed, but not critical in this case)
fps = 30

# Calculate the number of frames needed per image
frames_per_image = int(display_time * fps)

# Get all image files
image_files = [f for f in os.listdir(image_dir) if f.endswith(".jpg")]
image_files.sort()  # Ensure images are in order

# Convert images into a video file
with imageio.get_writer(filepath, fps=fps) as video:
    for file_name in image_files:
        image_path = os.path.join(image_dir, file_name)
        try:
            image = Image.open(image_path).convert("RGB")
            numpy_image = np.array(image)
            for _ in range(frames_per_image):  # Write repeated frames
                video.append_data(numpy_image)
            print(f"Added {file_name} for {display_time} seconds.")
        except Exception as e:
            print(f"Error processing {file_name}: {e}")

print(f"Video generated: {filepath}")
