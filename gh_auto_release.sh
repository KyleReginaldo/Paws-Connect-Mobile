#!/bin/bash
set -e

# Go to the project root (the directory where this script lives)
cd "$(dirname "$0")"

# === CONFIGURATION ===
REPO="KyleReginaldo/pawsconnect-uploads"
APP_NAME="pawsconnect"
OUTPUT_DIR="build/app/outputs/flutter-apk"
ORIGINAL_APK="$OUTPUT_DIR/app-prod-release.apk"  # Adjust if filename differs
NOTES="Auto-generated from local build"
TOKEN="$GITHUB_TOKEN"

echo "📂 Working directory: $(pwd)"
echo "🔍 Checking if APK exists at: $ORIGINAL_APK"

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

# === RENAME APK FILE ===
if [ -f "$ORIGINAL_APK" ]; then
  echo "🛠️ Renaming $ORIGINAL_APK → $RENAMED_APK"
  mv "$ORIGINAL_APK" "$RENAMED_APK"
else
  echo "❌ APK not found at $ORIGINAL_APK"
  exit 1
fi

# === CREATE RELEASE ===
gh release create "$NEW_VERSION" "$RENAMED_APK" \
  --repo "$REPO" \
  --title "$NEW_VERSION" \
  --notes "$NOTES"

echo "✅ Successfully created release: $NEW_VERSION"
