#!/bin/bash

# Check if arguments are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <start_index> <end_index>"
    exit 1
fi

start=$1
end=$2

# Remove existing inputFile
rm -f inputFile

# Generate the file
for ((i=start; i<=end; i++)); do
    random=$((RANDOM % 1000))
    echo "$i, $random" >> inputFile
done

echo "Generated inputFile with $((end - start + 1)) entries"
