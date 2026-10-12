#!/bin/sh

set -eu

SCHEME="Disk Inventory X"
WORKSPACE="workspace.xcworkspace"
BUILD_DIR="$(pwd)/build"
APP_NAME="Disk Inventory X.app"
APP_PATH="$BUILD_DIR/Release/$APP_NAME"

if [ $# -gt 1 ]; then
  echo "Usage: $0 [tag]" >&2
  exit 1
fi

TAG="${1:-}"
if [ -z "$TAG" ]; then
  TAG_VERSION=$(xcodebuild -workspace "$WORKSPACE" -scheme "$SCHEME" -configuration Release -showBuildSettings 2>/dev/null | awk '/MARKETING_VERSION/{print $3; exit}')
  if [ -z "$TAG_VERSION" ]; then
    echo "Unable to determine MARKETING_VERSION from the Xcode project." >&2
    exit 1
  fi
  TAG="v${TAG_VERSION}"
fi

ZIP_NAME="$BUILD_DIR/Disk-Inventory-X-${TAG}.zip"

./BuildRelease.sh

SIGNING_IDENTITY="${SIGNING_IDENTITY:-}"
if [ -z "$SIGNING_IDENTITY" ]; then
  SIGNING_IDENTITY=$(security find-identity -v -p codesigning | awk '/Apple Development:/{print $2; exit}')
fi
if [ -z "$SIGNING_IDENTITY" ]; then
  echo "Unable to find a codesigning identity. Set SIGNING_IDENTITY and retry." >&2
  exit 1
fi

codesign --force --sign "$SIGNING_IDENTITY" --timestamp=none --options runtime --deep "$APP_PATH"
codesign --verify --deep --strict --verbose=2 "$APP_PATH"

ditto -c -k --keepParent "$APP_PATH" "$ZIP_NAME"

if gh release view "$TAG" >/dev/null 2>&1; then
  gh release upload "$TAG" "$ZIP_NAME" --clobber
else
  gh release create "$TAG" \
    --title "Disk Inventory X ${TAG}" \
    --generate-notes \
    "$ZIP_NAME"
fi
