import '../entities/gasto_indireto.dart';
import '../repositories/gasto_indireto_repository.dart';

class CreateGastoIndiretoUsecase {
  final GastoIndiretoRepository repository;

  CreateGastoIndiretoUsecase(this.repository);

  Future<GastoIndireto> call({
    required String descricao,
    required double valor,
    required MetodoRateio metodoRateio,
  }) {
    return repository.createGastoIndireto(
      descricao: descricao,
      valor: valor,
      metodoRateio: metodoRateio,
    );
  }
}
