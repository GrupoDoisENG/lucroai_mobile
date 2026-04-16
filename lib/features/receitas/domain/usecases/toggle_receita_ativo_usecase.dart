import '../entities/receita.dart';
import '../repositories/receita_repository.dart';

class ToggleReceitaAtivoUsecase {
  final ReceitaRepository repository;

  ToggleReceitaAtivoUsecase(this.repository);

  Future<Receita> call(String id, bool ativo) {
    return repository.updateReceita(id: id, ativo: ativo);
  }
}
