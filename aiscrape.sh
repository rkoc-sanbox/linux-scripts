#!/usr/bin/env bash
# save as export_project.sh in your repo root and run: bash export_project.sh > project_dump.txt

# Exclude big/unnecessary folders
EXCLUDES="./.git ./node_modules ./vendor ./bin ./dist ./build"

# Print directory tree first (for context)
echo "===== PROJECT TREE ====="
tree -I '.git|node_modules|vendor|bin|dist|build'
echo
echo "===== FILE CONTENTS ====="

# Find relevant files and print with headers
find . \
  -type f \
  \( -name '*.go' -o -name '*.mod' -o -name '*.md' -o -name '*.yaml' -o -name '*.yml' -o -name '*.json' -o -name '*.kt' \) \
  | while read -r file; do
      echo
      echo "---------- FILE: $file ----------"
      cat "$file"
      echo
    done
