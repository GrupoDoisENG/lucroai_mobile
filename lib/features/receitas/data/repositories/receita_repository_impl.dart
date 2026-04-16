import '../../domain/entities/receita.dart';
import '../../domain/repositories/receita_repository.dart';
import '../datasources/receita_remote_datasource.dart';
import '../models/receita_model.dart';

class ReceitaRepositoryImpl implements ReceitaRepository {
  final ReceitaRemoteDatasource datasource;

  ReceitaRepositoryImpl({required this.datasource});

  @override
  Future<List<Receita>> getReceitas({
    bool? ativo,
    ReceitaCategoria? categoria,
    String? search,
  }) {
    return datasource.getReceitas(
      ativo: ativo,
      categoria: categoria,
      search: search,
    );
  }

  @override
  Future<Receita> getReceita(String id) => datasource.getReceita(id);

  @override
  Future<Receita> createReceita({
    required String nome,
    String? descricao,
    required ReceitaCategoria categoria,
    required double rendimento,
    required double custoTotal,
    required double precoVenda,
  }) {
    return datasource.createReceita(
      ReceitaModel.toJsonCreate(
        nome: nome,
        descricao: descricao,
        categoria: categoria,
        rendimento: rendimento,
        custoTotal: custoTotal,
        precoVenda: precoVenda,
      ),
    );
  }

  @override
  Future<Receita> updateReceita({
    required String id,
    String? nome,
    String? descricao,
    ReceitaCategoria? categoria,
    double? rendimento,
    double? custoTotal,
    double? precoVenda,
    bool? ativo,
  }) {
    return datasource.updateReceita(
      id,
      ReceitaModel.toJsonUpdate(
        nome: nome,
        descricao: descricao,
        categoria: categoria,
        rendimento: rendimento,
        custoTotal: custoTotal,
        precoVenda: precoVenda,
        ativo: ativo,
      ),
    );
  }

  @override
  Future<void> deleteReceita(String id) => datasource.deleteReceita(id);
}
