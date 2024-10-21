#!/bin/bash

# Check if exactly two arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <string_to_replace> <replacement_string>"
    exit 1
fi

STRING_TO_REPLACE=$1
REPLACEMENT_STRING=$2

# Find and replace the string in all files in the current directory
for file in $(find . -maxdepth 1 -type f); do
    echo "Do you want to process $file? (y/n)"
    read answer
    if [ "$answer" != "${answer#[Yy]}" ]; then
        sed -i "s/$STRING_TO_REPLACE/$REPLACEMENT_STRING/g" "$file"
        echo "Processed $file"
    else
        echo "Skipped $file"
    fi
done

echo "Replacement complete!"

