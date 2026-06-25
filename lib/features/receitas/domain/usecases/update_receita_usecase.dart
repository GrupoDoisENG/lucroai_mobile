import '../../../insumos/domain/entities/insumo.dart';
import '../entities/receita.dart';
import '../repositories/receita_repository.dart';

class UpdateReceitaUsecase {
  final ReceitaRepository repository;

  UpdateReceitaUsecase(this.repository);

  Future<Receita> call({
    required int id,
    String? nome,
    double? rendimento,
    InsumoUnidadeMedida? unidadeRendimento,
    double? margemLucro,
    List<ReceitaItemInput>? insumos,
  }) {
    return repository.updateReceita(
      id: id,
      nome: nome,
      rendimento: rendimento,
      unidadeRendimento: unidadeRendimento,
      margemLucro: margemLucro,
      insumos: insumos,
    );
  }
}
