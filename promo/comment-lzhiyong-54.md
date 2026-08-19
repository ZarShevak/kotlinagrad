For an arm64-v8a `aapt2` that handles SDK 36 resources, the build path is: clone `termux/android-build-tools`, apply the patches in https://github.com/ZarShevak/kotlinagrad (the `patches/` dir holds minimal fixes to compile AOSP on aarch64 with a recent NDK/CMake), then build from AOSP `android-17.0.0_r1`.

That produces a native aarch64 `aapt2` you can drop at `$PREFIX/bin/aapt2`. For Gradle projects, point AGP at it via `android.aapt2=...` in `gradle.properties`.

If you just need the standalone binary for an analysis script (no Gradle), the same patches + the `android-build-tools` CMake flow give you a bare `aapt2`. Happy to walk through the exact steps if that helps.
