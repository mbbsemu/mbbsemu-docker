#!/bin/bash

set -e
set -x

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
  exit 2
fi

echo "Archiving old mbbsemu builds."
mkdir -p "$ARCHIVE_DIR"
for dir in "$PKG_DIR"/mbbsemu-*; do
  if [ -d "$dir" ]; then  # Check if $dir exists and is a directory
    target="$ARCHIVE_DIR/$(basename "$dir")"
    [ -d "$target" ] && rm -rf "$target"  # if target exists, remove it
    mv "$dir" "$ARCHIVE_DIR"
  fi
done

echo "Downloading the artifact matching pattern $PATTERN for run ID $RUN_ID."
if ! gh run download --repo "$REPO" "$RUN_ID" -p "$PATTERN" -D $PKG_DIR;
then
  echo "Error: Failed to download the artifact."
  exit 3
fi

echo "Download and extraction complete."
