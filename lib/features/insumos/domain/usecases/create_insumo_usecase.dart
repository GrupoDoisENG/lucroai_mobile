import '../entities/insumo.dart';
import '../repositories/insumo_repository.dart';

class CreateInsumoUsecase {
  final InsumoRepository repository;

  CreateInsumoUsecase(this.repository);

  Future<Insumo> call({
    required String nome,
    String? descricao,
    required InsumoCategoria categoria,
    required InsumoUnidadeMedida unidadeMedida,
    required double precoUnitario,
    required double estoqueMinimo,
    double? quantidadeEmbalagem,
    double? precoEmbalagem,
  }) {
    return repository.createInsumo(
      nome: nome,
      descricao: descricao,
      categoria: categoria,
      unidadeMedida: unidadeMedida,
      precoUnitario: precoUnitario,
      estoqueMinimo: estoqueMinimo,
      quantidadeEmbalagem: quantidadeEmbalagem,
      precoEmbalagem: precoEmbalagem,
    );
  }
}