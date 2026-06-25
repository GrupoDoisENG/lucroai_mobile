import '../../../insumos/domain/entities/insumo.dart';
import '../entities/receita.dart';

abstract class ReceitaRepository {
  Future<List<Receita>> getReceitas({String? search});

  Future<Receita> getReceita(int id);

  Future<Receita> createReceita({
    required int empresaId,
    required String nome,
    required double rendimento,
    required InsumoUnidadeMedida unidadeRendimento,
    required double custoProducao,
    required double custoUnitario,
    required double margemLucro,
    required double precoSugerido,
    List<ReceitaItem> itens = const [],
  });

  Future<Receita> updateReceita({
    required int id,
    String? nome,
    double? rendimento,
    InsumoUnidadeMedida? unidadeRendimento,
    double? custoProducao,
    double? custoUnitario,
    double? margemLucro,
    double? precoSugerido,
    List<ReceitaItem>? itens,
  });

  Future<void> deleteReceita(int id);
}
