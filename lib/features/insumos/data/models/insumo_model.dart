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
    required super.quantidadeDisponivel,
    required super.quantidadeMinima,
    required super.dataCriacao,
  });

  factory InsumoModel.fromJson(Map<String, dynamic> json) {
    return InsumoModel(
      id: json['id'] as int,
      empresaId: json['empresaId'] as int,
      nome: json['nome'] as String,
      quantidade: double.parse(json['quantidade'].toString()),
      unidade: InsumoUnidadeMedida.fromValue(json['unidade'] as String),
      valorPago: double.parse(json['valorPago'].toString()),
      custoUnitario: double.parse(json['custoUnitario'].toString()),
      quantidadeDisponivel: double.parse(
        json['quantidadeDisponivel'].toString(),
      ),
      quantidadeMinima: double.parse(json['quantidadeMinima'].toString()),
      dataCriacao: DateTime.parse(json['dataCriacao'] as String),
    );
  }

  static Map<String, dynamic> toJsonCreate({
    required String nome,
    required double quantidade,
    required InsumoUnidadeMedida unidade,
    required double valorPago,
    double? quantidadeDisponivel,
    double? quantidadeMinima,
  }) {
    return {
      'nome': nome,
      'quantidade': quantidade,
      'unidade': unidade.value,
      'valorPago': valorPago,
      if (quantidadeDisponivel != null)
        'quantidadeDisponivel': quantidadeDisponivel,
      if (quantidadeMinima != null) 'quantidadeMinima': quantidadeMinima,
    };
  }

  static Map<String, dynamic> toJsonUpdate({
    String? nome,
    double? quantidade,
    InsumoUnidadeMedida? unidade,
    double? valorPago,
    double? quantidadeDisponivel,
    double? quantidadeMinima,
  }) {
    return {
      if (nome != null) 'nome': nome,
      if (quantidade != null) 'quantidade': quantidade,
      if (unidade != null) 'unidade': unidade.value,
      if (valorPago != null) 'valorPago': valorPago,
      if (quantidadeDisponivel != null)
        'quantidadeDisponivel': quantidadeDisponivel,
      if (quantidadeMinima != null) 'quantidadeMinima': quantidadeMinima,
    };
  }
}
