import '../entities/receita.dart';

abstract class ReceitaRepository {
  Future<List<Receita>> getReceitas({
    bool? ativo,
    ReceitaCategoria? categoria,
    String? search,
  });

  Future<Receita> getReceita(String id);

  Future<Receita> createReceita({
    required String nome,
    String? descricao,
    required ReceitaCategoria categoria,
    required double rendimento,
    required double custoTotal,
    required double precoVenda,
  });

  Future<Receita> updateReceita({
    required String id,
    String? nome,
    String? descricao,
    ReceitaCategoria? categoria,
    double? rendimento,
    double? custoTotal,
    double? precoVenda,
    bool? ativo,
  });

  Future<void> deleteReceita(String id);
}
