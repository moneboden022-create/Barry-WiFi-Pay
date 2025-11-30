// lib/widgets/app_drawer.dart
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  String? _localImagePath;

  @override
  void initState() {
    super.initState();
    _loadAvatar();

    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  Future<void> _loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _localImagePath = prefs.getString("avatar_path");
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _animatedTile({
    required IconData icon,
    required String title,
    required String route,
    required int index,
  }) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, 0.08 * (index + 1)),
          end: Offset.zero,
        ).animate(_fade),
        child: ListTile(
          leading: Icon(icon),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          onTap: () {
            Navigator.pop(context);
            if (ModalRoute.of(context)?.settings.name != route) {
              Navigator.pushNamed(context, route);
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // 🔵 HEADER FIXÉ (anti overflow)
            SizedBox(
              height: 150,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primary, primary.withOpacity(0.85)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: Container(color: Colors.transparent),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 10, top: 20),
                    child: Row(
                      children: [
                        Hero(
                          tag: "drawer-avatar",
                          child: CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.white,
                            backgroundImage: _localImagePath != null
                                ? FileImage(File(_localImagePath!))
                                : null,
                            child: _localImagePath == null
                                ? const Icon(Icons.person,
                                    size: 38, color: Colors.blue)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("BARRY WI-FI",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 3),
                              Text("Tableau de bord",
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 🔵 CONTENU SCROLLABLE (anti overflow web)
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 10),

                  _animatedTile(
                      icon: Icons.home_outlined,
                      title: "Accueil",
                      route: "/home",
                      index: 0),
                  _animatedTile(
                      icon: Icons.history_toggle_off,
                      title: "Historique des connexions",
                      route: "/connections",
                      index: 1),
                  _animatedTile(
                      icon: Icons.wifi_tethering,
                      title: "Activer / Désactiver Wi-Fi",
                      route: "/wifi-control",
                      index: 2),
                  _animatedTile(
                      icon: Icons.subscriptions,
                      title: "Abonnements",
                      route: "/subscriptions",
                      index: 3),
                  _animatedTile(
                      icon: Icons.card_giftcard_outlined,
                      title: "Voucher",
                      route: "/voucher",
                      index: 4),
                  _animatedTile(
                      icon: Icons.dashboard_outlined,
                      title: "Admin Dashboard",
                      route: "/admin",
                      index: 5),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Divider(),
                  ),

                  _animatedTile(
                      icon: Icons.settings_outlined,
                      title: "Paramètres",
                      route: "/settings",
                      index: 6),

                  _animatedTile(
                      icon: Icons.person,
                      title: "Mon Profil",
                      route: "/profile",
                      index: 7),

                  const SizedBox(height: 15),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: logout action
                      },
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text("Déconnexion",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 🔵 FOOTER FIXE
            Text(
              "v1.0 • BARRY WI-FI",
              style:
                  TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
