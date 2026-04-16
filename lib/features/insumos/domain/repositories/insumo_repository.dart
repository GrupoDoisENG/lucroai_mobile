import '../entities/insumo.dart';

abstract class InsumoRepository {
  Future<List<Insumo>> getInsumos();

  Future<Insumo> getInsumo(int id);

  Future<Insumo> createInsumo({
    required String nome,
    required double quantidade,
    required InsumoUnidadeMedida unidade,
    required double valorPago,
    double? quantidadeDisponivel,
    double? quantidadeMinima,
  });

  Future<Insumo> updateInsumo({
    required int id,
    String? nome,
    double? quantidade,
    InsumoUnidadeMedida? unidade,
    double? valorPago,
    double? quantidadeDisponivel,
    double? quantidadeMinima,
  });

  Future<void> deleteInsumo(int id);
}
