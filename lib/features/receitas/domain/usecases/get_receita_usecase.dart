import '../entities/receita.dart';
import '../repositories/receita_repository.dart';

class GetReceitaUsecase {
  final ReceitaRepository repository;

  GetReceitaUsecase(this.repository);

  Future<Receita> call(String id) => repository.getReceita(id);
}
