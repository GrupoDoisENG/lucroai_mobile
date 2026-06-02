import '../entities/movimentacao_estoque.dart';
import '../repositories/estoque_repository.dart';

class RegistrarEntradaEstoqueUsecase {
  final EstoqueRepository repository;

  RegistrarEntradaEstoqueUsecase(this.repository);

  Future<void> call({
    required String insumoId,
    required double quantidade,
    required OrigemMovimentacao origem,
  }) async {
    return await repository.registrarEntradaEstoque(
      insumoId: insumoId,
      quantidade: quantidade,
      origem: origem,
    );
  }
}
