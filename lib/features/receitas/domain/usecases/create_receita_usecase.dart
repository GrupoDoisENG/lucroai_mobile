import '../../../insumos/domain/entities/insumo.dart';
import '../entities/receita.dart';
import '../repositories/receita_repository.dart';

class CreateReceitaUsecase {
  final ReceitaRepository repository;

  CreateReceitaUsecase(this.repository);

  Future<Receita> call({
    required int empresaId,
    required String nome,
    required double rendimento,
    required InsumoUnidadeMedida unidadeRendimento,
    required double custoProducao,
    required double custoUnitario,
    required double margemLucro,
    required double precoSugerido,
    List<ReceitaItem> itens = const [],
  }) {
    return repository.createReceita(
      empresaId: empresaId,
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
