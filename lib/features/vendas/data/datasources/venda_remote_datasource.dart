import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_constants.dart';
import '../models/venda_model.dart';

abstract class VendaRemoteDatasource {
  Future<VendaModel> criarVenda(Map<String, dynamic> data);

  Future<List<VendaModel>> listarVendas({
    int? empresaId,
    DateTime? dataInicio,
    DateTime? dataFim,
  });

  Future<VendaModel> atualizarStatus(int id, String status);
}

class VendaRemoteDatasourceImpl implements VendaRemoteDatasource {
  final Dio dio;

  VendaRemoteDatasourceImpl({required this.dio});

  @override
  Future<VendaModel> criarVenda(Map<String, dynamic> data) async {
    try {
      final response = await dio.post(ApiConstants.vendas, data: data);
      return VendaModel.fromJson(_extractVendaMap(response.data));
    } on DioException catch (e) {
      throw _buildException(e);
    }
  }

  @override
  Future<List<VendaModel>> listarVendas({
    int? empresaId,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.vendas,
        queryParameters: {
          if (empresaId != null) 'empresaId': empresaId,
          if (dataInicio != null) 'dataInicio': _formatDate(dataInicio),
          if (dataFim != null) 'dataFim': _formatDate(dataFim),
        },
      );
      final data = _extractVendasList(response.data);

      return data
          .map((json) => VendaModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } on DioException catch (e) {
      throw _buildException(e);
    } on ServerException {
      rethrow;
    } on Object {
      throw const ServerException(
        message: 'Formato de resposta inválido ao buscar vendas.',
      );
    }
  }

  List<dynamic> _extractVendasList(dynamic responseData) {
    final parsedData = responseData is String
        ? jsonDecode(responseData)
        : responseData;

    if (parsedData is List<dynamic>) {
      return parsedData;
    }

    if (parsedData is Map && parsedData['data'] is List<dynamic>) {
      return parsedData['data'] as List<dynamic>;
    }

    if (parsedData is Map && parsedData['vendas'] is List<dynamic>) {
      return parsedData['vendas'] as List<dynamic>;
    }

    throw const ServerException(
      message: 'Formato de resposta inválido ao buscar vendas.',
    );
  }

  Map<String, dynamic> _extractVendaMap(dynamic responseData) {
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
      message: 'Formato de resposta inválido ao ler venda.',
    );
  }

  Exception _buildException(DioException e) {
    if (e.response?.statusCode == 401) {
      return const ServerException(
        message: 'Sessão expirada. Faça login novamente.',
        statusCode: 401,
      );
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return NetworkException(
        message: 'Sem conexão com o servidor: ${e.message}',
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

  @override
  Future<VendaModel> atualizarStatus(int id, String status) async {
    try {
      final response = await dio.patch(
        ApiConstants.vendaStatus(id),
        data: {'status': status},
      );
      return VendaModel.fromJson(_extractVendaMap(response.data));
    } on DioException catch (e) {
      throw _buildException(e);
    }
  }

  String _formatDate(DateTime value) {
    return value.toIso8601String().split('T').first;
  }
}
