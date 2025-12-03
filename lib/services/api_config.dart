// 🌐 BARRY WI-FI 5G - Configuration API Centrale

class ApiConfig {
  /// 🔥 URL principal du backend FastAPI
  /// Pour Android → remplacer localhost par l’IP de ton PC si nécessaire.
  static const String baseUrl = "http://localhost:8000/api";

  /// Retourne la route complète
  static String endpoint(String path) {
    return "$baseUrl$path";
  }
}
