import '../entities/venda.dart';

abstract class VendaRepository {
  Future<Venda> criarVenda(CreateVendaRequest request);

  Future<List<Venda>> listarVendas({
    int? empresaId,
    DateTime? dataInicio,
    DateTime? dataFim,
  });
}
