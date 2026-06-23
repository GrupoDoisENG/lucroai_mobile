class SimulacaoResult {
  final double custoUnitario;
  final double precoVenda;
  final int volume;
  final double lucroEstimado;
  final double margemProjetada;
  final int breakEven;

  const SimulacaoResult({
    required this.custoUnitario,
    required this.precoVenda,
    required this.volume,
    required this.lucroEstimado,
    required this.margemProjetada,
    required this.breakEven,
  });
}
