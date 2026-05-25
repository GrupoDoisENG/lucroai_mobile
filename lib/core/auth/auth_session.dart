import 'dart:convert';

class AuthSession {
  static String? token;
  static int? empresaId;
  static String? empresaNome;
  static String? usuarioNome;
  static String? usuarioEmail;

  static bool get isAuthenticated => token != null && token!.isNotEmpty;

  static void start(String accessToken) {
    token = accessToken;
    final payload = _decodeJwtPayload(accessToken);
    usuarioEmail = payload['email'] as String?;
    usuarioNome = payload['nome'] as String?;

    final empresa = payload['empresa'];
    if (empresa is Map<String, dynamic>) {
      empresaId = empresa['id'] as int?;
      empresaNome = empresa['nome'] as String?;
    }
  }

  static void clear() {
    token = null;
    empresaId = null;
    empresaNome = null;
    usuarioNome = null;
    usuarioEmail = null;
  }

  static Map<String, dynamic> _decodeJwtPayload(String jwt) {
    final parts = jwt.split('.');
    if (parts.length != 3) return {};

    final normalized = base64Url.normalize(parts[1]);
    final decoded = utf8.decode(base64Url.decode(normalized));
    return jsonDecode(decoded) as Map<String, dynamic>;
  }
}
