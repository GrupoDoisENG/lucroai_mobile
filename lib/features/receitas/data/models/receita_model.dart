import '../../domain/entities/receita.dart';

class ReceitaModel extends Receita {
  const ReceitaModel({
    required super.id,
    required super.nome,
    super.descricao,
    required super.categoria,
    required super.rendimento,
    required super.custoTotal,
    required super.precoVenda,
    required super.ativo,
    required super.criadoEm,
    required super.atualizadoEm,
  });

  factory ReceitaModel.fromJson(Map<String, dynamic> json) {
    return ReceitaModel(
      id: json['id'] as String,
      nome: json['nome'] as String,
      descricao: json['descricao'] as String?,
      categoria: ReceitaCategoria.fromValue(json['categoria'] as String? ?? ''),
      rendimento: double.parse(json['rendimento'].toString()),
      custoTotal: double.parse(json['custo_total'].toString()),
      precoVenda: double.parse(json['preco_venda'].toString()),
      ativo: json['ativo'] as bool? ?? true,
      criadoEm: DateTime.parse(json['criado_em'] as String),
      atualizadoEm: DateTime.parse(json['atualizado_em'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'descricao': descricao,
      'categoria': categoria.value,
      'rendimento': rendimento,
      'custo_total': custoTotal,
      'preco_venda': precoVenda,
      'ativo': ativo,
    };
  }

  static Map<String, dynamic> toJsonCreate({
    required String nome,
    String? descricao,
    required ReceitaCategoria categoria,
    required double rendimento,
    required double custoTotal,
    required double precoVenda,
  }) {
    return {
      'nome': nome,
      if (descricao != null && descricao.trim().isNotEmpty)
        'descricao': descricao,
      'categoria': categoria.value,
      'rendimento': rendimento,
      'custo_total': custoTotal,
      'preco_venda': precoVenda,
    };
  }

  static Map<String, dynamic> toJsonUpdate({
    String? nome,
    String? descricao,
    ReceitaCategoria? categoria,
    double? rendimento,
    double? custoTotal,
    double? precoVenda,
    bool? ativo,
  }) {
    return {
      if (nome != null) 'nome': nome,
      if (descricao != null) 'descricao': descricao,
      if (categoria != null) 'categoria': categoria.value,
      if (rendimento != null) 'rendimento': rendimento,
      if (custoTotal != null) 'custo_total': custoTotal,
      if (precoVenda != null) 'preco_venda': precoVenda,
      if (ativo != null) 'ativo': ativo,
    };
  }
}
