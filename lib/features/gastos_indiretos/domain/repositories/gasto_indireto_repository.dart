import '../entities/gasto_indireto.dart';

abstract class GastoIndiretoRepository {
  Future<List<GastoIndireto>> getGastosIndiretos();

  Future<GastoIndireto> createGastoIndireto({
    required String descricao,
    required double valor,
    required MetodoRateio metodoRateio,
  });

  Future<GastoIndireto> updateGastoIndireto({
    required int id,
    String? descricao,
    double? valor,
    MetodoRateio? metodoRateio,
  });

  Future<void> deleteGastoIndireto(int id);
}
