#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <application_name>"
    exit 1
fi

APP_NAME="$(echo "$1" | tr '[:upper:]' '[:lower:]')"

echo "Searching for files related to '$APP_NAME'..."

DIRECTORIES=(
    "$HOME/Library/Application Support"
    "$HOME/Library/Preferences"
    "$HOME/Library/Caches"
    "$HOME/.config"
)

FILES_TO_DELETE=()
for DIR in "${DIRECTORIES[@]}"; do
    if [ -d "$DIR" ]; then
        while IFS= read -r -d $'\0' ITEM; do
            if echo "$ITEM" | grep -qiE "(^|[_./-])${APP_NAME}([_./-]|$)"; then
                FILES_TO_DELETE+=("$ITEM")
            fi
        done < <(find "$DIR" -maxdepth 1 \( -type f -o -type d \) -print0 2>/dev/null)
    fi
done

if [ ${#FILES_TO_DELETE[@]} -eq 0 ]; then
    echo "No files or directories found related to '$APP_NAME'."
    exit 0
fi

# List files and dirs
echo "The following files and directories were found:"
for ITEM in "${FILES_TO_DELETE[@]}"; do
    echo "  $ITEM"
done

# Prompt
read -p "Do you want to delete all of these? (y/N): " CONFIRM
if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Deleting files and directories..."
    for ITEM in "${FILES_TO_DELETE[@]}"; do
        rm -rf "$ITEM"
        echo "Deleted: $ITEM"
    done
else
    echo "No files or directories were deleted."
fi