import 'dart:convert';

class AuthSession {
  static void Function()? onUnauthorized;

  static String? token;
  static int? usuarioId;
  static String? usuarioNome;
  static String? usuarioEmail;
  static int? empresaId;
  static String? empresaNome;
  static String? empresaCnpj;
  static String? empresaSegmento;

  static bool get isAuthenticated => token != null && token!.isNotEmpty;

  static void start(String accessToken) {
    token = accessToken;
    final payload = _decodeJwtPayload(accessToken);
    usuarioId = payload['sub'] as int?;
    usuarioEmail = payload['email'] as String?;
    usuarioNome = payload['nome'] as String?;

    final empresa = payload['empresa'];
    if (empresa is Map<String, dynamic>) {
      empresaId = empresa['id'] as int?;
      empresaNome = empresa['nome'] as String?;
      empresaCnpj = empresa['cnpj'] as String?;
      empresaSegmento = empresa['segmento'] as String?;
    }
  }

  static void clear() {
    token = null;
    usuarioId = null;
    usuarioNome = null;
    usuarioEmail = null;
    empresaId = null;
    empresaNome = null;
    empresaCnpj = null;
    empresaSegmento = null;
  }

  static Map<String, dynamic> _decodeJwtPayload(String jwt) {
    final parts = jwt.split('.');
    if (parts.length != 3) return {};

    final normalized = base64Url.normalize(parts[1]);
    final decoded = utf8.decode(base64Url.decode(normalized));
    return jsonDecode(decoded) as Map<String, dynamic>;
  }
}
