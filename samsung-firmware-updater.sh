#!/bin/bash

# --- Check for root privileges ---
# The script requires root access to use 'mount' and create directories in /mnt/ and /tmp/.
if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root or with sudo."
    echo "Please run the script using 'sudo ./scriptname.sh'"
    exit 1
fi

# Define the URL to scrape for firmware information
URL="https://semiconductor.samsung.com/consumer-storage/support/tools/"

# --- Configuration Variables ---
# Define download directory and expected filename
DOWNLOAD_DIR="/tmp"
ISO_FILENAME="Samsung_Firmware.iso" # A generic name for the downloaded file
ISO_PATH="$DOWNLOAD_DIR/$ISO_FILENAME"
MNT_ISO="/mnt/iso"
TMP_DIR="/tmp/fwupdate"

# --- Error Handling ---
set -e # Exit immediately if a command exits with a non-zero status

# Function to clean up mount points and temporary directories
cleanup() {
    echo "Cleaning up..."
    if mountpoint -q "$MNT_ISO"; then
        umount "$MNT_ISO"
        echo "Unmounted $MNT_ISO."
    fi
    if [ -d "$TMP_DIR" ]; then
        (cd / && rm -rf "$TMP_DIR")
        echo "Removed temporary directory $TMP_DIR."
    fi
    # Optional: remove the downloaded ISO file itself
    # if [ -f "$ISO_PATH" ]; then
    #     rm "$ISO_PATH"
    #     echo "Removed downloaded ISO file."
    # fi
}

trap cleanup EXIT ERR INT TERM

# --- User Input ---
# Ask for the model of your Samsung NVME
read -p "Please enter the model of your Samsung NVME (e.g., 990_PRO): " SSD_MODEL

# Fetch the Samsung Tools page for firmware information
echo "Fetching Samsung Tools page for $SSD_MODEL firmware information..."

# Use curl to fetch the page content and grep to find links ending in .iso containing the model name
LATEST_FIRMWARE_URL=$(curl -sL "$URL" | grep -oP 'https?://download\.semiconductor\.samsung\.com/resources/software-resources/Samsung_SSD_'"$SSD_MODEL"'_.*\.iso' | head -n 1)

if [ -n "$LATEST_FIRMWARE_URL" ]; then
    echo "Found latest firmware ISO URL:"
    echo "$LATEST_FIRMWARE_URL"

    # Extract the firmware version from the URL filename
    FIRMWARE_VERSION=$(basename "$LATEST_FIRMWARE_URL" | grep -oP '[A-Z0-9]+(?=\.iso)')
    echo "Latest online version: $FIRMWARE_VERSION"

    # --- Check the installed firmware version ---
    # DEVICE_PATH="/dev/nvme0n1" # <-- CHANGE THIS TO YOUR DEVICE PATH
    read -p "Please enter the path of your Samsung NVME (e.g., /dev/nvme0n1): " DEVICE_PATH
    if command -v smartctl &> /dev/null; then
        # Get the model of the device
        DEVICE_MODEL=$(smartctl -i "$DEVICE_PATH" | grep 'Device Model' | awk -F: '{print $2}' | sed 's/^ *//g')

        # Check if the device is a Samsung device
        if [[ "$DEVICE_MODEL" != *Samsung* ]]; then
            echo "Error: The device at $DEVICE_PATH is not a Samsung SSD. Exiting."
            exit 1
        fi

        CURRENT_VERSION=$(smartctl -a "$DEVICE_PATH" | grep 'Firmware Version' | awk '{print $NF}')
        echo "Currently installed version on $DEVICE_PATH: $CURRENT_VERSION"

        if [ "$FIRMWARE_VERSION" != "$CURRENT_VERSION" ]; then
            echo "--- UPDATE REQUIRED: New firmware ($FIRMWARE_VERSION) is available! ---"

            # --- Proceed with the update ---
            # Ensure the download directory exists
            mkdir -p "$DOWNLOAD_DIR"

            # Basic URL validation
            if [[ -z "$LATEST_FIRMWARE_URL" || ! "$LATEST_FIRMWARE_URL" =~ ^https?:// ]]; then
                echo "Invalid URL. Exiting."
                exit 1
            fi

            echo "Attempting to download ISO from: $LATEST_FIRMWARE_URL to $ISO_PATH"
            # Download the ISO using curl
            curl -L -o "$ISO_PATH" "$LATEST_FIRMWARE_URL"

            echo "Download complete."

            # --- Mount and extract the ISO ---
            mkdir -p "$MNT_ISO"
            mkdir -p "$TMP_DIR"
            echo "Created directories: $MNT_ISO and $TMP_DIR"

            echo "Mounting ISO: $ISO_PATH"
            mount "$ISO_PATH" "$MNT_ISO"

            echo "Extracting initrd from ISO..."
            cd "$TMP_DIR"
            gzip -dc "$MNT_ISO/initrd" | cpio -idv --no-absolute-filenames

            echo "Extraction complete."

            # --- Ask for confirmation before running fumagician ---
            read -p "Do you want to proceed with running the firmware update utility (fumagician)? (y/n): " confirmation
            if [[ "$confirmation" =~ ^[Yy]$ ]]; then
                FUMAGICIAN_DIR="root/fumagician"
                if [ -d "$FUMAGICIAN_DIR" ]; then
                    echo "Navigating to $FUMAGICIAN_DIR and running fumagician..."
                    cd "$FUMAGICIAN_DIR"
                    sh fumagician
                else
                    echo "Error: Directory $FUMAGICIAN_DIR not found after extraction."
                    exit 1
                fi
            else
                echo "Firmware update cancelled."
                exit 0
            fi

        else
            echo "Your firmware is up to date ($CURRENT_VERSION)."
        fi
    else
        echo "smartctl not found. Cannot compare current installed firmware version."
        echo "Please install smartmontools (e.g., 'emerge smartmontools') to check your current version."
    fi
else
    echo "Could not find a matching firmware ISO link for $SSD_MODEL on the page."
    echo "The website HTML structure might have changed, or the model name is incorrect."
fi

