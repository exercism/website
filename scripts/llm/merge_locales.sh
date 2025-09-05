#!/bin/bash

# Create merged locale.yaml from locales.bk directory
# This script merges all YAML files and removes the "en" prefix

OUTPUT_FILE="config/locale.yaml"
LOCALES_DIR="config/locales.bk"

# Remove existing output file
rm -f "$OUTPUT_FILE"

echo "Merging locale files from $LOCALES_DIR into $OUTPUT_FILE"

# Process all .yml files in locales.bk directory
find "$LOCALES_DIR" -name "*.yml" -type f | while read -r file; do
    echo "Processing $file"
    
    # Extract just the en: section and remove the "en:" prefix
    # Using yq would be ideal, but falling back to sed/awk for broader compatibility
    if command -v yq &> /dev/null; then
        # If yq is available, use it for proper YAML parsing
        yq eval '.en // {}' "$file" >> "$OUTPUT_FILE"
    else
        # Fallback: use awk to extract content under "en:" key
        awk '
        /^en:/ { in_en=1; next }
        /^[a-zA-Z]/ && !/^  / && in_en { in_en=0 }
        in_en && /^  / { print substr($0, 3) }
        ' "$file" >> "$OUTPUT_FILE"
    fi
done

echo "Merge complete. Output written to $OUTPUT_FILE"
echo "File size: $(wc -l < "$OUTPUT_FILE") lines"
