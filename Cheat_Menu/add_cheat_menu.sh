#!/usr/bin/env bash

# add_cheat_menu.sh
# Properly append Cheat_Menu plugin to plugins.js

# Get script's own directory
BASEDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Find plugins.js starting from script directory
if [ -f "$BASEDIR/plugins.js" ]; then
  FILE="$BASEDIR/plugins.js"
elif [ -f "$BASEDIR/js/plugins.js" ]; then
  FILE="$BASEDIR/js/plugins.js"
elif [ -f "$BASEDIR/www/js/plugins.js" ]; then
  FILE="$BASEDIR/www/js/plugins.js"
else
  echo "Error: plugins.js not found." >&2
  exit 1
fi

# Move into directory of plugins.js for simpler relative paths
cd "$(dirname "$FILE")"
FILE="plugins.js"

# Check if Cheat_Menu already exists
if grep -q '"name":"Cheat_Menu"' "$FILE"; then
  echo "Cheat_Menu already exists in $FILE."
  tail -n5 "$FILE"
  exit 0
fi

# Backup
cp "$FILE" "${FILE}.bak" || { echo "Backup failed" >&2; exit 1; }

echo "Adding Cheat_Menu to $FILE (backup at ${FILE}.bak)"

# Step 1: Insert Cheat_Menu before final ];
sed -i '/^\s*];/i {"name":"Cheat_Menu","status":true,"description":"","parameters":{}}' "$FILE" || { echo "Failed to insert Cheat_Menu." >&2; exit 1; }

# Step 2: Add a comma at the end of the line before Cheat_Menu
# Find the line number where Cheat_Menu was inserted
cheat_menu_line=$(grep -n '"name":"Cheat_Menu"' "$FILE" | cut -d: -f1)
if [ -n "$cheat_menu_line" ]; then
  prev_line=$((cheat_menu_line - 1))
  sed -i "${prev_line}s/}$/},/" "$FILE" || { echo "Failed to add comma to previous line." >&2; exit 1; }
else
  echo "Could not find Cheat_Menu after insertion." >&2
  exit 1
fi

echo "Insertion successful. Last few lines now:"
tail -n5 "$FILE"
