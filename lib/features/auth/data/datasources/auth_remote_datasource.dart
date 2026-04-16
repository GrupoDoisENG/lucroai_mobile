import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_constants.dart';
import '../models/auth_session_model.dart';

abstract class AuthRemoteDatasource {
  Future<AuthSessionModel> login({
    required String email,
    required String senha,
  });

  Future<AuthSessionModel> register({
    required String nome,
    required String email,
    required String senha,
    required String empresaNome,
    String? cnpj,
    String? segmento,
  });
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final Dio dio;

  AuthRemoteDatasourceImpl({required this.dio});

  @override
  Future<AuthSessionModel> login({
    required String email,
    required String senha,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.authLogin,
        data: {'email': email, 'senha': senha},
      );

      return AuthSessionModel.fromApiJson(_extractData(response.data));
    } on DioException catch (e) {
      throw _buildException(e);
    }
  }

  @override
  Future<AuthSessionModel> register({
    required String nome,
    required String email,
    required String senha,
    required String empresaNome,
    String? cnpj,
    String? segmento,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.authRegister,
        data: {
          'nome': nome,
          'email': email,
          'senha': senha,
          'empresaNome': empresaNome,
          if (cnpj != null && cnpj.isNotEmpty) 'cnpj': cnpj,
          if (segmento != null && segmento.isNotEmpty) 'segmento': segmento,
        },
      );

      return AuthSessionModel.fromApiJson(_extractData(response.data));
    } on DioException catch (e) {
      throw _buildException(e);
    }
  }

  Exception _buildException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return NetworkException(
        message: 'Sem conexão com o servidor: ${e.message}',
      );
    }

    final responseData = e.response?.data;
    String message = e.message ?? 'Erro no servidor';

    if (responseData is Map<String, dynamic>) {
      final rawMessage = responseData['message'];
      if (rawMessage is List && rawMessage.isNotEmpty) {
        message = rawMessage.join('\n');
      } else if (rawMessage != null) {
        message = rawMessage.toString();
      }
    }

    return ServerException(
      message: message,
      statusCode: e.response?.statusCode,
    );
  }

  Map<String, dynamic> _extractData(Object? responseData) {
    if (responseData is Map<String, dynamic>) {
      final wrappedData = responseData['data'];
      if (wrappedData is Map<String, dynamic>) return wrappedData;
      return responseData;
    }

    throw const ServerException(message: 'Resposta invÃ¡lida do servidor');
  }
}
