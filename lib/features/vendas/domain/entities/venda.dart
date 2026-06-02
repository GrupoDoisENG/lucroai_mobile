class VendaItem {
  final int receitaId;
  final String produto;
  final double quantidade;
  final double precoUnitarioReal;
  final double total;

  const VendaItem({
    required this.receitaId,
    required this.produto,
    required this.quantidade,
    required this.precoUnitarioReal,
    required this.total,
  });
}

class Venda {
  final int id;
  final int empresaId;
  final String produto;
  final double quantidade;
  final double total;
  final String status;
  final DateTime dataVenda;
  final List<VendaItem> itens;

  const Venda({
    required this.id,
    required this.empresaId,
    required this.produto,
    required this.quantidade,
    required this.total,
    required this.status,
    required this.dataVenda,
    this.itens = const [],
  });
}

class CreateVendaItem {
  final int receitaId;
  final double quantidade;
  final double precoUnitarioReal;

  const CreateVendaItem({
    required this.receitaId,
    required this.quantidade,
    required this.precoUnitarioReal,
  });
}

class CreateVendaRequest {
  final int empresaId;
  final List<CreateVendaItem> itens;

  const CreateVendaRequest({required this.empresaId, required this.itens});
}

class VendaResumo {
  final double totalVendido;
  final int quantidadeVendas;
  final double ticketMedio;

  const VendaResumo({
    required this.totalVendido,
    required this.quantidadeVendas,
    required this.ticketMedio,
  });

  factory VendaResumo.fromVendas(List<Venda> vendas) {
    final totalVendido = vendas.fold<double>(
      0,
      (total, venda) => total + venda.total,
    );

    return VendaResumo(
      totalVendido: totalVendido,
      quantidadeVendas: vendas.length,
      ticketMedio: vendas.isEmpty ? 0 : totalVendido / vendas.length,
    );
  }
}
