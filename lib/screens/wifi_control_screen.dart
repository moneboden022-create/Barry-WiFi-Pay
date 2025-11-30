import 'package:flutter/material.dart';
import '../services/wifi_service.dart';

class WifiControlScreen extends StatefulWidget {
  const WifiControlScreen({super.key});

  @override
  State<WifiControlScreen> createState() => _WifiControlScreenState();
}

class _WifiControlScreenState extends State<WifiControlScreen> {
  bool _loading = true;
  bool _wifiActive = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    bool status = await WifiService.getStatus();
    setState(() {
      _wifiActive = status;
      _loading = false;
    });
  }

  Future<void> _toggleWifi() async {
    setState(() => _loading = true);

    bool ok;
    if (_wifiActive) {
      ok = await WifiService.deactivate();
    } else {
      ok = await WifiService.activate();
    }

    if (ok) {
      setState(() => _wifiActive = !_wifiActive);
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Activer / Désactiver Wi-Fi"),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _wifiActive ? Icons.wifi : Icons.wifi_off,
                    size: 100,
                    color: _wifiActive ? Colors.green : Colors.red,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _wifiActive ? "Wi-Fi ACTIVÉ" : "Wi-Fi DÉSACTIVÉ",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _toggleWifi,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      backgroundColor: _wifiActive ? Colors.red : Colors.green,
                    ),
                    child: Text(
                      _wifiActive ? "Désactiver le Wi-Fi" : "Activer le Wi-Fi",
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
