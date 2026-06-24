import '../../../insumos/domain/entities/insumo.dart';

class ReceitaItemInput {
  final int insumoId;
  final double quantidade;

  const ReceitaItemInput({required this.insumoId, required this.quantidade});
}

class ReceitaItem {
  final int insumoId;
  final double quantidade;
  final double? custoCalculado;

  const ReceitaItem({
    required this.insumoId,
    required this.quantidade,
    this.custoCalculado,
  });
}

class Receita {
  final int id;
  final int empresaId;
  final String nome;
  final double rendimento;
  final InsumoUnidadeMedida unidadeRendimento;
  final double? custoProducao;
  final double? custoUnitario;
  final double? margemLucro;
  final double? precoSugerido;
  final DateTime dataCriacao;
  final List<ReceitaItem> itens;

  const Receita({
    required this.id,
    required this.empresaId,
    required this.nome,
    required this.rendimento,
    required this.unidadeRendimento,
    required this.dataCriacao,
    this.custoProducao,
    this.custoUnitario,
    this.margemLucro,
    this.precoSugerido,
    this.itens = const [],
  });
}
