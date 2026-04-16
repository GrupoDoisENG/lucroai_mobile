/*
import 'package:flutter/material.dart';
import '../../domain/entities/insumo.dart';

class InsumoCard extends StatelessWidget {
  final Insumo insumo;
  final VoidCallback onTap;
  final VoidCallback onToggleAtivo;
  final VoidCallback onDelete;

  const InsumoCard({
    super.key,
    required this.insumo,
    required this.onTap,
    required this.onToggleAtivo,
    required this.onDelete,
  });

  Color _categoriaColor(InsumoCategoria categoria) {
    return switch (categoria) {
      InsumoCategoria.materiaPrima => Colors.brown,
      InsumoCategoria.embalagem => Colors.blue,
      InsumoCategoria.ingrediente => Colors.green,
      InsumoCategoria.descartavel => Colors.orange,
      InsumoCategoria.limpeza => Colors.cyan,
      InsumoCategoria.outros => Colors.grey,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final categoriaColor = _categoriaColor(insumo.categoria);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: insumo.ativo ? 1 : 0,
      color: insumo.ativo ? null : colorScheme.surfaceContainerLow,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: categoriaColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: categoriaColor.withAlpha(80)),
                    ),
                    child: Text(
                      insumo.categoria.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: categoriaColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (!insumo.ativo)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Inativo',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'toggle',
                        child: Row(
                          children: [
                            Icon(
                              insumo.ativo ? Icons.toggle_off : Icons.toggle_on,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(insumo.ativo ? 'Desativar' : 'Ativar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Excluir', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'toggle') onToggleAtivo();
                      if (value == 'delete') onDelete();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                insumo.nome,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: insumo.ativo ? null : colorScheme.onSurface.withAlpha(120),
                ),
              ),
              if (insumo.descricao != null && insumo.descricao!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  insumo.descricao!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  _InfoChip(
                    label: 'Preço',
                    value:
                        'R\$ ${insumo.precoUnitario.toStringAsFixed(2)}/${insumo.unidadeMedida.label}',
                  ),
                  const SizedBox(width: 8),
                  _InfoChip(
                    label: 'Est. mín.',
                    value: '${insumo.estoqueMinimo.toStringAsFixed(2)} ${insumo.unidadeMedida.label}',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/

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
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      insumo.nome,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Colors.red,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Excluir',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'delete') onDelete();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(
                    label: 'Compra',
                    value:
                        '${insumo.quantidade.toStringAsFixed(2)} ${insumo.unidade.label}',
                  ),
                  _InfoChip(
                    label: 'Valor pago',
                    value: 'R\$ ${insumo.valorPago.toStringAsFixed(2)}',
                  ),
                  _InfoChip(
                    label: 'Custo unit.',
                    value:
                        'R\$ ${insumo.custoUnitario.toStringAsFixed(4)}/${insumo.unidade.label}',
                  ),
                  _InfoChip(
                    label: 'Estoque',
                    value:
                        '${insumo.quantidadeDisponivel.toStringAsFixed(2)} ${insumo.unidade.label}',
                    color:
                        insumo.quantidadeDisponivel <= insumo.quantidadeMinima
                        ? colorScheme.errorContainer
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*
class _DeprecatedInfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _InfoChip({
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color ?? colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
*/

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _InfoChip({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color ?? colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
