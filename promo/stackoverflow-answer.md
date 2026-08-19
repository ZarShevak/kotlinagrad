The AAPT2 error on Termux happens because the Android Gradle Plugin (AGP) downloads `aapt2` from maven.google.com, and that artifact ships an **x86_64 Linux** binary — which can't run on Termux's aarch64 environment.

The fix is to point AGP at a native aarch64 `aapt2` using the documented override in `gradle.properties`:

```properties
android.aapt2=/data/data/com.termux/files/usr/bin/aapt2
```

You can build a native aarch64 `aapt2` from AOSP — see the patches in https://github.com/ZarShevak/kotlinagrad (minimal fixes to compile on aarch64 with a recent NDK/CMake, applied on top of `termux/android-build-tools`).

Note that once aapt2 is fixed, you'll likely hit a second crash on native Termux:

```
Native registration unable to find class 'com/android/internal/dev/perfetto/sdk/PerfettoTrace'; aborting...
```

That's a separate JNI issue (`libperfetto_framework_jni.so` calling `RegisterNatives` for Android-internal classes OpenJDK doesn't have). The same repo ships a stub `JNI_OnLoad` that fixes it — set `LD_LIBRARY_PATH` to its `stub-libs/` directory before running `gradlew`, or use the provided `kotlinagrad` wrapper.
