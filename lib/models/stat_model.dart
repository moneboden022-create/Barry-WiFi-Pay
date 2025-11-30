// lib/models/stat_model.dart
class StatModel {
  final int totalUsers;
  final int activeSubscriptions;
  final double revenue;
  final int todaySales;

  StatModel({
    required this.totalUsers,
    required this.activeSubscriptions,
    required this.revenue,
    required this.todaySales,
  });

  factory StatModel.fromJson(Map<String, dynamic> j) {
    return StatModel(
      totalUsers: j['total_users'] ?? 0,
      activeSubscriptions: j['active_subscriptions'] ?? 0,
      revenue: (j['revenue'] ?? 0).toDouble(),
      todaySales: j['today_sales'] ?? 0,
    );
  }
}
