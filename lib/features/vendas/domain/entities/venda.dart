class VendaItem {
  final int receitaId;
  final String produto;
  final double quantidade;
  final double precoUnitarioReal;
  final double total;
  final double? custoUnitario;
  final double? margemRealizada;

  const VendaItem({
    required this.receitaId,
    required this.produto,
    required this.quantidade,
    required this.precoUnitarioReal,
    required this.total,
    this.custoUnitario,
    this.margemRealizada,
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

  bool get isCancelada {
    final normalized = status
        .trim()
        .toLowerCase()
        .replaceAll('í', 'i')
        .replaceAll('ú', 'u')
        .replaceAll('ã', 'a')
        .replaceAll('ç', 'c');

    return normalized == 'cancelada' ||
        normalized == 'cancelado' ||
        normalized == 'canceled' ||
        normalized == 'cancelled';
  }

  bool get isFaturavel => !isCancelada;
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
  final List<CreateVendaItem> itens;

  const CreateVendaRequest({required this.itens});
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
    final vendasFaturaveis = vendas
        .where((venda) => venda.isFaturavel)
        .toList();
    final totalVendido = vendasFaturaveis.fold<double>(
      0,
      (total, venda) => total + venda.total,
    );

    return VendaResumo(
      totalVendido: totalVendido,
      quantidadeVendas: vendasFaturaveis.length,
      ticketMedio: vendasFaturaveis.isEmpty
          ? 0
          : totalVendido / vendasFaturaveis.length,
    );
  }
}
