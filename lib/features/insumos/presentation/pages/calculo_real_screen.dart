import 'package:flutter/material.dart';

class CalculoRealScreen extends StatefulWidget {
  const CalculoRealScreen({super.key});

  @override
  State<CalculoRealScreen> createState() => _CalculoRealScreenState();
}

class _CalculoRealScreenState extends State<CalculoRealScreen> {
  static final List<_CalculoRealRegistro> _registros = [];

  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _ingredientesCtrl = TextEditingController();
  final _energiaCtrl = TextEditingController();
  final _aguaCtrl = TextEditingController();
  final _gasCtrl = TextEditingController();
  final _horasCtrl = TextEditingController();
  final _valorHoraCtrl = TextEditingController();
  final _rendimentoCtrl = TextEditingController(text: '1');

  static const bgDark = Color(0xFF0A0A0A);
  static const cardDark = Color(0xFF151515);
  static const inputDark = Color(0xFF1E1E1E);
  static const primaryOrange = Color(0xFFE85D33);
  static const textSecondary = Color(0xFF888888);
  static const success = Color(0xFF00D287);

  @override
  void initState() {
    super.initState();
    for (final controller in [
      _nomeCtrl,
      _ingredientesCtrl,
      _energiaCtrl,
      _aguaCtrl,
      _gasCtrl,
      _horasCtrl,
      _valorHoraCtrl,
      _rendimentoCtrl,
    ]) {
      controller.addListener(_refresh);
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _nomeCtrl,
      _ingredientesCtrl,
      _energiaCtrl,
      _aguaCtrl,
      _gasCtrl,
      _horasCtrl,
      _valorHoraCtrl,
      _rendimentoCtrl,
    ]) {
      controller.removeListener(_refresh);
      controller.dispose();
    }
    super.dispose();
  }

  void _refresh() => setState(() {});

  double get _custoIngredientes => _parseBR(_ingredientesCtrl.text);
  double get _energia => _parseBR(_energiaCtrl.text);
  double get _agua => _parseBR(_aguaCtrl.text);
  double get _gas => _parseBR(_gasCtrl.text);
  double get _horas => _parseBR(_horasCtrl.text);
  double get _valorHora => _parseBR(_valorHoraCtrl.text);
  int get _rendimento => int.tryParse(_rendimentoCtrl.text.trim()) ?? 0;

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
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calculo Real',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Custo verdadeiro incluindo custos invisiveis',
              style: TextStyle(fontSize: 12, color: textSecondary),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildResultadoCard(),
            const SizedBox(height: 16),
            _buildCard(
              title: 'IDENTIFICACAO',
              child: _buildInput(
                controller: _nomeCtrl,
                label: 'Nome da simulacao',
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe um nome';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildCard(
              title: 'CUSTO DOS INGREDIENTES',
              icon: Icons.receipt_long,
              child: _buildInput(
                controller: _ingredientesCtrl,
                label: 'Custo dos ingredientes',
                validator: _validateNonNegative,
              ),
            ),
            const SizedBox(height: 16),
            _buildCard(
              title: 'CUSTOS INVISIVEIS',
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildInput(
                          controller: _energiaCtrl,
                          label: 'Energia',
                          icon: Icons.flash_on,
                          validator: _validateNonNegative,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInput(
                          controller: _aguaCtrl,
                          label: 'Agua',
                          icon: Icons.water_drop,
                          validator: _validateNonNegative,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInput(
                          controller: _gasCtrl,
                          label: 'Gas',
                          icon: Icons.local_fire_department,
                          validator: _validateNonNegative,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInput(
                          controller: _horasCtrl,
                          label: 'Horas',
                          icon: Icons.schedule,
                          validator: _validateNonNegative,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInput(
                    controller: _valorHoraCtrl,
                    label: 'Valor/hora mao de obra',
                    validator: _validateNonNegative,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildCard(
              title: 'RENDIMENTO',
              child: _buildInput(
                controller: _rendimentoCtrl,
                label: 'Unidades produzidas',
                keyboardType: TextInputType.number,
                validator: (value) {
                  final parsed = int.tryParse(value?.trim() ?? '');
                  if (parsed == null || parsed <= 0) {
                    return 'Informe um rendimento maior que zero';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _novoCalculo,
                    icon: const Icon(Icons.add),
                    label: const Text('Novo'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Color(0xFF2B2B2B)),
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _salvarCalculo,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Salvar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildHistorico(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultadoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'CUSTO POR UNIDADE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: textSecondary,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatCurrency(_custoPorUnidade),
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: primaryOrange,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Metric(
                label: 'Custo Total',
                value: _formatCurrency(_custoTotal),
                color: Colors.white,
              ),
              Container(height: 30, width: 1, color: Colors.white10),
              _Metric(
                label: 'Custos Invisiveis',
                value: '${_percentualInvisivel.toStringAsFixed(1)}%',
                color: const Color(0xFFFFB74D),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    IconData? icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: primaryOrange, size: 16),
                const SizedBox(width: 6),
              ],
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: textSecondary,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    TextInputType keyboardType = const TextInputType.numberWithOptions(
      decimal: true,
    ),
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon == null ? null : Icon(icon, size: 18),
        labelStyle: const TextStyle(color: textSecondary),
        filled: true,
        fillColor: inputDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildHistorico() {
    return _buildCard(
      title: 'SIMULACOES SALVAS',
      child: _registros.isEmpty
          ? const Text(
              'Nenhuma simulacao salva.',
              style: TextStyle(color: textSecondary, fontSize: 12),
            )
          : Column(
              children: _registros.reversed.map((registro) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: inputDark,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              registro.nome,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${registro.rendimento} un - total ${_formatCurrency(registro.custoTotal)}',
                              style: const TextStyle(
                                color: textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatCurrency(registro.custoPorUnidade),
                            style: const TextStyle(
                              color: success,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextButton(
                            onPressed: () => _carregarRegistro(registro),
                            style: TextButton.styleFrom(
                              foregroundColor: primaryOrange,
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text('Abrir'),
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

  void _salvarCalculo() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _registros.add(
        _CalculoRealRegistro(
          nome: _nomeCtrl.text.trim(),
          custoIngredientes: _custoIngredientes,
          energia: _energia,
          agua: _agua,
          gas: _gas,
          horas: _horas,
          valorHora: _valorHora,
          rendimento: _rendimento,
          custoTotal: _custoTotal,
          custoPorUnidade: _custoPorUnidade,
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: cardDark,
        content: Text(
          'Simulacao salva.',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _novoCalculo() {
    _nomeCtrl.clear();
    _ingredientesCtrl.clear();
    _energiaCtrl.clear();
    _aguaCtrl.clear();
    _gasCtrl.clear();
    _horasCtrl.clear();
    _valorHoraCtrl.clear();
    _rendimentoCtrl.text = '1';
  }

  void _carregarRegistro(_CalculoRealRegistro registro) {
    _nomeCtrl.text = registro.nome;
    _ingredientesCtrl.text = _formatNumber(registro.custoIngredientes);
    _energiaCtrl.text = _formatNumber(registro.energia);
    _aguaCtrl.text = _formatNumber(registro.agua);
    _gasCtrl.text = _formatNumber(registro.gas);
    _horasCtrl.text = _formatNumber(registro.horas);
    _valorHoraCtrl.text = _formatNumber(registro.valorHora);
    _rendimentoCtrl.text = registro.rendimento.toString();
  }

  String? _validateNonNegative(String? value) {
    final parsed = _parseBR(value ?? '');
    if (parsed < 0) return 'Informe um valor valido';
    return null;
  }

  static double _parseBR(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    if (normalized.isEmpty) return 0;
    return double.tryParse(normalized) ?? -1;
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
  final Color color;

  const _Metric({
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF888888)),
        ),
      ],
    );
  }
}

class _CalculoRealRegistro {
  final String nome;
  final double custoIngredientes;
  final double energia;
  final double agua;
  final double gas;
  final double horas;
  final double valorHora;
  final int rendimento;
  final double custoTotal;
  final double custoPorUnidade;

  const _CalculoRealRegistro({
    required this.nome,
    required this.custoIngredientes,
    required this.energia,
    required this.agua,
    required this.gas,
    required this.horas,
    required this.valorHora,
    required this.rendimento,
    required this.custoTotal,
    required this.custoPorUnidade,
  });
}
