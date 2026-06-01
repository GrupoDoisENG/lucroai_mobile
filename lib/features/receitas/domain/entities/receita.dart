import '../../../insumos/domain/entities/insumo.dart';

class ReceitaItem {
  final int insumoId;
  final double quantidade;
  final double custoCalculado;

  const ReceitaItem({
    required this.insumoId,
    required this.quantidade,
    required this.custoCalculado,
  });
}

class Receita {
  final int id;
  final int empresaId;
  final String nome;
  final double rendimento;
  final InsumoUnidadeMedida unidadeRendimento;
  final double custoProducao;
  final double custoUnitario;
  final double margemLucro;
  final double precoSugerido;
  final List<ReceitaItem> itens;

  const Receita({
    required this.id,
    required this.empresaId,
    required this.nome,
    required this.rendimento,
    required this.unidadeRendimento,
    required this.custoProducao,
    required this.custoUnitario,
    required this.margemLucro,
    required this.precoSugerido,
    this.itens = const [],
  });
}
