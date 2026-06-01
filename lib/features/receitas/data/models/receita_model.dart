import '../../../insumos/domain/entities/insumo.dart';
import '../../domain/entities/receita.dart';

class ReceitaItemModel extends ReceitaItem {
  const ReceitaItemModel({
    required super.insumoId,
    required super.quantidade,
    required super.custoCalculado,
  });

  factory ReceitaItemModel.fromJson(Map<String, dynamic> json) {
    return ReceitaItemModel(
      insumoId: _toInt(json['insumoId'] ?? json['insumo_id']),
      quantidade: _toDouble(json['quantidade']),
      custoCalculado: _toDouble(
        json['custoCalculado'] ?? json['custo_calculado'],
      ),
    );
  }

  static Map<String, dynamic> toJsonCreate({
    required int insumoId,
    required double quantidade,
    required double custoCalculado,
  }) {
    return {
      'insumoId': insumoId,
      'quantidade': quantidade,
      'custoCalculado': custoCalculado,
    };
  }
}

class ReceitaModel extends Receita {
  const ReceitaModel({
    required super.id,
    required super.empresaId,
    required super.nome,
    required super.rendimento,
    required super.unidadeRendimento,
    required super.custoProducao,
    required super.custoUnitario,
    required super.margemLucro,
    required super.precoSugerido,
    super.itens,
  });

  factory ReceitaModel.fromJson(Map<String, dynamic> json) {
    return ReceitaModel(
      id: _toInt(json['id']),
      empresaId: _toInt(json['empresaId'] ?? json['empresa_id']),
      nome: (json['nome'] ?? '').toString(),
      rendimento: _toDouble(json['rendimento']),
      unidadeRendimento: InsumoUnidadeMedida.fromValue(
        (json['unidadeRendimento'] ?? json['unidade_rendimento'] ?? 'UN')
            .toString(),
      ),
      custoProducao: _toDouble(json['custoProducao'] ?? json['custo_producao']),
      custoUnitario: _toDouble(json['custoUnitario'] ?? json['custo_unitario']),
      margemLucro: _toDouble(json['margemLucro'] ?? json['margem_lucro']),
      precoSugerido: _toDouble(json['precoSugerido'] ?? json['preco_sugerido']),
      itens: _parseItens(json['itens']),
    );
  }

  static Map<String, dynamic> toJsonCreate({
    required int empresaId,
    required String nome,
    required double rendimento,
    required InsumoUnidadeMedida unidadeRendimento,
    required double custoProducao,
    required double custoUnitario,
    required double margemLucro,
    required double precoSugerido,
  }) {
    return {
      'empresaId': empresaId,
      'nome': nome,
      'rendimento': rendimento,
      'unidadeRendimento': unidadeRendimento.value,
      'custoProducao': custoProducao,
      'custoUnitario': custoUnitario,
      'margemLucro': margemLucro,
      'precoSugerido': precoSugerido,
    };
  }

  static Map<String, dynamic> toJsonUpdate({
    String? nome,
    double? rendimento,
    InsumoUnidadeMedida? unidadeRendimento,
    double? custoProducao,
    double? custoUnitario,
    double? margemLucro,
    double? precoSugerido,
  }) {
    return {
      if (nome != null) 'nome': nome,
      if (rendimento != null) 'rendimento': rendimento,
      if (unidadeRendimento != null)
        'unidadeRendimento': unidadeRendimento.value,
      if (custoProducao != null) 'custoProducao': custoProducao,
      if (custoUnitario != null) 'custoUnitario': custoUnitario,
      if (margemLucro != null) 'margemLucro': margemLucro,
      if (precoSugerido != null) 'precoSugerido': precoSugerido,
    };
  }

  static List<ReceitaItem> _parseItens(dynamic value) {
    if (value is! List) return const [];

    return value
        .whereType<Map>()
        .map(
          (json) => ReceitaItemModel.fromJson(Map<String, dynamic>.from(json)),
        )
        .toList();
  }
}

int _toInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString().replaceAll(',', '.') ?? '') ?? 0;
}
