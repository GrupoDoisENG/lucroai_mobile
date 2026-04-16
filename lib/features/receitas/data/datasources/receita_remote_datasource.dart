import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_constants.dart';
import '../../domain/entities/receita.dart';
import '../models/receita_model.dart';

abstract class ReceitaRemoteDatasource {
  Future<List<ReceitaModel>> getReceitas({
    bool? ativo,
    ReceitaCategoria? categoria,
    String? search,
  });

  Future<ReceitaModel> getReceita(String id);

  Future<ReceitaModel> createReceita(Map<String, dynamic> data);

  Future<ReceitaModel> updateReceita(String id, Map<String, dynamic> data);

  Future<void> deleteReceita(String id);
}

class ReceitaRemoteDatasourceImpl implements ReceitaRemoteDatasource {
  final Dio dio;

  ReceitaRemoteDatasourceImpl({required this.dio});

  @override
  Future<List<ReceitaModel>> getReceitas({
    bool? ativo,
    ReceitaCategoria? categoria,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (ativo != null) queryParams['ativo'] = ativo;
      if (categoria != null) queryParams['categoria'] = categoria.value;
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      final response = await dio.get(
        ApiConstants.receitas,
        queryParameters: queryParams,
      );

      final data = response.data as List<dynamic>;

      return data
          .map((json) => ReceitaModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _buildException(e);
    }
  }

  @override
  Future<ReceitaModel> getReceita(String id) async {
    try {
      final response = await dio.get(ApiConstants.receitaById(id));
      return ReceitaModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _buildException(e);
    }
  }

  @override
  Future<ReceitaModel> createReceita(Map<String, dynamic> data) async {
    try {
      final response = await dio.post(ApiConstants.receitas, data: data);
      return ReceitaModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _buildException(e);
    }
  }

  @override
  Future<ReceitaModel> updateReceita(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await dio.put(ApiConstants.receitaById(id), data: data);
      return ReceitaModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _buildException(e);
    }
  }

  @override
  Future<void> deleteReceita(String id) async {
    try {
      await dio.delete(ApiConstants.receitaById(id));
    } on DioException catch (e) {
      throw _buildException(e);
    }
  }

  Exception _buildException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return NetworkException(
        message: 'Sem conexao com o servidor: ${e.message}',
      );
    }

    final dynamic responseData = e.response?.data;
    String message = 'Erro no servidor';

    if (responseData is Map<String, dynamic>) {
      message =
          responseData['message']?.toString() ??
          responseData['error']?.toString() ??
          e.message ??
          message;
    } else if (e.message != null && e.message!.trim().isNotEmpty) {
      message = e.message!;
    }

    return ServerException(
      message: message,
      statusCode: e.response?.statusCode,
    );
  }
}
