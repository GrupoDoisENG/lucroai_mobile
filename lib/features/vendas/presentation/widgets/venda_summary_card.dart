import 'package:flutter/material.dart';

import '../../domain/entities/venda.dart';

class VendaSummaryCard extends StatelessWidget {
  final VendaResumo resumo;

  const VendaSummaryCard({super.key, required this.resumo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1A1A1A)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Metric(
              label: 'Total vendido',
              value: _formatCurrency(resumo.totalVendido),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _Metric(
              label: 'Vendas',
              value: resumo.quantidadeVendas.toString(),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _Metric(
              label: 'Ticket medio',
              value: _formatCurrency(resumo.ticketMedio),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatCurrency(double value) {
    return 'R\$ ${_formatNumber(value)}';
  }

  static String _formatNumber(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    return '${parts[0]},${parts[1]}';
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Color(0xFF858585), fontSize: 10.5),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFFFF6B3D),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
