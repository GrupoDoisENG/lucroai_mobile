import '../entities/receita.dart';
import '../repositories/receita_repository.dart';

class CreateReceitaUsecase {
  final ReceitaRepository repository;

  CreateReceitaUsecase(this.repository);

  Future<Receita> call({
    required String nome,
    String? descricao,
    required ReceitaCategoria categoria,
    required double rendimento,
    required double custoTotal,
    required double precoVenda,
  }) {
    return repository.createReceita(
      nome: nome,
      descricao: descricao,
      categoria: categoria,
      rendimento: rendimento,
      custoTotal: custoTotal,
      precoVenda: precoVenda,
    );
  }
}
