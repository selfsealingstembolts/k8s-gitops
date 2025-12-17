#!/bin/bash

find . -type f \( -name '*.yaml' -o -name '*.yml' \) -print0 | while IFS= read -r -d $'\0' file; do
  # Check if file is non-empty and first line does NOT start with ---
  if [ -s "$file" ] && ! head -n 1 "$file" | grep -q '^---'; then
    echo "Adding header to: $file"
    # GNU sed: -i modifies in place directly
    sed -i '1i ---' "$file"
  elif [ ! -s "$file" ]; then
     # Handle empty files: just add the header
     echo "Adding header to empty file: $file"
     echo "---" > "$file"
  else
     echo "Skipping: $file"
  fi
done
