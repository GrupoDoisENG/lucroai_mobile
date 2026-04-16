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
    super.quantidadeEmbalagem,
    super.precoEmbalagem,
  });

  factory InsumoModel.fromJson(Map<String, dynamic> json) {
    return InsumoModel(
      id: (json['id'] ?? '').toString(),
      nome: (json['nome'] ?? '').toString(),
      descricao: json['descricao']?.toString(),
      categoria: InsumoCategoria.fromValue(
        (json['categoria'] ?? 'outros').toString(),
      ),
      unidadeMedida: InsumoUnidadeMedida.fromValue(
        (json['unidade_medida'] ?? 'un').toString(),
      ),
      precoUnitario: _toDouble(json['preco_unitario']),
      estoqueMinimo: _toDouble(json['estoque_minimo']),
      ativo: json['ativo'] is bool ? json['ativo'] as bool : true,
      criadoEm: _toDate(json['criado_em']),
      atualizadoEm: _toDate(json['atualizado_em']),
      quantidadeEmbalagem: _firstDouble([
        json['quantidade_embalagem'],
        json['quantidade'],
        json['peso_embalagem'],
      ]),
      precoEmbalagem: _firstDouble([
        json['preco_embalagem'],
        json['preco_pacote'],
        json['valor_embalagem'],
      ]),
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
      if (quantidadeEmbalagem != null)
        'quantidade_embalagem': quantidadeEmbalagem,
      if (precoEmbalagem != null) 'preco_embalagem': precoEmbalagem,
    };
  }

  static Map<String, dynamic> toJsonCreate({
    required String nome,
    String? descricao,
    required InsumoCategoria categoria,
    required InsumoUnidadeMedida unidadeMedida,
    required double precoUnitario,
    required double estoqueMinimo,
    double? quantidadeEmbalagem,
    double? precoEmbalagem,
  }) {
    return {
      'nome': nome,
      if (descricao != null && descricao.trim().isNotEmpty) 'descricao': descricao,
      'categoria': categoria.value,
      'unidade_medida': unidadeMedida.value,
      'preco_unitario': precoUnitario,
      'estoque_minimo': estoqueMinimo,
      if (quantidadeEmbalagem != null)
        'quantidade_embalagem': quantidadeEmbalagem,
      if (precoEmbalagem != null) 'preco_embalagem': precoEmbalagem,
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
    double? quantidadeEmbalagem,
    double? precoEmbalagem,
  }) {
    return {
      if (nome != null) 'nome': nome,
      if (descricao != null) 'descricao': descricao,
      if (categoria != null) 'categoria': categoria.value,
      if (unidadeMedida != null) 'unidade_medida': unidadeMedida.value,
      if (precoUnitario != null) 'preco_unitario': precoUnitario,
      if (estoqueMinimo != null) 'estoque_minimo': estoqueMinimo,
      if (ativo != null) 'ativo': ativo,
      if (quantidadeEmbalagem != null)
        'quantidade_embalagem': quantidadeEmbalagem,
      if (precoEmbalagem != null) 'preco_embalagem': precoEmbalagem,
    };
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    return double.tryParse(value.toString().replaceAll(',', '.')) ?? 0;
  }

  static double? _firstDouble(List<dynamic> values) {
    for (final value in values) {
      if (value == null) continue;
      final parsed = double.tryParse(value.toString().replaceAll(',', '.'));
      if (parsed != null) return parsed;
    }
    return null;
  }

  static DateTime _toDate(dynamic value) {
    if (value == null) return DateTime.now();
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }
}