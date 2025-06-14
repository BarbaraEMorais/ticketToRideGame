class_name ImageParser extends Node

signal image_saved(image_path: String)

func _ready():
	return

# output_path = "user://decoded_image.png"
# user:// maps to the user data directory
func parseImage(image_data_uri: String, output_path: String):
	# 1. Check if it's a valid data URI and extract the Base64 string
	if image_data_uri.begins_with("data:image/png;base64,"):
		var base64_string = image_data_uri.split("data:image/png;base64,")[1]

		# 2. Decode the Base64 string into raw bytes
		var decoded_bytes = Marshalls.base64_to_raw(base64_string)

		if decoded_bytes.is_empty():
			print("Error: Could not decode Base64 string or the string was empty.")
			return

		# 3. Create an Image object and load the PNG data
		var image = Image.new()
		var error = image.load_png_from_buffer(decoded_bytes)

		if error != OK:
			print("Error loading PNG from buffer: ", error)
			return

		# 4. Save the Image as a PNG file
		error = image.save_png(output_path)

		if error != OK:
			print("Error saving PNG to file: ", error)
		else:
			print("Image successfully saved to: ", ProjectSettings.globalize_path(output_path))
			image_saved.emit(output_path)
	else:
		print("Error: The image data URI does not start with 'data:image/png;base64,'")
