class ProducaoRateio {
  final int gastoIndiretoId;
  final double valorRateado;

  const ProducaoRateio({
    required this.gastoIndiretoId,
    required this.valorRateado,
  });
}

class Producao {
  final int id;
  final int receitaId;
  final int empresaId;
  final int quantidade;
  final double custoTotal;
  final double custoUnitario;
  final DateTime dataProducao;
  final List<ProducaoRateio> rateios;

  const Producao({
    required this.id,
    required this.receitaId,
    required this.empresaId,
    required this.quantidade,
    required this.custoTotal,
    required this.custoUnitario,
    required this.dataProducao,
    this.rateios = const [],
  });
}
