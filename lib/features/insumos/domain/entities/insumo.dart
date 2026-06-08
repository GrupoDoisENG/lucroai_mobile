enum InsumoCategoria {
  graos('graos'),
  laticinios('laticinios'),
  carnes('carnes'),
  hortifruti('hortifruti'),
  temperos('temperos'),
  bebidas('bebidas'),
  embalagens('embalagens'),
  outros('outros');

  const InsumoCategoria(this.value);

  final String value;

  String get label {
    switch (this) {
      case InsumoCategoria.graos:
        return 'Graos';
      case InsumoCategoria.laticinios:
        return 'Laticinios';
      case InsumoCategoria.carnes:
        return 'Carnes';
      case InsumoCategoria.hortifruti:
        return 'Hortifruti';
      case InsumoCategoria.temperos:
        return 'Temperos';
      case InsumoCategoria.bebidas:
        return 'Bebidas';
      case InsumoCategoria.embalagens:
        return 'Embalagens';
      case InsumoCategoria.outros:
        return 'Outros';
    }
  }

  static InsumoCategoria fromValue(String value) {
    return InsumoCategoria.values.firstWhere(
      (e) => e.value == value,
      orElse: () => InsumoCategoria.outros,
    );
  }
}

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
