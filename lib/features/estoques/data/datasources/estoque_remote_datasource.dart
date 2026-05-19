import 'package:dio/dio.dart';
import '../../../../core/network/api_constants.dart';
import '../../domain/entities/movimentacao_estoque.dart';
import '../models/estoque_com_insumo_model.dart';
import '../models/movimentacao_estoque_model.dart';

class EstoqueRemoteDatasource {
  final Dio dio;

  EstoqueRemoteDatasource({required this.dio});

  Future<List<EstoqueComInsumoModel>> getEstoques() async {
    try {
      final insumosResponse = await dio.get(ApiConstants.insumos);

      if (insumosResponse.statusCode == 200) {
        final insumos = _unwrapData(insumosResponse.data) as List<dynamic>;
        final estoques = <EstoqueComInsumoModel>[];

        for (final rawInsumo in insumos) {
          final insumo = rawInsumo as Map<String, dynamic>;
          final insumoId = insumo['id'].toString();
          final estoque = await getEstoqueByInsumoId(insumoId);
          estoques.add(
            EstoqueComInsumoModel(
              id: estoque.id,
              insumoId: insumoId,
              insumoNome: insumo['nome'] as String,
              insumoCategoria: 'materia_prima',
              insumoUnidade: (insumo['unidade'] ?? 'UN').toString(),
              quantidadeDisponivel: estoque.quantidadeDisponivel,
              quantidadeMinima: estoque.quantidadeMinima,
              dataAlteracao: estoque.dataAlteracao,
            ),
          );
        }

        return estoques;
      }
      throw Exception('Erro ao carregar estoques');
    } catch (e) {
      rethrow;
    }
  }

  Future<EstoqueComInsumoModel> getEstoqueByInsumoId(String insumoId) async {
    try {
      final response = await dio.get(ApiConstants.estoqueByInsumoId(insumoId));

      if (response.statusCode == 200) {
        final data = _unwrapData(response.data) as Map<String, dynamic>;
        return EstoqueComInsumoModel.fromJson({
          ...data,
          'insumoNome': data['insumoNome'] ?? 'Insumo $insumoId',
          'insumoCategoria': data['insumoCategoria'] ?? 'materia_prima',
          'insumoUnidade': data['insumoUnidade'] ?? 'UN',
        });
      }
      throw Exception('Erro ao carregar estoque do insumo');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> registrarEntradaEstoque({
    required String insumoId,
    required double quantidade,
    required String origem,
  }) async {
    try {
      await dio.post(
        ApiConstants.estoqueEntradaByInsumoId(insumoId),
        data: {
          'quantidade': quantidade,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> atualizarEstoque({
    required String insumoId,
    required double quantidadeDisponivel,
    required double quantidadeMinima,
  }) async {
    throw UnsupportedError(
      'O backend atual nao expoe endpoint para atualizar estoque diretamente '
      '(insumoId: $insumoId, quantidadeDisponivel: $quantidadeDisponivel, '
      'quantidadeMinima: $quantidadeMinima).',
    );
  }

  Future<List<MovimentacaoEstoqueModel>> getMovimentacoes({
    String? insumoId,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    try {
      if (insumoId == null) return [];

      final response = await dio.get(
        ApiConstants.estoqueMovimentacoesByInsumoId(insumoId),
      );

      if (response.statusCode == 200) {
        final data = _unwrapData(response.data) as List<dynamic>;
        return data
            .map(
              (json) =>
                  MovimentacaoEstoqueModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }
      throw Exception('Erro ao carregar movimentações');
    } catch (e) {
      rethrow;
    }
  }

  dynamic _unwrapData(dynamic responseData) {
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      return responseData['data'];
    }
    return responseData;
  }
}
