**Title:** Build Android/Gradle projects on native Termux (aarch64) — no proot, no chroot

If you've ever run `./gradlew` on native Termux and got:

```
Native registration unable to find class 'com/android/internal/dev/perfetto/sdk/PerfettoTrace'; aborting...
```

...it's not you. It's `libperfetto_framework_jni.so` trying to `RegisterNatives` for Android-internal classes that OpenJDK doesn't have, which aborts the JVM. AGP also bundles x86_64 AAPT2 binaries that don't run on aarch64.

I made a small no-proot fix: a stub `JNI_OnLoad` + a native aarch64 AAPT2 build.

**Repo:** https://github.com/ZarShevak/kotlinagrad

**Usage:**

```bash
cd your-android-project
kotlinagrad assembleDebug
```

Tested on FlorisBoard (AGP 9.0.0, Kotlin 2.3.20, Gradle 9.4.1) — 31 MB APK builds fine.

Happy to help if anyone hits edge cases.
