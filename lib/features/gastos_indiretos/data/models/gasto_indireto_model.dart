import '../../domain/entities/gasto_indireto.dart';

class GastoIndiretoModel extends GastoIndireto {
  const GastoIndiretoModel({
    required super.id,
    required super.empresaId,
    required super.descricao,
    required super.valor,
    required super.metodoRateio,
  });

  factory GastoIndiretoModel.fromJson(Map<String, dynamic> json) {
    return GastoIndiretoModel(
      id: _toInt(json['id']),
      empresaId: _toInt(json['empresaId'] ?? json['empresa_id']),
      descricao: (json['descricao'] ?? '').toString(),
      valor: _toDouble(json['valor']),
      metodoRateio: MetodoRateio.fromValue(
        (json['metodoRateio'] ?? json['metodo_rateio'] ?? 'FIXO').toString(),
      ),
    );
  }

  static Map<String, dynamic> toJsonCreate({
    required String descricao,
    required double valor,
    required MetodoRateio metodoRateio,
  }) {
    return {
      'descricao': descricao,
      'valor': valor,
      'metodo_rateio': metodoRateio.value,
    };
  }

  static Map<String, dynamic> toJsonUpdate({
    String? descricao,
    double? valor,
    MetodoRateio? metodoRateio,
  }) {
    return {
      if (descricao != null) 'descricao': descricao,
      if (valor != null) 'valor': valor,
      if (metodoRateio != null) 'metodo_rateio': metodoRateio.value,
    };
  }
}

int _toInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString().replaceAll(',', '.') ?? '') ?? 0;
}
