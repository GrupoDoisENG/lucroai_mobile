import '../entities/insumo.dart';
import '../repositories/insumo_repository.dart';

class GetInsumoUsecase {
  final InsumoRepository repository;
  GetInsumoUsecase(this.repository);

  Future<Insumo> call(String id) => repository.getInsumo(id);
}
