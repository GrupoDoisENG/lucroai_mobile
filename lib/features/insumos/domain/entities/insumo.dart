import 'package:equatable/equatable.dart';

/*
enum _DeprecatedInsumoCategoria {
  materiaPrima('materia_prima', 'Matéria-Prima'),
  embalagem('embalagem', 'Embalagem'),
  ingrediente('ingrediente', 'Ingrediente'),
  descartavel('descartavel', 'Descartável'),
  limpeza('limpeza', 'Limpeza'),
  outros('outros', 'Outros');

  final String value;
  final String label;
  const InsumoCategoria(this.value, this.label);

  static InsumoCategoria fromValue(String value) =>
      InsumoCategoria.values.firstWhere((e) => e.value == value);
}

enum _DeprecatedInsumoUnidadeMedida {
  kg('kg', 'kg'),
  g('g', 'g'),
  mg('mg', 'mg'),
  l('l', 'L'),
  ml('ml', 'mL'),
  un('un', 'un'),
  cx('cx', 'cx'),
  pct('pct', 'pct'),
  m('m', 'm'),
  cm('cm', 'cm');

  final String value;
  final String label;
  const _DeprecatedInsumoUnidadeMedida(this.value, this.label);

  static _DeprecatedInsumoUnidadeMedida fromValue(String value) =>
      _DeprecatedInsumoUnidadeMedida.values.firstWhere((e) => e.value == value);
}

class _DeprecatedInsumo extends Equatable {
  final String id;
  final String nome;
  final String? descricao;
  final _DeprecatedInsumoCategoria categoria;
  final _DeprecatedInsumoUnidadeMedida unidadeMedida;
  final double precoUnitario;
  final double estoqueMinimo;
  final bool ativo;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  const _DeprecatedInsumo({
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
  });

  @override
  List<Object?> get props => [
    id,
    nome,
    descricao,
    categoria,
    unidadeMedida,
    precoUnitario,
    estoqueMinimo,
    ativo,
    criadoEm,
    atualizadoEm,
  ];
}

*/
enum InsumoUnidadeMedida {
  g('G', 'g'),
  kg('KG', 'kg'),
  ml('ML', 'mL'),
  l('L', 'L'),
  un('UN', 'un');

  final String value;
  final String label;
  const InsumoUnidadeMedida(this.value, this.label);

  static InsumoUnidadeMedida fromValue(String value) =>
      InsumoUnidadeMedida.values.firstWhere((e) => e.value == value);
}

class Insumo extends Equatable {
  final int id;
  final int empresaId;
  final String nome;
  final double quantidade;
  final InsumoUnidadeMedida unidade;
  final double valorPago;
  final double custoUnitario;
  final double quantidadeDisponivel;
  final double quantidadeMinima;
  final DateTime dataCriacao;

  const Insumo({
    required this.id,
    required this.empresaId,
    required this.nome,
    required this.quantidade,
    required this.unidade,
    required this.valorPago,
    required this.custoUnitario,
    required this.quantidadeDisponivel,
    required this.quantidadeMinima,
    required this.dataCriacao,
  });

  @override
  List<Object?> get props => [
    id,
    empresaId,
    nome,
    quantidade,
    unidade,
    valorPago,
    custoUnitario,
    quantidadeDisponivel,
    quantidadeMinima,
    dataCriacao,
  ];
}
