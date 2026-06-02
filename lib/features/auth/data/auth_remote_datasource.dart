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

    final data = _unwrapData(response.data);
    if (data is String) return data;

    throw Exception('Resposta de login invalida');
  }

  dynamic _unwrapData(dynamic responseData) {
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      return responseData['data'];
    }
    return responseData;
  }
}
