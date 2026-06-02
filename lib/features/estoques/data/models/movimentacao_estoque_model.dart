import '../../domain/entities/movimentacao_estoque.dart';

class MovimentacaoEstoqueModel extends MovimentacaoEstoque {
  const MovimentacaoEstoqueModel({
    required super.id,
    required super.insumoId,
    required super.tipo,
    required super.origem,
    required super.quantidade,
    super.referenciaId,
    required super.dataMovimentacao,
  });

  factory MovimentacaoEstoqueModel.fromJson(Map<String, dynamic> json) {
    final tipoString = (json['tipo'] as String).toUpperCase();
    final origemString = (json['origem'] as String).toUpperCase();

    return MovimentacaoEstoqueModel(
      id: json['id'] as int,
      insumoId: (json['insumoId'] ?? json['insumo_id']) as int,
      tipo: tipoString == 'ENTRADA'
          ? TipoMovimentacao.entrada
          : TipoMovimentacao.saida,
      origem: origemString == 'COMPRA'
          ? OrigemMovimentacao.compra
          : OrigemMovimentacao.producao,
      quantidade: (json['quantidade'] as num).toDouble(),
      referenciaId: (json['referenciaId'] ?? json['referencia_id']) as int?,
      dataMovimentacao: DateTime.parse(
        json['dataMovimentacao'] ?? json['data_movimentacao'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'insumoId': insumoId,
      'tipo': tipo == TipoMovimentacao.entrada ? 'ENTRADA' : 'SAIDA',
      'origem': origem == OrigemMovimentacao.compra ? 'COMPRA' : 'PRODUCAO',
      'quantidade': quantidade,
      'referenciaId': referenciaId,
      'dataMovimentacao': dataMovimentacao.toIso8601String(),
    };
  }
}
