import '../../domain/entities/estoque_com_insumo.dart';

class EstoqueComInsumoModel extends EstoqueComInsumo {
  const EstoqueComInsumoModel({
    required int id,
    required String insumoId,
    required String insumoNome,
    required String insumoCategoria,
    required String insumoUnidade,
    required double quantidadeDisponivel,
    required double quantidadeMinima,
    DateTime? dataAlteracao,
  }) : super(
    id: id,
    insumoId: insumoId,
    insumoNome: insumoNome,
    insumoCategoria: insumoCategoria,
    insumoUnidade: insumoUnidade,
    quantidadeDisponivel: quantidadeDisponivel,
    quantidadeMinima: quantidadeMinima,
    dataAlteracao: dataAlteracao,
  );

  factory EstoqueComInsumoModel.fromJson(Map<String, dynamic> json) {
    return EstoqueComInsumoModel(
      id: json['id'] as int,
      insumoId: (json['insumoId'] ?? json['insumo_id']).toString(),
      insumoNome: (json['insumoNome'] ?? json['insumo_nome']) as String,
      insumoCategoria:
          (json['insumoCategoria'] ?? json['insumo_categoria']) as String,
      insumoUnidade: (json['insumoUnidade'] ?? json['insumo_unidade']) as String,
      quantidadeDisponivel: ((json['quantidadeDisponivel'] ??
              json['quantidade_disponivel']) as num)
          .toDouble(),
      quantidadeMinima:
          ((json['quantidadeMinima'] ?? json['quantidade_minima']) as num)
              .toDouble(),
      dataAlteracao:
          json['dataAlteracao'] != null || json['data_alteracao'] != null
          ? DateTime.parse(json['dataAlteracao'] ?? json['data_alteracao'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'insumoId': insumoId,
      'insumoNome': insumoNome,
      'insumoCategoria': insumoCategoria,
      'insumoUnidade': insumoUnidade,
      'quantidadeDisponivel': quantidadeDisponivel,
      'quantidadeMinima': quantidadeMinima,
      'dataAlteracao': dataAlteracao?.toIso8601String(),
    };
  }
}
