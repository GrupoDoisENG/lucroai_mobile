import '../entities/gasto_indireto.dart';
import '../repositories/gasto_indireto_repository.dart';

class UpdateGastoIndiretoUsecase {
  final GastoIndiretoRepository repository;

  UpdateGastoIndiretoUsecase(this.repository);

  Future<GastoIndireto> call({
    required int id,
    String? descricao,
    double? valor,
    MetodoRateio? metodoRateio,
  }) {
    return repository.updateGastoIndireto(
      id: id,
      descricao: descricao,
      valor: valor,
      metodoRateio: metodoRateio,
    );
  }
}
