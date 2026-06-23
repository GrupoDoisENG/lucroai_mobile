import 'package:dio/dio.dart';

class AuthRemoteDatasource {
  final Dio dio;

  AuthRemoteDatasource({required this.dio});

  Future<String> login({
    required String email,
    required String senha,
  }) async {
    final response = await dio.post(
      '/auth/login',
      data: {
        'email': email,
        'senha': senha,
      },
    );

    final body = response.data;
    if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is Map<String, dynamic>) {
        final token = data['access_token'];
        if (token is String && token.isNotEmpty) return token;
      }
    }

    throw Exception('Resposta de login invalida');
  }
}
