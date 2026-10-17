#!/usr/bin/env bash
set -euo pipefail

CRATE_DIR="LauncherApp/rust"
OUT_DIR="public"
mkdir -p "${OUT_DIR}"

# Ensure rust toolchain
if ! command -v rustc >/dev/null 2>&1; then
  echo "Installing rustup..."
  curl https://sh.rustup.rs -sSf | sh -s -- -y
  export PATH="$HOME/.cargo/bin:$PATH"
fi

rustup target add wasm32-unknown-unknown || true

# Ensure wasm-bindgen is available
if ! command -v wasm-bindgen >/dev/null 2>&1; then
  echo "Installing wasm-bindgen-cli... (this may take a while)"
  cargo install -f wasm-bindgen-cli || true
fi

# Build the crate for wasm target
pushd "$CRATE_DIR"
cargo build --release --target wasm32-unknown-unknown
CRATE_NAME=$(sed -n 's/^name *= *"\(.*\)".*/\1/p' Cargo.toml | head -n1 | tr -d '"')
WASM_PATH="target/wasm32-unknown-unknown/release/${CRATE_NAME}.wasm"

if [ ! -f "$WASM_PATH" ]; then
  echo "Error: wasm file not found at $WASM_PATH"
  echo "Build output:" && ls -la target/wasm32-unknown-unknown/release || true
  exit 1
fi
popd

# Run wasm-bindgen to generate web bindings
mkdir -p "${OUT_DIR}/pkg"
wasm-bindgen "$WASM_PATH" --out-dir "${OUT_DIR}/pkg" --target web || true

# Copy static assets from the crate (if any)
cp -r "${CRATE_DIR}/assets/." "${OUT_DIR}/" 2>/dev/null || true

# Copy landing page and styles to public/
cp -f index.html "${OUT_DIR}/index.html"
cp -f styles.css "${OUT_DIR}/styles.css"

echo "Build complete — public/ is ready."
