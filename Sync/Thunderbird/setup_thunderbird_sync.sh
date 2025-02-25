#!/bin/bash

##########################################################################################
## Author: Alicia Garrido Peña
## Date: 02/25/2025
## Description: Script to sync your Thunderbird configuration into Nextcloud
## Warning: If Thunderbird is not installed in snap, change the path to the corresponding one.
##########################################################################################


# Define paths
NEXTCLOUD_DIR="$HOME/Nextcloud/ThunderbirdConfig"
THUNDERBIRD_DIR="$HOME/snap/thunderbird/common/.thunderbird"

# Find the active profile marked as Default=1
PROFILE_NAME=$(awk -F= '/^\[Profile/,/^$/ {if ($1 == "Path") path=$2; if ($1 == "Default" && $2 == "1") print path}' "$THUNDERBIRD_DIR/profiles.ini")

# Ensure profile was found
if [ -z "$PROFILE_NAME" ]; then
    echo "Error: Could not determine the default Thunderbird profile from profiles.ini!"
    exit 1
fi

PROFILE_PATH="$THUNDERBIRD_DIR/$PROFILE_NAME"
echo "Detected default Thunderbird profile: $PROFILE_NAME"

# Ensure Nextcloud directory exists
mkdir -p "$NEXTCLOUD_DIR"

# List of files/folders to sync (excluding emails)
FILES_TO_SYNC=("prefs.js" "calendar-data" "key4.db" "logins.json" "panacea.dat" "cert9.db" "abook.sqlite" "ldap_2.servers")

# Move and create symlinks for main config files
for FILE in "${FILES_TO_SYNC[@]}"; do
    if [ -e "$PROFILE_PATH/$FILE" ]; then
        if [ ! -e "$NEXTCLOUD_DIR/$FILE" ]; then
            mv "$PROFILE_PATH/$FILE" "$NEXTCLOUD_DIR/"
        fi
        rm -rf "$PROFILE_PATH/$FILE"
        ln -s "$NEXTCLOUD_DIR/$FILE" "$PROFILE_PATH/$FILE"
        echo "Linked $FILE"
    else
        echo "Skipping $FILE (not found)"
    fi
done

# Sync message filters (`msgFilterRules.dat`) from each email account
echo "Looking for message filters..."
mkdir -p "$NEXTCLOUD_DIR/msgFilters"

for ACCOUNT_DIR in "$PROFILE_PATH/ImapMail/"* "$PROFILE_PATH/Mail/"*; do
    FILTER_FILE="$ACCOUNT_DIR/msgFilterRules.dat"
    ACCOUNT_NAME=$(basename "$ACCOUNT_DIR")

    if [ -e "$FILTER_FILE" ]; then
        echo "Syncing filters for account: $ACCOUNT_NAME"

        # Move to Nextcloud if not already moved
        if [ ! -e "$NEXTCLOUD_DIR/msgFilters/$ACCOUNT_NAME.dat" ]; then
            mv "$FILTER_FILE" "$NEXTCLOUD_DIR/msgFilters/$ACCOUNT_NAME.dat"
        fi

        # Remove old file and create symlink
        rm -f "$FILTER_FILE"
        ln -s "$NEXTCLOUD_DIR/msgFilters/$ACCOUNT_NAME.dat" "$FILTER_FILE"
    fi
done

echo "Thunderbird configuration sync setup complete!"
