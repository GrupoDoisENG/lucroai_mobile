import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository;

  AuthCubit({required this.repository}) : super(const AuthInitial());

  Future<void> restoreSession() async {
    emit(const AuthLoading());
    try {
      final session = await repository.restoreSession();
      if (session == null) {
        emit(const AuthUnauthenticated());
        return;
      }

      emit(AuthAuthenticated(session));
    } catch (_) {
      await repository.logout();
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> login({required String email, required String senha}) async {
    emit(const AuthLoading());
    try {
      final session = await repository.login(email: email, senha: senha);
      emit(AuthAuthenticated(session));
    } catch (error) {
      emit(AuthUnauthenticated(message: _mapErrorMessage(error)));
    }
  }

  Future<void> register({
    required String nome,
    required String email,
    required String senha,
    required String empresaNome,
    String? cnpj,
    String? segmento,
  }) async {
    emit(const AuthLoading());
    try {
      final session = await repository.register(
        nome: nome,
        email: email,
        senha: senha,
        empresaNome: empresaNome,
        cnpj: cnpj,
        segmento: segmento,
      );
      emit(AuthAuthenticated(session));
    } catch (error) {
      emit(AuthUnauthenticated(message: _mapErrorMessage(error)));
    }
  }

  Future<void> logout() async {
    emit(const AuthLoading());
    await repository.logout();
    emit(const AuthUnauthenticated());
  }

  String _mapErrorMessage(Object error) {
    if (error is ServerException || error is NetworkException) {
      return error.toString().replaceFirst(RegExp(r'^[^:]+: '), '');
    }

    return 'Não foi possível concluir a autenticação.';
  }
}
