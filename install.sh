#!/data/data/com.termux/files/usr/bin/bash
# kotlinagrad — one-shot installer for native Termux aarch64 (no proot)
set -euo pipefail

PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[1/3] native aarch64 aapt2"
install -Dm755 "$SCRIPT_DIR/bin/aapt2" "$PREFIX/bin/aapt2"

echo "[2/3] PerfettoTrace stub (kills the JNI abort() crash)"
install -Dm644 "$SCRIPT_DIR/stub-libs/libperfetto_framework_jni.so" "$PREFIX/lib/libperfetto_framework_jni.so"

echo "[3/3] wrapper on PATH"
ln -sf "$SCRIPT_DIR/kotlinagrad" "$PREFIX/bin/kotlinagrad"

echo ""
echo "Done. Point AGP at the native aapt2 in gradle.properties:"
echo "  android.aapt2=$PREFIX/bin/aapt2"
echo ""
echo "Then build:"
echo "  cd /path/to/android-project && kotlinagrad assembleDebug"
