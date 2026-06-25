import 'package:shared_preferences/shared_preferences.dart';

import 'local_datasource.dart';

class SharedPreferencesLocalDatasource implements LocalDatasource {
  final SharedPreferences _prefs;

  static const String _tokenKey = 'auth_token';

  SharedPreferencesLocalDatasource(this._prefs);

  @override
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  @override
  Future<String?> loadToken() async {
    return _prefs.getString(_tokenKey);
  }

  @override
  Future<void> clearToken() async {
    await _prefs.remove(_tokenKey);
  }
}
