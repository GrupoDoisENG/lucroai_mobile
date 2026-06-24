import '../entities/producao.dart';
import '../repositories/producao_repository.dart';

class RegistrarProducaoUsecase {
  final ProducaoRepository repository;

  RegistrarProducaoUsecase(this.repository);

  Future<Producao> call({
    required int receitaId,
    required int quantidade,
    List<int>? gastoIndiretoIds,
  }) =>
      repository.registrarProducao(
        receitaId: receitaId,
        quantidade: quantidade,
        gastoIndiretoIds: gastoIndiretoIds,
      );
}
