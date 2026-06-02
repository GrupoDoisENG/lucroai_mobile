import '../entities/estoque_com_insumo.dart';
import '../repositories/estoque_repository.dart';

class GetEstoquesUsecase {
  final EstoqueRepository repository;

  GetEstoquesUsecase(this.repository);

  Future<List<EstoqueComInsumo>> call() async {
    return await repository.getEstoques();
  }
}
