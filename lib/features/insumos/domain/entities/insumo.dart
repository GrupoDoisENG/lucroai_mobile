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
  gramas('g'),
  quilogramas('kg'),
  mililitros('ml'),
  litros('l'),
  unidades('un'),
  porcao('porcao');

  const InsumoUnidadeMedida(this.value);

  final String value;

  String get label {
    switch (this) {
      case InsumoUnidadeMedida.gramas:
        return 'g';
      case InsumoUnidadeMedida.quilogramas:
        return 'kg';
      case InsumoUnidadeMedida.mililitros:
        return 'ml';
      case InsumoUnidadeMedida.litros:
        return 'l';
      case InsumoUnidadeMedida.unidades:
        return 'un';
      case InsumoUnidadeMedida.porcao:
        return 'porcao';
    }
  }

  static InsumoUnidadeMedida fromValue(String value) {
    return InsumoUnidadeMedida.values.firstWhere(
      (e) => e.value == value,
      orElse: () => InsumoUnidadeMedida.unidades,
    );
  }
}

class Insumo {
  final String id;
  final String nome;
  final String? descricao;
  final InsumoCategoria categoria;
  final InsumoUnidadeMedida unidadeMedida;
  final double precoUnitario;
  final double estoqueMinimo;
  final bool ativo;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final double? quantidadeEmbalagem;
  final double? precoEmbalagem;

  const Insumo({
    required this.id,
    required this.nome,
    this.descricao,
    required this.categoria,
    required this.unidadeMedida,
    required this.precoUnitario,
    required this.estoqueMinimo,
    required this.ativo,
    required this.criadoEm,
    required this.atualizadoEm,
    this.quantidadeEmbalagem,
    this.precoEmbalagem,
  });

  String get detalheFormatado =>
      '${categoria.label} - Minimo: ${estoqueMinimo.toInt()} ${unidadeMedida.label}';

  String get custoUnitarioFormatado =>
      'R\$ ${precoUnitario.toStringAsFixed(4)}/${unidadeMedida.label}';
}
