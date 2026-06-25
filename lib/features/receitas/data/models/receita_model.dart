import '../../../insumos/domain/entities/insumo.dart';
import '../../domain/entities/receita.dart';

class ReceitaItemModel extends ReceitaItem {
  const ReceitaItemModel({
    required super.insumoId,
    required super.quantidade,
    super.custoCalculado,
  });

  factory ReceitaItemModel.fromJson(Map<String, dynamic> json) {
    return ReceitaItemModel(
      insumoId: _toInt(json['insumoId'] ?? json['insumo_id']),
      quantidade: _toDouble(json['quantidade']),
      custoCalculado: _toDoubleOrNull(
        json['custoCalculado'] ?? json['custo_calculado'],
      ),
    );
  }

  Map<String, dynamic> toJsonCreate() {
    return {'insumo_id': insumoId, 'quantidade': quantidade};
  }
}

class ReceitaModel extends Receita {
  const ReceitaModel({
    required super.id,
    required super.empresaId,
    required super.nome,
    required super.rendimento,
    required super.unidadeRendimento,
    required super.dataCriacao,
    super.custoProducao,
    super.custoUnitario,
    super.margemLucro,
    super.precoSugerido,
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
      custoProducao: _toDoubleOrNull(
        json['custoProducao'] ?? json['custo_producao'],
      ),
      custoUnitario: _toDoubleOrNull(
        json['custoUnitario'] ?? json['custo_unitario'],
      ),
      margemLucro: _toDoubleOrNull(json['margemLucro'] ?? json['margem_lucro']),
      precoSugerido: _toDoubleOrNull(
        json['precoSugerido'] ?? json['preco_sugerido'],
      ),
      dataCriacao:
          DateTime.tryParse(
            (json['dataCriacao'] ?? json['data_criacao'] ?? '').toString(),
          ) ??
          DateTime.now(),
      itens: _parseItens(json['itens']),
    );
  }

  static Map<String, dynamic> toJsonCreate({
    required String nome,
    required double rendimento,
    required InsumoUnidadeMedida unidadeRendimento,
    double? margemLucro,
    List<ReceitaItemModel> insumos = const [],
  }) {
    return {
      'nome': nome,
      'rendimento': rendimento,
      'unidadeRendimento': unidadeRendimento.value,
      if (margemLucro != null) 'margem_lucro': margemLucro,
      'insumos': insumos.map((i) => i.toJsonCreate()).toList(),
    };
  }

  static Map<String, dynamic> toJsonUpdate({
    String? nome,
    double? rendimento,
    InsumoUnidadeMedida? unidadeRendimento,
    double? margemLucro,
    List<ReceitaItemModel>? insumos,
  }) {
    return {
      if (nome != null) 'nome': nome,
      if (rendimento != null) 'rendimento': rendimento,
      if (unidadeRendimento != null)
        'unidadeRendimento': unidadeRendimento.value,
      if (margemLucro != null) 'margem_lucro': margemLucro,
      if (insumos != null)
        'insumos': insumos.map((i) => i.toJsonCreate()).toList(),
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

double? _toDoubleOrNull(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString().replaceAll(',', '.'));
}
