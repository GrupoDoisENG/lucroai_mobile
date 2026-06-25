import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../receitas/domain/entities/receita.dart';
import '../../../receitas/presentation/cubit/receitas_cubit.dart';
import '../../../receitas/presentation/cubit/receitas_state.dart';
import '../../../vendas/domain/entities/venda.dart';
import '../../../vendas/presentation/cubit/vendas_cubit.dart';
import '../../../vendas/presentation/cubit/vendas_state.dart';

class SimulacaoPage extends StatefulWidget {
  final ValueChanged<int>? onNavigate;

  const SimulacaoPage({super.key, this.onNavigate});

  static const _background = Color(0xFF050505);
  static const _surface = Color(0xFF141414);
  static const _surfaceAlt = Color(0xFF202020);
  static const _border = Color(0xFF242424);
  static const _primary = Color(0xFFFF6B3D);
  static const _success = Color(0xFF00D287);
  static const _warning = Color(0xFFFFB000);
  static const _muted = Color(0xFF858585);

  @override
  State<SimulacaoPage> createState() => _SimulacaoPageState();
}

class _SimulacaoPageState extends State<SimulacaoPage> {
  int? _selectedReceitaId;
  double? _priceOverride;
  double _costVariation = 0;
  double? _volumeOverride;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final receitasCubit = context.read<ReceitasCubit>();
      if (receitasCubit.state.status == ReceitasStatus.initial) {
        receitasCubit.loadReceitas();
      }

      final vendasCubit = context.read<VendasCubit>();
      if (vendasCubit.state.status == VendasStatus.initial) {
        vendasCubit.loadInitial();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SimulacaoPage._background,
      body: BlocBuilder<ReceitasCubit, ReceitasState>(
        builder: (context, receitasState) {
          return BlocBuilder<VendasCubit, VendasState>(
            builder: (context, vendasState) {
              final receitas = receitasState.receitas;
              final selectedReceita = _resolveSelectedReceita(receitas);
              final isLoading =
                  receitasState.status == ReceitasStatus.loading ||
                  vendasState.status == VendasStatus.loading;

              return SafeArea(
                child: RefreshIndicator(
                  color: SimulacaoPage._primary,
                  backgroundColor: SimulacaoPage._surface,
                  onRefresh: _refresh,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                    children: [
                      _Header(isLoading: isLoading, onBack: _goBack),
                      const SizedBox(height: 20),
                      if (receitas.isEmpty)
                        _EmptySimulationState(
                          isLoading: isLoading,
                          errorMessage: receitasState.errorMessage,
                        )
                      else
                        _buildSimulationContent(
                          receitas: receitas,
                          receita: selectedReceita!,
                          vendas: vendasState.vendas,
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSimulationContent({
    required List<Receita> receitas,
    required Receita receita,
    required List<Venda> vendas,
  }) {
    final base = _ScenarioBase.fromReceita(receita, vendas);
    final priceRange = _priceRangeFor(receita);
    final volumeRange = _volumeRangeFor(base.actualVolume, receita.rendimento);

    final price = (_priceOverride ?? base.currentPrice).clamp(
      priceRange.start,
      priceRange.end,
    );
    final volume = (_volumeOverride ?? base.defaultVolume).clamp(
      volumeRange.start,
      volumeRange.end,
    );
    final projectedCost = base.unitCost * (1 + (_costVariation / 100));
    final projectedProfitPerUnit = price - projectedCost;
    final projectedProfit = projectedProfitPerUnit * volume;
    final projectedRevenue = price * volume;
    final currentProfit = base.actualProfit;
    final currentMargin = base.currentRevenue == 0
        ? 0.0
        : (currentProfit / base.currentRevenue) * 100;
    final projectedMargin = projectedRevenue == 0
        ? 0.0
        : (projectedProfit / projectedRevenue) * 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ResultCard(
          price: price,
          projectedProfitPerUnit: projectedProfitPerUnit,
          projectedProfit: projectedProfit,
          projectedMargin: projectedMargin,
        ),
        const SizedBox(height: 14),
        _ProductCard(
          receitas: receitas,
          selectedReceitaId: receita.id,
          onSelected: _selectReceita,
          unitCost: base.unitCost,
          currentPrice: base.currentPrice,
          currentVolume: base.actualVolume,
        ),
        const SizedBox(height: 14),
        _SliderCard(
          title: 'Preco de venda',
          valueLabel: _formatCurrency(price),
          helper: 'Atual: ${_formatCurrency(base.currentPrice)}',
          minLabel: _formatCurrency(priceRange.start),
          maxLabel: _formatCurrency(priceRange.end),
          value: price,
          min: priceRange.start,
          max: priceRange.end,
          divisions: 80,
          onChanged: (value) => setState(() => _priceOverride = value),
        ),
        const SizedBox(height: 14),
        _SliderCard(
          title: 'Variacao de custo',
          valueLabel: _formatSignedPercent(_costVariation),
          helper: 'Custo projetado: ${_formatCurrency(projectedCost)}',
          minLabel: '-50%',
          maxLabel: '+100%',
          value: _costVariation,
          min: -50,
          max: 100,
          divisions: 150,
          onChanged: (value) => setState(() => _costVariation = value),
        ),
        const SizedBox(height: 14),
        _SliderCard(
          title: 'Volume projetado',
          valueLabel: '${volume.round()} un.',
          helper: 'Volume atual: ${_formatQuantity(base.actualVolume)} un.',
          minLabel: '${volumeRange.start.round()}',
          maxLabel: '${volumeRange.end.round()}',
          value: volume,
          min: volumeRange.start,
          max: volumeRange.end,
          divisions: math.max(1, (volumeRange.end - volumeRange.start).round()),
          onChanged: (value) => setState(() => _volumeOverride = value),
        ),
        const SizedBox(height: 14),
        _ProjectionChartCard(
          currentProfit: currentProfit,
          projectedProfit: projectedProfit,
          currentMargin: currentMargin,
          projectedMargin: projectedMargin,
        ),
        const SizedBox(height: 14),
        _VolumePreviewCard(
          unitPrice: price,
          unitCost: projectedCost,
          baseVolume: volume,
        ),
      ],
    );
  }

  Receita? _resolveSelectedReceita(List<Receita> receitas) {
    if (receitas.isEmpty) return null;

    for (final receita in receitas) {
      if (receita.id == _selectedReceitaId) {
        return receita;
      }
    }

    return receitas.first;
  }

  void _selectReceita(Receita receita) {
    setState(() {
      _selectedReceitaId = receita.id;
      _priceOverride = null;
      _costVariation = 0;
      _volumeOverride = null;
    });
  }

  Future<void> _refresh() async {
    await Future.wait([
      context.read<ReceitasCubit>().loadReceitas(showLoader: false),
      context.read<VendasCubit>().loadInitial(),
    ]);
  }

  void _goBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }

    widget.onNavigate?.call(0);
  }

  _Range _priceRangeFor(Receita receita) {
    final custo = receita.custoUnitario ?? 0;
    final basePrice = (receita.precoSugerido ?? 0) > 0
        ? receita.precoSugerido!
        : custo * (1 + (receita.margemLucro ?? 0));
    final safeBase = math.max(basePrice, custo * 1.25);
    final min = math.max(0.01, math.min(custo * 0.75, safeBase));
    final max = math.max(safeBase * 2.2, custo * 3);
    return _Range(min, max);
  }

  _Range _volumeRangeFor(double actualVolume, double rendimento) {
    final base = math.max(1.0, actualVolume > 0 ? actualVolume : rendimento);
    return _Range(1, math.max(20, base * 3).ceilToDouble());
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

  static String _formatQuantity(double value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(1).replaceAll('.', ',');
  }

  static String _formatSignedPercent(double value) {
    final signal = value > 0 ? '+' : '';
    return '$signal${value.toStringAsFixed(0)}%';
  }
}

class _ScenarioBase {
  final double unitCost;
  final double currentPrice;
  final double currentRevenue;
  final double actualVolume;
  final double actualProfit;
  final double defaultVolume;

  const _ScenarioBase({
    required this.unitCost,
    required this.currentPrice,
    required this.currentRevenue,
    required this.actualVolume,
    required this.actualProfit,
    required this.defaultVolume,
  });

  factory _ScenarioBase.fromReceita(Receita receita, List<Venda> vendas) {
    var quantity = 0.0;
    var revenue = 0.0;

    for (final venda in vendas.where((venda) => venda.isFaturavel)) {
      if (venda.itens.isEmpty) {
        if (venda.produto.trim().toLowerCase() ==
            receita.nome.trim().toLowerCase()) {
          quantity += venda.quantidade;
          revenue += venda.total;
        }
        continue;
      }

      for (final item in venda.itens) {
        if (item.receitaId == receita.id) {
          quantity += item.quantidade;
          revenue += item.total;
        }
      }
    }

    final custo = receita.custoUnitario ?? 0;
    final suggestedPrice = (receita.precoSugerido ?? 0) > 0
        ? receita.precoSugerido!
        : custo * (1 + (receita.margemLucro ?? 0));
    final currentPrice = quantity > 0 ? revenue / quantity : suggestedPrice;
    final fallbackVolume = math.max(1.0, receita.rendimento);
    final currentRevenue = quantity > 0
        ? revenue
        : currentPrice * fallbackVolume;
    final actualVolume = quantity > 0 ? quantity : fallbackVolume;
    final actualProfit = currentRevenue - (custo * actualVolume);

    return _ScenarioBase(
      unitCost: custo,
      currentPrice: currentPrice,
      currentRevenue: currentRevenue,
      actualVolume: actualVolume,
      actualProfit: actualProfit,
      defaultVolume: actualVolume,
    );
  }
}

class _Range {
  final double start;
  final double end;

  const _Range(this.start, this.end);
}

class _Header extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onBack;

  const _Header({required this.isLoading, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 10, top: 2),
          child: IconButton(
            onPressed: onBack,
            tooltip: 'Voltar',
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: SimulacaoPage._surface,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Simulacao',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Projete preco, custo e volume antes de agir',
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
                color: SimulacaoPage._primary,
              ),
            ),
          ),
      ],
    );
  }
}

class _EmptySimulationState extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;

  const _EmptySimulationState({required this.isLoading, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: SimulacaoPage._surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SimulacaoPage._border),
      ),
      child: Text(
        isLoading
            ? 'Carregando receitas...'
            : errorMessage ?? 'Cadastre uma receita para simular cenarios.',
        textAlign: TextAlign.center,
        style: const TextStyle(color: SimulacaoPage._muted, fontSize: 13),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final double price;
  final double projectedProfitPerUnit;
  final double projectedProfit;
  final double projectedMargin;

  const _ResultCard({
    required this.price,
    required this.projectedProfitPerUnit,
    required this.projectedProfit,
    required this.projectedMargin,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = projectedProfit >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        color: SimulacaoPage._surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SimulacaoPage._border),
      ),
      child: Column(
        children: [
          const Text(
            'PRECO SIMULADO',
            style: TextStyle(
              color: SimulacaoPage._muted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _SimulacaoPageState._formatCurrency(price),
              style: const TextStyle(
                color: SimulacaoPage._primary,
                fontSize: 38,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lucro: ${_SimulacaoPageState._formatCurrency(projectedProfitPerUnit)} por unidade',
            style: TextStyle(
              color: isPositive
                  ? SimulacaoPage._success
                  : SimulacaoPage._primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _TinyMetric(
                  label: 'Lucro projetado',
                  value: _SimulacaoPageState._formatCurrency(projectedProfit),
                  color: isPositive
                      ? SimulacaoPage._success
                      : SimulacaoPage._primary,
                ),
              ),
              Container(width: 1, height: 36, color: const Color(0xFF2A2A2A)),
              Expanded(
                child: _TinyMetric(
                  label: 'Margem',
                  value: '${projectedMargin.toStringAsFixed(1)}%',
                  color: SimulacaoPage._warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TinyMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _TinyMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(color: SimulacaoPage._muted, fontSize: 10),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final List<Receita> receitas;
  final int selectedReceitaId;
  final ValueChanged<Receita> onSelected;
  final double unitCost;
  final double currentPrice;
  final double currentVolume;

  const _ProductCard({
    required this.receitas,
    required this.selectedReceitaId,
    required this.onSelected,
    required this.unitCost,
    required this.currentPrice,
    required this.currentVolume,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Produto',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: receitas.map((receita) {
              final selected = receita.id == selectedReceitaId;
              return ChoiceChip(
                selected: selected,
                onSelected: (_) => onSelected(receita),
                label: Text(receita.nome, overflow: TextOverflow.ellipsis),
                labelStyle: TextStyle(
                  color: selected ? Colors.white : Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
                selectedColor: SimulacaoPage._primary,
                backgroundColor: SimulacaoPage._surfaceAlt,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ReadOnlyInfo(
                  label: 'Custo unitario',
                  value: _SimulacaoPageState._formatCurrency(unitCost),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ReadOnlyInfo(
                  label: 'Preco atual',
                  value: _SimulacaoPageState._formatCurrency(currentPrice),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _ReadOnlyInfo(
            label: 'Volume atual no periodo',
            value:
                '${_SimulacaoPageState._formatQuantity(currentVolume)} unidades',
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyInfo extends StatelessWidget {
  final String label;
  final String value;

  const _ReadOnlyInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: SimulacaoPage._surfaceAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: SimulacaoPage._muted, fontSize: 10),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SliderCard extends StatelessWidget {
  final String title;
  final String valueLabel;
  final String helper;
  final String minLabel;
  final String maxLabel;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const _SliderCard({
    required this.title,
    required this.valueLabel,
    required this.helper,
    required this.minLabel,
    required this.maxLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: title,
      trailing: Text(
        valueLabel,
        style: const TextStyle(
          color: SimulacaoPage._primary,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            helper,
            style: const TextStyle(
              color: SimulacaoPage._success,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: SimulacaoPage._primary,
              inactiveTrackColor: Colors.white,
              thumbColor: SimulacaoPage._primary,
              overlayColor: SimulacaoPage._primary.withValues(alpha: 0.15),
              trackHeight: 8,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                minLabel,
                style: const TextStyle(
                  color: SimulacaoPage._muted,
                  fontSize: 10,
                ),
              ),
              Text(
                maxLabel,
                style: const TextStyle(
                  color: SimulacaoPage._muted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProjectionChartCard extends StatelessWidget {
  final double currentProfit;
  final double projectedProfit;
  final double currentMargin;
  final double projectedMargin;

  const _ProjectionChartCard({
    required this.currentProfit,
    required this.projectedProfit,
    required this.currentMargin,
    required this.projectedMargin,
  });

  @override
  Widget build(BuildContext context) {
    final difference = projectedProfit - currentProfit;
    final isPositive = difference >= 0;

    return _SectionCard(
      title: 'Lucro projetado vs atual',
      trailing: Text(
        '${isPositive ? '+' : ''}${_SimulacaoPageState._formatCurrency(difference)}',
        style: TextStyle(
          color: isPositive ? SimulacaoPage._success : SimulacaoPage._primary,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 120,
            child: CustomPaint(
              painter: _ProfitComparisonPainter(
                currentProfit: currentProfit,
                projectedProfit: projectedProfit,
              ),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _LegendMetric(
                  label: 'Atual',
                  value: _SimulacaoPageState._formatCurrency(currentProfit),
                  detail: '${currentMargin.toStringAsFixed(1)}% margem',
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _LegendMetric(
                  label: 'Projetado',
                  value: _SimulacaoPageState._formatCurrency(projectedProfit),
                  detail: '${projectedMargin.toStringAsFixed(1)}% margem',
                  color: SimulacaoPage._success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfitComparisonPainter extends CustomPainter {
  final double currentProfit;
  final double projectedProfit;

  const _ProfitComparisonPainter({
    required this.currentProfit,
    required this.projectedProfit,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = const Color(0xFF2A2A2A)
      ..strokeWidth = 1;
    final baseY = size.height - 18;
    canvas.drawLine(Offset(0, baseY), Offset(size.width, baseY), axisPaint);

    final values = [currentProfit.abs(), projectedProfit.abs(), 1.0];
    final maxValue = values.reduce(math.max);
    final barWidth = math.min(72.0, size.width * 0.22);
    final gap = size.width * 0.16;
    final startX = (size.width - (barWidth * 2 + gap)) / 2;
    final availableHeight = size.height - 28;

    void drawBar({
      required double value,
      required double x,
      required Color color,
    }) {
      final normalized = value.abs() / maxValue;
      final barHeight = math.max(4.0, normalized * availableHeight);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, baseY - barHeight, barWidth, barHeight),
        const Radius.circular(8),
      );
      canvas.drawRRect(rect, Paint()..color = color);
    }

    drawBar(value: currentProfit, x: startX, color: const Color(0xFFE8E8E8));
    drawBar(
      value: projectedProfit,
      x: startX + barWidth + gap,
      color: SimulacaoPage._primary,
    );
  }

  @override
  bool shouldRepaint(covariant _ProfitComparisonPainter oldDelegate) {
    return oldDelegate.currentProfit != currentProfit ||
        oldDelegate.projectedProfit != projectedProfit;
  }
}

class _LegendMetric extends StatelessWidget {
  final String label;
  final String value;
  final String detail;
  final Color color;

  const _LegendMetric({
    required this.label,
    required this.value,
    required this.detail,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SimulacaoPage._surfaceAlt,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: SimulacaoPage._muted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            detail,
            style: const TextStyle(color: SimulacaoPage._muted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _VolumePreviewCard extends StatelessWidget {
  final double unitPrice;
  final double unitCost;
  final double baseVolume;

  const _VolumePreviewCard({
    required this.unitPrice,
    required this.unitCost,
    required this.baseVolume,
  });

  @override
  Widget build(BuildContext context) {
    final volumes = {
      math.max(1, (baseVolume * 0.5).round()): 'Conservador',
      math.max(1, baseVolume.round()): 'Simulado',
      math.max(1, (baseVolume * 1.5).round()): 'Otimista',
    };

    return _SectionCard(
      title: 'Simulacao de volume',
      child: Column(
        children: volumes.entries.map((entry) {
          final volume = entry.key;
          final profit = (unitPrice - unitCost) * volume;
          final revenue = unitPrice * volume;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$volume unidades',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        entry.value,
                        style: const TextStyle(
                          color: SimulacaoPage._muted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _SimulacaoPageState._formatCurrency(revenue),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Lucro: ${_SimulacaoPageState._formatCurrency(profit)}',
                      style: TextStyle(
                        color: profit >= 0
                            ? SimulacaoPage._success
                            : SimulacaoPage._primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SimulacaoPage._surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SimulacaoPage._border),
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
                    color: SimulacaoPage._muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 13),
          child,
        ],
      ),
    );
  }
}
