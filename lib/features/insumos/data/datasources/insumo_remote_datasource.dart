import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_constants.dart';
import '../../domain/entities/insumo.dart';
import '../models/insumo_model.dart';

abstract class InsumoRemoteDatasource {
  Future<List<InsumoModel>> getInsumos({
    bool? ativo,
    InsumoCategoria? categoria,
    String? search,
  });

  Future<InsumoModel> getInsumo(String id);

  Future<InsumoModel> createInsumo(Map<String, dynamic> data);

  Future<InsumoModel> updateInsumo(String id, Map<String, dynamic> data);

  Future<void> deleteInsumo(String id);
}

class InsumoRemoteDatasourceImpl implements InsumoRemoteDatasource {
  final Dio dio;

  InsumoRemoteDatasourceImpl({required this.dio});

  @override
  Future<List<InsumoModel>> getInsumos({
    bool? ativo,
    InsumoCategoria? categoria,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (ativo != null) queryParams['ativo'] = ativo;
      if (categoria != null) queryParams['categoria'] = categoria.value;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await dio.get(
        ApiConstants.insumos,
        queryParameters: queryParams,
      );

      final data = _unwrapData(response.data) as List<dynamic>;
      var insumos = data
          .map((json) => InsumoModel.fromJson(json as Map<String, dynamic>))
          .toList();

      if (ativo != null) {
        insumos = insumos.where((insumo) => insumo.ativo == ativo).toList();
      }
      if (categoria != null) {
        insumos = insumos
            .where((insumo) => insumo.categoria == categoria)
            .toList();
      }
      if (search != null && search.isNotEmpty) {
        final normalizedSearch = search.toLowerCase();
        insumos = insumos
            .where(
              (insumo) => insumo.nome.toLowerCase().contains(normalizedSearch),
            )
            .toList();
      }

      return insumos;
    } on DioException catch (e) {
      throw _buildException(e);
    }
  }

  @override
  Future<InsumoModel> getInsumo(String id) async {
    try {
      final response = await dio.get(ApiConstants.insumoById(id));
      return InsumoModel.fromJson(
        _unwrapData(response.data) as Map<String, dynamic>,
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
        _unwrapData(response.data) as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _buildException(e);
    }
  }

  @override
  Future<InsumoModel> updateInsumo(String id, Map<String, dynamic> data) async {
    try {
      final response = await dio.patch(ApiConstants.insumoById(id), data: data);
      return InsumoModel.fromJson(
        _unwrapData(response.data) as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _buildException(e);
    }
  }

  @override
  Future<void> deleteInsumo(String id) async {
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

  dynamic _unwrapData(dynamic responseData) {
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      return responseData['data'];
    }
    return responseData;
  }
}
