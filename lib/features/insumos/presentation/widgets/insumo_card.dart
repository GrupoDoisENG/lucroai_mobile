import 'package:flutter/material.dart';

import '../../domain/entities/insumo.dart';

class InsumoCard extends StatelessWidget {
  final Insumo insumo;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const InsumoCard({
    super.key,
    required this.insumo,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = _buildSubtitle(insumo);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFF101010),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFF1A1A1A),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFF151515),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF242424),
                    ),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    size: 18,
                    color: Color(0xFFFF6B3D),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          insumo.nome,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF858585),
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatUnitPrice(
                        insumo.precoUnitario,
                        insumo.unidadeMedida.label,
                      ),
                      style: const TextStyle(
                        color: Color(0xFFFF6B3D),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: onDelete,
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          size: 17,
                          color: Color(0xFF7F7F7F),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _buildSubtitle(Insumo insumo) {
    if (insumo.quantidadeEmbalagem != null && insumo.precoEmbalagem != null) {
      return '${_formatNumber(insumo.quantidadeEmbalagem!)} ${insumo.unidadeMedida.label} - ${_formatCurrency(insumo.precoEmbalagem!)}';
    }

    if (insumo.descricao != null && insumo.descricao!.trim().isNotEmpty) {
      return insumo.descricao!;
    }

    return 'Estoque mín. ${_formatNumber(insumo.estoqueMinimo)} ${insumo.unidadeMedida.label}';
  }

  static String _formatCurrency(double value) {
    return 'R\$ ${_formatNumber(value, decimals: 2)}';
  }

  static String _formatUnitPrice(double value, String unidade) {
    return 'R\$ ${_formatNumber(value, decimals: 4)}/$unidade';
  }

  static String _formatNumber(double value, {int decimals = 2}) {
    final fixed = value.toStringAsFixed(decimals);
    final parts = fixed.split('.');

    final integer = parts[0];
    String decimal = parts.length > 1 ? parts[1] : '';

    if (decimals > 2) {
      decimal = decimal.replaceFirst(RegExp(r'0+$'), '');
      if (decimal.isEmpty) {
        decimal = '0';
      }
    }

    return decimal.isEmpty ? integer : '$integer,$decimal';
  }
}