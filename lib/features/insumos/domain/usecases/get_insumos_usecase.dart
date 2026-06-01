import '../entities/insumo.dart';
import '../repositories/insumo_repository.dart';

class GetInsumosUsecase {
  final InsumoRepository repository;
  GetInsumosUsecase(this.repository);

  Future<List<Insumo>> call({String? search}) =>
      repository.getInsumos(search: search);
}
