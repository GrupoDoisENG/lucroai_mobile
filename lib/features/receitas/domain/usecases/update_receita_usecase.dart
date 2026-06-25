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
    double? custoProducao,
    double? custoUnitario,
    double? margemLucro,
    double? precoSugerido,
    List<ReceitaItem>? itens,
  }) {
    return repository.updateReceita(
      id: id,
      nome: nome,
      rendimento: rendimento,
      unidadeRendimento: unidadeRendimento,
      custoProducao: custoProducao,
      custoUnitario: custoUnitario,
      margemLucro: margemLucro,
      precoSugerido: precoSugerido,
      itens: itens,
    );
  }
}
