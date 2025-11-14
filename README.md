
# BARRY Pay‑WiFi (MVP Monorepo)

Une base **moderne et professionnelle** pour vendre l'accès Wi‑Fi via **Orange Money, MTN Mobile Money, PayPal, Visa** (adaptateurs prêts) et **activer automatiquement** la connexion (sans ouvrir de page Web) via :
- Provision d’un profil Wi‑Fi (Android/iOS/Windows) après paiement,
- OU ajout automatique de l’adresse **MAC**/utilisateur dans le routeur (MikroTik/UniFi) ou **RADIUS**.

> ⚠️ **Important** : les API de paiement, les restrictions locales (licences, ARTP/ARPT, régulation), et **Starlink** (revente/partage) ont des conditions strictes. Vérifiez la légalité et les ToS de votre pays/opérateur avant un déploiement réel.

## Périmètre & choix techniques
- **App mobile/desktop/web** : Flutter (Android, iOS, Windows, macOS, Linux, Web)
- **Backend** : FastAPI (Python 3.11) + PostgreSQL + Redis (en option), packagé avec Docker Compose
- **Intégrations** (stubs prêts) :
  - Paiements : Orange Money, MTN MoMo, PayPal, Visa (via passerelle), **Mock Sandbox** pour test rapide
  - Réseau : MikroTik (RouterOS API), UniFi (Controller API), FreeRADIUS (CoA / users), **Mock Wi‑Fi** pour test rapide
- **Design** : couleurs éclatantes, fond dégradé, icônes modernes (Material Icons)

## Structure
```
barry-paywifi/
  app_flutter/                # Application Flutter (UI moderne)
  backend/                    # API FastAPI + intégrations paiement & réseau
  docker/                     # Fichiers Docker/compose
  scripts/                    # Scripts utiles (dev/seed)
  .env.example                # Variables d'environnement
  README.md                   # Ce fichier
  LICENSE
```

## Démarrage ultra-rapide (démo locale)
1) **Backend (Docker)**
```bash
cd backend
cp ../.env.example .env
docker compose up --build
```
- API dispo sur `http://localhost:8000/docs` (Swagger)
- Mode mock : aucun argent réel, paiements **simulés** ✅

2) **App Flutter**
```bash
cd app_flutter
flutter pub get
flutter run -d chrome         # ou -d windows / -d android / -d ios
```
- Sur Android/iOS : l'app peut **proposer/configurer le Wi‑Fi** (voir code `wifi_provisioning.dart`).
- Sur desktop/web : **affiche le voucher/QR et statut**.

## Flux fonctionnel (MVP)
1. L’utilisateur choisit un **forfait** (jour/mois/année) dans l’app.
2. Il sélectionne un **moyen de paiement** (Orange/MTN/PayPal/Visa).
3. Paiement **Mock** (démo) → Statut **SUCCESS**.
4. L’app **provisionne** le Wi‑Fi (ajout du réseau/identifiants) **ou** l’API ajoute l’équipement au routeur/RADIUS (par **MAC**/utilisateur) → accès actif pour la **durée** du forfait.
5. Tableau de bord **"Mon accès"** : temps restant, renouvellement, facture PDF (à ajouter).

## Production (notes)
- iOS **oblige un Mac** pour compiler/signer.
- Android : `flutter build apk` ou `flutter build appbundle`.
- Desktop (Windows) : `flutter build windows`.
- **Paiements réels** : renseignez les clés dans `.env` et activez les adaptateurs (voir `backend/payments/`).
- **Réseau réel** : fournissez les accès MikroTik/UniFi/FreeRADIUS (voir `backend/network/`).

## Sécurité & conformité
- Chiffrez les secrets (Docker secrets, Vault).
- RGPD / protection des données.
- Conformité opérateurs (revendeurs, agréments).
- ToS Starlink : renseignez-vous avant tout partage/revente.

Bon dev ⚡
