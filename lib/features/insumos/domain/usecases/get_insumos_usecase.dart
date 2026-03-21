import '../entities/insumo.dart';
import '../repositories/insumo_repository.dart';

class GetInsumosUsecase {
  final InsumoRepository repository;
  GetInsumosUsecase(this.repository);

  Future<List<Insumo>> call({
    bool? ativo,
    InsumoCategoria? categoria,
    String? search,
  }) => repository.getInsumos(ativo: ativo, categoria: categoria, search: search);
}
