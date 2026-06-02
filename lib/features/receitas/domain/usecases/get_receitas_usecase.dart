import '../entities/receita.dart';
import '../repositories/receita_repository.dart';

class GetReceitasUsecase {
  final ReceitaRepository repository;

  GetReceitasUsecase(this.repository);

  Future<List<Receita>> call({String? search}) {
    return repository.getReceitas(search: search);
  }
}
