#!/bin/bash

# Helper script for decrypting files with age

# Check if age is installed
if ! command -v age &> /dev/null; then
    echo "Error: age is not installed. Please install it first."
    exit 1
fi

# Check if arguments are provided
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <encrypted_file> [identity_file]"
    echo "  encrypted_file: The .age file to decrypt"
    echo "  identity_file: Optional path to identity/private key file"
    exit 1
fi

ENCRYPTED_FILE="$1"
IDENTITY_FILE="$2"
OUTPUT="${ENCRYPTED_FILE%.age}"

# Check if file exists
if [ ! -f "$ENCRYPTED_FILE" ]; then
    echo "Error: File '$ENCRYPTED_FILE' not found."
    exit 1
fi

# Check if file has .age extension
if [[ "$ENCRYPTED_FILE" != *.age ]]; then
    echo "Warning: File '$ENCRYPTED_FILE' does not have .age extension."
    OUTPUT="${ENCRYPTED_FILE}.decrypted"
fi

# Decrypt the file
if [ -z "$IDENTITY_FILE" ]; then
    echo "Decrypting '$ENCRYPTED_FILE' with passphrase..."
    age -d -o "$OUTPUT" "$ENCRYPTED_FILE"
else
    # Check if identity file exists
    if [ ! -f "$IDENTITY_FILE" ]; then
        echo "Error: Identity file '$IDENTITY_FILE' not found."
        exit 1
    fi
    
    echo "Decrypting '$ENCRYPTED_FILE' with identity file '$IDENTITY_FILE'..."
    age -d -i "$IDENTITY_FILE" -o "$OUTPUT" "$ENCRYPTED_FILE"
fi

echo "Decryption complete: '$OUTPUT'"
