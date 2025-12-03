# 🚀 Comment compiler automatiquement BARRY WI-FI

## 📖 Guide rapide

Ce projet est configuré pour compiler automatiquement sur **toutes les plateformes** via GitHub Actions.

## 🎯 Démarrage rapide

### 1️⃣ Configuration initiale (une seule fois)

#### Pour Android (signature automatique) :

1. **Créez un keystore** (si vous n'en avez pas) :
```bash
cd flutter/android/app
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. **Encodez le keystore en base64** :
```bash
# Linux/macOS
base64 -i upload-keystore.jks | pbcopy

# Windows (PowerShell)
[Convert]::ToBase64String([IO.File]::ReadAllBytes("upload-keystore.jks"))
```

3. **Configurez les secrets GitHub** :
   - Allez dans votre dépôt GitHub
   - **Settings** → **Secrets and variables** → **Actions**
   - Cliquez sur **New repository secret**
   - Ajoutez ces secrets :

| Secret | Valeur | Exemple |
|--------|--------|---------|
| `ANDROID_KEYSTORE_FILE` | Nom du fichier keystore | `upload-keystore.jks` |
| `ANDROID_KEY_ALIAS` | Alias de la clé | `upload` |
| `ANDROID_STORE_PASSWORD` | Mot de passe du keystore | `votre_mot_de_passe` |
| `ANDROID_KEY_PASSWORD` | Mot de passe de la clé | `votre_mot_de_passe` |
| `ANDROID_KEYSTORE_BASE64` | Keystore encodé en base64 | `[coller le résultat base64]` |

### 2️⃣ Lancer un build

#### Option A : Automatique (push)
```bash
git push origin main
```
Les builds se lancent automatiquement !

#### Option B : Manuel (GitHub UI)
1. Allez dans l'onglet **Actions**
2. Sélectionnez le workflow souhaité (ex: `🚀 Build All Platforms`)
3. Cliquez sur **Run workflow**
4. Sélectionnez la branche
5. Cliquez sur **Run workflow**

### 3️⃣ Récupérer les builds

1. Allez dans **Actions** → Cliquez sur le workflow terminé
2. Faites défiler jusqu'à **Artifacts**
3. Téléchargez les fichiers :
   - 📱 **android-apk** : Fichiers APK pour Android
   - 📦 **android-aab** : App Bundle pour Google Play
   - 🌐 **web-release** : Application web
   - 🪟 **windows-release** : Exécutable Windows
   - 🐧 **linux-release** : Application Linux
   - 🍎 **macos-release** : Application macOS

## 📋 Workflows disponibles

| Workflow | Description | Quand il se déclenche |
|----------|-------------|----------------------|
| `android_build.yml` | Build Android (APK + AAB) | Push/PR sur main/master/develop |
| `web_build.yml` | Build Web | Push/PR sur main/master/develop |
| `windows_build.yml` | Build Windows | Push/PR sur main/master/develop |
| `linux_build.yml` | Build Linux | Push/PR sur main/master/develop |
| `macos_build.yml` | Build macOS | Push/PR sur main/master/develop |
| `all_in_one.yml` | Build toutes les plateformes | Push/PR sur main/master ou tags v* |

## 🔍 Vérifier le statut d'un build

1. Allez dans **Actions**
2. Cliquez sur le workflow en cours ou terminé
3. Voir les logs détaillés de chaque étape

## ⚠️ Problèmes courants

### ❌ "Secrets not found"
**Solution** : Configurez les secrets GitHub comme décrit dans la section 1️⃣

### ❌ "Build failed - signing config"
**Solution** : Vérifiez que :
- Les secrets sont correctement nommés
- Le keystore est valide
- Le base64 est correctement encodé

### ❌ "Flutter version not found"
**Solution** : Le workflow utilise Flutter 3.24.0. Si besoin, modifiez dans `.github/workflows/*.yml` :
```yaml
flutter-version: '3.24.0'  # Changez la version ici
```

### ❌ "Platform not enabled"
**Solution** : Les workflows activent automatiquement les plateformes. Si erreur, vérifiez que Flutter supporte la plateforme.

## 📱 Installation des builds

### Android
- **APK** : Transférez sur votre appareil et installez
- **AAB** : Upload sur Google Play Console

### Web
- Déployez le contenu de `build/web/` sur un serveur web
- Ou utilisez GitHub Pages, Netlify, Vercel, etc.

### Windows
- Exécutez `barry_wifi.exe` depuis le dossier `Release`

### Linux
- Rendez l'AppImage exécutable : `chmod +x barry_wifi.AppImage`
- Double-cliquez pour lancer

### macOS
- Ouvrez le fichier `.app` dans le dossier `Release`
- ⚠️ Peut nécessiter de désactiver la quarantaine macOS

## 🔄 Mise à jour de la configuration

Pour modifier les workflows :
1. Éditez les fichiers dans `.github/workflows/`
2. Commitez et poussez
3. Les changements s'appliquent aux prochains builds

## 📚 Documentation complète

Voir `compile_config.md` pour la documentation technique complète.

## 🆘 Support

Si vous rencontrez des problèmes :
1. Vérifiez les logs dans GitHub Actions
2. Consultez `compile_config.md`
3. Vérifiez que tous les secrets sont configurés

---

**🎉 Bon build !**

