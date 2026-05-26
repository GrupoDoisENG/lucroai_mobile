import '../../domain/entities/venda.dart';
import '../../domain/repositories/venda_repository.dart';
import '../datasources/venda_remote_datasource.dart';
import '../models/venda_model.dart';

class VendaRepositoryImpl implements VendaRepository {
  final VendaRemoteDatasource datasource;

  VendaRepositoryImpl({required this.datasource});

  @override
  Future<Venda> criarVenda(CreateVendaRequest request) {
    return datasource.criarVenda(
      CreateVendaRequestModel.fromEntity(request).toJson(),
    );
  }

  @override
  Future<List<Venda>> listarVendas({
    int? empresaId,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) {
    return datasource.listarVendas(
      empresaId: empresaId,
      dataInicio: dataInicio,
      dataFim: dataFim,
    );
  }
}
