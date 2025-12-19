#!/bin/bash
# Automatic GPU Profile + PWM Fan Switcher
# Detects running Steam games and switches LACT profiles + fan speed
# Must run as root

# --- Config ---
LACT_CLI="/usr/bin/lact"        # Adjust if lact CLI path is different
GPU_ID="1002:73DF-1462:3990-0000:30:00.0"

PROFILE_QUIET="RX 6750 XT Gaming X Trio - Quiet"
PROFILE_PERF="RX 6750 XT Gaming X Trio - Performance"

# Fan speeds
PWM_MAX=255
FAN_DESKTOP=$((PWM_MAX * 35 / 100))   # Quiet curve
FAN_GAMING=$((PWM_MAX * 65 / 100))    # Fixed 65% for gaming

# Check interval
INTERVAL=5

# --- Initialization ---
[[ $EUID -ne 0 ]] && { echo "Run as root"; exit 1; }

# Function to get all installed Steam games for a user
get_installed_steam_games() {
    local steam_dir="$1"
    
    find "$steam_dir" -type f -name "appmanifest_*.acf" | while read -r manifest; do
        grep -m 1 'name' "$manifest" | cut -d '"' -f 4
    done
}

# --- Function to get non-root users ---
get_non_root_users() {
    awk -F: '$3 >= 1000 {print $1}' /etc/passwd
}

# --- Function to dynamically detect usable PWM files ---
detect_pwm_file() {
    local PWM_FILE=""
    local PWM_DIR
    local TEMP_FILE

    for PWM_DIR in /sys/class/drm/card*/device/hwmon/*; do
        for PWM in "$PWM_DIR"/pwm*; do
            if [[ -f "$PWM" && -w "$PWM" ]]; then
                TEMP_FILE=$(mktemp)
                echo 128 > "$PWM" 2>$TEMP_FILE
                if [ $? -eq 0 ]; then
                    PWM_FILE="$PWM"
                    break 2
                fi
            fi
        done
    done

    if [[ -n "$PWM_FILE" ]]; then
        echo "$PWM_FILE"
        return 0
    else
        echo "No valid PWM file found."
        return 1
    fi
}

# --- Function to check if the value to be written is valid ---
is_valid_pwm_value() {
    local value=$1
    if [[ "$value" -ge 0 && "$value" -le 255 ]]; then
        return 0
    else
        return 1
    fi
}

# --- Function to check if a Steam game is running ---
check_if_game_is_running() {
    # We now need to check for actual game processes (excluding non-game Steam processes)
    ps aux | grep -E 'gamescope|cs2|steam-launcher|steam-runtime' | grep -v 'grep' | grep -v 'steamwebhelper' | grep -v 'steam-runtime' | grep -v 'steam-launcher' >/dev/null
    return $?
}

# --- Main Loop ---
LAST_STATE="desktop"
CURRENT_PROFILE="$PROFILE_QUIET"  # Start in desktop profile

while true; do
    GAME_RUNNING=false

    # Check if any Steam game is running
    if check_if_game_is_running; then
        GAME_RUNNING=true
        echo "$(date '+%F %T') - Game detected: running"
    else
        echo "$(date '+%F %T') - No game running"
    fi

    # Only switch profiles and fan speed if the game state has changed
    if $GAME_RUNNING && [[ "$LAST_STATE" != "gaming" ]]; then
        echo "$(date '+%F %T') - Switching to Performance profile + 65% fan"

        # Debugging output for lact profile switching
        echo "Switching profile to: $PROFILE_PERF"
        $LACT_CLI cli profile set "$PROFILE_PERF"
        
        # Check if the profile was switched successfully
        if [ $? -eq 0 ]; then
            echo "Profile switched to: $PROFILE_PERF"
        else
            echo "Failed to switch profile to: $PROFILE_PERF"
        fi

        PWM_FILE=$(detect_pwm_file)

        if [[ -n "$PWM_FILE" && "$CURRENT_PROFILE" != "$PROFILE_PERF" ]]; then
            if is_valid_pwm_value "$FAN_GAMING"; then
                echo "Writing $FAN_GAMING to PWM file"
                echo "$FAN_GAMING" > "$PWM_FILE"
            else
                echo "Invalid PWM value: $FAN_GAMING"
            fi
            CURRENT_PROFILE="$PROFILE_PERF"
        fi

        LAST_STATE="gaming"
    elif ! $GAME_RUNNING && [[ "$LAST_STATE" != "desktop" ]]; then
        echo "$(date '+%F %T') - Switching to Quiet profile + 35% fan"

        # Debugging output for lact profile switching
        echo "Switching profile to: $PROFILE_QUIET"
        $LACT_CLI cli profile set "$PROFILE_QUIET"
        
        # Check if the profile was switched successfully
        if [ $? -eq 0 ]; then
            echo "Profile switched to: $PROFILE_QUIET"
        else
            echo "Failed to switch profile to: $PROFILE_QUIET"
        fi

        PWM_FILE=$(detect_pwm_file)

        if [[ -n "$PWM_FILE" && "$CURRENT_PROFILE" != "$PROFILE_QUIET" ]]; then
            if is_valid_pwm_value "$FAN_DESKTOP"; then
                echo "Writing $FAN_DESKTOP to PWM file"
                echo "$FAN_DESKTOP" > "$PWM_FILE"
            else
                echo "Invalid PWM value: $FAN_DESKTOP"
            fi
            CURRENT_PROFILE="$PROFILE_QUIET"
        fi

        LAST_STATE="desktop"
    fi

    # Sleep for the specified interval before checking again
    sleep $INTERVAL
done

