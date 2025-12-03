# 🔧 Configuration de Compilation - BARRY WI-FI

## 📋 Vue d'ensemble

Ce document décrit la configuration complète pour compiler automatiquement l'application BARRY WI-FI sur toutes les plateformes via GitHub Actions.

## 🎯 Plateformes supportées

- ✅ **Android** : APK + AAB (App Bundle)
- ✅ **Web** : Application web progressive
- ✅ **Windows** : Exécutable .exe
- ✅ **Linux** : AppImage
- ✅ **macOS** : Application .app

## 🔑 Configuration Android (Signature)

### Option 1 : GitHub Secrets (Recommandé)

Pour signer automatiquement les builds Android, configurez ces secrets dans GitHub :

1. Allez dans **Settings → Secrets and variables → Actions**
2. Ajoutez les secrets suivants :

```
ANDROID_KEYSTORE_FILE=upload-keystore.jks
ANDROID_KEY_ALIAS=upload
ANDROID_STORE_PASSWORD=votre_mot_de_passe_store
ANDROID_KEY_PASSWORD=votre_mot_de_passe_key
ANDROID_KEYSTORE_BASE64=[votre_keystore_encodé_en_base64]
```

#### Comment encoder votre keystore en base64 :

**Sur Linux/macOS :**
```bash
base64 -i your-keystore.jks | pbcopy
```

**Sur Windows (PowerShell) :**
```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("your-keystore.jks"))
```

### Option 2 : Fichier local (Développement uniquement)

1. Copiez `flutter/android/app/key.properties.template` vers `flutter/android/app/key.properties`
2. Remplissez avec vos vraies valeurs
3. ⚠️ **NE COMMITEZ JAMAIS** `key.properties` dans Git !

## 📁 Structure des workflows

Tous les workflows sont dans `.github/workflows/` :

- `android_build.yml` → Build Android uniquement
- `web_build.yml` → Build Web uniquement
- `windows_build.yml` → Build Windows uniquement
- `linux_build.yml` → Build Linux uniquement
- `macos_build.yml` → Build macOS uniquement
- `all_in_one.yml` → Build toutes les plateformes en parallèle

## 🚀 Déclenchement des builds

### Automatique
- Push sur `main`, `master`, ou `develop`
- Pull requests vers `main`, `master`, ou `develop`
- Tags `v*` (pour `all_in_one.yml` uniquement)

### Manuel
- Allez dans **Actions** → Sélectionnez le workflow → **Run workflow**

## 📦 Récupération des artifacts

1. Allez dans l'onglet **Actions** de votre dépôt GitHub
2. Cliquez sur le workflow terminé
3. Faites défiler jusqu'à la section **Artifacts**
4. Téléchargez les fichiers générés

### Emplacements des builds

- **Android APK** : `flutter/build/app/outputs/flutter-apk/*.apk`
- **Android AAB** : `flutter/build/app/outputs/bundle/release/*.aab`
- **Web** : `flutter/build/web/**`
- **Windows** : `flutter/build/windows/x64/runner/Release/**`
- **Linux** : `flutter/build/linux/x64/release/bundle/**`
- **macOS** : `flutter/build/macos/Build/Products/Release/**`

## ⚙️ Configuration Flutter

- **Version Flutter** : 3.24.0 (stable)
- **SDK Dart** : >=3.0.0 <4.0.0
- **Compile SDK Android** : 34
- **Min SDK Android** : 21
- **Target SDK Android** : 34

## 🔍 Vérifications automatiques

Chaque workflow exécute :
- ✅ `flutter pub get` (installation des dépendances)
- ✅ `flutter analyze` (analyse statique du code)
- ✅ Build de la plateforme cible

## ⚠️ Notes importantes

1. **Secrets manquants** : Si les secrets Android ne sont pas configurés, le build utilisera la signature debug (non recommandé pour la production)

2. **Temps de build** : Les builds peuvent prendre 5-15 minutes selon la plateforme

3. **Rétention des artifacts** : Les artifacts sont conservés 30 jours (workflows individuels) ou 90 jours (all_in_one.yml)

4. **macOS** : Nécessite un runner macOS (disponible sur GitHub Actions)

5. **Windows** : Le build génère un dossier avec l'exécutable, pas un installateur MSI

## 🐛 Dépannage

### Build Android échoue
- Vérifiez que les secrets GitHub sont correctement configurés
- Vérifiez que le keystore est valide et encodé correctement en base64

### Build Web échoue
- Vérifiez que toutes les dépendances sont compatibles avec le web
- Certains packages peuvent ne pas supporter le web

### Build Desktop échoue
- Vérifiez que Flutter Desktop est activé : `flutter config --enable-*-desktop`
- Vérifiez les dépendances système requises

## 📝 Mise à jour

Pour mettre à jour la version Flutter dans les workflows, modifiez la ligne :
```yaml
flutter-version: '3.24.0'
```
dans chaque fichier `.github/workflows/*.yml`

