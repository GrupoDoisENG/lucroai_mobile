import '../../domain/entities/venda.dart';

class VendaItemModel extends VendaItem {
  const VendaItemModel({
    required super.receitaId,
    required super.produto,
    required super.quantidade,
    required super.precoUnitarioReal,
    required super.total,
    super.custoUnitario,
    super.margemRealizada,
  });

  factory VendaItemModel.fromJson(Map<String, dynamic> json) {
    final quantidade = _toDouble(json['quantidade']);
    final preco = _toDouble(
      json['preco_unitario_real'] ?? json['precoUnitarioReal'],
    );

    return VendaItemModel(
      receitaId: _toInt(json['receita_id'] ?? json['receitaId']),
      produto: (json['produto'] ?? json['nome'] ?? json['receita'] ?? '')
          .toString(),
      quantidade: quantidade,
      precoUnitarioReal: preco,
      total: _toDouble(json['total'] ?? json['valor_total']) == 0
          ? quantidade * preco
          : _toDouble(json['total'] ?? json['valor_total']),
      custoUnitario: json['custoUnitario'] != null
          ? _toDouble(json['custoUnitario'])
          : null,
      margemRealizada: json['margemRealizada'] != null
          ? _toDouble(json['margemRealizada'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'receita_id': receitaId,
      'quantidade': quantidade,
      'preco_unitario_real': precoUnitarioReal,
    };
  }
}

class VendaModel extends Venda {
  const VendaModel({
    required super.id,
    required super.empresaId,
    required super.produto,
    required super.quantidade,
    required super.total,
    required super.status,
    required super.dataVenda,
    super.itens,
  });

  factory VendaModel.fromJson(Map<String, dynamic> json) {
    final itens = _parseItens(json['itens'] ?? json['items']);
    final produto =
        (json['produto'] ??
                json['descricao'] ??
                json['nome'] ??
                (itens.isNotEmpty ? itens.first.produto : 'Venda'))
            .toString();
    final quantidade = _toDouble(json['quantidade']) == 0 && itens.isNotEmpty
        ? itens.fold<double>(0, (total, item) => total + item.quantidade)
        : _toDouble(json['quantidade']);
    final total =
        _toDouble(json['total'] ?? json['valor_total']) == 0 && itens.isNotEmpty
        ? itens.fold<double>(0, (sum, item) => sum + item.total)
        : _toDouble(json['total'] ?? json['valor_total']);

    return VendaModel(
      id: _toInt(json['id']),
      empresaId: _toInt(json['empresa_id'] ?? json['empresaId']),
      produto: produto,
      quantidade: quantidade,
      total: total,
      status: (json['status'] ?? 'CONCLUIDA').toString(),
      dataVenda: _toDate(json['data_venda'] ?? json['dataVenda']),
      itens: itens,
    );
  }
}

class CreateVendaRequestModel extends CreateVendaRequest {
  const CreateVendaRequestModel({required super.itens});

  factory CreateVendaRequestModel.fromEntity(CreateVendaRequest request) {
    return CreateVendaRequestModel(itens: request.itens);
  }

  Map<String, dynamic> toJson() {
    return {
      'itens': itens
          .map(
            (item) => {
              'receita_id': item.receitaId,
              'quantidade': item.quantidade,
              'preco_unitario_real': double.parse(
                item.precoUnitarioReal.toStringAsFixed(2),
              ),
            },
          )
          .toList(),
    };
  }
}

List<VendaItem> _parseItens(dynamic value) {
  if (value is! List) return const [];

  return value
      .whereType<Map>()
      .map((json) => VendaItemModel.fromJson(Map<String, dynamic>.from(json)))
      .toList();
}

int _toInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString().replaceAll(',', '.') ?? '') ?? 0;
}

DateTime _toDate(dynamic value) {
  if (value == null) return DateTime.now();
  return DateTime.tryParse(value.toString()) ?? DateTime.now();
}
