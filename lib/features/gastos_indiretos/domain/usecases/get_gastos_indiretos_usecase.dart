import '../entities/gasto_indireto.dart';
import '../repositories/gasto_indireto_repository.dart';

class GetGastosIndiretosUsecase {
  final GastoIndiretoRepository repository;

  GetGastosIndiretosUsecase(this.repository);

  Future<List<GastoIndireto>> call() => repository.getGastosIndiretos();
}
