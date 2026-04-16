import '../entities/insumo.dart';
import '../repositories/insumo_repository.dart';

class UpdateInsumoUsecase {
  final InsumoRepository repository;
  UpdateInsumoUsecase(this.repository);

  Future<Insumo> call({
    required int id,
    String? nome,
    double? quantidade,
    InsumoUnidadeMedida? unidade,
    double? valorPago,
    double? quantidadeDisponivel,
    double? quantidadeMinima,
  }) => repository.updateInsumo(
    id: id,
    nome: nome,
    quantidade: quantidade,
    unidade: unidade,
    valorPago: valorPago,
    quantidadeDisponivel: quantidadeDisponivel,
    quantidadeMinima: quantidadeMinima,
  );
}
