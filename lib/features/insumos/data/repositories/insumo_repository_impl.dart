import '../../domain/entities/insumo.dart';
import '../../domain/repositories/insumo_repository.dart';
import '../datasources/insumo_remote_datasource.dart';
import '../models/insumo_model.dart';

class InsumoRepositoryImpl implements InsumoRepository {
  final InsumoRemoteDatasource datasource;

  InsumoRepositoryImpl({required this.datasource});

  @override
  Future<List<Insumo>> getInsumos({
    bool? ativo,
    InsumoCategoria? categoria,
    String? search,
  }) => datasource.getInsumos(ativo: ativo, categoria: categoria, search: search);

  @override
  Future<Insumo> getInsumo(String id) => datasource.getInsumo(id);

  @override
  Future<Insumo> createInsumo({
    required String nome,
    String? descricao,
    required InsumoCategoria categoria,
    required InsumoUnidadeMedida unidadeMedida,
    required double precoUnitario,
    required double estoqueMinimo,
  }) => datasource.createInsumo(
        InsumoModel.toJsonCreate(
          nome: nome,
          descricao: descricao,
          categoria: categoria,
          unidadeMedida: unidadeMedida,
          precoUnitario: precoUnitario,
          estoqueMinimo: estoqueMinimo,
        ),
      );

  @override
  Future<Insumo> updateInsumo({
    required String id,
    String? nome,
    String? descricao,
    InsumoCategoria? categoria,
    InsumoUnidadeMedida? unidadeMedida,
    double? precoUnitario,
    double? estoqueMinimo,
    bool? ativo,
  }) => datasource.updateInsumo(
        id,
        InsumoModel.toJsonUpdate(
          nome: nome,
          descricao: descricao,
          categoria: categoria,
          unidadeMedida: unidadeMedida,
          precoUnitario: precoUnitario,
          estoqueMinimo: estoqueMinimo,
          ativo: ativo,
        ),
      );

  @override
  Future<void> deleteInsumo(String id) => datasource.deleteInsumo(id);
}
