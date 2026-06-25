import '../../domain/entities/gasto_indireto.dart';
import '../../domain/repositories/gasto_indireto_repository.dart';
import '../datasources/gasto_indireto_remote_datasource.dart';
import '../models/gasto_indireto_model.dart';

class GastoIndiretoRepositoryImpl implements GastoIndiretoRepository {
  final GastoIndiretoRemoteDatasource datasource;

  GastoIndiretoRepositoryImpl({required this.datasource});

  @override
  Future<List<GastoIndireto>> getGastosIndiretos() =>
      datasource.getGastosIndiretos();

  @override
  Future<GastoIndireto> createGastoIndireto({
    required String descricao,
    required double valor,
    required MetodoRateio metodoRateio,
  }) {
    return datasource.createGastoIndireto(
      GastoIndiretoModel.toJsonCreate(
        descricao: descricao,
        valor: valor,
        metodoRateio: metodoRateio,
      ),
    );
  }

  @override
  Future<GastoIndireto> updateGastoIndireto({
    required int id,
    String? descricao,
    double? valor,
    MetodoRateio? metodoRateio,
  }) {
    return datasource.updateGastoIndireto(
      id,
      GastoIndiretoModel.toJsonUpdate(
        descricao: descricao,
        valor: valor,
        metodoRateio: metodoRateio,
      ),
    );
  }

  @override
  Future<void> deleteGastoIndireto(int id) =>
      datasource.deleteGastoIndireto(id);
}
