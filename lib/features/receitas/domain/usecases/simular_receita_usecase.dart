import '../entities/simulacao_result.dart';
import '../repositories/receita_repository.dart';

class SimularReceitaUsecase {
  final ReceitaRepository repository;

  SimularReceitaUsecase(this.repository);

  Future<SimulacaoResult> call({
    required int id,
    double? novoCusto,
    double? novoPreco,
    int? volume,
  }) {
    return repository.simularReceita(
      id: id,
      novoCusto: novoCusto,
      novoPreco: novoPreco,
      volume: volume,
    );
  }
}
