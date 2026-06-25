import '../../../insumos/domain/entities/insumo.dart';
import '../entities/receita.dart';
import '../entities/simulacao_result.dart';

abstract class ReceitaRepository {
  Future<List<Receita>> getReceitas({String? search});

  Future<Receita> getReceita(int id);

  Future<Receita> createReceita({
    required String nome,
    required double rendimento,
    required InsumoUnidadeMedida unidadeRendimento,
    double? margemLucro,
    List<ReceitaItemInput> insumos = const [],
  });

  Future<Receita> updateReceita({
    required int id,
    String? nome,
    double? rendimento,
    InsumoUnidadeMedida? unidadeRendimento,
    double? margemLucro,
    List<ReceitaItemInput>? insumos,
  });

  Future<void> deleteReceita(int id);

  Future<SimulacaoResult> simularReceita({
    required int id,
    double? novoCusto,
    double? novoPreco,
    int? volume,
  });
}
