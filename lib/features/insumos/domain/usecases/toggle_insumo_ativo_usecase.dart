import '../entities/insumo.dart';
import '../repositories/insumo_repository.dart';

class ToggleInsumoAtivoUsecase {
  final InsumoRepository repository;
  ToggleInsumoAtivoUsecase(this.repository);

  Future<Insumo> call(String id, bool ativo) =>
      repository.updateInsumo(id: id, ativo: ativo);
}
