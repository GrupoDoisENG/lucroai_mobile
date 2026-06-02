import '../entities/insumo.dart';

abstract class InsumoRepository {
  Future<List<Insumo>> getInsumos({String? search});

  Future<Insumo> getInsumo(int id);

  Future<Insumo> createInsumo({
    required int empresaId,
    required String nome,
    required double quantidade,
    required InsumoUnidadeMedida unidade,
    required double valorPago,
  });

  Future<Insumo> updateInsumo({
    required int id,
    String? nome,
    double? quantidade,
    InsumoUnidadeMedida? unidade,
    double? valorPago,
  });

  Future<void> deleteInsumo(int id);
}
