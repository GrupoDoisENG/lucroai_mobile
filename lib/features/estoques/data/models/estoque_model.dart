import '../../domain/entities/estoque.dart';

class EstoqueModel extends Estoque {
  const EstoqueModel({
    required super.id,
    required super.insumoId,
    required super.quantidadeDisponivel,
    required super.quantidadeMinima,
    super.dataAlteracao,
  });

  factory EstoqueModel.fromJson(Map<String, dynamic> json) {
    return EstoqueModel(
      id: json['id'] as int,
      insumoId: json['insumoId'] ?? json['insumo_id'] as int,
      quantidadeDisponivel: (json['quantidadeDisponivel'] ?? json['quantidade_disponivel'] as num).toDouble(),
      quantidadeMinima: (json['quantidadeMinima'] ?? json['quantidade_minima'] as num).toDouble(),
      dataAlteracao: json['dataAlteracao'] != null || json['data_alteracao'] != null
          ? DateTime.parse(json['dataAlteracao'] ?? json['data_alteracao'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'insumoId': insumoId,
      'quantidadeDisponivel': quantidadeDisponivel,
      'quantidadeMinima': quantidadeMinima,
      'dataAlteracao': dataAlteracao?.toIso8601String(),
    };
  }
}
