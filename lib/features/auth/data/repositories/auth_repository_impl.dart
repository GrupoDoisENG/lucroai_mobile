import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;
  final AuthLocalDatasource localDatasource;

  AuthRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
  });

  @override
  Future<AuthSession> login({
    required String email,
    required String senha,
  }) async {
    final session = await remoteDatasource.login(email: email, senha: senha);
    await localDatasource.saveSession(session);
    return session;
  }

  @override
  Future<AuthSession> register({
    required String nome,
    required String email,
    required String senha,
    required String empresaNome,
    String? cnpj,
    String? segmento,
  }) async {
    final session = await remoteDatasource.register(
      nome: nome,
      email: email,
      senha: senha,
      empresaNome: empresaNome,
      cnpj: cnpj,
      segmento: segmento,
    );
    await localDatasource.saveSession(session);
    return session;
  }

  @override
  Future<AuthSession?> restoreSession() => localDatasource.restoreSession();

  @override
  Future<void> logout() => localDatasource.clearSession();
}
