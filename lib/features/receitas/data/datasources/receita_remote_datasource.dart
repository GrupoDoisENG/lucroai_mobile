import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_constants.dart';
import '../../domain/entities/simulacao_result.dart';
import '../models/receita_model.dart';
import '../models/simulacao_result_model.dart';

abstract class ReceitaRemoteDatasource {
  Future<List<ReceitaModel>> getReceitas({String? search});

  Future<ReceitaModel> getReceita(int id);

  Future<ReceitaModel> createReceita(Map<String, dynamic> data);

  Future<ReceitaModel> updateReceita(int id, Map<String, dynamic> data);

  Future<void> deleteReceita(int id);

  Future<SimulacaoResult> simularReceita(int id, Map<String, dynamic> data);
}

class ReceitaRemoteDatasourceImpl implements ReceitaRemoteDatasource {
  final Dio dio;

  ReceitaRemoteDatasourceImpl({required this.dio});

  @override
  Future<List<ReceitaModel>> getReceitas({String? search}) async {
    try {
      final response = await dio.get(ApiConstants.receitas);
      final data = _extractReceitasList(response.data);

      final receitas = data
          .map((json) => ReceitaModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();

      if (search == null || search.trim().isEmpty) {
        return receitas;
      }

      final normalizedSearch = search.trim().toLowerCase();
      return receitas
          .where(
            (receita) => receita.nome.toLowerCase().contains(normalizedSearch),
          )
          .toList();
    } on DioException catch (e) {
      throw _buildException(e);
    } on ServerException {
      rethrow;
    } on Object {
      throw const ServerException(
        message: 'Formato de resposta invalido ao buscar receitas.',
      );
    }
  }

  @override
  Future<ReceitaModel> getReceita(int id) async {
    try {
      final response = await dio.get(ApiConstants.receitaById(id));
      return ReceitaModel.fromJson(_extractReceitaMap(response.data));
    } on DioException catch (e) {
      throw _buildException(e);
    }
  }

  @override
  Future<ReceitaModel> createReceita(Map<String, dynamic> data) async {
    try {
      final response = await dio.post(ApiConstants.receitas, data: data);
      return ReceitaModel.fromJson(_extractReceitaMap(response.data));
    } on DioException catch (e) {
      throw _buildException(e);
    }
  }

  @override
  Future<ReceitaModel> updateReceita(int id, Map<String, dynamic> data) async {
    try {
      final response = await dio.put(
        ApiConstants.receitaById(id),
        data: data,
      );
      return ReceitaModel.fromJson(_extractReceitaMap(response.data));
    } on DioException catch (e) {
      throw _buildException(e);
    }
  }

  @override
  Future<void> deleteReceita(int id) async {
    try {
      await dio.delete(ApiConstants.receitaById(id));
    } on DioException catch (e) {
      throw _buildException(e);
    }
  }

  @override
  Future<SimulacaoResult> simularReceita(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await dio.post(
        ApiConstants.receitaSimular(id),
        data: data,
      );
      return SimulacaoResultModel.fromJson(_extractDataMap(response.data));
    } on DioException catch (e) {
      throw _buildException(e);
    }
  }

  Map<String, dynamic> _extractDataMap(dynamic responseData) {
    final parsedData = responseData is String
        ? jsonDecode(responseData)
        : responseData;

    if (parsedData is Map<String, dynamic>) {
      if (parsedData['data'] is Map<String, dynamic>) {
        return parsedData['data'] as Map<String, dynamic>;
      }

      return parsedData;
    }

    throw const ServerException(
      message: 'Formato de resposta invalido.',
    );
  }

  List<dynamic> _extractReceitasList(dynamic responseData) {
    final parsedData = responseData is String
        ? jsonDecode(responseData)
        : responseData;

    if (parsedData is List<dynamic>) {
      return parsedData;
    }

    if (parsedData is Map && parsedData['data'] is List<dynamic>) {
      return parsedData['data'] as List<dynamic>;
    }

    throw const ServerException(
      message: 'Formato de resposta invalido ao buscar receitas.',
    );
  }

  Map<String, dynamic> _extractReceitaMap(dynamic responseData) {
    final parsedData = responseData is String
        ? jsonDecode(responseData)
        : responseData;

    if (parsedData is Map<String, dynamic>) {
      if (parsedData['data'] is Map<String, dynamic>) {
        return parsedData['data'] as Map<String, dynamic>;
      }

      return parsedData;
    }

    throw const ServerException(
      message: 'Formato de resposta invalido ao ler receita.',
    );
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
