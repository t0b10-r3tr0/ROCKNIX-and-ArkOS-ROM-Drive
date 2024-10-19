#!/bin/bash

# Function to display usage information
show_usage() {
    echo "Usage: $0 [-r] directory old_extension new_extension"
    echo "Example: $0 /path/to/directory .zip .dosz -r"
    echo "Note: The -r switch is optional and enables recursive file search."
    exit 1
}

# Check if the correct number of arguments are passed
if [[ "$#" -lt 3 ]]; then
    echo "Error: Missing required arguments."
    show_usage
fi

# Set default values for variables
recursive="false"

# Parse options
while getopts ":r" opt; do
    case $opt in
        r)
            recursive="true"
            ;;
        *)
            echo "Invalid option: -$OPTARG" >&2
            show_usage
            ;;
    esac
done

# Shift the processed options, and take the positional arguments
shift $((OPTIND -1))
directory="$1"
old_extension="$2"
new_extension="$3"

# Validate required arguments
if [[ -z "$directory" || -z "$old_extension" || -z "$new_extension" ]]; then
    echo "Error: Missing required arguments."
    show_usage
fi

# Check if the directory exists
if [[ ! -d "$directory" ]]; then
    echo "Error: The specified directory does not exist."
    show_usage
fi

# Function to rename files with the old extension to the new extension
rename_files() {
    local dir="$1"
    local old_ext="$2"
    local new_ext="$3"
    local recursive="$4"
    local count=0

    if [[ "$recursive" == "true" ]]; then
        find "$dir" -type f -name "*$old_ext" | while read -r file; do
            mv "$file" "${file%$old_ext}$new_ext"
            echo "Renamed $file to ${file%$old_ext}$new_ext"
            ((count++))
        done
    else
        find "$dir" -maxdepth 1 -type f -name "*$old_ext" | while read -r file; do
            mv "$file" "${file%$old_ext}$new_ext"
            echo "Renamed $file to ${file%$old_ext}$new_ext"
            ((count++))
        done
    fi

    echo ""
    echo "Operation completed. Modified $count files."
}

# Rename files
rename_files "$directory" "$old_extension" "$new_extension" "$recursive"
