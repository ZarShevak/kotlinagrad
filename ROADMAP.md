# ROADMAP — kotlinagrad

> Native Android Build Toolkit — compiler des projets Gradle/AGP directement
> sous Termux aarch64, sans proot-distro ni chroot. Deux blockers, deux fixes.
> Démarré : 2026-06-07

## Contexte

Sur Termux natif (aarch64), tout `gradlew`/`java` crash avec :

```
Native registration unable to find class
'com/android/internal/dev/perfetto/sdk/PerfettoTrace'; aborting...
```

Chaîne causale : `libandroid-shmem.so` → `libandroid.so` → `libandroid_runtime.so`
→ `libperfetto_framework_jni.so` → `JNI_OnLoad` → `RegisterNatives` (classes
Android absentes d'OpenJDK) → `abort()`.

Second blocker : l'Android Gradle Plugin embarque un AAPT2 **x86_64**,
inutilisable sur aarch64.

## Phases

### Phase 0 — Diagnostic des blockers ✅ COMPLETE
- [x] Cartographier la chaîne causale du crash Perfetto (JNI RegisterNatives)
- [x] Identifier le blocker AAPT2 x86_64 embarqué par AGP
- [x] Tester LD_PRELOAD vs LD_LIBRARY_PATH (Bionic ne surcharge pas DT_NEEDED)
- [x] Vérifier que rien n'utilise PerfettoTrace en mode build (compat)

### Phase 1 — Stub libperfetto_framework_jni.so ✅ COMPLETE
- [x] Écrire `stub_perfetto.c` (JNI_OnLoad → JNI_VERSION_1_6, zéro RegisterNatives)
- [x] Compiler le stub en aarch64 (`stub-libs/libperfetto_framework_jni.so`)
- [x] Charger le stub via `LD_LIBRARY_PATH` avant les libs système
- [x] Valider `gradlew --version` sans crash sur Termux natif
- [x] Documenter la technique (Bionic, priorité de résolution)

### Phase 2 — AAPT2 natif aarch64 ✅ COMPLETE
- [x] Écrire les patches AOSP pour build aarch64 (`patches/`)
- [x] Mettre en place le harness `native-build/` (termux/android-build-tools)
- [x] Produire `bin/aapt2` (2.20-android-17.0.0_r1, aarch64)
- [x] Pointer AGP dessus via `gradle.properties` (android.aapt2=…)
- [x] Vérifier le link de ressources sur un projet réel

### Phase 3 — Wrapper & installation ✅ COMPLETE
- [x] Écrire le wrapper `kotlinagrad` (export LD_LIBRARY_PATH + exec gradlew)
- [x] Écrire `install.sh` one-shot (aapt2 + stub + wrapper)
- [x] Installer via symlink `$PREFIX/bin/kotlinagrad`
- [x] `kotlinagrad --version` / `--stop` fonctionnels

### Phase 4 — Validation & distribution ✅ COMPLETE
- [x] Valider sur FlorisBoard (AGP 9.0.0, Kotlin 2.3.20, Gradle 9.4.1)
- [x] `assembleDebug` → APK 31 MB produit ✅
- [x] README.md bilingue (FR/EN) + ALMA.md de raison d'être
- [x] Promo (GitHub issue / Reddit / StackOverflow) via `promo/` — contenu rédigé (6 posts)
- [x] Publication du repo public (ZarShevak/kotlinagrad) finalisée (origin + push)

**TOTAL 23/23 (100%)**

## Prochaines étapes

- Poster les contenus `promo/` sur les canaux (manuel — comptes requis)
- Tester sur un second projet AGP (multi-module avec resources)
- Documenter le cas Gradle 8.x (AGP 8.x) si besoin

---

*Dernière mise à jour : 2026-08-19*
