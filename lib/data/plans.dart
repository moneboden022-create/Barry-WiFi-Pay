// lib/data/plans.dart
// ⭐ BARRY WI-FI — Plans & Forfaits 5ème Génération

/// ------------------------------------------------------------
/// MODELE PRINCIPAL DU FORFAIT
/// ------------------------------------------------------------
class WifiPlan {
  final String id;
  final String name;
  final String description;
  final int price;
  final int durationMinutes; // durée totale en minutes
  final int devices;          // nombre d'appareils autorisés
  final int speed;            // vitesse en Mbps
  final bool isBusiness;      // plan entreprise ?
  final bool isPremium;       // pour futur UI 5G premium

  WifiPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMinutes,
    this.devices = 1,
    this.speed = 50,          // vitesse par défaut: 50 Mbps
    this.isBusiness = false,
    this.isPremium = false,
  });

  /// Durée formatée en heures/minutes
  String get formattedDuration {
    if (durationMinutes >= 24 * 60) {
      final days = durationMinutes ~/ (24 * 60);
      return '$days jour${days > 1 ? 's' : ''}';
    } else if (durationMinutes >= 60) {
      final hours = durationMinutes ~/ 60;
      return '$hours heure${hours > 1 ? 's' : ''}';
    } else {
      return '$durationMinutes min';
    }
  }

  /// Prix formaté en GNF
  String get formattedPrice {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M GNF';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)} 000 GNF';
    }
    return '$price GNF';
  }

  /// Vitesse formatée
  String get formattedSpeed => '$speed Mbps';
}

/// ------------------------------------------------------------
/// 🧍 FORFAITS INDIVIDUELS
/// ------------------------------------------------------------
final List<WifiPlan> userPlans = [
  WifiPlan(
    id: "p1",
    name: "Pass 30 minutes",
    description: "Idéal pour tester la connexion",
    price: 500,
    durationMinutes: 30,
    devices: 1,
    speed: 50,
    isPremium: false,
  ),
  WifiPlan(
    id: "p2",
    name: "Pass 1 heure",
    description: "Navigation légère et réseaux sociaux",
    price: 1000,
    durationMinutes: 60,
    devices: 1,
    speed: 50,
  ),
  WifiPlan(
    id: "p3",
    name: "Pass 2 heures",
    description: "Utilisation moyenne (YouTube, réseaux)",
    price: 2000,
    durationMinutes: 120,
    devices: 1,
    speed: 50,
  ),
  WifiPlan(
    id: "p4",
    name: "Pass 3 heures",
    description: "Streaming et téléchargements",
    price: 3000,
    durationMinutes: 180,
    devices: 2,
    speed: 75,
    isPremium: true,
  ),
  WifiPlan(
    id: "p5",
    name: "Pass Journée",
    description: "24h de connexion illimitée",
    price: 5000,
    durationMinutes: 24 * 60,
    devices: 3,
    speed: 100,
    isPremium: true,
  ),
  WifiPlan(
    id: "p6",
    name: "Pass Weekend",
    description: "48h de connexion premium",
    price: 8000,
    durationMinutes: 48 * 60,
    devices: 3,
    speed: 100,
    isPremium: true,
  ),
  WifiPlan(
    id: "p7",
    name: "Pass Semaine",
    description: "7 jours de connexion haute vitesse",
    price: 25000,
    durationMinutes: 7 * 24 * 60,
    devices: 5,
    speed: 150,
    isPremium: true,
  ),
];

/// ------------------------------------------------------------
/// 🏢 FORFAITS ENTREPRISE
/// ------------------------------------------------------------
final List<WifiPlan> businessPlans = [
  WifiPlan(
    id: "b1",
    name: "Entreprise 10 employés",
    description: "Pour petits bureaux / boutiques",
    price: 300000,
    durationMinutes: 24 * 60, // 1 jour
    devices: 10,
    speed: 100,
    isBusiness: true,
  ),
  WifiPlan(
    id: "b2",
    name: "Entreprise 30 employés",
    description: "Écoles, hôtels, mini-cafés",
    price: 800000,
    durationMinutes: 7 * 24 * 60, // 1 semaine
    devices: 30,
    speed: 200,
    isBusiness: true,
    isPremium: true,
  ),
  WifiPlan(
    id: "b3",
    name: "Entreprise illimitée",
    description: "Grandes structures / restaurants",
    price: 15000000,
    durationMinutes: 30 * 24 * 60, // 1 mois
    devices: 99,
    speed: 300,
    isBusiness: true,
    isPremium: true,
  ),
  WifiPlan(
    id: "b4",
    name: "Pass Année",
    description: "Abonnement professionnel annuel",
    price: 150000000,
    durationMinutes: 365 * 24 * 60,
    devices: 50,
    speed: 250,
    isBusiness: true,
    isPremium: true,
  ),
];

/// ------------------------------------------------------------
/// 📊 TOUS LES FORFAITS
/// ------------------------------------------------------------
List<WifiPlan> get allPlans => [...userPlans, ...businessPlans];

/// Trouver un plan par ID
WifiPlan? findPlanById(String id) {
  try {
    return allPlans.firstWhere((p) => p.id == id);
  } catch (_) {
    return null;
  }
}

/// ------------------------------------------------------------
/// 💰 MONTANT PERSONNALISÉ
/// 1 000 GNF = 1 heure → Auto-génération durée
/// ------------------------------------------------------------
class CustomWifiPlan extends WifiPlan {
  CustomWifiPlan(int amount)
      : super(
          id: "custom",
          name: "Montant personnalisé",
          description: "Durée générée automatiquement",
          price: amount,
          durationMinutes: ((amount / 1000) * 60).toInt(),
          devices: 1,
          speed: 50,
          isBusiness: false,
          isPremium: false,
        );
}

/// ------------------------------------------------------------
/// 🎁 FORFAITS PROMOTIONNELS (optionnel)
/// ------------------------------------------------------------
final List<WifiPlan> promoPlans = [
  WifiPlan(
    id: "promo1",
    name: "Offre Spéciale Weekend",
    description: "48h pour le prix de 24h !",
    price: 5000,
    durationMinutes: 48 * 60,
    devices: 2,
    speed: 100,
    isPremium: true,
  ),
];
