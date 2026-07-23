/// =========================================================
/// API CONFIGURATION
/// =========================================================
/// Ubah nilai [baseUrl] sesuai environment yang sedang digunakan:
///
/// [LOCAL EMULATOR Android]
///   baseUrl = 'http://10.0.2.2:8000';
///
/// [VS CODE PORT FORWARDING / GITHUB CODESPACE]
///   baseUrl = 'https://xxxx-forward.app.github.dev';
///
/// [NGROK]
///   baseUrl = 'https://xxxx.ngrok-free.app';
///
/// [PRODUCTION]
///   baseUrl = 'https://your-domain.com';
/// =========================================================
class ApiConfig {
  // ✏️ GANTI URL INI sesuai environment yang digunakan
  static const String baseUrl = 'https://steep-vagueness-rudder.ngrok-free.dev/';

  // --- Endpoints ---
  static String get smartphones => '$baseUrl/api/public/smartphones';
  static String get recommend => '$baseUrl/api/public/recommend';
}
