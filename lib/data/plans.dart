class WifiPlan {
  final String id;
  final String name;
  final String description;
  final int price;
  final int durationMinutes; // durée en minutes
  final bool isBusiness;

  WifiPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMinutes,
    this.isBusiness = false,
  });
}

/// ----------------------------
/// FORFAITS INDIVIDUELS FIXES
/// ----------------------------
final List<WifiPlan> userPlans = [
  WifiPlan(
    id: "p1",
    name: "Pass 30 minutes",
    description: "Idéal pour un test rapide",
    price: 500,
    durationMinutes: 30,
  ),
  WifiPlan(
    id: "p2",
    name: "Pass 1 heure",
    description: "Navigation courte durée",
    price: 1000,
    durationMinutes: 60,
  ),
  WifiPlan(
    id: "p3",
    name: "Pass 2 heures",
    description: "Pour usages et réseaux sociaux",
    price: 2000,
    durationMinutes: 120,
  ),
];

/// ----------------------------
/// FORFAITS ENTREPRISE
/// ----------------------------
final List<WifiPlan> businessPlans = [
  WifiPlan(
    id: "b1",
    name: "Entreprise 10 employés",
    description: "Idéal pour petits bureaux",
    price: 300000,
    durationMinutes: 24 * 60, // 1 jour
    isBusiness: true,
  ),
  WifiPlan(
    id: "b2",
    name: "Entreprise 30 employés",
    description: "Pour écoles, hôtels etc.",
    price: 800000,
    durationMinutes: 7 * 24 * 60, // 1 semaine
    isBusiness: true,
  ),
  WifiPlan(
    id: "b3",
    name: "Entreprise illimitée",
    description: "Grandes structures & cafés",
    price: 15000000,
    durationMinutes: 30 * 24 * 60, // 1 mois
    isBusiness: true,
  ),
  WifiPlan(
    id: "b4",
    name: "Pass Année",
    description: "Abonnement annuel complet",
    price: 15000000,
    durationMinutes: 365 * 24 * 60,
    isBusiness: true,
  ),
];

/// -----------------------------------------------------
/// MONTANT PERSONNALISÉ (1000 GNF = 1 heure)
/// -----------------------------------------------------
class CustomWifiPlan extends WifiPlan {
  CustomWifiPlan(int amount)
      : super(
          id: "custom",
          name: "Montant personnalisé",
          description:
              "Durée générée automatiquement selon le montant tapé",
          price: amount,
          durationMinutes: ((amount / 1000) * 60).toInt(),
          isBusiness: false,
        );
}
