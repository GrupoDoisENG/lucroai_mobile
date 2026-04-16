import '../entities/insumo.dart';
import '../repositories/insumo_repository.dart';

class CreateInsumoUsecase {
  final InsumoRepository repository;
  CreateInsumoUsecase(this.repository);

  Future<Insumo> call({
    required String nome,
    required double quantidade,
    required InsumoUnidadeMedida unidade,
    required double valorPago,
    double? quantidadeDisponivel,
    double? quantidadeMinima,
  }) => repository.createInsumo(
    nome: nome,
    quantidade: quantidade,
    unidade: unidade,
    valorPago: valorPago,
    quantidadeDisponivel: quantidadeDisponivel,
    quantidadeMinima: quantidadeMinima,
  );
}
