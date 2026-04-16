enum ReceitaCategoria {
  doce('doce', 'Doce'),
  salgada('salgada', 'Salgada'),
  bebida('bebida', 'Bebida'),
  sobremesa('sobremesa', 'Sobremesa'),
  lanche('lanche', 'Lanche'),
  outros('outros', 'Outros');

  const ReceitaCategoria(this.value, this.label);

  final String value;
  final String label;

  static ReceitaCategoria fromValue(String value) {
    return ReceitaCategoria.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ReceitaCategoria.outros,
    );
  }
}

class Receita {
  final String id;
  final String nome;
  final String? descricao;
  final ReceitaCategoria categoria;
  final double rendimento;
  final double custoTotal;
  final double precoVenda;
  final bool ativo;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  const Receita({
    required this.id,
    required this.nome,
    this.descricao,
    required this.categoria,
    required this.rendimento,
    required this.custoTotal,
    required this.precoVenda,
    required this.ativo,
    required this.criadoEm,
    required this.atualizadoEm,
  });
}
