#!/bin/bash

# --- Script Configuration for Robustness ---
set -euo pipefail # Exit on error, unset variables, and pipe failures
# set -x # Uncomment this line for debugging output (prints commands as they are executed)

# --- FLAC to MP3 Converter (Bash Script) ---
#
# This script converts all FLAC files found in a specified input directory
# and its subdirectories into MP3 files, saving them to a specified output directory
# while preserving the original directory structure.
#
# Usage: ./convert_flac_to_mp3.sh [OPTIONS] <input_directory> <output_directory>
#
# Options:
#   --dry-run      : Simulate the conversion process without actually creating
#                    files or directories, or running ffmpeg.
#
# Arguments:
#   <input_directory>  : The path to the directory containing FLAC files.
#   <output_directory> : The path where the converted MP3 files will be saved.
#
# Requirements:
#   - ffmpeg: Must be installed and accessible in your system's PATH.
#   - realpath: Must be installed and accessible in your system's PATH.
#               (Typically part of GNU coreutils on Linux. macOS users might need `brew install coreutils`)
#   - xargs: Standard utility, usually present.
#
# Example:
#   ./convert_flac_to_mp3.sh "/home/user/music/flac albums" "/home/user/music/mp3 converted"
#   ./convert_flac_to_mp3.sh --dry-run "/home/user/music/flac albums" "/home/user/music/mp3 converted"

# --- Global Variables ---
DRY_RUN=false # Default to false, set to true if --dry-run is present

# --- Function to display usage information ---
usage() {
    echo "Usage: $0 [OPTIONS] <input_directory> <output_directory>"
    echo "Convert FLAC files to MP3 format, preserving directory structure."
    echo ""
    echo "Options:"
    echo "  --dry-run      : Simulate the conversion process without actually creating"
    echo "                   files or directories, or running ffmpeg."
    echo ""
    echo "Arguments:"
    echo "  <input_directory>  : The path to the directory containing FLAC files."
    echo "  <output_directory> : The path where the converted MP3 files will be saved."
    echo ""
    echo "Example:"
    echo "  $0 /path/to/flac_files /path/to/mp3_output"
    echo "  $0 --dry-run /path/to/flac_files /path/to/mp3_output"
    exit 1
}

# --- Parse Command Line Arguments ---
# Check for --dry-run flag
if [[ "$#" -ge 1 && "$1" == "--dry-run" ]]; then
    DRY_RUN=true
    shift # Remove --dry-run from the arguments list
fi

# Check for correct number of remaining arguments
if [ "$#" -ne 2 ]; then
    usage
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

# Check if xargs is installed (should be standard, but good practice)
if ! command -v xargs &> /dev/null; then
    echo "Error: xargs command not found. This script requires 'xargs'."
    echo "Please ensure xargs is installed on your system."
    exit 1
fi

# Resolve input and output directories to their absolute, canonical paths.
# This makes path handling consistent and robust against symbolic links or relative paths.
# Export them so they are available in the subshell created by 'xargs'.
export INPUT_DIR=$(realpath "$1")
export OUTPUT_DIR=$(realpath "$2")

# Check if resolved input directory exists
if [ ! -d "$INPUT_DIR" ]; then
    echo "Error: Input directory '$INPUT_DIR' does not exist or is not a directory."
    exit 1
fi

# Create the output directory if it doesn't exist.
# mkdir -p handles creation of parent directories and doesn't error if it already exists.
if [ "$DRY_RUN" = true ]; then
    echo "Dry run: Would create output directory if it didn't exist: '$OUTPUT_DIR'"
else
    mkdir -p "$OUTPUT_DIR"
fi


echo "Starting FLAC to MP3 conversion..."
if [ "$DRY_RUN" = true ]; then
    echo "*** DRY RUN MODE ENABLED *** No actual files will be created or modified."
fi
echo "Input Directory (resolved): $INPUT_DIR"
echo "Output Directory (resolved): $OUTPUT_DIR"
echo "--------------------------------------------------"

# Define a function to process a single FLAC file.
# This function will be called by 'xargs' for each file found.
convert_single_file() {
    local FLAC_FILEPATH="$1" # The input FLAC file path passed by xargs

    # Ensure FLAC_FILEPATH is an absolute and canonical path.
    FLAC_FILEPATH_CANONICAL=$(realpath "$FLAC_FILEPATH")

    # Calculate the relative path of the FLAC file from the input directory.
    # realpath --relative-to is the most robust way to get this.
    RELATIVE_PATH=$(realpath --relative-to="$INPUT_DIR" "$FLAC_FILEPATH_CANONICAL")

    # Construct the output filename by replacing the .flac extension with .mp3.
    MP3_FILENAME="${RELATIVE_PATH%.flac}.mp3"

    # Construct the full output path by combining the resolved output directory
    # with the newly calculated relative MP3 filename.
    # The original script had an extra "$INPUT_BASENAME/" in the path,
    # which would create a redundant directory under OUTPUT_DIR.
    # Changed from: OUTPUT_FILEPATH="${OUTPUT_DIR}/${INPUT_BASENAME}/${MP3_FILENAME}"
    # To:
    OUTPUT_FILEPATH="${OUTPUT_DIR}/${MP3_FILENAME}"

    echo "Processing: '$FLAC_FILEPATH_CANONICAL'"
    echo "Would save to:  '$OUTPUT_FILEPATH'"

    # Create the necessary subdirectory structure in the output directory.
    if [ "$DRY_RUN" = true ]; then
        echo "Dry run: Would create directory: '$(dirname "$OUTPUT_FILEPATH")'"
    else
        mkdir -p "$(dirname "$OUTPUT_FILEPATH")"
    fi

    # Execute the ffmpeg command for conversion.
    # We suppress output to keep the main script clean, but errors will still be reported by 'set -euo pipefail'.
    if [ "$DRY_RUN" = true ]; then
        echo "Dry run: Would execute ffmpeg command:"
        echo "ffmpeg -i \"$FLAC_FILEPATH_CANONICAL\" -map 0:a:0 -codec:a libmp3lame -b:a 320k -y \"$OUTPUT_FILEPATH\""
    else
        ffmpeg -i "$FLAC_FILEPATH_CANONICAL" -map 0:a:0 -codec:a libmp3lame -b:a 320k -y "$OUTPUT_FILEPATH" >/dev/null 2>&1

        # Check the exit status of the ffmpeg command.
        if [ $? -eq 0 ]; then
            echo "Successfully converted: '$MP3_FILENAME'"
        else
            # If ffmpeg fails, print a more specific error message.
            # Note: 'set -e' will cause the script to exit on the first ffmpeg failure.
            echo "Error converting: '$FLAC_FILEPATH_CANONICAL'. Check ffmpeg output for details (remove >/dev/null 2>&1 to see)."
        fi
    fi
    echo "--------------------------------------------------"
}

# Export the function so xargs can find it.
export -f convert_single_file
export INPUT_DIR
export OUTPUT_DIR
export DRY_RUN # Export DRY_RUN so the function can access it

# Find all .flac files recursively starting from the resolved input directory.
# Pipe the null-delimited list of files to 'xargs -0', which then executes
# the 'bash -c' command (which calls our defined function) for each file.
find "$INPUT_DIR" -type f -name "*.flac" -print0 | sort -zV | xargs -0 -I {} bash -c 'convert_single_file "$@"' _ {}

echo "Conversion process completed."
if [ "$DRY_RUN" = true ]; then
    echo "This was a DRY RUN. No files were actually converted or created."
fi
