import '../entities/insumo.dart';

abstract class InsumoRepository {
  Future<List<Insumo>> getInsumos({
    bool? ativo,
    InsumoCategoria? categoria,
    String? search,
  });

  Future<Insumo> getInsumo(String id);

  Future<Insumo> createInsumo({
    required String nome,
    String? descricao,
    required InsumoCategoria categoria,
    required InsumoUnidadeMedida unidadeMedida,
    required double precoUnitario,
    required double estoqueMinimo,
  });

  Future<Insumo> updateInsumo({
    required String id,
    String? nome,
    String? descricao,
    InsumoCategoria? categoria,
    InsumoUnidadeMedida? unidadeMedida,
    double? precoUnitario,
    double? estoqueMinimo,
    bool? ativo,
  });

  Future<void> deleteInsumo(String id);
}
