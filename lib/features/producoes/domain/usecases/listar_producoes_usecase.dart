import '../entities/producao.dart';
import '../repositories/producao_repository.dart';

class ListarProducoesUsecase {
  final ProducaoRepository repository;

  ListarProducoesUsecase(this.repository);

  Future<List<Producao>> call({int? receitaId}) =>
      repository.listarProducoes(receitaId: receitaId);
}
