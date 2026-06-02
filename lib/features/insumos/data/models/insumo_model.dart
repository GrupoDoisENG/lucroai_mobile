import '../../domain/entities/insumo.dart';

class InsumoModel extends Insumo {
  const InsumoModel({
    required super.id,
    required super.empresaId,
    required super.nome,
    required super.quantidade,
    required super.unidade,
    required super.valorPago,
    required super.custoUnitario,
    required super.dataCriacao,
  });

  factory InsumoModel.fromJson(Map<String, dynamic> json) {
    return InsumoModel(
      id: _toInt(json['id']),
      empresaId: _toInt(json['empresaId'] ?? json['empresa_id']),
      nome: (json['nome'] ?? '').toString(),
      quantidade: _toDouble(json['quantidade']),
      unidade: InsumoUnidadeMedida.fromValue(
        (json['unidade'] ?? 'UN').toString(),
      ),
      valorPago: _toDouble(json['valorPago'] ?? json['valor_pago']),
      custoUnitario: _toDouble(json['custoUnitario'] ?? json['custo_unitario']),
      dataCriacao: _toDate(json['dataCriacao'] ?? json['data_criacao']),
    );
  }

  static Map<String, dynamic> toJsonCreate({
    required int empresaId,
    required String nome,
    required double quantidade,
    required InsumoUnidadeMedida unidade,
    required double valorPago,
  }) {
    return {
      'empresaId': empresaId,
      'nome': nome,
      'quantidade': quantidade,
      'unidade': unidade.value,
      'valorPago': valorPago,
    };
  }

  static Map<String, dynamic> toJsonUpdate({
    String? nome,
    double? quantidade,
    InsumoUnidadeMedida? unidade,
    double? valorPago,
  }) {
    return {
      if (nome != null) 'nome': nome,
      if (quantidade != null) 'quantidade': quantidade,
      if (unidade != null) 'unidade': unidade.value,
      if (valorPago != null) 'valorPago': valorPago,
    };
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString().replaceAll(',', '.') ?? '') ?? 0;
  }

  static DateTime _toDate(dynamic value) {
    if (value == null) return DateTime.now();
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }
}
