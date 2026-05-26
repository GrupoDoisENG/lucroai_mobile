import '../entities/venda.dart';
import '../repositories/venda_repository.dart';

class CriarVendaUsecase {
  final VendaRepository repository;

  CriarVendaUsecase(this.repository);

  Future<Venda> call(CreateVendaRequest request) {
    return repository.criarVenda(request);
  }
}
