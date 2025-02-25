#!/bin/bash

##########################################################################################
## Author: Alicia Garrido Peña
## Date: 02/25/2025
## Description: Script to sync your Thunderbird configuration into Nextcloud
## Warning: If Thunderbird is not installed in snap, change the path to the corresponding one.
##########################################################################################
# Ask the user whether they are using the Snap version or the local version of Thunderbird
echo "Select Thunderbird installation type:"
echo "1) Snap version"
echo "0) Local version"
read -p "Enter your choice (1 for Snap, 0 for Local): " choice

# Define paths based on user input
if [ "$choice" == "1" ]; then
    THUNDERBIRD_DIR="$HOME/snap/thunderbird/common/.thunderbird"
    echo "Using Thunderbird Snap version at: $THUNDERBIRD_DIR"
elif [ "$choice" == "0" ]; then
    THUNDERBIRD_DIR="$HOME/.thunderbird"
    echo "Using Thunderbird local version at: $THUNDERBIRD_DIR"
else
    echo "Invalid selection. Please run the script again and select 1 or 0."
    exit 1
fi

# Define Nextcloud directory
NEXTCLOUD_DIR="$HOME/Nextcloud/ThunderbirdConfig"

# Find the default profile from profiles.ini
PROFILE_NAME=$(awk -F= '/^\[Profile/,/^$/ {if ($1 == "Path") path=$2; if ($1 == "Default" && $2 == "1") print path}' "$THUNDERBIRD_DIR/profiles.ini")

# Ensure we found the correct profile
if [ -z "$PROFILE_NAME" ]; then
    echo "Error: Could not determine the default Thunderbird profile."
    exit 1
fi

PROFILE_PATH="$THUNDERBIRD_DIR/$PROFILE_NAME"
echo "Detected profile: $PROFILE_NAME"

# Create Nextcloud directory if it doesn't exist
mkdir -p "$NEXTCLOUD_DIR"
mkdir -p "$NEXTCLOUD_DIR/msgFilters"

# List of configuration files to sync (including tags.json)
FILES_TO_SYNC=("prefs.js" "calendar-data" "key4.db" "logins.json" "cert9.db" "abook.sqlite")

# Sync main configuration files
for FILE in "${FILES_TO_SYNC[@]}"; do
    if [ -e "$NEXTCLOUD_DIR/$FILE" ]; then
        echo "Using Nextcloud version of: $FILE"
        rm -rf "$PROFILE_PATH/$FILE"
        ln -s "$NEXTCLOUD_DIR/$FILE" "$PROFILE_PATH/$FILE"
    elif [ -e "$PROFILE_PATH/$FILE" ]; then
        echo "Moving $FILE to Nextcloud..."
        mv "$PROFILE_PATH/$FILE" "$NEXTCLOUD_DIR/"
        ln -s "$NEXTCLOUD_DIR/$FILE" "$PROFILE_PATH/$FILE"
    else
        echo "File $FILE missing locally. Checking in Nextcloud..."
        if [ -e "$NEXTCLOUD_DIR/$FILE" ]; then
            echo "Using Nextcloud version for missing file: $FILE"
            ln -s "$NEXTCLOUD_DIR/$FILE" "$PROFILE_PATH/$FILE"
        else
            echo "Skipping $FILE (not found anywhere)"
        fi
    fi
done

# Detect the correct Thunderbird profile path dynamically
PROFILE_PATH=$(find $THUNDERBIRD_DIR -maxdepth 1 -type d -name "*.default*" | head -n 1)

if [ -z "$PROFILE_PATH" ]; then
    echo "Error: No Thunderbird profile found!"
    exit 1
fi

echo "Detected Thunderbird profile: $PROFILE_PATH"

# Search and sync email filter rules (`msgFilterRules.dat`)
echo "Searching for email filters..."
ACCOUNT_DIRS=("$PROFILE_PATH/ImapMail/"* "$PROFILE_PATH/Mail/"*)

# Ensure directories exist before proceeding
for ACCOUNT_DIR in "${ACCOUNT_DIRS[@]}"; do
    [ ! -d "$ACCOUNT_DIR" ] && continue  # Skip non-existing directories

    ACCOUNT_NAME=$(basename "$ACCOUNT_DIR")
    FILTER_FILE="$ACCOUNT_DIR/msgFilterRules.dat"
    NEXTCLOUD_FILTER="$NEXTCLOUD_DIR/msgFilters/$ACCOUNT_NAME.dat"

    # Ensure Nextcloud filter directory exists
    mkdir -p "$NEXTCLOUD_DIR/msgFilters"

    if [ -e "$NEXTCLOUD_FILTER" ]; then
        echo "Using Nextcloud filters for account: $ACCOUNT_NAME"
        rm -f "$FILTER_FILE"
        ln -s "$NEXTCLOUD_FILTER" "$FILTER_FILE"
    else
        echo "No filters found for $ACCOUNT_NAME in Nextcloud. Creating empty filter file."
        touch "$NEXTCLOUD_FILTER"
        ln -s "$NEXTCLOUD_FILTER" "$FILTER_FILE"
    fi
done

echo "Thunderbird configuration sync setup complete. 🚀"
