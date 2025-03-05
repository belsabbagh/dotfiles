#!/bin/zsh

# Check if a directory path is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <directory_path>"
  exit 1
fi

# Resolve the absolute path and directory name
DIR_PATH=$(realpath "$1")
DIR_NAME=$(basename "$DIR_PATH")

# Check if the directory exists
if [ ! -d "$DIR_PATH" ]; then
  echo "Error: Directory '$DIR_PATH' does not exist."
  exit 1
fi

# Create or attach to a tmux session named after the directory
SESSION_NAME="$DIR_NAME"
tmux new-session -d -s "$SESSION_NAME" -c "$DIR_PATH"

# Window 1: Open nvim
tmux rename-window -t "$SESSION_NAME:1" "nvim"
tmux send-keys -t "$SESSION_NAME:1" "nvim" C-m

# Window 2: Terminal in the directory
tmux new-window -t "$SESSION_NAME:2" -n "terminal" -c "$DIR_PATH"

# Window 3: Lazygit
tmux new-window -t "$SESSION_NAME:3" -n "lazygit" -c "$DIR_PATH"
tmux send-keys -t "$SESSION_NAME:3" "lazygit" C-m

# Attach to the session
tmux attach-session -t "$SESSION_NAME"
