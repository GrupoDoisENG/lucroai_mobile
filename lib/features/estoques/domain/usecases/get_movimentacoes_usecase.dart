import '../entities/movimentacao_estoque.dart';
import '../repositories/estoque_repository.dart';

class GetMovimentacoesUsecase {
  final EstoqueRepository repository;

  GetMovimentacoesUsecase(this.repository);

  Future<List<MovimentacaoEstoque>> call({
    String? insumoId,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    return await repository.getMovimentacoes(
      insumoId: insumoId,
      dataInicio: dataInicio,
      dataFim: dataFim,
    );
  }
}
