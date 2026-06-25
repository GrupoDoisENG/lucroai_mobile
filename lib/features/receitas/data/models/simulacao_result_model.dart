import '../../domain/entities/simulacao_result.dart';

class SimulacaoResultModel extends SimulacaoResult {
  const SimulacaoResultModel({
    required super.custoUnitario,
    required super.precoVenda,
    required super.volume,
    required super.lucroEstimado,
    required super.margemProjetada,
    required super.breakEven,
  });

  factory SimulacaoResultModel.fromJson(Map<String, dynamic> json) {
    return SimulacaoResultModel(
      custoUnitario: _toDouble(json['custoUnitario'] ?? json['custo_unitario']),
      precoVenda: _toDouble(json['precoVenda'] ?? json['preco_venda']),
      volume: _toInt(json['volume']),
      lucroEstimado: _toDouble(json['lucroEstimado'] ?? json['lucro_estimado']),
      margemProjetada: _toDouble(
        json['margemProjetada'] ?? json['margem_projetada'],
      ),
      breakEven: _toInt(json['breakEven'] ?? json['break_even']),
    );
  }
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString().replaceAll(',', '.') ?? '') ?? 0;
}

int _toInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ??
      double.tryParse(value?.toString() ?? '')?.toInt() ??
      0;
}
