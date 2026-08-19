# ALMA.md — kotlinagrad

> **Raison d'être** : compiler des projets Android Gradle/AGP **nativement
> sur Termux aarch64**, sans `proot-distro` ni chroot. C'est LA réponse à
> « impossible de builder sous Termux » — deux blockers, deux fixes.

---

## 🔤 Le nom — à lire en premier

**`kotlinagrad`** = **Kotlin** + **grad** (Gradle) + **град** (« ville » en
cyrillique). Le répertoire s'appelle **`KotlinAГРАД`** — `ГРАД` est « grad »
écrit en cyrillique. Jeu de mots façon « Leningrad / Stalingrad » → la *ville
de Kotlin*.

- **Canonique** : `kotlinagrad`
- **Répertoire** : `KotlinAГРАД`
- **Alias / typo fréquente** : `kolinagrad` (sans le `t`) — **c'est le même
  projet**, ne pas créer de doublon.

---

## 🎯 Ce que c'est

Une boîte à outils native qui élimine les deux causes du crash de `gradlew`
sous Termux stock (aarch64) :

```
gradlew / java → crash :
  "Native registration unable to find class
   'com/android/internal/dev/perfetto/sdk/PerfettoTrace'; aborting..."
```

**Chaîne causale :**

```
libandroid-shmem.so (Termux)
  → libandroid.so (SYSTEM)
  → libandroid_runtime.so
  → libperfetto_framework_jni.so
  → JNI_OnLoad → RegisterNatives (classes Android absentes d'OpenJDK)
  → abort()
```

Second blocker : l'Android Gradle Plugin (AGP) embarque un AAPT2 **x86_64**,
inutilisable sur aarch64.

---

## 🛠️ Les deux fixes

### 1. Stub `libperfetto_framework_jni.so`

Stub C minimal exposant un `JNI_OnLoad` qui retourne `JNI_VERSION_1_6` sans
enregistrer de méthode native. Chargé via `LD_LIBRARY_PATH` **avant** les
libs système → la vraie lib Perfetto JNI n'est jamais invoquée.

### 2. AAPT2 natif aarch64

Binaire pré-compilé dans `bin/aapt2` (AAPT2 `2.20-android-17.0.0_r1`), compilé
depuis AOSP `android-17.0.0_r1` (voir `patches/`). Pointer AGP dessus dans
`gradle.properties` :

```properties
android.aapt2=/data/data/com.termux/files/usr/bin/aapt2
```

---

## 🚀 Usage

```bash
cd /path/to/android-project
kotlinagrad assembleDebug
kotlinagrad --version
kotlinagrad --stop
```

Équivalent manuel :

```bash
LD_LIBRARY_PATH=/path/to/kotlinagrad/stub-libs:$LD_LIBRARY_PATH ./gradlew assembleDebug
```

Installation :

```bash
git clone https://github.com/ZarShevak/kotlinagrad.git
cd kotlinagrad
bash install.sh   # aapt2 + stub + wrapper, one-shot
```

---

## 🧭 Technique (points clés)

- **Stub JNI_OnLoad** — pas de `RegisterNatives`, retour immédiat
  `JNI_VERSION_1_6`. Le vrai `.so` enregistre 18+ classes Perfetto ; le stub
  élimine tout.
- **Pourquoi `LD_LIBRARY_PATH` et pas `LD_PRELOAD`** — Bionic (libc Android)
  ne surcharge pas les dépendances `DT_NEEDED` via `LD_PRELOAD`.
  `LD_LIBRARY_PATH` a priorité sur les chemins système pour toutes les
  résolutions (directes et transitives).
- **Compat** — le stub ne fait que prévenir le crash. Aucun outil
  Gradle/AGP n'utilise `PerfettoTrace` en mode build aujourd'hui.

---

## 📁 Structure

```
KotlinAГРАД/
├── kotlinagrad                     # wrapper script (export LD_LIBRARY_PATH + exec gradlew)
├── install.sh                      # installateur one-shot
├── bin/
│   └── aapt2                       # binaire aarch64 pré-compilé
├── stub-libs/
│   ├── stub_perfetto.c             # source du stub
│   └── libperfetto_framework_jni.so  # stub compilé aarch64
├── patches/                        # patches AOSP pour build natif aarch64
├── native-build/                   # harness de build AAPT2 (termux/android-build-tools)
├── promo/                          # GitHub issue / Reddit / StackOverflow
├── LICENSE                         # MIT (wrapper + stub)
├── NOTICE                          # AOSP Apache-2.0 (attribution)
└── README.md
```

---

## ✅ Validation

Testé avec succès sur **FlorisBoard** (Kotlin multi-module, AGP 9.0.0,
Kotlin 2.3.20, Gradle 9.4.1) :

- `./gradlew --version` ✅
- `./gradlew assembleDebug` ✅ — APK 31 MB produit

---

## 🔗 Famille native aarch64 — aBUN

`kotlinagrad` n'est pas seul : il fait partie de la famille **« native
aarch64, zéro proot »** de `ACROPOLIS/PROJECTS/`. Son frère jumeau :

- **`aBUN/`** — kit autonome de build **Bun** natif sur Termux. Résout les
  deux bugs Bun : `--backend=hardlink` incompatible f2fs (`EACCES`) et
  `bun run` → `CouldntReadCurrentDirectory` (getcwd Zig interne, pas la
  libc). Contournements : `bun install --backend=copyfile` + `bun build.ts`
  (exécution directe, **jamais** `bun run build`).

Même philosophie, deux chaînes d'outillage :

| Projet | Chaîne | Cible |
|--------|--------|-------|
| `kotlinagrad` | Gradle / AGP / AAPT2 | APK Android (Kotlin/Java) |
| `aBUN` | Bun / TypeScript | binaire JS (`dist/cli.js`) |

Les deux partagent le réflexe **NATIVE AARCH64 FIRST** (proot = dernier
recours) : neutraliser les libs système Android qui plantent en natif —
`kotlinagrad` via le stub `LD_LIBRARY_PATH`, `aBUN` via `--backend=copyfile`
+ exécution directe.

---

## ⚖️ Licence

- Wrapper `kotlinagrad` + `stub-libs/` → **MIT** (`LICENSE`)
- `patches/` + AAPT2 natif → **Apache-2.0** (AOSP, `NOTICE`)
