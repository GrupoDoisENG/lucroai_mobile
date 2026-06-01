import 'package:flutter_test/flutter_test.dart';
import 'package:lucroai_mobile/features/insumos/domain/services/insumo_custo_calculator.dart';

void main() {
  group('InsumoCustoCalculator', () {
    test('calcula custo unitario dividindo valor pago pela quantidade', () {
      final custoUnitario = InsumoCustoCalculator.calcularCustoUnitario(
        valorPago: 12.50,
        quantidade: 500,
      );

      expect(custoUnitario, 0.025);
    });

    test('retorna zero quando quantidade for zero ou negativa', () {
      expect(
        InsumoCustoCalculator.calcularCustoUnitario(
          valorPago: 10,
          quantidade: 0,
        ),
        0,
      );

      expect(
        InsumoCustoCalculator.calcularCustoUnitario(
          valorPago: 10,
          quantidade: -1,
        ),
        0,
      );
    });
  });
}
