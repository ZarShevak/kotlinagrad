# DEBUG — kotlinagrad (KotlinAГРАД)

> Bugs racines connus, fixes natifs, et chantiers ouverts.
> Toolkit Gradle/AGP natif sur Termux aarch64, sans proot-distro ni chroot.

## Bug 1 — Crash Perfetto au démarrage de tout `gradlew`/`java`

- **Symptôme** :
  ```
  Native registration unable to find class
  'com/android/internal/dev/perfetto/sdk/PerfettoTrace'; aborting...
  ```
- **Chaîne causale** :
  ```
  libandroid-shmem.so (Termux)
    → libandroid.so (SYSTEM)
    → libandroid_runtime.so
    → libperfetto_framework_jni.so
    → JNI_OnLoad → RegisterNatives (classes Android absentes d'OpenJDK)
    → abort()
  ```
- **Fix natif** : stub `stub-libs/libperfetto_framework_jni.so`
  (`JNI_OnLoad` → `JNI_VERSION_1_6`, zéro `RegisterNatives`) chargé via
  `LD_LIBRARY_PATH` avant les libs système → la vraie lib Perfetto JNI n'est
  jamais invoquée
- **Pourquoi `LD_LIBRARY_PATH` et pas `LD_PRELOAD`** : Bionic (libc Android)
  ne surcharge pas les dépendances `DT_NEEDED` via `LD_PRELOAD`
- **Compat** : le stub prévient uniquement le crash — aucun outil
  Gradle/AGP n'utilise `PerfettoTrace` en mode build aujourd'hui

## Bug 2 — AAPT2 x86_64 embarqué par AGP

- **Symptôme** : le build échoue avec un AAPT2 **x86_64** (embarqué dans
  l'Android Gradle Plugin) sur machine aarch64
- **Fix natif** : `bin/aapt2` — AAPT2 `2.20-android-17.0.0_r1` compilé depuis
  AOSP `android-17.0.0_r1` (voir `patches/` + `native-build/`)
- **Branchement** : `gradle.properties` →
  `android.aapt2=/data/data/com.termux/files/usr/bin/aapt2`

## Chantiers ouverts (Phase 4)

- [x] Promo rédigée (`promo/` — 6 posts : GitHub issue, Reddit, StackOverflow) — à poster manuellement
- [x] Publication du repo public (ZarShevak/kotlinagrad) finalisée (origin + push)
- [ ] Second projet AGP multi-module (avec resources) — validation optionnelle
- [ ] Cas Gradle 8.x / AGP 8.x — documentation optionnelle (testé sur Gradle 9.4.1 / AGP 9.0.0)

## Validation acquise

- FlorisBoard (Kotlin multi-module, AGP 9.0.0, Kotlin 2.3.20, Gradle 9.4.1) :
  `./gradlew --version` ✅ · `./gradlew assembleDebug` ✅ → APK 31 MB

---

*Dernière mise à jour : 2026-08-19*
