import '../repositories/insumo_repository.dart';

class DeleteInsumoUsecase {
  final InsumoRepository repository;
  DeleteInsumoUsecase(this.repository);

  Future<void> call(int id) => repository.deleteInsumo(id);
}
