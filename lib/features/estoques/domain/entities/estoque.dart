import 'package:equatable/equatable.dart';

class Estoque extends Equatable {
  final int id;
  final int insumoId;
  final double quantidadeDisponivel;
  final double quantidadeMinima;
  final DateTime? dataAlteracao;

  const Estoque({
    required this.id,
    required this.insumoId,
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
    quantidadeDisponivel,
    quantidadeMinima,
    dataAlteracao,
  ];
}
