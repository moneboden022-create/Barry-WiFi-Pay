class WifiPlan {
  final String id;
  final String name;
  final int price;
  final int durationMinutes; // durée en minutes
  final bool isBusiness;

  WifiPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.durationMinutes,
    this.isBusiness = false,
  });
}

final List<WifiPlan> userPlans = [
  WifiPlan(id: "p1", name: "30 minutes", price: 500, durationMinutes: 30),
  WifiPlan(id: "p2", name: "1 heure", price: 1000, durationMinutes: 60),
  WifiPlan(id: "p3", name: "2 heures", price: 2000, durationMinutes: 120),
  WifiPlan(id: "p4", name: "1 jour", price: 10000, durationMinutes: 24 * 60),
  WifiPlan(id: "p5", name: "1 mois", price: 150000, durationMinutes: 30 * 24 * 60),
  WifiPlan(id: "p6", name: "1 année", price: 1500000, durationMinutes: 12 * 30 * 24 * 60),
];

final List<WifiPlan> businessPlans = [
  WifiPlan(id: "b1", name: "Entreprise — 1 jour", price: 50000, durationMinutes: 24 * 60, isBusiness: true),
  WifiPlan(id: "b2", name: "Entreprise — 1 mois", price: 300000, durationMinutes: 30 * 24 * 60, isBusiness: true),
  WifiPlan(id: "b3", name: "Entreprise — 1 année", price: 3000000, durationMinutes: 12 * 30 * 24 * 60, isBusiness: true),
];
