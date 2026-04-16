import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_constants.dart';
import '../models/insumo_model.dart';

abstract class InsumoRemoteDatasource {
  Future<List<InsumoModel>> getInsumos();

  Future<InsumoModel> getInsumo(int id);

  Future<InsumoModel> createInsumo(Map<String, dynamic> data);

  Future<InsumoModel> updateInsumo(int id, Map<String, dynamic> data);

  Future<void> deleteInsumo(int id);
}

class InsumoRemoteDatasourceImpl implements InsumoRemoteDatasource {
  final Dio dio;

  InsumoRemoteDatasourceImpl({required this.dio});

  @override
  Future<List<InsumoModel>> getInsumos() async {
    try {
      final response = await dio.get(ApiConstants.insumos);

      final data = _extractData(response.data) as List<dynamic>;
      return data
          .map((json) => InsumoModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _buildException(e);
    }
  }

  @override
  Future<InsumoModel> getInsumo(int id) async {
    try {
      final response = await dio.get(ApiConstants.insumoById(id));
      return InsumoModel.fromJson(
        _extractData(response.data) as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _buildException(e);
    }
  }

  @override
  Future<InsumoModel> createInsumo(Map<String, dynamic> data) async {
    try {
      final response = await dio.post(ApiConstants.insumos, data: data);
      return InsumoModel.fromJson(
        _extractData(response.data) as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _buildException(e);
    }
  }

  @override
  Future<InsumoModel> updateInsumo(int id, Map<String, dynamic> data) async {
    try {
      final response = await dio.patch(ApiConstants.insumoById(id), data: data);
      return InsumoModel.fromJson(
        _extractData(response.data) as Map<String, dynamic>,
      );
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

  Exception _buildException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return NetworkException(
        message: 'Sem conexão com o servidor: ${e.message}',
      );
    }
    return ServerException(
      message:
          e.response?.data?['message']?.toString() ??
          e.message ??
          'Erro no servidor',
      statusCode: e.response?.statusCode,
    );
  }

  Object? _extractData(Object? responseData) {
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      return responseData['data'];
    }

    return responseData;
  }
}
