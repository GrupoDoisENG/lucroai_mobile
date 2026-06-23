abstract class LocalDatasource {
  Future<void> saveToken(String token);
  Future<String?> loadToken();
  Future<void> clearToken();
}
