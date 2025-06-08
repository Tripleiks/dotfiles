#!/bin/bash

# Helper script for encrypting files with age

# Check if age is installed
if ! command -v age &> /dev/null; then
    echo "Error: age is not installed. Please install it first."
    exit 1
fi

# Check if arguments are provided
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <file> [recipient]"
    echo "  file: The file to encrypt"
    echo "  recipient: Optional recipient public key (default: use passphrase)"
    exit 1
fi

FILE="$1"
OUTPUT="${FILE}.age"
RECIPIENT="$2"

# Check if file exists
if [ ! -f "$FILE" ]; then
    echo "Error: File '$FILE' not found."
    exit 1
fi

# Encrypt the file
if [ -z "$RECIPIENT" ]; then
    echo "Encrypting '$FILE' with passphrase..."
    age -p -o "$OUTPUT" "$FILE"
else
    echo "Encrypting '$FILE' for recipient '$RECIPIENT'..."
    age -r "$RECIPIENT" -o "$OUTPUT" "$FILE"
fi

echo "Encryption complete: '$OUTPUT'"
