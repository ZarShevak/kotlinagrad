For anyone still hitting this on **native Termux aarch64**:

```
Native registration unable to find class 'com/android/internal/dev/perfetto/sdk/PerfettoTrace'; aborting...
```

Root cause: `libandroid-shmem.so` → `libandroid_runtime.so` → `libperfetto_framework_jni.so` runs `JNI_OnLoad`, which calls `RegisterNatives` for Android-internal Perfetto classes that don't exist in OpenJDK → `abort()`. On top of that, AGP ships x86_64 AAPT2 binaries that can't run on aarch64.

Quick no-proot fix (stub `JNI_OnLoad` + native aarch64 AAPT2):

https://github.com/ZarShevak/kotlinagrad

```bash
cd /path/to/android-project
kotlinagrad assembleDebug
# or manually:
LD_LIBRARY_PATH=/path/to/kotlinagrad/stub-libs:$LD_LIBRARY_PATH ./gradlew assembleDebug
```

Validated on FlorisBoard (Kotlin multi-module, AGP 9.0.0, Gradle 9.4.1) → 31 MB APK builds fine.
