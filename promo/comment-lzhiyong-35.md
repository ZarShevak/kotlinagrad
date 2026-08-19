There's a simpler way to skip the whole maven-local jar-replacement dance — AGP has a documented override to point at a custom aapt2 binary:

```properties
# gradle.properties
android.aapt2=/data/data/com.termux/files/usr/bin/aapt2
```

This makes AGP use that binary directly instead of the x86_64 one it downloads from maven.google.com, so no `cacheToMavenLocal` / jar swap needed.

For a native aarch64 `aapt2` build, plus a stub that also fixes the related `PerfettoTrace` JNI `abort()` crash that hits `gradlew` on native Termux, I put together a small no-proot toolkit: https://github.com/ZarShevak/kotlinagrad
