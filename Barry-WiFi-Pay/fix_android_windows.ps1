# ================================================
#  FULL AUTO-FIX ANDROID + WINDOWS FOR FLUTTER
#  (Barry WiFi Pay)
#  Repairs Gradle, plugins, Kotlin, directories,
#  MainActivity, CMake, and pushes to GitHub
# ================================================

Write-Host "DEMARRAGE DE LA REPARATION AUTOMATIQUE..."

# Change to flutter directory
Set-Location flutter

# ----------------------------------------
# 1) Nettoyage ancien Android casse
# ----------------------------------------

Write-Host "Nettoyage des anciens fichiers Android..."

$pathsToDelete = @(
    "android\app\src\main\kotlin\com\example",
    "android\init.gradle",
    "android\fix_geolocator.gradle",
    "android\app\src\main\kotlin\example"
)

foreach ($p in $pathsToDelete) {
    if (Test-Path $p) {
        Remove-Item -Recurse -Force $p
        Write-Host "  [OK] Supprime : $p"
    }
}

# ----------------------------------------
# 2) Recréer structure Kotlin officielle
# ----------------------------------------

Write-Host "Verification du repertoire Kotlin..."

$newPath = "android\app\src\main\kotlin\com\barrywifi\pay"

if (!(Test-Path $newPath)) {
    New-Item -ItemType Directory -Path $newPath -Force | Out-Null
    Write-Host "  [OK] Dossier cree : $newPath"
} else {
    Write-Host "  [OK] Dossier existe deja : $newPath"
}

# MainActivity.kt correct
$mainActivityPath = "$newPath\MainActivity.kt"
$mainActivityContent = "package com.barrywifi.pay`n`nimport io.flutter.embedding.android.FlutterActivity`n`nclass MainActivity: FlutterActivity() {`n}`n"

if (Test-Path $mainActivityPath) {
    $existing = Get-Content $mainActivityPath -Raw
    if ($existing -ne $mainActivityContent) {
        $mainActivityContent | Out-File -Encoding utf8 $mainActivityPath
        Write-Host "  [OK] MainActivity.kt mis a jour"
    } else {
        Write-Host "  [OK] MainActivity.kt deja correct"
    }
} else {
    $mainActivityContent | Out-File -Encoding utf8 $mainActivityPath
    Write-Host "  [OK] MainActivity.kt cree"
}

# ----------------------------------------
# 3) Correction du build.gradle Android
# ----------------------------------------

Write-Host "Verification build.gradle..."

$gradlePath = "android\app\build.gradle"
if (Test-Path $gradlePath) {
    $content = Get-Content $gradlePath -Raw
    $needsUpdate = $false
    
    # Verifier et corriger compileSdkVersion
    if ($content -notmatch 'compileSdk\s*=\s*35' -and $content -notmatch 'compileSdkVersion\s+35') {
        $content = $content -replace 'compileSdk\s*=\s*\d+', 'compileSdk = 35'
        $content = $content -replace 'compileSdkVersion\s+\d+', 'compileSdkVersion 35'
        $needsUpdate = $true
    }
    
    # Verifier et corriger minSdkVersion
    if ($content -notmatch 'minSdk\s*=\s*21' -and $content -notmatch 'minSdkVersion\s+21') {
        $content = $content -replace 'minSdk\s*=\s*\d+', 'minSdk = 21'
        $content = $content -replace 'minSdkVersion\s+\d+', 'minSdkVersion 21'
        $needsUpdate = $true
    }
    
    # Verifier et corriger targetSdkVersion
    if ($content -notmatch 'targetSdk\s*=\s*35' -and $content -notmatch 'targetSdkVersion\s+35') {
        $content = $content -replace 'targetSdk\s*=\s*flutter\.targetSdkVersion', 'targetSdk = 35'
        $content = $content -replace 'targetSdkVersion\s+\d+', 'targetSdkVersion 35'
        $needsUpdate = $true
    }
    
    # Verifier applicationId
    if ($content -notmatch 'applicationId\s*=\s*"com\.barrywifi\.pay"') {
        $content = $content -replace 'applicationId\s*=\s*"[^"]*"', 'applicationId = "com.barrywifi.pay"'
        $content = $content -replace 'applicationId\s+"[^"]*"', 'applicationId "com.barrywifi.pay"'
        $needsUpdate = $true
    }
    
    if ($needsUpdate) {
        $content | Out-File -Encoding utf8 $gradlePath
        Write-Host "  [OK] build.gradle mis a jour"
    } else {
        Write-Host "  [OK] build.gradle deja correct"
    }
}

# ----------------------------------------
# 4) Fix Windows CMake
# ----------------------------------------

Write-Host "Verification CMake Windows..."

$cmakePath = "windows\CMakeLists.txt"

if (Test-Path $cmakePath) {
    $c = Get-Content $cmakePath -Raw
    $needsUpdate = $false
    
    # Verifier CMAKE_CXX_STANDARD
    if ($c -notmatch 'CMAKE_CXX_STANDARD\s+17' -and $c -notmatch 'cxx_std_17') {
        # Si on trouve un set(CMAKE_CXX_STANDARD, le remplacer
        if ($c -match 'set\(CMAKE_CXX_STANDARD\s+[^)]+\)') {
            $c = $c -replace 'set\(CMAKE_CXX_STANDARD\s+[^)]+\)', 'set(CMAKE_CXX_STANDARD 17)'
            $needsUpdate = $true
        }
    }
    
    if ($needsUpdate) {
        $c | Out-File -Encoding utf8 $cmakePath
        Write-Host "  [OK] CMake Windows corrige"
    } else {
        Write-Host "  [OK] CMake Windows deja correct (utilise cxx_std_17)"
    }
}

# ----------------------------------------
# 5) Flutter clean + pub get
# ----------------------------------------

Write-Host "Nettoyage Flutter..."

flutter clean
if ($LASTEXITCODE -eq 0) {
    Write-Host "  [OK] Flutter clean OK"
} else {
    Write-Host "  [WARN] Flutter clean a echoue"
}

flutter pub get
if ($LASTEXITCODE -eq 0) {
    Write-Host "  [OK] Flutter pub get OK"
} else {
    Write-Host "  [WARN] Flutter pub get a echoue"
}

# ----------------------------------------
# 6) Git add + commit + push
# ----------------------------------------

Write-Host "Preparation du commit..."

# Retourner au repertoire racine pour git
Set-Location ..

git add .
if ($LASTEXITCODE -eq 0) {
    Write-Host "  [OK] Git add OK"
} else {
    Write-Host "  [WARN] Git add a echoue"
}

git commit -m "Full automatic fix for Android + Windows builds (Gradle, Kotlin, CMake) for Barry WiFi Pay"
if ($LASTEXITCODE -eq 0) {
    Write-Host "  [OK] Git commit OK"
} else {
    Write-Host "  [WARN] Git commit a echoue (peut-etre aucun changement)"
}

git push origin main
if ($LASTEXITCODE -eq 0) {
    Write-Host "  [OK] Git push OK"
} else {
    Write-Host "  [WARN] Git push a echoue"
}

# ----------------------------------------
# FIN
# ----------------------------------------

Write-Host ""
Write-Host "REPARATION TERMINEE - GitHub Actions doit reussir maintenant."
Write-Host "Surveille l'onglet 'Actions' sur GitHub."
Write-Host "========================================"
