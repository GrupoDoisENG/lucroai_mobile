import '../../../insumos/domain/entities/insumo.dart';
import '../../domain/entities/receita.dart';
import '../../domain/entities/simulacao_result.dart';
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
    required String nome,
    required double rendimento,
    required InsumoUnidadeMedida unidadeRendimento,
    double? margemLucro,
    List<ReceitaItemInput> insumos = const [],
  }) {
    return datasource.createReceita(
      ReceitaModel.toJsonCreate(
        nome: nome,
        rendimento: rendimento,
        unidadeRendimento: unidadeRendimento,
        margemLucro: margemLucro,
        insumos: insumos
            .map(
              (i) => ReceitaItemModel(
                insumoId: i.insumoId,
                quantidade: i.quantidade,
              ),
            )
            .toList(),
      ),
    );
  }

  @override
  Future<Receita> updateReceita({
    required int id,
    String? nome,
    double? rendimento,
    InsumoUnidadeMedida? unidadeRendimento,
    double? margemLucro,
    List<ReceitaItemInput>? insumos,
  }) {
    return datasource.updateReceita(
      id,
      ReceitaModel.toJsonUpdate(
        nome: nome,
        rendimento: rendimento,
        unidadeRendimento: unidadeRendimento,
        margemLucro: margemLucro,
        insumos: insumos
            ?.map(
              (i) => ReceitaItemModel(
                insumoId: i.insumoId,
                quantidade: i.quantidade,
              ),
            )
            .toList(),
      ),
    );
  }

  @override
  Future<void> deleteReceita(int id) => datasource.deleteReceita(id);

  @override
  Future<SimulacaoResult> simularReceita({
    required int id,
    double? novoCusto,
    double? novoPreco,
    int? volume,
  }) {
    return datasource.simularReceita(id, {
      if (novoCusto != null) 'novoCusto': novoCusto,
      if (novoPreco != null) 'novoPreco': novoPreco,
      if (volume != null) 'volume': volume,
    });
  }
}
