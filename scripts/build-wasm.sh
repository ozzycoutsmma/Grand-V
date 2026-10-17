#!/usr/bin/env bash
set -euo pipefail

# This build script intentionally SKIPS building the native Rust launcher.
# The LauncherApp/rust crate is a native backend (uses mio/tokio/etc.) and
# cannot be compiled to wasm32-unknown-unknown. For Vercel hosting we only
# need a static site. This script prepares public/ by copying the landing
# page, styles, and any web-safe assets.

OUT_DIR="public"
mkdir -p "${OUT_DIR}"

# Copy site files
cp -f index.html "${OUT_DIR}/index.html"
cp -f styles.css "${OUT_DIR}/styles.css"

# If the LauncherApp/rust/assets directory contains web assets (images, PNGs),
# copy them. Many native assets (platform-specific binaries) are not copied.
if [ -d "LauncherApp/rust/assets" ]; then
  echo "Copying LauncherApp/rust/assets to ${OUT_DIR}/"
  cp -r LauncherApp/rust/assets/. "${OUT_DIR}/" 2>/dev/null || true
fi

# Ensure public/pkg exists so any simple web loader doesn't error
mkdir -p "${OUT_DIR}/pkg"

echo "Skipped native Rust build. public/ is ready for Vercel." 
