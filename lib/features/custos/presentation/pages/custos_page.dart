import 'package:flutter/material.dart';

class CustosPage extends StatefulWidget {
  const CustosPage({super.key});

  @override
  State<CustosPage> createState() => _CustosPageState();
}

class _CustosPageState extends State<CustosPage> {
  final _ingredientesController = TextEditingController();
  final _energiaController = TextEditingController();
  final _aguaController = TextEditingController();
  final _gasController = TextEditingController();
  final _horasController = TextEditingController();
  final _valorHoraController = TextEditingController();
  final _rendimentoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    for (final controller in _controllers) {
      controller.addListener(_onValueChanged);
    }
  }

  List<TextEditingController> get _controllers => [
    _ingredientesController,
    _energiaController,
    _aguaController,
    _gasController,
    _horasController,
    _valorHoraController,
    _rendimentoController,
  ];

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.removeListener(_onValueChanged);
      controller.dispose();
    }
    super.dispose();
  }

  void _onValueChanged() {
    setState(() {});
  }

  double get _custoIngredientes => _parse(_ingredientesController.text);
  double get _energia => _parse(_energiaController.text);
  double get _agua => _parse(_aguaController.text);
  double get _gas => _parse(_gasController.text);
  double get _horas => _parse(_horasController.text);
  double get _valorHora => _parse(_valorHoraController.text);
  double get _rendimento => _parse(_rendimentoController.text);

  double get _maoDeObra => _horas * _valorHora;
  double get _custosInvisiveis => _energia + _agua + _gas + _maoDeObra;
  double get _custoTotal => _custoIngredientes + _custosInvisiveis;
  double get _custoPorUnidade =>
      _rendimento > 0 ? _custoTotal / _rendimento : 0;
  double get _percentualInvisivel =>
      _custoTotal > 0 ? (_custosInvisiveis / _custoTotal) * 100 : 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 28),
          children: [
            const Text(
              'Calculo Real',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Custo verdadeiro incluindo custos invisiveis',
              style: TextStyle(color: Color(0xFF777777), fontSize: 13),
            ),
            const SizedBox(height: 18),
            _ResultCard(
              custoPorUnidade: _custoPorUnidade,
              custoTotal: _custoTotal,
              percentualInvisivel: _percentualInvisivel,
            ),
            const SizedBox(height: 20),
            _SectionCard(
              title: 'CUSTO DOS INGREDIENTES',
              icon: Icons.receipt_long_outlined,
              children: [_CostInput(controller: _ingredientesController)],
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'CUSTOS INVISIVEIS',
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _LabeledCostInput(
                        label: 'Energia',
                        icon: Icons.bolt_outlined,
                        controller: _energiaController,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _LabeledCostInput(
                        label: 'Agua',
                        icon: Icons.water_drop_outlined,
                        controller: _aguaController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _LabeledCostInput(
                        label: 'Gas',
                        icon: Icons.local_fire_department_outlined,
                        controller: _gasController,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _LabeledCostInput(
                        label: 'Horas',
                        icon: Icons.access_time,
                        controller: _horasController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _LabeledCostInput(
                  label: 'Valor/hora mao de obra (R\$)',
                  controller: _valorHoraController,
                  compactLabel: true,
                ),
              ],
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'RENDIMENTO (UNIDADES)',
              children: [_CostInput(controller: _rendimentoController)],
            ),
          ],
        ),
      ),
    );
  }

  double _parse(String value) {
    return double.tryParse(value.trim().replaceAll(',', '.')) ?? 0;
  }
}

class _ResultCard extends StatelessWidget {
  final double custoPorUnidade;
  final double custoTotal;
  final double percentualInvisivel;

  const _ResultCard({
    required this.custoPorUnidade,
    required this.custoTotal,
    required this.percentualInvisivel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF232323)),
      ),
      child: Column(
        children: [
          const Text(
            'CUSTO POR UNIDADE',
            style: TextStyle(
              color: Color(0xFF858585),
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatCurrency(custoPorUnidade),
            style: const TextStyle(
              color: Color(0xFFFF6B3D),
              fontSize: 38,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _ResultMetric(
                  value: _formatCurrency(custoTotal),
                  label: 'Custo Total',
                  valueColor: Colors.white,
                ),
              ),
              Container(width: 1, height: 38, color: const Color(0xFF2A2A2A)),
              Expanded(
                child: _ResultMetric(
                  value: '${percentualInvisivel.toStringAsFixed(1)}%',
                  label: 'Custos Invisiveis',
                  valueColor: const Color(0xFFFFB000),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2)}';
  }
}

class _ResultMetric extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;

  const _ResultMetric({
    required this.value,
    required this.label,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF777777), fontSize: 9.5),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF232323)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 13, color: const Color(0xFFFF6B3D)),
                const SizedBox(width: 6),
              ],
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF777777),
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _LabeledCostInput extends StatelessWidget {
  final String label;
  final IconData? icon;
  final TextEditingController controller;
  final bool compactLabel;

  const _LabeledCostInput({
    required this.label,
    required this.controller,
    this.icon,
    this.compactLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: const Color(0xFF777777)),
              const SizedBox(width: 5),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF777777),
                  fontSize: compactLabel ? 10 : 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _CostInput(controller: controller),
      ],
    );
  }
}

class _CostInput extends StatelessWidget {
  final TextEditingController controller;

  const _CostInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFF1C1C1C),
          contentPadding: const EdgeInsets.symmetric(horizontal: 13),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF2B2B2B)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF2B2B2B)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFFF6B3D)),
          ),
        ),
      ),
    );
  }
}
