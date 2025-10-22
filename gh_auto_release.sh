#!/bin/bash
set -e

# Go to the project root (the directory where this script lives)
cd "$(dirname "$0")"

# === CONFIGURATION ===
REPO="KyleReginaldo/pawsconnect-uploads"
APP_NAME="pawsconnect"
OUTPUT_DIR="build/app/outputs/flutter-apk"
# Prefer a custom-named APK if present
CUSTOM_APK="$OUTPUT_DIR/${APP_NAME}.apk"
DEFAULT_ORIGINAL_APK="$OUTPUT_DIR/app-prod-release.apk"
NOTES="Auto-generated from local build"
TOKEN="$GITHUB_TOKEN"

echo "📂 Working directory: $(pwd)"
echo "🔍 Looking for APK…"

# === FETCH LATEST TAG ===
LATEST_TAG=$(gh release list --repo "$REPO" --limit 1 --json tagName --jq '.[0].tagName')
if [ -z "$LATEST_TAG" ]; then
  echo "No releases found. Starting from v1.0.0"
  LATEST_TAG="v1.0.0"
fi
VERSION=${LATEST_TAG#v}
IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION"
PATCH=$((PATCH + 1))
NEW_VERSION="v$MAJOR.$MINOR.$PATCH"

RENAMED_APK="$OUTPUT_DIR/${APP_NAME}-${NEW_VERSION}.apk"

# === LOCATE ORIGINAL APK ===
if [ -f "$CUSTOM_APK" ]; then
  ORIGINAL_APK="$CUSTOM_APK"
  echo "✅ Found custom APK: $ORIGINAL_APK"
elif [ -f "$DEFAULT_ORIGINAL_APK" ]; then
  ORIGINAL_APK="$DEFAULT_ORIGINAL_APK"
  echo "✅ Found default APK: $ORIGINAL_APK"
else
  # Fallback: first APK in OUTPUT_DIR
  ORIGINAL_APK=$(ls -1 "$OUTPUT_DIR"/*.apk 2>/dev/null | head -n 1 || true)
  if [ -n "$ORIGINAL_APK" ] && [ -f "$ORIGINAL_APK" ]; then
    echo "✅ Found fallback APK: $ORIGINAL_APK"
  else
    echo "❌ No APK found in $OUTPUT_DIR"
    exit 1
  fi
fi

# === RENAME APK FILE ===
echo "🛠️ Renaming $ORIGINAL_APK → $RENAMED_APK"
mv "$ORIGINAL_APK" "$RENAMED_APK"

# === CREATE RELEASE ===
gh release create "$NEW_VERSION" "$RENAMED_APK" \
  --repo "$REPO" \
  --title "$NEW_VERSION" \
  --notes "$NOTES"

echo "✅ Successfully created release: $NEW_VERSION"
