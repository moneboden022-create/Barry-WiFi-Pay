// lib/screens/admin/admin_dashboard_screen.dart
// Dashboard Admin Professionnel 5G - BARRY WiFi
// Design moderne avec Material 3, néon et graphiques

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/admin_service.dart';
import '../../services/admin_auth_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  bool _loading = true;
  String _adminName = "Admin";
  String _adminRole = "admin";

  // Stats
  Map<String, dynamic> _overview = {};
  List<Map<String, dynamic>> _dailyConnections = [];
  Map<String, dynamic> _weeklyComparison = {};

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    // Charger les infos admin
    final name = await AdminAuthService.getName();
    final role = await AdminAuthService.getRole();

    // Charger les stats
    final overview = await AdminService.getOverviewStats();
    final connections = await AdminService.getDailyConnections(days: 7);
    final weekly = await AdminService.getWeeklyComparison();

    setState(() {
      _adminName = name ?? "Admin";
      _adminRole = role ?? "admin";
      _overview = overview;
      _dailyConnections = connections;
      _weeklyComparison = weekly;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.cyan),
              )
            : CustomScrollView(
                slivers: [
                  // App Bar personnalisé
                  _buildAppBar(),

                  // Contenu
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Bienvenue
                        _buildWelcomeCard(),
                        const SizedBox(height: 20),

                        // Stats rapides
                        _buildQuickStats(),
                        const SizedBox(height: 20),

                        // Graphique connexions
                        _buildConnectionsChart(),
                        const SizedBox(height: 20),

                        // Comparaison semaine
                        _buildWeeklyComparison(),
                        const SizedBox(height: 20),

                        // Actions rapides
                        _buildQuickActions(),
                        const SizedBox(height: 20),

                        // Revenus
                        _buildRevenueCard(),
                        const SizedBox(height: 100),
                      ]),
                    ),
                  ),
                ],
              ),
      ),

      // Bottom Navigation
      bottomNavigationBar: _buildBottomNav(),

      // FAB
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateVoucherDialog,
        backgroundColor: Colors.cyan,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 80,
      floating: true,
      backgroundColor: const Color(0xFF0D1B2A),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.cyan),
          onPressed: _loadData,
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.red),
          onPressed: _logout,
        ),
      ],
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.cyan.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.admin_panel_settings, color: Colors.cyan),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "BARRY WiFi",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Admin Dashboard",
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.cyan.shade900, Colors.blue.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bienvenue, $_adminName",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _adminRole.toUpperCase(),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Tableau de bord en temps réel",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white30, width: 2),
            ),
            child: const Icon(
              Icons.dashboard,
              size: 40,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final users = _overview["users"] ?? {};
    final connections = _overview["connections"] ?? {};
    final vouchers = _overview["vouchers"] ?? {};
    final devices = _overview["devices"] ?? {};

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _statCard(
          "Utilisateurs",
          "${users["total"] ?? 0}",
          Icons.people,
          Colors.blue,
          "+${users["today"] ?? 0} aujourd'hui",
        ),
        _statCard(
          "Connexions",
          "${connections["today"] ?? 0}",
          Icons.wifi,
          Colors.green,
          "${connections["active_now"] ?? 0} actives",
        ),
        _statCard(
          "Vouchers",
          "${vouchers["available"] ?? 0}",
          Icons.card_giftcard,
          Colors.orange,
          "${vouchers["used"] ?? 0} utilisés",
        ),
        _statCard(
          "Appareils",
          "${devices["total"] ?? 0}",
          Icons.devices,
          Colors.purple,
          "${devices["blocked"] ?? 0} bloqués",
        ),
      ],
    );
  }

  Widget _statCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionsChart() {
    if (_dailyConnections.isEmpty) {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Connexions (7 jours)",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.trending_up, color: Colors.green),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white.withOpacity(0.1),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < _dailyConnections.length) {
                          return Text(
                            _dailyConnections[index]["label"] ?? "",
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                            ),
                          );
                        }
                        return const Text("");
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _dailyConnections.asMap().entries.map((e) {
                      return FlSpot(
                        e.key.toDouble(),
                        (e.value["connections"] ?? 0).toDouble(),
                      );
                    }).toList(),
                    isCurved: true,
                    color: Colors.cyan,
                    barWidth: 3,
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.cyan.withOpacity(0.2),
                    ),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                        radius: 4,
                        color: Colors.cyan,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyComparison() {
    final thisWeek = _weeklyComparison["this_week"] ?? {};
    final changes = _weeklyComparison["changes"] ?? {};

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Cette semaine vs Précédente",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _comparisonItem(
                "Connexions",
                "${thisWeek["connections"] ?? 0}",
                changes["connections"] ?? 0,
              ),
              _comparisonItem(
                "Nouveaux",
                "${thisWeek["new_users"] ?? 0}",
                changes["new_users"] ?? 0,
              ),
              _comparisonItem(
                "Vouchers",
                "${thisWeek["vouchers_used"] ?? 0}",
                changes["vouchers_used"] ?? 0,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _comparisonItem(String label, String value, num change) {
    final isPositive = change >= 0;
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                color: isPositive ? Colors.green : Colors.red,
                size: 14,
              ),
              Text(
                "${change.abs()}%",
                style: TextStyle(
                  color: isPositive ? Colors.green : Colors.red,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Actions rapides",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _actionButton("Vouchers", Icons.card_giftcard, Colors.orange, () {
              Navigator.pushNamed(context, '/admin/vouchers');
            }),
            _actionButton("Utilisateurs", Icons.people, Colors.blue, () {
              Navigator.pushNamed(context, '/admin/users');
            }),
            _actionButton("Appareils", Icons.devices, Colors.purple, () {
              Navigator.pushNamed(context, '/admin/devices');
            }),
            _actionButton("Connexions", Icons.history, Colors.green, () {
              Navigator.pushNamed(context, '/admin/connections');
            }),
            _actionButton("Stats", Icons.bar_chart, Colors.cyan, () {
              Navigator.pushNamed(context, '/admin/stats');
            }),
            _actionButton("Zones", Icons.map, Colors.teal, () {
              Navigator.pushNamed(context, '/admin/zones');
            }),
          ],
        ),
      ],
    );
  }

  Widget _actionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueCard() {
    final revenue = _overview["revenue"] ?? {};
    final total = revenue["total"] ?? 0;
    final today = revenue["today"] ?? 0;
    final currency = revenue["currency"] ?? "GNF";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade900, Colors.teal.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance_wallet, color: Colors.white),
              SizedBox(width: 10),
              Text(
                "Revenus",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "$total $currency",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "+$today $currency aujourd'hui",
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "💳 Paiement Orange/MTN bientôt disponible",
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: Colors.cyan,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Users"),
          BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: "Vouchers"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
        onTap: (index) {
          switch (index) {
            case 1:
              Navigator.pushNamed(context, '/admin/users');
              break;
            case 2:
              Navigator.pushNamed(context, '/admin/vouchers');
              break;
            case 3:
              Navigator.pushNamed(context, '/settings');
              break;
          }
        },
      ),
    );
  }

  void _showCreateVoucherDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1B263B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _VoucherCreationSheet(onCreated: _loadData),
    );
  }

  Future<void> _logout() async {
    await AdminAuthService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}

// Widget pour créer un voucher
class _VoucherCreationSheet extends StatefulWidget {
  final VoidCallback onCreated;

  const _VoucherCreationSheet({required this.onCreated});

  @override
  State<_VoucherCreationSheet> createState() => _VoucherCreationSheetState();
}

class _VoucherCreationSheetState extends State<_VoucherCreationSheet> {
  String _type = "individual";
  int _duration = 60;
  int _quantity = 1;
  bool _loading = false;

  Future<void> _create() async {
    setState(() => _loading = true);

    final result = await AdminService.createVoucher(
      type: _type,
      durationMinutes: _duration,
      quantity: _quantity,
    );

    setState(() => _loading = false);

    if (result["ok"] == true) {
      widget.onCreated();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${result["data"]?["created"] ?? _quantity} voucher(s) créé(s)"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result["error"] ?? "Erreur"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Créer un Voucher",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Type
          const Text("Type", style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _type,
            dropdownColor: const Color(0xFF1B263B),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            items: const [
              DropdownMenuItem(value: "individual", child: Text("Individual (1 appareil)")),
              DropdownMenuItem(value: "business", child: Text("Business (3 appareils)")),
              DropdownMenuItem(value: "enterprise", child: Text("Enterprise (10 appareils)")),
            ],
            onChanged: (v) => setState(() => _type = v!),
          ),
          const SizedBox(height: 16),

          // Durée
          const Text("Durée (minutes)", style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Slider(
            value: _duration.toDouble(),
            min: 30,
            max: 1440,
            divisions: 28,
            activeColor: Colors.cyan,
            label: "$_duration min",
            onChanged: (v) => setState(() => _duration = v.toInt()),
          ),
          Text(
            "$_duration minutes (${(_duration / 60).toStringAsFixed(1)}h)",
            style: const TextStyle(color: Colors.cyan),
          ),
          const SizedBox(height: 16),

          // Quantité
          const Text("Quantité", style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                icon: const Icon(Icons.remove_circle, color: Colors.cyan),
              ),
              Text(
                "$_quantity",
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
              IconButton(
                onPressed: _quantity < 100 ? () => setState(() => _quantity++) : null,
                icon: const Icon(Icons.add_circle, color: Colors.cyan),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Bouton
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _create,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("CRÉER VOUCHER(S)", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

