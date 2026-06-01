class InsumoCustoCalculator {
  const InsumoCustoCalculator._();

  static double calcularCustoUnitario({
    required double valorPago,
    required double quantidade,
  }) {
    return quantidade > 0 ? valorPago / quantidade : 0;
  }
}
