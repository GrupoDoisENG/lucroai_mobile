import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/security/token_provider.dart';
import '../models/auth_session_model.dart';

abstract class AuthLocalDatasource implements TokenProvider {
  Future<void> initialize();

  Future<AuthSessionModel?> restoreSession();

  Future<void> saveSession(AuthSessionModel session);

  Future<void> clearSession();
}

class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  static const _sessionKey = 'auth_session';

  final FlutterSecureStorage storage;
  AuthSessionModel? _cachedSession;

  AuthLocalDatasourceImpl({required this.storage});

  @override
  String? get accessToken => _cachedSession?.accessToken;

  @override
  Future<void> initialize() async {
    _cachedSession = await restoreSession();
  }

  @override
  Future<AuthSessionModel?> restoreSession() async {
    final rawSession = await storage.read(key: _sessionKey);
    if (rawSession == null || rawSession.isEmpty) {
      _cachedSession = null;
      return null;
    }

    _cachedSession = AuthSessionModel.fromStorageJson(
      jsonDecode(rawSession) as Map<String, dynamic>,
    );
    return _cachedSession;
  }

  @override
  Future<void> saveSession(AuthSessionModel session) async {
    _cachedSession = session;
    await storage.write(key: _sessionKey, value: jsonEncode(session.toJson()));
  }

  @override
  Future<void> clearSession() async {
    _cachedSession = null;
    await storage.delete(key: _sessionKey);
  }
}
