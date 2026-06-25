import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../estoques/domain/entities/estoque_com_insumo.dart';
import '../../../estoques/presentation/cubit/estoques_cubit.dart';
import '../../../estoques/presentation/cubit/estoques_state.dart';
import '../../../receitas/domain/entities/receita.dart';
import '../../../receitas/presentation/cubit/receitas_cubit.dart';
import '../../../receitas/presentation/cubit/receitas_state.dart';
import '../../../vendas/domain/entities/venda.dart';
import '../../../vendas/presentation/cubit/vendas_cubit.dart';
import '../../../vendas/presentation/cubit/vendas_state.dart';

class DashboardPage extends StatefulWidget {
  final ValueChanged<int>? onNavigate;

  const DashboardPage({super.key, this.onNavigate});

  static const _background = Color(0xFF050505);
  static const _surface = Color(0xFF101010);
  static const _surfaceAlt = Color(0xFF161616);
  static const _border = Color(0xFF1F1F1F);
  static const _primary = Color(0xFFFF6B3D);
  static const _success = Color(0xFF00D287);
  static const _textMuted = Color(0xFF858585);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final vendasCubit = context.read<VendasCubit>();
      if (vendasCubit.state.status == VendasStatus.initial) {
        vendasCubit.loadInitial();
      }

      final receitasCubit = context.read<ReceitasCubit>();
      if (receitasCubit.state.status == ReceitasStatus.initial) {
        receitasCubit.loadReceitas();
      }

      final estoquesCubit = context.read<EstoquesCubit>();
      if (estoquesCubit.state is EstoquesInitial) {
        estoquesCubit.loadEstoques();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DashboardPage._background,
      body: BlocBuilder<VendasCubit, VendasState>(
        builder: (context, vendasState) {
          return BlocBuilder<ReceitasCubit, ReceitasState>(
            builder: (context, receitasState) {
              return BlocBuilder<EstoquesCubit, EstoquesState>(
                builder: (context, estoquesState) {
                  final dashboard = _DashboardData.fromStates(
                    vendasState: vendasState,
                    receitas: receitasState.receitas,
                    estoques: _extractEstoques(estoquesState),
                  );

                  return SafeArea(
                    child: RefreshIndicator(
                      color: DashboardPage._primary,
                      backgroundColor: DashboardPage._surface,
                      onRefresh: _refreshDashboard,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                        children: [
                          _buildHeader(
                            vendasState,
                            receitasState,
                            estoquesState,
                          ),
                          const SizedBox(height: 22),
                          _buildKpis(dashboard),
                          const SizedBox(height: 24),
                          const _SectionTitle(title: 'Evolução mensal'),
                          const SizedBox(height: 12),
                          _ChartCard(
                            values: dashboard.monthlyValues,
                            labels: dashboard.monthLabels,
                            trendLabel: dashboard.monthlyTrendLabel,
                          ),
                          const SizedBox(height: 24),
                          const _SectionTitle(title: 'Ações rápidas'),
                          const SizedBox(height: 12),
                          _QuickActions(onNavigate: widget.onNavigate),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              const Expanded(
                                child: _SectionTitle(
                                  title: 'Produtos mais rentáveis',
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () => widget.onNavigate?.call(4),
                                iconAlignment: IconAlignment.end,
                                icon: const Icon(Icons.arrow_forward, size: 18),
                                label: const Text('Ver tudo'),
                                style: TextButton.styleFrom(
                                  foregroundColor: DashboardPage._primary,
                                  padding: EdgeInsets.zero,
                                  textStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (dashboard.topProducts.isEmpty)
                            const _EmptyStateCard(
                              message:
                                  'Cadastre receitas e registre vendas para ver rentabilidade.',
                            )
                          else
                            ...dashboard.topProducts.map(
                              (product) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _ProfitableProductTile(
                                  name: product.name,
                                  units: product.unitsLabel,
                                  value: _formatCurrency(product.profit),
                                  margin: _formatPercent(product.margin),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader(
    VendasState vendasState,
    ReceitasState receitasState,
    EstoquesState estoquesState,
  ) {
    final isLoading =
        vendasState.status == VendasStatus.loading ||
        receitasState.status == ReceitasStatus.loading ||
        estoquesState is EstoquesLoading;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LucroAI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Seu painel financeiro',
                style: TextStyle(color: Color(0xFF7C7C7C), fontSize: 12.5),
              ),
            ],
          ),
        ),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: DashboardPage._primary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildKpis(_DashboardData dashboard) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 560;
        return GridView.count(
          crossAxisCount: isWide ? 4 : 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: isWide ? 1.45 : 1.28,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            _KpiCard(
              title: 'Faturamento',
              value: _formatCurrency(dashboard.revenue),
              detail: 'Período atual',
              icon: Icons.attach_money,
              accentColor: DashboardPage._primary,
              detailColor: DashboardPage._success,
            ),
            _KpiCard(
              title: 'Lucro liquido',
              value: _formatCurrency(dashboard.profit),
              detail: 'Margem ${_formatPercent(dashboard.margin)}',
              icon: Icons.trending_up,
              accentColor: DashboardPage._primary,
              detailColor: dashboard.profit >= 0
                  ? DashboardPage._success
                  : DashboardPage._primary,
            ),
            _KpiCard(
              title: 'Vendas',
              value: dashboard.salesLastSevenDays.toString(),
              detail: 'Últimos 7 dias',
              icon: Icons.shopping_cart_outlined,
              accentColor: DashboardPage._primary,
              detailColor: DashboardPage._textMuted,
            ),
            _KpiCard(
              title: 'Estoque baixo',
              value: dashboard.lowStockCount.toString(),
              detail: dashboard.lowStockCount == 1
                  ? 'Item crítico'
                  : 'Itens críticos',
              icon: Icons.warning_amber_rounded,
              accentColor: DashboardPage._primary,
              detailColor: dashboard.lowStockCount == 0
                  ? DashboardPage._success
                  : DashboardPage._primary,
            ),
          ],
        );
      },
    );
  }

  Future<void> _refreshDashboard() async {
    await Future.wait([
      context.read<VendasCubit>().loadInitial(),
      context.read<ReceitasCubit>().loadReceitas(showLoader: false),
      context.read<EstoquesCubit>().loadEstoques(resetFilters: true),
    ]);
  }

  static List<EstoqueComInsumo> _extractEstoques(EstoquesState state) {
    return switch (state) {
      EstoquesLoaded(:final estoques) => estoques,
      EstoqueActionLoading(:final estoques) => estoques,
      EstoqueActionSuccess(:final estoques) => estoques,
      EstoqueActionError(:final estoques) => estoques,
      _ => const [],
    };
  }

  static String _formatCurrency(double value) {
    final signal = value < 0 ? '- ' : '';
    final absolute = value.abs();
    final parts = absolute.toStringAsFixed(2).split('.');
    final whole = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
    return '${signal}R\$ $whole,${parts[1]}';
  }

  static String _formatPercent(double value) {
    return '${value.toStringAsFixed(1)}%';
  }
}

class _DashboardData {
  final double revenue;
  final double profit;
  final double margin;
  final int salesLastSevenDays;
  final int lowStockCount;
  final List<double> monthlyValues;
  final List<String> monthLabels;
  final String monthlyTrendLabel;
  final List<_ProductProfit> topProducts;

  const _DashboardData({
    required this.revenue,
    required this.profit,
    required this.margin,
    required this.salesLastSevenDays,
    required this.lowStockCount,
    required this.monthlyValues,
    required this.monthLabels,
    required this.monthlyTrendLabel,
    required this.topProducts,
  });

  factory _DashboardData.fromStates({
    required VendasState vendasState,
    required List<Receita> receitas,
    required List<EstoqueComInsumo> estoques,
  }) {
    final vendas = vendasState.vendas
        .where((venda) => venda.isFaturavel)
        .toList();
    final receitaById = {for (final receita in receitas) receita.id: receita};
    final receitaByName = {
      for (final receita in receitas)
        receita.nome.trim().toLowerCase(): receita,
    };

    final revenue = vendas.fold<double>(0, (sum, venda) => sum + venda.total);
    final profit = vendas.fold<double>(
      0,
      (sum, venda) =>
          sum + _calculateVendaProfit(venda, receitaById, receitaByName),
    );
    final margin = revenue == 0 ? 0.0 : (profit / revenue) * 100;
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final salesLastSevenDays = vendas
        .where((venda) => !venda.dataVenda.isBefore(sevenDaysAgo))
        .length;

    final lowStockCount = estoques
        .where((estoque) => estoque.isBaixoEstoque)
        .length;
    final monthlyValues = _buildMonthlyValues(vendas);
    final monthLabels = _buildMonthLabels();

    return _DashboardData(
      revenue: revenue,
      profit: profit,
      margin: margin,
      salesLastSevenDays: salesLastSevenDays,
      lowStockCount: lowStockCount,
      monthlyValues: monthlyValues,
      monthLabels: monthLabels,
      monthlyTrendLabel: _buildTrendLabel(monthlyValues),
      topProducts: _buildTopProducts(
        vendas,
        receitas,
        receitaById,
        receitaByName,
      ),
    );
  }

  static double _calculateVendaProfit(
    Venda venda,
    Map<int, Receita> receitaById,
    Map<String, Receita> receitaByName,
  ) {
    if (venda.itens.isNotEmpty) {
      return venda.itens.fold<double>(0, (sum, item) {
        final receita = receitaById[item.receitaId];
        final cost = (receita?.custoUnitario ?? 0.0) * item.quantidade;
        return sum + item.total - cost;
      });
    }

    final receita = receitaByName[venda.produto.trim().toLowerCase()];
    final unitCost = receita?.custoUnitario ?? 0.0;
    return venda.total - (unitCost * venda.quantidade);
  }

  static List<double> _buildMonthlyValues(List<Venda> vendas) {
    final now = DateTime.now();
    final months = List.generate(
      6,
      (index) => DateTime(now.year, now.month - 5 + index),
    );

    return months.map((month) {
      return vendas
          .where(
            (venda) =>
                venda.dataVenda.year == month.year &&
                venda.dataVenda.month == month.month,
          )
          .fold<double>(0, (sum, venda) => sum + venda.total);
    }).toList();
  }

  static List<String> _buildMonthLabels() {
    const labels = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez',
    ];
    final now = DateTime.now();

    return List.generate(6, (index) {
      final month = DateTime(now.year, now.month - 5 + index);
      return labels[month.month - 1];
    });
  }

  static String _buildTrendLabel(List<double> values) {
    if (values.length < 2) return '0.0%';

    final previous = values[values.length - 2];
    final current = values.last;
    if (previous == 0 && current == 0) return '0.0%';
    if (previous == 0) return '+100.0%';

    final trend = ((current - previous) / previous) * 100;
    final signal = trend >= 0 ? '+' : '';
    return '$signal${trend.toStringAsFixed(1)}%';
  }

  static List<_ProductProfit> _buildTopProducts(
    List<Venda> vendas,
    List<Receita> receitas,
    Map<int, Receita> receitaById,
    Map<String, Receita> receitaByName,
  ) {
    final products = <String, _ProductProfitAccumulator>{};

    for (final venda in vendas) {
      if (venda.itens.isEmpty) {
        final receita = receitaByName[venda.produto.trim().toLowerCase()];
        final profit =
            venda.total - ((receita?.custoUnitario ?? 0.0) * venda.quantidade);
        final revenue = venda.total;
        products.update(
          venda.produto,
          (current) => current.add(venda.quantidade, revenue, profit),
          ifAbsent: () => _ProductProfitAccumulator(
            name: venda.produto,
            quantity: venda.quantidade,
            revenue: revenue,
            profit: profit,
          ),
        );
        continue;
      }

      for (final item in venda.itens) {
        final receita = receitaById[item.receitaId];
        final name = item.produto.isNotEmpty
            ? item.produto
            : receita?.nome ?? 'Produto';
        final profit =
            item.total - ((receita?.custoUnitario ?? 0.0) * item.quantidade);
        products.update(
          name,
          (current) => current.add(item.quantidade, item.total, profit),
          ifAbsent: () => _ProductProfitAccumulator(
            name: name,
            quantity: item.quantidade,
            revenue: item.total,
            profit: profit,
          ),
        );
      }
    }

    if (products.isEmpty) {
      final fallbackProducts =
          receitas
              .map((receita) {
                final preco = receita.precoSugerido ?? 0.0;
                final custo = receita.custoUnitario ?? 0.0;
                final profit = preco - custo;
                return _ProductProfit(
                  name: receita.nome,
                  quantity: receita.rendimento,
                  profit: profit,
                  margin: preco == 0
                      ? (receita.margemLucro ?? 0.0) * 100
                      : (profit / preco) * 100,
                  hasSales: false,
                );
              })
              .where((product) => product.profit > 0)
              .toList()
            ..sort((a, b) => b.profit.compareTo(a.profit));
      return fallbackProducts.take(3).toList();
    }

    final soldProducts =
        products.values.map((item) => item.toProduct()).toList()
          ..sort((a, b) => b.profit.compareTo(a.profit));
    return soldProducts.take(3).toList();
  }
}

class _ProductProfitAccumulator {
  final String name;
  final double quantity;
  final double revenue;
  final double profit;

  const _ProductProfitAccumulator({
    required this.name,
    required this.quantity,
    required this.revenue,
    required this.profit,
  });

  _ProductProfitAccumulator add(
    double extraQuantity,
    double extraRevenue,
    double extraProfit,
  ) {
    return _ProductProfitAccumulator(
      name: name,
      quantity: quantity + extraQuantity,
      revenue: revenue + extraRevenue,
      profit: profit + extraProfit,
    );
  }

  _ProductProfit toProduct() {
    return _ProductProfit(
      name: name,
      quantity: quantity,
      profit: profit,
      margin: revenue == 0 ? 0 : (profit / revenue) * 100,
      hasSales: true,
    );
  }
}

class _ProductProfit {
  final String name;
  final double quantity;
  final double profit;
  final double margin;
  final bool hasSales;

  const _ProductProfit({
    required this.name,
    required this.quantity,
    required this.profit,
    required this.margin,
    required this.hasSales,
  });

  String get unitsLabel {
    if (!hasSales) return 'sem vendas no período';
    final displayQuantity = quantity % 1 == 0
        ? quantity.toInt().toString()
        : quantity.toStringAsFixed(1).replaceAll('.', ',');
    return quantity == 1 ? '1 unidade' : '$displayQuantity unidades';
  }
}

class _EmptyStateCard extends StatelessWidget {
  final String message;

  const _EmptyStateCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DashboardPage._surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DashboardPage._border),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: DashboardPage._textMuted, fontSize: 12.5),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String detail;
  final IconData icon;
  final Color accentColor;
  final Color detailColor;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.detail,
    required this.icon,
    required this.accentColor,
    required this.detailColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DashboardPage._surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DashboardPage._border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: DashboardPage._textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(icon, color: accentColor, size: 18),
            ],
          ),
          const Spacer(),
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            detail,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: detailColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: DashboardPage._textMuted,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final String trendLabel;

  const _ChartCard({
    required this.values,
    required this.labels,
    required this.trendLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 205,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: DashboardPage._surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DashboardPage._border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Receita dos últimos 6 meses',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                trendLabel,
                style: TextStyle(
                  color: trendLabel.startsWith('-')
                      ? DashboardPage._primary
                      : DashboardPage._success,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: CustomPaint(
              painter: _MonthlyEvolutionPainter(values: values),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 9),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: labels
                .map(
                  (label) => Text(
                    label,
                    style: const TextStyle(
                      color: DashboardPage._textMuted,
                      fontSize: 10.5,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _MonthlyEvolutionPainter extends CustomPainter {
  final List<double> values;

  const _MonthlyEvolutionPainter({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2 || size.width <= 0 || size.height <= 0) {
      return;
    }

    final gridPaint = Paint()
      ..color = const Color(0xFF242424)
      ..strokeWidth = 1;

    for (var i = 0; i < 4; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);
    final range = math.max(maxValue - minValue, 1);
    final stepX = size.width / (values.length - 1);

    Offset pointAt(int index) {
      final normalized = (values[index] - minValue) / range;
      return Offset(stepX * index, size.height - (normalized * size.height));
    }

    final fillPath = Path()..moveTo(0, size.height);
    final linePath = Path();

    for (var i = 0; i < values.length; i++) {
      final point = pointAt(i);
      if (i == 0) {
        linePath.moveTo(point.dx, point.dy);
        fillPath.lineTo(point.dx, point.dy);
      } else {
        final previous = pointAt(i - 1);
        final controlX = previous.dx + (point.dx - previous.dx) / 2;
        linePath.cubicTo(
          controlX,
          previous.dy,
          controlX,
          point.dy,
          point.dx,
          point.dy,
        );
        fillPath.cubicTo(
          controlX,
          previous.dy,
          controlX,
          point.dy,
          point.dx,
          point.dy,
        );
      }
    }

    fillPath
      ..lineTo(size.width, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x66FF6B3D), Color(0x00FF6B3D)],
      ).createShader(Offset.zero & size);

    final linePaint = Paint()
      ..color = DashboardPage._primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);

    final dotPaint = Paint()..color = DashboardPage._success;
    final borderPaint = Paint()..color = DashboardPage._surface;
    for (var i = 0; i < values.length; i++) {
      final point = pointAt(i);
      canvas.drawCircle(point, 5, borderPaint);
      canvas.drawCircle(point, 3.2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MonthlyEvolutionPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}

class _QuickActions extends StatelessWidget {
  final ValueChanged<int>? onNavigate;

  const _QuickActions({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 3.2,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        _ActionButton(
          label: 'Novo Insumo',
          icon: Icons.add_box_outlined,
          onTap: () => onNavigate?.call(1),
        ),
        _ActionButton(
          label: 'Nova Receita',
          icon: Icons.restaurant_menu_outlined,
          onTap: () => onNavigate?.call(2),
        ),
        _ActionButton(
          label: 'Produção',
          icon: Icons.precision_manufacturing_outlined,
          onTap: () => onNavigate?.call(6),
        ),
        _ActionButton(
          label: 'Gastos',
          icon: Icons.receipt_long_outlined,
          onTap: () => onNavigate?.call(7),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 17),
      label: FittedBox(fit: BoxFit.scaleDown, child: Text(label, maxLines: 1)),
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: DashboardPage._primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _ProfitableProductTile extends StatelessWidget {
  final String name;
  final String units;
  final String value;
  final String margin;

  const _ProfitableProductTile({
    required this.name,
    required this.units,
    required this.value,
    required this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: DashboardPage._surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DashboardPage._border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$units - margem $margin',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: DashboardPage._textMuted,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            maxLines: 1,
            style: const TextStyle(
              color: DashboardPage._success,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
