import '../../../insumos/domain/entities/insumo.dart';
import '../entities/receita.dart';
import '../repositories/receita_repository.dart';

class CreateReceitaUsecase {
  final ReceitaRepository repository;

  CreateReceitaUsecase(this.repository);

  Future<Receita> call({
    required String nome,
    required double rendimento,
    required InsumoUnidadeMedida unidadeRendimento,
    double? margemLucro,
    List<ReceitaItemInput> insumos = const [],
  }) {
    return repository.createReceita(
      nome: nome,
      rendimento: rendimento,
      unidadeRendimento: unidadeRendimento,
      margemLucro: margemLucro,
      insumos: insumos,
    );
  }
}
