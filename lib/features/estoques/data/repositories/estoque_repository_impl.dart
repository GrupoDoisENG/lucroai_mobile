import '../../domain/entities/estoque_com_insumo.dart';
import '../../domain/entities/movimentacao_estoque.dart';
import '../../domain/repositories/estoque_repository.dart';
import '../datasources/estoque_remote_datasource.dart';

class EstoqueRepositoryImpl implements EstoqueRepository {
  final EstoqueRemoteDatasource remoteDatasource;

  EstoqueRepositoryImpl({required this.remoteDatasource});

  @override
  Future<List<EstoqueComInsumo>> getEstoques() async {
    try {
      final models = await remoteDatasource.getEstoques();
      return models.cast<EstoqueComInsumo>();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<EstoqueComInsumo> getEstoqueByInsumoId(String insumoId) async {
    try {
      final model = await remoteDatasource.getEstoqueByInsumoId(insumoId);
      return model as EstoqueComInsumo;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> registrarEntradaEstoque({
    required String insumoId,
    required double quantidade,
    required OrigemMovimentacao origem,
  }) async {
    try {
      final origemStr = origem == OrigemMovimentacao.compra ? 'COMPRA' : 'PRODUCAO';
      await remoteDatasource.registrarEntradaEstoque(
        insumoId: insumoId,
        quantidade: quantidade,
        origem: origemStr,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> atualizarEstoque({
    required String insumoId,
    required double quantidadeDisponivel,
    required double quantidadeMinima,
  }) async {
    try {
      await remoteDatasource.atualizarEstoque(
        insumoId: insumoId,
        quantidadeDisponivel: quantidadeDisponivel,
        quantidadeMinima: quantidadeMinima,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<MovimentacaoEstoque>> getMovimentacoes({
    String? insumoId,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    try {
      final models = await remoteDatasource.getMovimentacoes(
        insumoId: insumoId,
        dataInicio: dataInicio,
        dataFim: dataFim,
      );
      return models.cast<MovimentacaoEstoque>();
    } catch (e) {
      rethrow;
    }
  }
}
