import '../../../insumos/domain/entities/insumo.dart';
import '../../domain/entities/receita.dart';
import '../../domain/repositories/receita_repository.dart';
import '../datasources/receita_remote_datasource.dart';
import '../models/receita_model.dart';

class ReceitaRepositoryImpl implements ReceitaRepository {
  final ReceitaRemoteDatasource datasource;

  ReceitaRepositoryImpl({required this.datasource});

  @override
  Future<List<Receita>> getReceitas({String? search}) {
    return datasource.getReceitas(search: search);
  }

  @override
  Future<Receita> getReceita(int id) => datasource.getReceita(id);

  @override
  Future<Receita> createReceita({
    required int empresaId,
    required String nome,
    required double rendimento,
    required InsumoUnidadeMedida unidadeRendimento,
    required double custoProducao,
    required double custoUnitario,
    required double margemLucro,
    required double precoSugerido,
  }) {
    return datasource.createReceita(
      ReceitaModel.toJsonCreate(
        empresaId: empresaId,
        nome: nome,
        rendimento: rendimento,
        unidadeRendimento: unidadeRendimento,
        custoProducao: custoProducao,
        custoUnitario: custoUnitario,
        margemLucro: margemLucro,
        precoSugerido: precoSugerido,
      ),
    );
  }

  @override
  Future<Receita> updateReceita({
    required int id,
    String? nome,
    double? rendimento,
    InsumoUnidadeMedida? unidadeRendimento,
    double? custoProducao,
    double? custoUnitario,
    double? margemLucro,
    double? precoSugerido,
  }) {
    return datasource.updateReceita(
      id,
      ReceitaModel.toJsonUpdate(
        nome: nome,
        rendimento: rendimento,
        unidadeRendimento: unidadeRendimento,
        custoProducao: custoProducao,
        custoUnitario: custoUnitario,
        margemLucro: margemLucro,
        precoSugerido: precoSugerido,
      ),
    );
  }

  @override
  Future<void> deleteReceita(int id) => datasource.deleteReceita(id);
}
