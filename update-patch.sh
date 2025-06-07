#!/usr/bin/env bash
set -euo pipefail

# ----------- CONFIG -----------

TAG="1.0.18"
PATCH_FILE="1.0.18-complete-x.patch"
NEW_PATCH_FILE="1.0.18-complete-x-x.patch"
SCRIPT_NAME="$(basename "$0")"

# ----------- INTERNAL -----------

REPO_ROOT="$(git rev-parse --show-toplevel)"
TMP_DIR="/tmp/git_patch_workflow_$$"
mkdir -p "$TMP_DIR"

PATCH_BACKUP="$TMP_DIR/$(basename "$PATCH_FILE")"
SCRIPT_BACKUP="$TMP_DIR/$SCRIPT_NAME"

# ----------- START -----------

echo "📁 Backing up patch and script..."
cp "$PATCH_FILE" "$PATCH_BACKUP"
cp "$0" "$SCRIPT_BACKUP"

echo "🔁 Resetting to tag: $TAG"
git checkout "$TAG"
git reset --hard
git clean -fdx

echo "📦 Applying patch..."
git apply --binary "$PATCH_BACKUP" || {
  echo "❌ Patch failed to apply. Check for conflicts or mismatched context."
  exit 1
}

echo "🛠️ Patch applied. Make your changes now."
echo "👉 Press ENTER when you're done editing..."
read -r _

echo "✅ Staging changes..."
git add .

echo "📤 Generating new patch: $NEW_PATCH_FILE"
git diff --binary "$TAG" > "$NEW_PATCH_FILE"

echo "🔙 Restoring original patch and script..."
cp "$PATCH_BACKUP" "$REPO_ROOT/$PATCH_FILE"
cp "$SCRIPT_BACKUP" "$REPO_ROOT/$SCRIPT_NAME"

echo "✅ Done."
echo "📄 Patch written to: $NEW_PATCH_FILE"
echo "📄 Original patch and script restored in the repo."

# Clean up tmp
rm -rf "$TMP_DIR"