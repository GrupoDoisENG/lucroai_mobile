import '../entities/venda.dart';
import '../repositories/venda_repository.dart';

class ListarVendasUsecase {
  final VendaRepository repository;

  ListarVendasUsecase(this.repository);

  Future<List<Venda>> call({
    int? empresaId,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) {
    return repository.listarVendas(
      empresaId: empresaId,
      dataInicio: dataInicio,
      dataFim: dataFim,
    );
  }
}
