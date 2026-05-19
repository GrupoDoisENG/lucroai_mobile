import 'package:flutter/material.dart';
import '../../domain/entities/estoque_com_insumo.dart';

class EstoqueCard extends StatelessWidget {
  final EstoqueComInsumo estoque;
  final VoidCallback onTapRegistrarEntrada;

  const EstoqueCard({
    super.key,
    required this.estoque,
    required this.onTapRegistrarEntrada,
  });

  Color _categoriaColor(String categoria) {
    return switch (categoria.toLowerCase()) {
      'materia_prima' => Colors.brown,
      'embalagem' => Colors.blue,
      'ingrediente' => Colors.green,
      'descartavel' => Colors.orange,
      'limpeza' => Colors.cyan,
      _ => Colors.grey,
    };
  }

  Color _getIndicadorColor() {
    if (estoque.isBaixoEstoque) return Colors.redAccent;
    if (estoque.percentualEstoque < 50) return Colors.amber;
    return Colors.greenAccent;
  }

  String _getIndicadorLabel() {
    if (estoque.isBaixoEstoque) return 'Crítico';
    if (estoque.percentualEstoque < 50) return 'Baixo';
    return 'Adequado';
  }

  @override
  Widget build(BuildContext context) {
    final categoriaColor = _categoriaColor(estoque.insumoCategoria);
    final indicadorColor = _getIndicadorColor();
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      color: estoque.isBaixoEstoque 
          ? colorScheme.surfaceContainerHigh 
          : colorScheme.surfaceContainer,
      child: InkWell(
        onTap: onTapRegistrarEntrada,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho: Nome do insumo e indicador
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          estoque.insumoNome,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: categoriaColor.withAlpha(30),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: categoriaColor.withAlpha(80),
                                ),
                              ),
                              child: Text(
                                estoque.insumoCategoria,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: categoriaColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: indicadorColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: indicadorColor.withAlpha(80),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getIndicadorLabel(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: indicadorColor,
                          ),
                        ),
                        Text(
                          '${estoque.percentualEstoque.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 9,
                            color: indicadorColor.withAlpha(200),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Barra de progresso
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (estoque.percentualEstoque / 100).clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: Colors.grey.withAlpha(80),
                  valueColor: AlwaysStoppedAnimation<Color>(indicadorColor),
                ),
              ),
              const SizedBox(height: 12),
              
              // Informações de quantidade
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Disponível',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.withAlpha(200),
                        ),
                      ),
                      Text(
                        '${estoque.quantidadeDisponivel.toStringAsFixed(2)} ${estoque.insumoUnidade}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mínimo',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.withAlpha(200),
                        ),
                      ),
                      Text(
                        '${estoque.quantidadeMinima.toStringAsFixed(2)} ${estoque.insumoUnidade}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  if (estoque.isBaixoEstoque)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withAlpha(30),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.redAccent.withAlpha(80),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning_rounded,
                            size: 14,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Alerta',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Botão para registrar entrada
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onTapRegistrarEntrada,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Registrar Entrada'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFE85D33),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
