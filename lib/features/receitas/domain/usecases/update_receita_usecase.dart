import '../entities/receita.dart';
import '../repositories/receita_repository.dart';

class UpdateReceitaUsecase {
  final ReceitaRepository repository;

  UpdateReceitaUsecase(this.repository);

  Future<Receita> call({
    required String id,
    String? nome,
    String? descricao,
    ReceitaCategoria? categoria,
    double? rendimento,
    double? custoTotal,
    double? precoVenda,
    bool? ativo,
  }) {
    return repository.updateReceita(
      id: id,
      nome: nome,
      descricao: descricao,
      categoria: categoria,
      rendimento: rendimento,
      custoTotal: custoTotal,
      precoVenda: precoVenda,
      ativo: ativo,
    );
  }
}
