import '../../domain/entities/insumo.dart';

class InsumoModel extends Insumo {
  const InsumoModel({
    required super.id,
    required super.nome,
    super.descricao,
    required super.categoria,
    required super.unidadeMedida,
    required super.precoUnitario,
    required super.estoqueMinimo,
    required super.ativo,
    required super.criadoEm,
    required super.atualizadoEm,
  });

  factory InsumoModel.fromJson(Map<String, dynamic> json) {
    return InsumoModel(
      id: json['id'] as String,
      nome: json['nome'] as String,
      descricao: json['descricao'] as String?,
      categoria: InsumoCategoria.fromValue(json['categoria'] as String),
      unidadeMedida: InsumoUnidadeMedida.fromValue(json['unidade_medida'] as String),
      precoUnitario: double.parse(json['preco_unitario'].toString()),
      estoqueMinimo: double.parse(json['estoque_minimo'].toString()),
      ativo: json['ativo'] as bool,
      criadoEm: DateTime.parse(json['criado_em'] as String),
      atualizadoEm: DateTime.parse(json['atualizado_em'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'descricao': descricao,
      'categoria': categoria.value,
      'unidade_medida': unidadeMedida.value,
      'preco_unitario': precoUnitario,
      'estoque_minimo': estoqueMinimo,
      'ativo': ativo,
    };
  }

  static Map<String, dynamic> toJsonCreate({
    required String nome,
    String? descricao,
    required InsumoCategoria categoria,
    required InsumoUnidadeMedida unidadeMedida,
    required double precoUnitario,
    required double estoqueMinimo,
  }) {
    return {
      'nome': nome,
      if (descricao != null) 'descricao': descricao,
      'categoria': categoria.value,
      'unidade_medida': unidadeMedida.value,
      'preco_unitario': precoUnitario,
      'estoque_minimo': estoqueMinimo,
    };
  }

  static Map<String, dynamic> toJsonUpdate({
    String? nome,
    String? descricao,
    InsumoCategoria? categoria,
    InsumoUnidadeMedida? unidadeMedida,
    double? precoUnitario,
    double? estoqueMinimo,
    bool? ativo,
  }) {
    return {
      if (nome != null) 'nome': nome,
      if (descricao != null) 'descricao': descricao,
      if (categoria != null) 'categoria': categoria.value,
      if (unidadeMedida != null) 'unidade_medida': unidadeMedida.value,
      if (precoUnitario != null) 'preco_unitario': precoUnitario,
      if (estoqueMinimo != null) 'estoque_minimo': estoqueMinimo,
      if (ativo != null) 'ativo': ativo,
    };
  }
}
