import 'package:equatable/equatable.dart';

class EstoqueComInsumo extends Equatable {
  final int id;
  final String insumoId;
  final String insumoNome;
  final String insumoCategoria;
  final String insumoUnidade;
  final double quantidadeDisponivel;
  final double quantidadeMinima;
  final DateTime? dataAlteracao;

  const EstoqueComInsumo({
    required this.id,
    required this.insumoId,
    required this.insumoNome,
    required this.insumoCategoria,
    required this.insumoUnidade,
    required this.quantidadeDisponivel,
    required this.quantidadeMinima,
    this.dataAlteracao,
  });

  bool get isBaixoEstoque => quantidadeDisponivel < quantidadeMinima;
  
  double get percentualEstoque => quantidadeMinima > 0 
      ? (quantidadeDisponivel / quantidadeMinima) * 100 
      : 100;

  @override
  List<Object?> get props => [
    id,
    insumoId,
    insumoNome,
    insumoCategoria,
    insumoUnidade,
    quantidadeDisponivel,
    quantidadeMinima,
    dataAlteracao,
  ];
}
