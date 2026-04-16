import '../entities/insumo.dart';
import '../repositories/insumo_repository.dart';

class UpdateInsumoUsecase {
  final InsumoRepository repository;

  UpdateInsumoUsecase(this.repository);

  Future<Insumo> call({
    required String id,
    String? nome,
    String? descricao,
    InsumoCategoria? categoria,
    InsumoUnidadeMedida? unidadeMedida,
    double? precoUnitario,
    double? estoqueMinimo,
    bool? ativo,
    double? quantidadeEmbalagem,
    double? precoEmbalagem,
  }) {
    return repository.updateInsumo(
      id: id,
      nome: nome,
      descricao: descricao,
      categoria: categoria,
      unidadeMedida: unidadeMedida,
      precoUnitario: precoUnitario,
      estoqueMinimo: estoqueMinimo,
      ativo: ativo,
      quantidadeEmbalagem: quantidadeEmbalagem,
      precoEmbalagem: precoEmbalagem,
    );
  }
}