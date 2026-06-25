import '../repositories/gasto_indireto_repository.dart';

class DeleteGastoIndiretoUsecase {
  final GastoIndiretoRepository repository;

  DeleteGastoIndiretoUsecase(this.repository);

  Future<void> call(int id) => repository.deleteGastoIndireto(id);
}
