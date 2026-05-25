import 'package:flutter/material.dart';

class CalculoRealScreen extends StatefulWidget {
  const CalculoRealScreen({super.key});

  @override
  State<CalculoRealScreen> createState() => _CalculoRealScreenState();
}

class _CalculoRealScreenState extends State<CalculoRealScreen> {
  // Estado local para o cálculo
  double? _custoIngredientes;
  double? _energia;
  double? _agua;
  double? _gas;
  double? _horas;
  double? _valorHora;
  int _rendimento = 1;

  // Controladores
  late final TextEditingController _rendimentoCtrl;

  // Cores do protótipo
  final Color bgDark = const Color(0xFF0A0A0A);
  final Color cardDark = const Color(0xFF151515);
  final Color inputDark = const Color(0xFF1E1E1E);
  final Color primaryOrange = const Color(0xFFE85D33);
  final Color textSecondary = const Color(0xFF888888);

  @override
  void initState() {
    super.initState();
    _rendimentoCtrl = TextEditingController(text: _rendimento.toString());
  }

  @override
  void dispose() {
    _rendimentoCtrl.dispose();
    super.dispose();
  }

  // Função auxiliar para converter vírgula em ponto no input brasileiro
  double? _parseBR(String value) {
    return double.tryParse(value.replaceAll(',', '.'));
  }

  double get _custoTotal {
    final ci = _custoIngredientes ?? 0;
    final e = _energia ?? 0;
    final a = _agua ?? 0;
    final g = _gas ?? 0;
    final h = (_horas ?? 0) * (_valorHora ?? 0);
    return ci + e + a + g + h;
  }

  double get _custoPorUnidade {
    return _rendimento > 0 ? _custoTotal / _rendimento : 0;
  }

  double get _percentualInvisivel {
    final invisivel = (_energia ?? 0) + (_agua ?? 0) + (_gas ?? 0) + ((_horas ?? 0) * (_valorHora ?? 0));
    final total = _custoTotal;
    return total > 0 ? (invisivel / total) * 100 : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Cálculo Real", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            Text("Custo verdadeiro incluindo custos invisíveis", style: TextStyle(fontSize: 12, color: textSecondary)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. CARD PRINCIPAL: RESULTADO DO CÁLCULO
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Text("CUSTO POR UNIDADE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textSecondary, letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  Text("R\$ ${_custoPorUnidade.toStringAsFixed(2)}", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: primaryOrange)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text("R\$ ${_custoTotal.toStringAsFixed(2)}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text("Custo Total", style: TextStyle(fontSize: 10, color: textSecondary)),
                        ],
                      ),
                      Container(height: 30, width: 1, color: Colors.white10),
                      Column(
                        children: [
                          Text("${_percentualInvisivel.toStringAsFixed(1)}%", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFFB74D))),
                          Text("Custos Invisíveis", style: TextStyle(fontSize: 10, color: textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. CARD: CUSTO DOS INGREDIENTES
            _buildCard(
              title: "CUSTO DOS INGREDIENTES",
              icon: Icons.receipt_long,
              child: _buildInputSemIcone(_custoIngredientes?.toStringAsFixed(2), (v) {
                setState(() {
                  _custoIngredientes = _parseBR(v);
                });
              }),
            ),
            const SizedBox(height: 16),

            // 3. CARD: CUSTOS INVISÍVEIS
            _buildCard(
              title: "CUSTOS INVISÍVEIS",
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildInput("Energia", Icons.flash_on, _energia?.toStringAsFixed(2), (v) {
                        setState(() => _energia = _parseBR(v));
                      })),
                      const SizedBox(width: 12),
                      Expanded(child: _buildInput("Água", Icons.water_drop, _agua?.toStringAsFixed(2), (v) {
                        setState(() => _agua = _parseBR(v));
                      })),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildInput("Gás", Icons.local_fire_department, _gas?.toStringAsFixed(2), (v) {
                        setState(() => _gas = _parseBR(v));
                      })),
                      const SizedBox(width: 12),
                      Expanded(child: _buildInput("Horas", Icons.schedule, _horas?.toStringAsFixed(1), (v) {
                        setState(() => _horas = _parseBR(v));
                      })),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text("Valor/hora mão de obra (R\$)", style: TextStyle(color: textSecondary, fontSize: 11)),
                  const SizedBox(height: 6),
                  _buildInputSemIcone(_valorHora?.toStringAsFixed(2), (v) {
                    setState(() => _valorHora = _parseBR(v));
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 4. CARD: RENDIMENTO
            _buildCard(
              title: "RENDIMENTO (UNIDADES)",
              child: TextField(
                controller: _rendimentoCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                onChanged: (v) {
                  setState(() {
                    _rendimento = int.tryParse(v) ?? 1;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Ex: 12",
                  hintStyle: TextStyle(color: textSecondary),
                  filled: true,
                  fillColor: inputDark,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---
  Widget _buildCard({required String title, IconData? icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[Icon(icon, color: primaryOrange, size: 16), const SizedBox(width: 6)],
              Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textSecondary, letterSpacing: 1.0)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildInput(String label, IconData icon, String? initialValue, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: textSecondary, size: 14),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: textSecondary, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 6),
        _buildInputSemIcone(initialValue, onChanged),
      ],
    );
  }

  Widget _buildInputSemIcone(String? initialValue, Function(String) onChanged) {
    return TextFormField(
      initialValue: initialValue ?? "",
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: Colors.white),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: "0.00",
        hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.5)),
        filled: true,
        fillColor: inputDark,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
