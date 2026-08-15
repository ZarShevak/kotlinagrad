# kotlinagrad — Native Android Build Toolkit (Termux aarch64, no proot)

> Build Gradle/AGP Android projects **natively on Termux aarch64** — no
> `proot-distro`, no chroot. Fixes the two blockers that make `gradlew`
> crash or fail on stock Termux.

[FR] Boîte à outils native pour compiler des projets Android Gradle/AGP
directement sous Termux aarch64 — sans proot-distro ni chroot.

---

## The problem / Le problème

On native Termux (aarch64), any `gradlew` or `java` invocation crashes with:

```
Native registration unable to find class 'com/android/internal/dev/perfetto/sdk/PerfettoTrace'; aborting...
```

**Root cause chain / Chaîne causale :**

```
libandroid-shmem.so (Termux)
  → libandroid.so (SYSTEM)
  → libandroid_runtime.so
  → libperfetto_framework_jni.so
  → JNI_OnLoad → RegisterNatives for Android classes missing in OpenJDK
  → abort()
```

Second blocker: Android Gradle Plugin (AGP) bundles **x86_64** AAPT2 binaries,
unusable on aarch64.

---

## The fix / La solution

### 1. Stub `libperfetto_framework_jni.so`

A minimal C stub exposing a `JNI_OnLoad` that returns `JNI_VERSION_1_6`
without registering any native method. Loaded via `LD_LIBRARY_PATH` ahead of
the system libraries, so the real Perfetto JNI library is never invoked.

### 2. Native aarch64 AAPT2

Compiled from AOSP `android-17.0.0_r1` (see `patches/`), installed to
`$PREFIX/bin/aapt2`. Point AGP at it in `gradle.properties`:

```properties
android.aapt2=/data/data/com.termux/files/usr/bin/aapt2
```

---

## Install / Installation

```bash
# 1. Clone
git clone https://github.com/<you>/kotlinagrad.git
cd kotlinagrad

# 2. Put the wrapper on PATH (or run it directly)
ln -s "$PWD/kotlinagrad" "$PREFIX/bin/kotlinagrad"

# 3. (Optional) Install the stub system-wide so LD_LIBRARY_PATH is not needed
cp stub-libs/libperfetto_framework_jni.so "$PREFIX/lib/"
```

## Usage

```bash
cd /path/to/android-project
kotlinagrad assembleDebug
kotlinagrad --version
```

Manual equivalent:

```bash
LD_LIBRARY_PATH=/path/to/kotlinagrad/stub-libs:$LD_LIBRARY_PATH ./gradlew assembleDebug
```

---

## How it works / Technique

- **Stub JNI_OnLoad** — no `RegisterNatives`, immediate `JNI_VERSION_1_6`.
  The real `.so` registers 18+ Perfetto classes; the stub eliminates all of it.
- **Why `LD_LIBRARY_PATH` and not `LD_PRELOAD`** — Bionic (Android libc) does
  not override `DT_NEEDED` dependencies via `LD_PRELOAD`. `LD_LIBRARY_PATH`
  takes priority over system paths for resolving all dependencies, direct and
  transitive.
- **Compat** — the stub only prevents the crash. No Gradle/AGP tool uses
  `PerfettoTrace` in build mode today.

---

## Building native AAPT2 (from source)

The `patches/` directory contains minimal fixes to compile AOSP on aarch64
with a recent NDK/CMake. The build harness is
[termux/android-build-tools](https://github.com/termux/android-build-tools).

```bash
# Clone the harness, apply patches/, then build (see its clone.sh / CMakeLists.txt)
```

---

## Structure

```
kotlinagrad/
├── kotlinagrad                     # wrapper script
├── stub-libs/
│   ├── stub_perfetto.c             # stub source
│   └── libperfetto_framework_jni.so  # compiled aarch64
├── patches/                        # AOSP patches for native aarch64 build
│   ├── aidl/ base/ build/ core/ incremental_delivery/ libziparchive/ zopfli/
├── LICENSE                         # MIT (wrapper + stub)
├── NOTICE                          # AOSP Apache-2.0 attribution
└── README.md
```

---

## Validation

Tested successfully on **FlorisBoard** (Kotlin multi-module, AGP 9.0.0,
Kotlin 2.3.20, Gradle 9.4.1):

- `./gradlew --version` ✅
- `./gradlew assembleDebug` ✅ — 31 MB APK produced

---

## License

- `kotlinagrad` wrapper + `stub-libs/` → **MIT** (see `LICENSE`)
- `patches/` + native AAPT2 → **Apache-2.0** (AOSP, see `NOTICE`)
