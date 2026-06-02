enum InsumoUnidadeMedida {
  gramas('G', 'g'),
  quilogramas('KG', 'kg'),
  mililitros('ML', 'ml'),
  litros('L', 'l'),
  unidades('UN', 'un');

  const InsumoUnidadeMedida(this.value, this.label);

  final String value;
  final String label;

  static InsumoUnidadeMedida fromValue(String value) {
    final normalizedValue = value.trim().toUpperCase();

    return InsumoUnidadeMedida.values.firstWhere(
      (unidade) => unidade.value == normalizedValue,
      orElse: () => InsumoUnidadeMedida.unidades,
    );
  }
}

class Insumo {
  final int id;
  final int empresaId;
  final String nome;
  final double quantidade;
  final InsumoUnidadeMedida unidade;
  final double valorPago;
  final double custoUnitario;
  final DateTime dataCriacao;

  const Insumo({
    required this.id,
    required this.empresaId,
    required this.nome,
    required this.quantidade,
    required this.unidade,
    required this.valorPago,
    required this.custoUnitario,
    required this.dataCriacao,
  });
}
