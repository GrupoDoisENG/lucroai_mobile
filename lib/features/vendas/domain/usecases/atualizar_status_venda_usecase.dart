import '../entities/venda.dart';
import '../repositories/venda_repository.dart';

class AtualizarStatusVendaUsecase {
  final VendaRepository repository;

  AtualizarStatusVendaUsecase(this.repository);

  Future<Venda> call(int vendaId, String status) {
    return repository.atualizarStatus(vendaId, status);
  }
}
