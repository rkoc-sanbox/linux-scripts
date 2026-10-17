#!/usr/bin/env bash
WATCH_DIR="$HOME/Aquila"
REMOTE="aquilahightech:Aquila"

# Run an initial copy to make sure everything is in sync
rclone copy "$WATCH_DIR" "$REMOTE"

# Continuously watch for changes and upload immediately when they occur
inotifywait -m -r -e modify,create,delete,move "$WATCH_DIR" |
while read -r directory event filename; do
    rclone copy "$WATCH_DIR" "$REMOTE"
    echo "Synced changes to Google Drive at $(date)"
done

