// lib/models/insumo_model.dart

class Insumo {
  final String id;
  final String nome;
  final double quantidade;
  final String unidade;
  final double precoCusto;

  Insumo({
    required this.id,
    required this.nome,
    required this.quantidade,
    required this.unidade,
    required this.precoCusto,
  });

  // Helper para formatar o texto "5000 g • R$ 18.90"
  String get detalheFormatado => "${quantidade.toInt()} $unidade • R\$ ${precoCusto.toStringAsFixed(2)}";

  // Helper para calcular e formatar o custo unitário (ex: "R$ 0.0038/g")
  String get custoUnitarioFormatado {
    double custo = precoCusto / quantidade;
    return "R\$ ${custo.toStringAsFixed(4)}/$unidade";
  }
}