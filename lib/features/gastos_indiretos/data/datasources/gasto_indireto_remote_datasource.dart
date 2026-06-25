import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_constants.dart';
import '../models/gasto_indireto_model.dart';

abstract class GastoIndiretoRemoteDatasource {
  Future<List<GastoIndiretoModel>> getGastosIndiretos();
  Future<GastoIndiretoModel> createGastoIndireto(Map<String, dynamic> data);
  Future<GastoIndiretoModel> updateGastoIndireto(
    int id,
    Map<String, dynamic> data,
  );
  Future<void> deleteGastoIndireto(int id);
}

class GastoIndiretoRemoteDatasourceImpl implements GastoIndiretoRemoteDatasource {
  final Dio dio;

  GastoIndiretoRemoteDatasourceImpl({required this.dio});

  @override
  Future<List<GastoIndiretoModel>> getGastosIndiretos() async {
    try {
      final response = await dio.get(ApiConstants.gastosIndiretos);
      final list = _extractList(response.data);
      return list
          .map(
            (json) =>
                GastoIndiretoModel.fromJson(Map<String, dynamic>.from(json)),
          )
          .toList();
    } on DioException catch (e) {
      throw _buildException(e);
    } on ServerException {
      rethrow;
    } on Object {
      throw const ServerException(
        message: 'Formato de resposta invalido ao buscar gastos indiretos.',
      );
    }
  }

  @override
  Future<GastoIndiretoModel> createGastoIndireto(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await dio.post(ApiConstants.gastosIndiretos, data: data);
      return GastoIndiretoModel.fromJson(_extractMap(response.data));
    } on DioException catch (e) {
      throw _buildException(e);
    }
  }

  @override
  Future<GastoIndiretoModel> updateGastoIndireto(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await dio.put(
        ApiConstants.gastoIndiretoPorId(id),
        data: data,
      );
      return GastoIndiretoModel.fromJson(_extractMap(response.data));
    } on DioException catch (e) {
      throw _buildException(e);
    }
  }

  @override
  Future<void> deleteGastoIndireto(int id) async {
    try {
      await dio.delete(ApiConstants.gastoIndiretoPorId(id));
    } on DioException catch (e) {
      throw _buildException(e);
    }
  }

  List<dynamic> _extractList(dynamic responseData) {
    final parsed =
        responseData is String ? jsonDecode(responseData) : responseData;

    if (parsed is List) return parsed;

    if (parsed is Map && parsed['data'] is List) {
      return parsed['data'] as List;
    }

    throw const ServerException(
      message: 'Formato de resposta invalido ao buscar gastos indiretos.',
    );
  }

  Map<String, dynamic> _extractMap(dynamic responseData) {
    final parsed =
        responseData is String ? jsonDecode(responseData) : responseData;

    if (parsed is Map<String, dynamic>) {
      if (parsed['data'] is Map<String, dynamic>) {
        return parsed['data'] as Map<String, dynamic>;
      }
      return parsed;
    }

    throw const ServerException(
      message: 'Formato de resposta invalido.',
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
