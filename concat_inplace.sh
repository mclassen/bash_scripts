#!/bin/bash

# Check if two arguments were provided
if [ "$#" -ne 2 ]; then
    echo "Concatenates <sourcefile1> into <sourcefile2> in-place, so that file 1 contains both files, without requiring extra disk space.
Note: only useful for files over 1GB size.
Usage: $0 <sourcefile1> <sourcefile2>"
    exit 1
fi

# Assign command line arguments to variables
file1="$1"
file2="$2"

# Check if both files exist
if [ ! -f "$file1" ]; then
    echo "Error: File $file1 does not exist."
    exit 1
fi

if [ ! -f "$file2" ]; then
    echo "Error: File $file2 does not exist."
    exit 1
fi

# Calculate the size of the first file in GB
size1=$(stat --format="%s" "$file1")
size1GB=$((($size1 + 1073741823) / 1073741824))

# Calculate the size of the second file in GB, rounded up
size2=$(stat --format="%s" "$file2")
size2GB=$((($size2 + 1073741823) / 1073741824)) # Adding 1073741823 bytes to round up to the nearest GB

# Display the sizes
echo "Size of $file1: $size1GB GB"
echo "Size of $file2: $size2GB GB"

# Append content from the second file to the first file, and truncate the second file accordingly
for ((i=$size2GB-1; i>=0; i--)); do
  echo "Copying block $((i+1)) of $size2GB from $file2 to $file1"
  
  # Copy one block from file2 to the end of file1
  dd if="$file2" of="$file1" bs=1G skip="$i" seek="$i" count=1 oflag=append conv=notrunc
  
  # Truncate the last block from file2
  dd if=/dev/zero of="$file2" bs=1G count=0 seek="$i"
done

echo "In-place concatenation complete."