Honestly, two things have been the main blockers for native (non-proot) Termux builds:

1. `gradlew` crashes with:

```
Native registration unable to find class 'com/android/internal/dev/perfetto/sdk/PerfettoTrace'; aborting...
```

A JNI library (`libperfetto_framework_jni.so`) tries to `RegisterNatives` for Android-internal classes that OpenJDK doesn't have, so the JVM aborts.

2. AGP downloads an **x86_64** `aapt2` from maven.google.com that can't run on aarch64.

Both are fixable without proot. I put together a small toolkit — a stub `JNI_OnLoad` to kill the Perfetto crash, plus a native aarch64 `aapt2` build (with the patches to reproduce it):

https://github.com/ZarShevak/kotlinagrad

Usage:

```bash
cd your-android-project
kotlinagrad assembleDebug
```

Tested on FlorisBoard (AGP 9.0.0, Kotlin 2.3.20, Gradle 9.4.1) — 31 MB APK builds fine.
