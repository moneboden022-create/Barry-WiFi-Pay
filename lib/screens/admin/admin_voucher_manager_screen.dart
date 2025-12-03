// lib/screens/admin/admin_voucher_manager_screen.dart

import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

class AdminVoucherManagerScreen extends StatefulWidget {
  const AdminVoucherManagerScreen({super.key});

  @override
  State<AdminVoucherManagerScreen> createState() => _AdminVoucherManagerScreenState();
}

class _AdminVoucherManagerScreenState extends State<AdminVoucherManagerScreen> {
  late Future<List<dynamic>> _vouchers;

  @override
  void initState() {
    super.initState();
    _vouchers = _loadVouchers();
  }

  Future<List<dynamic>> _loadVouchers() async {
    final res = await AdminService.getVouchers();
    return res["vouchers"] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gestion des Vouchers")),
      body: FutureBuilder<List<dynamic>>(
        future: _vouchers,
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());

          final vouchers = snap.data!;
          if (vouchers.isEmpty) return const Center(child: Text("Aucun voucher"));

          return ListView.builder(
            itemCount: vouchers.length,
            itemBuilder: (ctx, i) {
              final v = vouchers[i];

              return ListTile(
                title: Text(v["code"] ?? "CODE"),
                subtitle: Text("Durée : ${v["duration_minutes"]} min"),
                trailing: Text(v["type"] ?? ""),
              );
            },
          );
        },
      ),
    );
  }
}
