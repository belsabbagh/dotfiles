#!/bin/zsh

# --- Script Configuration for Robustness ---
setopt ERR_EXIT NO_UNSET PIPE_FAIL
# set -x # Uncomment this line for debugging output

# --- FLAC to MP3 Converter (Zsh Script - Recursive Globbing) ---
#
# This script converts all FLAC files found in a specified input directory
# and its subdirectories into MP3 files, saving them to a specified output directory
# while preserving the original directory structure.
#
# Usage: ./convert_flac_to_mp3_zsh_glob.zsh [-d|--dry-run] <input_directory> <output_directory>
#
# Arguments:
#   -d, --dry-run      : Optional. If present, the script will only show what
#                        it would do without actually performing conversions
#                        or creating directories.
#   <input_directory>  : The path to the directory containing FLAC files.
#   <output_directory> : The path where the converted MP3 files will be saved.
#
# Requirements:
#   - ffmpeg: Must be installed and accessible in your system's PATH.
#   - realpath: Must be installed and accessible in your system's PATH.
#
# Example:
#   ./convert_flac_to_mp3_zsh_glob.zsh "/home/user/music/flac albums" "/home/user/music/mp3 converted"
#   ./convert_flac_to_mp3_zsh_glob.zsh --dry-run "/home/user/music/flac albums" "/home/user/music/mp3 converted"
#

# Initialize dry run flag
local DRY_RUN=false

# Parse arguments
# Check for dry run flag
if [[ "$1" == "-d" || "$1" == "--dry-run" ]]; then
    DRY_RUN=true
    shift # Remove the flag from the arguments list
fi

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

# Check for correct number of remaining arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 [-d|--dry-run] <input_directory> <output_directory>"
    echo "Example: $0 /path/to/flac_files /path/to/mp3_output"
    echo "Example (Dry Run): $0 --dry-run /path/to/flac_files /path/to/mp3_output"
    exit 1
fi

# Resolve input and output directories to their absolute, canonical paths.
local INPUT_DIR=$(realpath "$1")
local OUTPUT_DIR=$(realpath "$2")
local INPUT_BASENAME=$(basename "$INPUT_DIR") # Base name of the input directory

# Check if resolved input directory exists
if [ ! -d "$INPUT_DIR" ]; then
    echo "Error: Input directory '$INPUT_DIR' does not exist or is not a directory."
    exit 1
fi

# Create the output directory if it doesn't exist (only if not in dry run mode).
if $DRY_RUN; then
    echo "Dry Run: Would create output base directory '$OUTPUT_DIR' if it didn't exist."
else
    mkdir -p "$OUTPUT_DIR"
fi

echo "Starting FLAC to MP3 conversion using Zsh globbing..."
echo "Input Directory (resolved): $INPUT_DIR"
echo "Output Directory (resolved): $OUTPUT_DIR"
if $DRY_RUN; then
    echo "--- DRY RUN MODE ACTIVE --- No files will be converted or directories created."
fi
echo "--------------------------------------------------"

# Enable recursive globbing (globstar) and nullglob (handle no matches gracefully)
setopt GLOBSTAR NULL_GLOB

# Loop through all FLAC files found recursively
for FLAC_FILEPATH_CANONICAL in "${INPUT_DIR}"/**/*.flac; do
    # Skip if the glob found no files (due to NULL_GLOB)
    [[ -e "$FLAC_FILEPATH_CANONICAL" ]] || continue

    # Calculate the relative path of the FLAC file from the input directory.
    RELATIVE_PATH=$(realpath --relative-to="$INPUT_DIR" "$FLAC_FILEPATH_CANONICAL")

    # Construct the output filename by replacing the .flac extension with .mp3.
    MP3_FILENAME="${RELATIVE_PATH%.flac}.mp3"

    # Construct the full output path
    OUTPUT_FILEPATH="${OUTPUT_DIR}/${INPUT_BASENAME}/${MP3_FILENAME}"

    # Create the necessary subdirectory structure in the output directory (only if not in dry run mode).
    local OUTPUT_SUBDIR="$(dirname "$OUTPUT_FILEPATH")"
    if $DRY_RUN; then
        echo "Dry Run: Would create directory: '$OUTPUT_SUBDIR'"
    else
        mkdir -p "$OUTPUT_SUBDIR"
    fi

    echo "Processing: '$FLAC_FILEPATH_CANONICAL'"
    echo "Target MP3: '$OUTPUT_FILEPATH'"

    if $DRY_RUN; then
        echo "Dry Run: Would convert '$FLAC_FILEPATH_CANONICAL' to '$OUTPUT_FILEPATH'"
    else
        # Perform the conversion
        ffmpeg -i "$FLAC_FILEPATH_CANONICAL" -map 0:a:0 -codec:a libmp3lame -b:a 320k -y "$OUTPUT_FILEPATH" >/dev/null 2>&1

        if [ $? -eq 0 ]; then
            echo "Successfully converted: '$MP3_FILENAME'"
        else
            echo "Error converting: '$FLAC_FILEPATH_CANONICAL'. Check ffmpeg output for details."
        fi
    fi
    echo "--------------------------------------------------"
done

echo "Conversion process completed."
if $DRY_RUN; then
    echo "Remember: This was a DRY RUN. No actual files were converted or directories created."
fi

