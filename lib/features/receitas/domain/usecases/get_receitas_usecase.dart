import '../entities/receita.dart';
import '../repositories/receita_repository.dart';

class GetReceitasUsecase {
  final ReceitaRepository repository;

  GetReceitasUsecase(this.repository);

  Future<List<Receita>> call({
    bool? ativo,
    ReceitaCategoria? categoria,
    String? search,
  }) {
    return repository.getReceitas(
      ativo: ativo,
      categoria: categoria,
      search: search,
    );
  }
}
