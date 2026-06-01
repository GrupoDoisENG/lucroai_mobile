import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_constants.dart';
import '../models/insumo_model.dart';

abstract class InsumoRemoteDatasource {
  Future<List<InsumoModel>> getInsumos({String? search});

  Future<InsumoModel> getInsumo(int id);

  Future<InsumoModel> createInsumo(Map<String, dynamic> data);

  Future<InsumoModel> updateInsumo(int id, Map<String, dynamic> data);

  Future<void> deleteInsumo(int id);
}

class InsumoRemoteDatasourceImpl implements InsumoRemoteDatasource {
  final Dio dio;

  InsumoRemoteDatasourceImpl({required this.dio});

  @override
  Future<List<InsumoModel>> getInsumos({String? search}) async {
    try {
      final response = await dio.get(ApiConstants.insumos);
      final data = _extractInsumosList(response.data);

      final insumos = data
          .map((json) => InsumoModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();

      if (search == null || search.trim().isEmpty) {
        return insumos;
      }

      final normalizedSearch = search.trim().toLowerCase();
      return insumos
          .where(
            (insumo) => insumo.nome.toLowerCase().contains(normalizedSearch),
          )
          .toList();
    } on DioException catch (e) {
      throw _buildException(e);
    } on ServerException {
      rethrow;
    } on Object {
      throw const ServerException(
        message: 'Formato de resposta invalido ao buscar insumos.',
      );
    }
  }

  @override
  Future<InsumoModel> getInsumo(int id) async {
    try {
      final response = await dio.get(ApiConstants.insumoById(id));
      return InsumoModel.fromJson(_extractInsumoMap(response.data));
    } on DioException catch (e) {
      throw _buildException(e);
    }
  }

  @override
  Future<InsumoModel> createInsumo(Map<String, dynamic> data) async {
    try {
      final response = await dio.post(ApiConstants.insumos, data: data);
      return InsumoModel.fromJson(_extractInsumoMap(response.data));
    } on DioException catch (e) {
      throw _buildException(e);
    }
  }

  @override
  Future<InsumoModel> updateInsumo(int id, Map<String, dynamic> data) async {
    try {
      final response = await dio.patch(ApiConstants.insumoById(id), data: data);
      return InsumoModel.fromJson(_extractInsumoMap(response.data));
    } on DioException catch (e) {
      throw _buildException(e);
    }
  }

  @override
  Future<void> deleteInsumo(int id) async {
    try {
      await dio.delete(ApiConstants.insumoById(id));
    } on DioException catch (e) {
      throw _buildException(e);
    }
  }

  List<dynamic> _extractInsumosList(dynamic responseData) {
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
      message: 'Formato de resposta invalido ao buscar insumos.',
    );
  }

  Map<String, dynamic> _extractInsumoMap(dynamic responseData) {
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
      message: 'Formato de resposta invalido ao ler insumo.',
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
