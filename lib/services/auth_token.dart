class AuthToken {
  static String? token;        // token normal
  static String? adminToken;   // token admin (Nouveau)

  static void clear() {
    token = null;
    adminToken = null;
  }
}
