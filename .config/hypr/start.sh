#!/bin/sh

# Redirect all output to start.log (overwriting previous logs)
exec > "$HOME/start.log" 2>&1

# Function to log and time each command
run_and_time() {
    echo "[$(date +'%H:%M:%S')] Starting: $1"
    # /usr/bin/time -f "Took: %E" $1 & 
    # Note: Since most of these are backgrounded (&), 
    # we use a subshell to capture the duration of the launch itself.
    start_time=$(date +%s%N)
    "$@" &
    end_time=$(date +%s%N)
    
    # Calculate duration in milliseconds (simple shell math)
    duration=$(( (end_time - start_time) / 1000000 ))
    echo "  -> Launched in ${duration}ms"
}

echo "--- Hyprland Startup: $(date) ---"

run_and_time qs -c caelestia
# run_and_time systemctl --user start hyprpaper
# run_and_time systemctl --user start hypridle
# run_and_time systemctl --user start hyprpolkitagent
run_and_time systemctl --user start xdg-desktop-portal-hyprland
run_and_time ssh-agent
run_and_time copyq
run_and_time kdeconnect-indicator
run_and_time dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

echo "--- All processes dispatched ---"
