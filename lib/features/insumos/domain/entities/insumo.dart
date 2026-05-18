import 'package:equatable/equatable.dart';

enum InsumoCategoria {
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

enum InsumoUnidadeMedida {
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
  const InsumoUnidadeMedida(this.value, this.label);

  static InsumoUnidadeMedida fromValue(String value) =>
      InsumoUnidadeMedida.values.firstWhere((e) => e.value == value);
}

class Insumo extends Equatable {
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
  });

  String get detalheFormatado => "${categoria.label} • Mínimo: ${estoqueMinimo.toInt()} ${unidadeMedida.label}";
  
  String get custoUnitarioFormatado => "R\$ ${precoUnitario.toStringAsFixed(4)}/${unidadeMedida.label}";

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