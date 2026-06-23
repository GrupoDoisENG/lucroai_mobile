import 'package:flutter/material.dart';

import '../../domain/entities/receita.dart';

class ReceitaCard extends StatelessWidget {
  final Receita receita;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onSimular;

  const ReceitaCard({
    super.key,
    required this.receita,
    required this.onTap,
    required this.onDelete,
    required this.onSimular,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFF101010),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF1A1A1A)),
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
                    border: Border.all(color: const Color(0xFF242424)),
                  ),
                  child: const Icon(
                    Icons.restaurant_menu_outlined,
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
                          receita.nome,
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
                          '${_formatNumber(receita.rendimento)} ${receita.unidadeRendimento.label} - custo ${_formatCurrency(receita.custoProducao)}',
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
                      _formatCurrency(receita.precoSugerido),
                      style: const TextStyle(
                        color: Color(0xFFFF6B3D),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${_formatNumber(receita.margemLucro * 100, decimals: 1)}%',
                      style: const TextStyle(
                        color: Color(0xFF858585),
                        fontSize: 10.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: onSimular,
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.science_outlined,
                          size: 17,
                          color: Color(0xFF7F7F7F),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
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

  static String _formatCurrency(double value) {
    return 'R\$ ${_formatNumber(value, decimals: 2)}';
  }

  static String _formatNumber(double value, {int decimals = 2}) {
    final fixed = value.toStringAsFixed(decimals);
    final parts = fixed.split('.');
    final integer = parts[0];
    final decimal = parts.length > 1 ? parts[1] : '';

    return decimal.isEmpty ? integer : '$integer,$decimal';
  }
}
