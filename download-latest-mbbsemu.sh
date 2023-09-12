#!/bin/bash

set -e
set -x

# Check for the presence of the gh command
if ! command -v gh &> /dev/null; then
    echo "The 'gh' command is not found. Please install it from https://github.com/cli/cli/blob/trunk/docs/install_linux.md"
    exit 1
fi

REPO="mbbsemu/mbbsemu"
WORKFLOW="dotnet.yml"
PATTERN="mbbsemu-linux-x64-*"
PKG_DIR="pkg"
ARCHIVE_DIR="$PKG_DIR/archive/mbbsemu"

echo "Fetching the latest successful run ID for $REPO on $WORKFLOW."
RUN_ID=$(gh run list --repo "$REPO" --workflow "$WORKFLOW" --status success --branch master --json databaseId --jq '.[0].databaseId')

if [ -z "$RUN_ID" ]; then
    echo "Error: Could not retrieve a successful run ID."
    exit 1
fi

echo "Archiving old mbbsemu builds."
mkdir -p "$ARCHIVE_DIR"
mv "$PKG_DIR"/mbbsemu-*/* "$ARCHIVE_DIR"/ 2>/dev/null

echo "Downloading the artifact matching pattern $PATTERN for run ID $RUN_ID."
gh run download --repo "$REPO" "$RUN_ID" -p "$PATTERN" -D $PKG_DIR

if [ $? -ne 0 ]; then
    echo "Error: Failed to download the artifact."
    exit 1
fi

echo "Download and extraction complete."
