# Define the base output directory
BASE_OUTPUT_DIR="converted_h265"

# Create the base output directory
mkdir -p "$BASE_OUTPUT_DIR"

# Define the conversion function
convert_video() {
  local input_file="$1"

  # Calculate relative path to maintain directory structure
  local relative_path=$(realpath --relative-to=. "$input_file")
  
  # Construct the output directory path
  local output_dir="$BASE_OUTPUT_DIR/$(dirname "$relative_path")"
  
  # Extract filename and remove extension
  local filename=$(basename -- "$input_file")
  local filename_no_ext="${filename%.*}"
  
  # Construct the full output file path
  local output_file="${output_dir}/${filename_no_ext}.mp4"

  # Create the output directory if it doesn't exist
  mkdir -p "$output_dir"

  echo "Converting: '$input_file' -> '$output_file'"

  # Run the ffmpeg command
  ffmpeg -y -i "$input_file" \
    -vf "scale=1920:1080" \
    -c:v hevc_nvenc \
    -preset medium \
    -b:v 5M \
    -maxrate 7.5M \
    -bufsize 10M \
    -c:a copy \
    "$output_file"

  # Check if ffmpeg command was successful
  if [ $? -eq 0 ]; then
    echo "Successfully converted: '$input_file'"
  else
    echo "Error converting: '$input_file'. Check ffmpeg output above."
  fi
}

# Export the function so xargs can use it
export -f convert_video
export BASE_OUTPUT_DIR # Export the variable too if it's used inside the function

# Find MP4 files and pass them to the function using xargs
# -print0 and -0 are crucial for handling filenames with spaces or special characters
# -P 4 specifies parallel processing with 4 jobs (adjust as needed based on your CPU/GPU)
find . -type f -name "*.mp4" -print0 | xargs -0 -P 4 -n 1 bash -c 'convert_video "$@"' _
