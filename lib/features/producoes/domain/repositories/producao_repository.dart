import '../entities/producao.dart';

abstract class ProducaoRepository {
  Future<Producao> registrarProducao({
    required int receitaId,
    required int quantidade,
    List<int>? gastoIndiretoIds,
  });

  Future<List<Producao>> listarProducoes({int? receitaId});
}
