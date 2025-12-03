// lib/services/admin_voucher_service.dart
// 🎟️ Service Admin Vouchers - BARRY WiFi
// Génération massive, export PDF/Excel, gestion complète

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_token.dart';

/// Configuration des presets de vouchers
class VoucherPreset {
  final String key;
  final String label;
  final int price;
  final int durationMinutes;
  final int maxDevices;

  const VoucherPreset({
    required this.key,
    required this.label,
    required this.price,
    required this.durationMinutes,
    required this.maxDevices,
  });

  String get durationLabel {
    if (durationMinutes < 60) return "$durationMinutes min";
    if (durationMinutes < 1440) return "${durationMinutes ~/ 60}h";
    if (durationMinutes < 10080) return "${durationMinutes ~/ 1440} jour(s)";
    if (durationMinutes < 43200) return "${durationMinutes ~/ 10080} semaine(s)";
    return "${durationMinutes ~/ 43200} mois";
  }

  String get priceLabel => "${_formatPrice(price)} GNF";

  static String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
  }
}

/// Presets prédéfinis par catégorie
class VoucherPresets {
  // 1️⃣ INDIVIDUAL - Vouchers individuels
  static const List<VoucherPreset> individual = [
    VoucherPreset(key: "pass_500", label: "Pass 500", price: 500, durationMinutes: 30, maxDevices: 1),
    VoucherPreset(key: "pass_1000", label: "Pass 1000", price: 1000, durationMinutes: 60, maxDevices: 1),
    VoucherPreset(key: "pass_2000", label: "Pass 2000", price: 2000, durationMinutes: 120, maxDevices: 1),
    VoucherPreset(key: "pass_5000", label: "Pass 5000", price: 5000, durationMinutes: 360, maxDevices: 1),
    VoucherPreset(key: "1_jour", label: "1 Jour", price: 10000, durationMinutes: 1440, maxDevices: 1),
    VoucherPreset(key: "2_jours", label: "2 Jours", price: 18000, durationMinutes: 2880, maxDevices: 1),
    VoucherPreset(key: "3_jours", label: "3 Jours", price: 25000, durationMinutes: 4320, maxDevices: 2),
  ];

  // 2️⃣ SUBSCRIPTION - Abonnements
  static const List<VoucherPreset> subscription = [
    VoucherPreset(key: "semaine", label: "Abonnement Semaine", price: 50000, durationMinutes: 10080, maxDevices: 2),
    VoucherPreset(key: "mois", label: "Abonnement Mensuel", price: 150000, durationMinutes: 43200, maxDevices: 3),
    VoucherPreset(key: "trimestre", label: "Abonnement Trimestriel", price: 400000, durationMinutes: 129600, maxDevices: 3),
    VoucherPreset(key: "annee", label: "Abonnement Annuel", price: 1500000, durationMinutes: 525600, maxDevices: 5),
  ];

  // 3️⃣ BUSINESS - Entreprise
  static const List<VoucherPreset> business = [
    VoucherPreset(key: "10_employes", label: "Entreprise 10 Employés", price: 500000, durationMinutes: 43200, maxDevices: 10),
    VoucherPreset(key: "30_employes", label: "Entreprise 30 Employés", price: 1200000, durationMinutes: 43200, maxDevices: 30),
    VoucherPreset(key: "50_employes", label: "Entreprise 50 Employés", price: 2000000, durationMinutes: 43200, maxDevices: 50),
    VoucherPreset(key: "illimite", label: "Entreprise Illimité", price: 5000000, durationMinutes: 43200, maxDevices: 999),
  ];

  static List<VoucherPreset> getByCategory(String category) {
    switch (category) {
      case 'individual':
        return individual;
      case 'subscription':
        return subscription;
      case 'business':
        return business;
      default:
        return individual;
    }
  }
}

/// Modèle de voucher généré
class GeneratedVoucher {
  final int? id;
  final String code;
  final String category;
  final String type;
  final String? label;
  final int durationMinutes;
  final int maxDevices;
  final int price;
  final String status;
  final String? qrData;
  final String? createdAt;

  GeneratedVoucher({
    this.id,
    required this.code,
    required this.category,
    required this.type,
    this.label,
    required this.durationMinutes,
    required this.maxDevices,
    required this.price,
    required this.status,
    this.qrData,
    this.createdAt,
  });

  factory GeneratedVoucher.fromJson(Map<String, dynamic> json) {
    return GeneratedVoucher(
      id: json['id'],
      code: json['code'] ?? '',
      category: json['category'] ?? 'individual',
      type: json['type'] ?? 'individual',
      label: json['label'],
      durationMinutes: json['duration_minutes'] ?? 0,
      maxDevices: json['max_devices'] ?? 1,
      price: json['price'] ?? 0,
      status: json['status'] ?? 'unused',
      qrData: json['qr_data'],
      createdAt: json['created_at'],
    );
  }

  bool get isUsed => status == 'used';
}

/// Résultat de génération massive
class BulkGenerationResult {
  final bool success;
  final String? message;
  final String? batchId;
  final int created;
  final String category;
  final String? label;
  final int totalValue;
  final List<GeneratedVoucher> vouchers;
  final String? error;

  BulkGenerationResult({
    required this.success,
    this.message,
    this.batchId,
    required this.created,
    required this.category,
    this.label,
    required this.totalValue,
    required this.vouchers,
    this.error,
  });

  factory BulkGenerationResult.fromJson(Map<String, dynamic> json) {
    final vouchersList = (json['vouchers'] as List?)
        ?.map((v) => GeneratedVoucher.fromJson(v as Map<String, dynamic>))
        .toList() ?? [];

    return BulkGenerationResult(
      success: json['ok'] == true,
      message: json['message'],
      batchId: json['batch_id'],
      created: json['created'] ?? 0,
      category: json['category'] ?? 'individual',
      label: json['label'],
      totalValue: json['total_value'] ?? 0,
      vouchers: vouchersList,
    );
  }

  factory BulkGenerationResult.error(String errorMessage) {
    return BulkGenerationResult(
      success: false,
      created: 0,
      category: '',
      totalValue: 0,
      vouchers: [],
      error: errorMessage,
    );
  }
}

/// Service principal pour la gestion des vouchers admin
class AdminVoucherService {
  static const String baseUrl = "http://127.0.0.1:8000/api/admin/vouchers";

  /// 🔥 Récupère les headers avec le token admin de manière fiable
  static Future<Map<String, String>> _getHeaders() async {
    String? token;
    
    // 🔥 1. Priorité au token admin en mémoire
    if (AuthToken.adminToken != null && AuthToken.adminToken!.isNotEmpty) {
      token = AuthToken.adminToken;
    }
    // 🔥 2. Sinon token normal en mémoire
    else if (AuthToken.token != null && AuthToken.token!.isNotEmpty) {
      token = AuthToken.token;
    }
    // 🔥 3. Sinon essayer de récupérer depuis AdminAuthService
    else {
      // Import dynamique pour éviter les dépendances circulaires
      final adminToken = await _getAdminToken();
      if (adminToken != null && adminToken.isNotEmpty) {
        token = adminToken;
        AuthToken.adminToken = token;
      }
    }
    
    return {
      "Accept": "application/json",
      "Content-Type": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }
  
  /// 🔑 Récupère le token admin depuis SharedPreferences
  static Future<String?> _getAdminToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('admin_token') ?? prefs.getString('auth_token');
    } catch (e) {
      return null;
    }
  }

  /// 🔄 Headers synchrones (pour compatibilité) - utilise le token en mémoire
  static Map<String, String> _headers() {
    final token = AuthToken.adminToken?.isNotEmpty == true
        ? AuthToken.adminToken
        : AuthToken.token;
    return {
      "Accept": "application/json",
      "Content-Type": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  static dynamic _safeDecodeBody(http.Response res) {
    try {
      return json.decode(res.body);
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // 🚀 GÉNÉRATION MASSIVE DE VOUCHERS
  // ============================================================
  
  /// Génère massivement des vouchers
  static Future<BulkGenerationResult> generateBulk({
    required String category,
    required String type,
    required int durationMinutes,
    required int maxDevices,
    required int quantity,
    required int price,
    required String label,
    String? prefix,
    int? expiresInDays,
  }) async {
    final url = Uri.parse("$baseUrl/generate-bulk");
    
    try {
      // 🔥 Récupérer les headers avec token de manière fiable
      final headers = await _getHeaders();
      
      // 🔥 Vérifier si le token est présent
      if (!headers.containsKey('Authorization')) {
        return BulkGenerationResult.error("Non authentifié. Veuillez vous reconnecter en tant qu'admin.");
      }
      
      final body = {
        "category": category,
        "type": type,
        "duration_minutes": durationMinutes,
        "max_devices": maxDevices,
        "quantity": quantity,
        "price": price,
        "label": label,
        if (prefix != null && prefix.isNotEmpty) "prefix": prefix,
        if (expiresInDays != null) "expires_in_days": expiresInDays,
      };

      final res = await http.post(
        url,
        headers: headers,
        body: json.encode(body),
      );

      final data = _safeDecodeBody(res);
      
      if (res.statusCode == 200 && data != null) {
        return BulkGenerationResult.fromJson(data);
      }
      
      // 🔥 Gestion erreur 401 - Non authentifié
      if (res.statusCode == 401) {
        return BulkGenerationResult.error("Session expirée. Veuillez vous reconnecter en tant qu'admin.");
      }
      
      // 🔥 Gestion erreur 403 - Non autorisé
      if (res.statusCode == 403) {
        return BulkGenerationResult.error("Accès refusé. Droits administrateur requis.");
      }
      
      return BulkGenerationResult.error(
        data?['detail'] ?? "Erreur HTTP ${res.statusCode}"
      );
    } catch (e) {
      return BulkGenerationResult.error(e.toString());
    }
  }

  /// Génère des vouchers à partir d'un preset
  static Future<BulkGenerationResult> generateFromPreset({
    required String category,
    required VoucherPreset preset,
    required int quantity,
    String? prefix,
  }) async {
    return generateBulk(
      category: category,
      type: category,
      durationMinutes: preset.durationMinutes,
      maxDevices: preset.maxDevices,
      quantity: quantity,
      price: preset.price,
      label: preset.label,
      prefix: prefix,
    );
  }

  // ============================================================
  // 📋 LISTE DES VOUCHERS
  // ============================================================
  
  /// Liste tous les vouchers avec filtres
  static Future<Map<String, dynamic>> listVouchers({
    String? status,
    String? category,
    String? batchId,
    int limit = 200,
    int offset = 0,
  }) async {
    final params = <String, String>{
      'limit': '$limit',
      'offset': '$offset',
    };
    
    if (status != null) params['status'] = status;
    if (category != null) params['type'] = category;
    
    final url = Uri.parse(baseUrl).replace(queryParameters: params);
    
    try {
      // 🔥 Récupérer les headers avec token de manière fiable
      final headers = await _getHeaders();
      
      final res = await http.get(url, headers: headers);
      
      if (res.statusCode == 200) {
        final body = _safeDecodeBody(res);
        return {
          "total": body?['total'] ?? 0,
          "count": body?['count'] ?? 0,
          "vouchers": (body?['vouchers'] as List?)
              ?.map((v) => GeneratedVoucher.fromJson(v))
              .toList() ?? [],
        };
      }
      
      // 🔥 Gestion erreur 401/403
      if (res.statusCode == 401 || res.statusCode == 403) {
        return {"total": 0, "count": 0, "vouchers": [], "error": "Non authentifié ou accès refusé"};
      }
      
      return {"total": 0, "count": 0, "vouchers": [], "error": "HTTP ${res.statusCode}"};
    } catch (e) {
      return {"total": 0, "count": 0, "vouchers": [], "error": e.toString()};
    }
  }

  /// Récupère les vouchers d'un lot spécifique
  static Future<Map<String, dynamic>> getVouchersByBatch(String batchId, {bool includeQr = false}) async {
    final url = Uri.parse("$baseUrl/batch/$batchId").replace(
      queryParameters: {'include_qr': includeQr.toString()}
    );
    
    try {
      final res = await http.get(url, headers: _headers());
      
      if (res.statusCode == 200) {
        final body = _safeDecodeBody(res);
        return {
          "batch_id": body?['batch_id'],
          "count": body?['count'] ?? 0,
          "vouchers": (body?['vouchers'] as List?)
              ?.map((v) => GeneratedVoucher.fromJson(v))
              .toList() ?? [],
        };
      }
      
      return {"count": 0, "vouchers": [], "error": "HTTP ${res.statusCode}"};
    } catch (e) {
      return {"count": 0, "vouchers": [], "error": e.toString()};
    }
  }

  // ============================================================
  // 📄 EXPORT PDF
  // ============================================================
  
  /// Exporte les vouchers en PDF et retourne le chemin du fichier
  static Future<String?> exportPDF({
    String? batchId,
    String? status,
    String? category,
    int limit = 500,
  }) async {
    final params = <String, String>{'limit': '$limit'};
    if (batchId != null) params['batch_id'] = batchId;
    if (status != null) params['status'] = status;
    if (category != null) params['category'] = category;
    
    final url = Uri.parse("$baseUrl/export/pdf").replace(queryParameters: params);
    
    try {
      final res = await http.get(url, headers: _headers());
      
      if (res.statusCode == 200) {
        // Sauvegarder le fichier
        final directory = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final filePath = '${directory.path}/vouchers_$timestamp.pdf';
        final file = File(filePath);
        await file.writeAsBytes(res.bodyBytes);
        return filePath;
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // 📊 EXPORT EXCEL
  // ============================================================
  
  /// Exporte les vouchers en Excel et retourne le chemin du fichier
  static Future<String?> exportExcel({
    String? batchId,
    String? status,
    String? category,
    int limit = 5000,
  }) async {
    final params = <String, String>{'limit': '$limit'};
    if (batchId != null) params['batch_id'] = batchId;
    if (status != null) params['status'] = status;
    if (category != null) params['category'] = category;
    
    final url = Uri.parse("$baseUrl/export/excel").replace(queryParameters: params);
    
    try {
      final res = await http.get(url, headers: _headers());
      
      if (res.statusCode == 200) {
        // Sauvegarder le fichier
        final directory = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final filePath = '${directory.path}/vouchers_$timestamp.xlsx';
        final file = File(filePath);
        await file.writeAsBytes(res.bodyBytes);
        return filePath;
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // 📊 STATISTIQUES
  // ============================================================
  
  /// Récupère les statistiques des vouchers
  static Future<Map<String, dynamic>> getStats() async {
    final url = Uri.parse("$baseUrl/stats/summary");
    
    try {
      final headers = await _getHeaders();
      final res = await http.get(url, headers: headers);
      
      if (res.statusCode == 200) {
        return _safeDecodeBody(res) ?? {};
      }
      
      return {"error": "HTTP ${res.statusCode}"};
    } catch (e) {
      return {"error": e.toString()};
    }
  }

  /// Récupère les statistiques par catégorie
  static Future<Map<String, dynamic>> getStatsByCategory() async {
    final url = Uri.parse("$baseUrl/stats/by-category");
    
    try {
      final headers = await _getHeaders();
      final res = await http.get(url, headers: headers);
      
      if (res.statusCode == 200) {
        return _safeDecodeBody(res) ?? {};
      }
      
      return {"error": "HTTP ${res.statusCode}"};
    } catch (e) {
      return {"error": e.toString()};
    }
  }

  /// Récupère les presets disponibles depuis l'API
  static Future<Map<String, dynamic>> getPresets() async {
    final url = Uri.parse("$baseUrl/presets");
    
    try {
      final headers = await _getHeaders();
      final res = await http.get(url, headers: headers);
      
      if (res.statusCode == 200) {
        return _safeDecodeBody(res) ?? {};
      }
      
      return {"error": "HTTP ${res.statusCode}"};
    } catch (e) {
      return {"error": e.toString()};
    }
  }

  // ============================================================
  // 🔧 ACTIONS SUR UN VOUCHER
  // ============================================================
  
  /// Désactive un voucher
  static Future<bool> disableVoucher(int voucherId) async {
    final url = Uri.parse("$baseUrl/$voucherId/disable");
    
    try {
      final res = await http.post(url, headers: _headers());
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Réactive un voucher
  static Future<bool> enableVoucher(int voucherId) async {
    final url = Uri.parse("$baseUrl/$voucherId/enable");
    
    try {
      final res = await http.post(url, headers: _headers());
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Supprime un voucher
  static Future<bool> deleteVoucher(int voucherId) async {
    final url = Uri.parse("$baseUrl/$voucherId");
    
    try {
      final res = await http.delete(url, headers: _headers());
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Recherche un voucher par code
  static Future<GeneratedVoucher?> searchByCode(String code) async {
    final url = Uri.parse("$baseUrl/search/${code.toUpperCase()}");
    
    try {
      final res = await http.get(url, headers: _headers());
      
      if (res.statusCode == 200) {
        final body = _safeDecodeBody(res);
        if (body != null) {
          return GeneratedVoucher.fromJson(body);
        }
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
}

