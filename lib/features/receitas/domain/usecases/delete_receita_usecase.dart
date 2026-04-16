import '../repositories/receita_repository.dart';

class DeleteReceitaUsecase {
  final ReceitaRepository repository;

  DeleteReceitaUsecase(this.repository);

  Future<void> call(String id) => repository.deleteReceita(id);
}
