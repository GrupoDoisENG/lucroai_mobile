import '../../domain/entities/insumo.dart';
import '../../domain/repositories/insumo_repository.dart';
import '../datasources/insumo_remote_datasource.dart';
import '../models/insumo_model.dart';

class InsumoRepositoryImpl implements InsumoRepository {
  final InsumoRemoteDatasource datasource;

  InsumoRepositoryImpl({required this.datasource});

  @override
  Future<List<Insumo>> getInsumos() => datasource.getInsumos();

  @override
  Future<Insumo> getInsumo(int id) => datasource.getInsumo(id);

  @override
  Future<Insumo> createInsumo({
    required String nome,
    required double quantidade,
    required InsumoUnidadeMedida unidade,
    required double valorPago,
    double? quantidadeDisponivel,
    double? quantidadeMinima,
  }) => datasource.createInsumo(
    InsumoModel.toJsonCreate(
      nome: nome,
      quantidade: quantidade,
      unidade: unidade,
      valorPago: valorPago,
      quantidadeDisponivel: quantidadeDisponivel,
      quantidadeMinima: quantidadeMinima,
    ),
  );

  @override
  Future<Insumo> updateInsumo({
    required int id,
    String? nome,
    double? quantidade,
    InsumoUnidadeMedida? unidade,
    double? valorPago,
    double? quantidadeDisponivel,
    double? quantidadeMinima,
  }) => datasource.updateInsumo(
    id,
    InsumoModel.toJsonUpdate(
      nome: nome,
      quantidade: quantidade,
      unidade: unidade,
      valorPago: valorPago,
      quantidadeDisponivel: quantidadeDisponivel,
      quantidadeMinima: quantidadeMinima,
    ),
  );

  @override
  Future<void> deleteInsumo(int id) => datasource.deleteInsumo(id);
}
