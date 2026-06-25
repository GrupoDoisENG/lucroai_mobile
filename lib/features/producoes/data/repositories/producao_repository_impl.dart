import '../../domain/entities/producao.dart';
import '../../domain/repositories/producao_repository.dart';
import '../datasources/producao_remote_datasource.dart';

class ProducaoRepositoryImpl implements ProducaoRepository {
  final ProducaoRemoteDatasource datasource;

  ProducaoRepositoryImpl({required this.datasource});

  @override
  Future<Producao> registrarProducao({
    required int receitaId,
    required int quantidade,
    List<int>? gastoIndiretoIds,
  }) =>
      datasource.registrarProducao(
        receitaId: receitaId,
        quantidade: quantidade,
        gastoIndiretoIds: gastoIndiretoIds,
      );

  @override
  Future<List<Producao>> listarProducoes({int? receitaId}) =>
      datasource.listarProducoes(receitaId: receitaId);
}
