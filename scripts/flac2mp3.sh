#!/bin/zsh

# --- Script Configuration for Robustness ---
setopt ERR_EXIT NO_UNSET PIPE_FAIL
# set -x # Uncomment this line for debugging output

# --- FLAC to MP3 Converter (Zsh Script - find -exec) ---
#
# This script converts all FLAC files found in a specified input directory
# and its subdirectories into MP3 files, saving them to a specified output directory
# while preserving the original directory structure.
#
# Usage: ./convert_flac_to_mp3_find_exec.zsh <input_directory> <output_directory>
#
# Arguments:
#   <input_directory>  : The path to the directory containing FLAC files.
#   <output_directory> : The path where the converted MP3 files will be saved.
#
# Requirements:
#   - ffmpeg: Must be installed and accessible in your system's PATH.
#   - realpath: Must be installed and accessible in your system's PATH.
#
# Example:
#   ./convert_flac_to_mp3_find_exec.zsh "/home/user/music/flac albums" "/home/user/music/mp3 converted"
#

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "Error: ffmpeg is not installed. Please install it to use this script."
    exit 1
fi

# Check if realpath is installed
if ! command -v realpath &> /dev/null; then
    echo "Error: realpath command not found. This script requires 'realpath' for robust path handling."
    echo "Please install it (e.g., 'sudo apt-get install realpath' on Debian/Ubuntu, or 'brew install coreutils' on macOS)."
    exit 1
fi

# Check for correct number of arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input_directory> <output_directory>"
    echo "Example: $0 /path/to/flac_files /path/to/mp3_output"
    exit 1
fi

# Resolve input and output directories to their absolute, canonical paths.
export INPUT_DIR=$(realpath "$1") # Export for the subshell
export OUTPUT_DIR=$(realpath "$2") # Export for the subshell
export INPUT_BASENAME=$(basename "$INPUT_DIR") # Export for the subshell

# Check if resolved input directory exists
if [ ! -d "$INPUT_DIR" ]; then
    echo "Error: Input directory '$INPUT_DIR' does not exist or is not a directory."
    exit 1
fi

# Create the output directory if it doesn't exist.
mkdir -p "$OUTPUT_DIR"

echo "Starting FLAC to MP3 conversion using find -exec..."
echo "Input Directory (resolved): $INPUT_DIR"
echo "Output Directory (resolved): $OUTPUT_DIR"
echo "--------------------------------------------------"

# Define a helper function to be called by find -exec.
# This function will be executed in a new subshell for each file.
exec_convert_single_file() {
    local FLAC_FILEPATH_CANONICAL=$(realpath "$1")

    local RELATIVE_PATH=$(realpath --relative-to="$INPUT_DIR" "$FLAC_FILEPATH_CANONICAL")
    local MP3_FILENAME="${RELATIVE_PATH%.flac}.mp3"
    local OUTPUT_FILEPATH="${OUTPUT_DIR}/${INPUT_BASENAME}/${MP3_FILENAME}"

    mkdir -p "$(dirname "$OUTPUT_FILEPATH")"

    echo "Converting: '$FLAC_FILEPATH_CANONICAL'"
    echo "Saving to:  '$OUTPUT_FILEPATH'"

    ffmpeg -i "$FLAC_FILEPATH_CANONICAL" -map 0:a:0 -codec:a libmp3lame -b:a 320k -y "$OUTPUT_FILEPATH" >/dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo "Successfully converted: '$MP3_FILENAME'"
    else
        echo "Error converting: '$FLAC_FILEPATH_CANONICAL'. Check ffmpeg output for details."
        # find -exec doesn't stop on errors by default, so we explicitly exit the subshell.
        return 1
    fi
    echo "--------------------------------------------------"
}

# Export the function so `find -exec zsh -c '...'` can see it.
export -f exec_convert_single_file

# Find all .flac files and execute the helper function for each.
# Using `+` instead of `;` tells find to pass multiple files to a single invocation
# of `zsh -c` if possible, which can be more efficient.
find "$INPUT_DIR" -type f -name "*.flac" -exec zsh -c 'exec_convert_single_file "$@"' _ {} +

echo "Conversion process completed."
