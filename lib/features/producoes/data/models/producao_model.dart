import '../../domain/entities/producao.dart';

class ProducaoRateioModel extends ProducaoRateio {
  const ProducaoRateioModel({
    required super.gastoIndiretoId,
    required super.valorRateado,
  });

  factory ProducaoRateioModel.fromJson(Map<String, dynamic> json) {
    return ProducaoRateioModel(
      gastoIndiretoId: _toInt(json['gastoIndiretoId'] ?? json['gasto_indireto_id']),
      valorRateado: _toDouble(json['valorRateado'] ?? json['valor_rateado']),
    );
  }
}

class ProducaoModel extends Producao {
  const ProducaoModel({
    required super.id,
    required super.receitaId,
    required super.empresaId,
    required super.quantidade,
    required super.custoTotal,
    required super.custoUnitario,
    required super.dataProducao,
    super.rateios,
  });

  factory ProducaoModel.fromJson(Map<String, dynamic> json) {
    return ProducaoModel(
      id: _toInt(json['id']),
      receitaId: _toInt(json['receitaId'] ?? json['receita_id']),
      empresaId: _toInt(json['empresaId'] ?? json['empresa_id']),
      quantidade: _toInt(json['quantidade']),
      custoTotal: _toDouble(json['custoTotal'] ?? json['custo_total']),
      custoUnitario: _toDouble(json['custoUnitario'] ?? json['custo_unitario']),
      dataProducao: _toDate(json['dataProducao'] ?? json['data_producao']),
      rateios: _parseRateios(json['rateios']),
    );
  }
}

List<ProducaoRateio> _parseRateios(dynamic value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((j) => ProducaoRateioModel.fromJson(Map<String, dynamic>.from(j)))
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
