import '../entities/movimentacao_estoque.dart';
import '../entities/estoque_com_insumo.dart';

abstract class EstoqueRepository {
  Future<List<EstoqueComInsumo>> getEstoques();
  Future<EstoqueComInsumo> getEstoqueByInsumoId(String insumoId);
  Future<void> registrarEntradaEstoque({
    required String insumoId,
    required double quantidade,
    required OrigemMovimentacao origem,
  });
  Future<void> atualizarEstoque({
    required String insumoId,
    required double quantidadeDisponivel,
    required double quantidadeMinima,
  });
  Future<List<MovimentacaoEstoque>> getMovimentacoes({
    String? insumoId,
    DateTime? dataInicio,
    DateTime? dataFim,
  });
}
