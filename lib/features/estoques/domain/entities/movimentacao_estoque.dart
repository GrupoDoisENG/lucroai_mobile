import 'package:equatable/equatable.dart';

enum TipoMovimentacao { entrada, saida }
enum OrigemMovimentacao { compra, producao }

class MovimentacaoEstoque extends Equatable {
  final int id;
  final int insumoId;
  final TipoMovimentacao tipo;
  final OrigemMovimentacao origem;
  final double quantidade;
  final int? referenciaId;
  final DateTime dataMovimentacao;

  const MovimentacaoEstoque({
    required this.id,
    required this.insumoId,
    required this.tipo,
    required this.origem,
    required this.quantidade,
    this.referenciaId,
    required this.dataMovimentacao,
  });

  String get tipoLabel => tipo == TipoMovimentacao.entrada ? 'Entrada' : 'Saída';
  String get origemLabel => switch(origem) {
    OrigemMovimentacao.compra => 'Compra',
    OrigemMovimentacao.producao => 'Produção',
  };

  @override
  List<Object?> get props => [
    id,
    insumoId,
    tipo,
    origem,
    quantidade,
    referenciaId,
    dataMovimentacao,
  ];
}
