import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../domain/entities/producao.dart';
import '../models/producao_model.dart';

class ProducaoRemoteDatasource {
  final Dio operationsDio;

  ProducaoRemoteDatasource({required this.operationsDio});

  Future<Producao> registrarProducao({
    required int receitaId,
    required int quantidade,
    List<int>? gastoIndiretoIds,
  }) async {
    final body = <String, dynamic>{
      'receita_id': receitaId,
      'quantidade': quantidade,
    };
    if (gastoIndiretoIds != null) {
      body['gasto_indireto_ids'] = gastoIndiretoIds;
    }

    final response = await operationsDio.post(
      ApiConstants.producoes,
      data: body,
    );
    return ProducaoModel.fromJson(_unwrap(response.data));
  }

  Future<List<Producao>> listarProducoes({int? receitaId}) async {
    final response = await operationsDio.get(
      ApiConstants.producoes,
      queryParameters: {
        if (receitaId != null) 'receitaId': receitaId,
      },
    );
    final data = _unwrapList(response.data);
    return data
        .map((j) => ProducaoModel.fromJson(Map<String, dynamic>.from(j)))
        .toList();
  }

  Map<String, dynamic> _unwrap(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['data'] is Map<String, dynamic>) return data['data'] as Map<String, dynamic>;
      return data;
    }
    throw Exception('Formato de resposta inválido');
  }

  List<dynamic> _unwrapList(dynamic data) {
    if (data is List) return data;
    if (data is Map && data['data'] is List) return data['data'] as List;
    return const [];
  }
}
