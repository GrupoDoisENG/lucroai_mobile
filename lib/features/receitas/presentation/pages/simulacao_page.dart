import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/receita.dart';
import '../../domain/entities/simulacao_result.dart';
import '../cubit/simulacao_cubit.dart';
import '../cubit/simulacao_state.dart';

class SimulacaoPage extends StatefulWidget {
  final Receita receita;

  const SimulacaoPage({super.key, required this.receita});

  @override
  State<SimulacaoPage> createState() => _SimulacaoPageState();
}

class _SimulacaoPageState extends State<SimulacaoPage> {
  late final TextEditingController _custoController;
  late final TextEditingController _precoController;
  late final TextEditingController _volumeController;

  @override
  void initState() {
    super.initState();
    _custoController = TextEditingController(
      text: widget.receita.custoUnitario > 0
          ? widget.receita.custoUnitario.toStringAsFixed(2)
          : '',
    );
    _precoController = TextEditingController(
      text: widget.receita.precoSugerido > 0
          ? widget.receita.precoSugerido.toStringAsFixed(2)
          : '',
    );
    _volumeController = TextEditingController(
      text: widget.receita.rendimento > 0
          ? widget.receita.rendimento.toStringAsFixed(0)
          : '',
    );
  }

  @override
  void dispose() {
    _custoController.dispose();
    _precoController.dispose();
    _volumeController.dispose();
    super.dispose();
  }

  double? _parseDouble(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }

  int? _parseInt(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return null;
    return int.tryParse(normalized) ??
        double.tryParse(normalized)?.toInt();
  }

  void _simular() {
    context.read<SimulacaoCubit>().simular(
      receitaId: widget.receita.id,
      novoCusto: _parseDouble(_custoController.text),
      novoPreco: _parseDouble(_precoController.text),
      volume: _parseInt(_volumeController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050505),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 18,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.receita.nome,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
          children: [
            const Text(
              'Simulacao de cenario',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Ajuste os valores e veja o impacto no lucro',
              style: TextStyle(color: Color(0xFF7C7C7C), fontSize: 12.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'Parametros',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _custoController,
              label: 'Custo por unidade (R\$)',
              hint: 'Ex: 2,50',
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _precoController,
              label: 'Preco de venda (R\$)',
              hint: 'Ex: 5,00',
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _volumeController,
              label: 'Quantidade (unidades)',
              hint: 'Ex: 12',
              isInt: true,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _simular,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B3D),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Simular',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            BlocBuilder<SimulacaoCubit, SimulacaoState>(
              builder: (context, state) {
                if (state.status == SimulacaoStatus.loading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF6B3D),
                      ),
                    ),
                  );
                }
                if (state.status == SimulacaoStatus.error) {
                  return _buildErrorPanel(
                    state.errorMessage ?? 'Erro ao simular.',
                  );
                }
                if (state.status == SimulacaoStatus.success &&
                    state.result != null) {
                  return _buildResultPanel(state.result!);
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isInt = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isInt
          ? TextInputType.number
          : const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Color(0xFF8A8A8A)),
        hintStyle: const TextStyle(color: Color(0xFF4C4C4C)),
        filled: true,
        fillColor: const Color(0xFF171717),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF272727)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF272727)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF6B3D)),
        ),
      ),
    );
  }

  Widget _buildResultPanel(SimulacaoResult result) {
    final isPositive = result.lucroEstimado >= 0;
    final lucroColor =
        isPositive ? const Color(0xFF4CAF50) : const Color(0xFFFF5252);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1A1A1A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resultado',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isPositive
                  ? const Color(0xFF0D2E10)
                  : const Color(0xFF2E0D0D),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isPositive
                    ? const Color(0xFF1B5E20)
                    : const Color(0xFF5E1B1B),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Lucro estimado',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Text(
                  _formatCurrency(result.lucroEstimado),
                  style: TextStyle(
                    color: lucroColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildResultTile(
                  label: 'Margem projetada',
                  value:
                      '${(result.margemProjetada * 100).toStringAsFixed(1)}%',
                  valueColor: result.margemProjetada >= 0
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFFF5252),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildResultTile(
                  label: 'Custo/unidade',
                  value: _formatCurrency(result.custoUnitario),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildResultTile(
                  label: 'Preco de venda',
                  value: _formatCurrency(result.precoVenda),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildResultTile(
                  label: 'Volume simulado',
                  value: '${result.volume} un.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF171717),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 14,
                  color: Color(0xFF7C7C7C),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Venda pelo menos ${result.breakEven} unidades para nao ter prejuizo.',
                    style: const TextStyle(
                      color: Color(0xFF9E9E9E),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultTile({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF7C7C7C), fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorPanel(String message) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2E0D0D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF5E1B1B)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFFF5252), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFFFF8A80), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatCurrency(double value) {
    final isNegative = value < 0;
    final abs = value.abs();
    final fixed = abs.toStringAsFixed(2);
    final parts = fixed.split('.');
    final decimal = parts.length > 1 ? ',${parts[1]}' : '';
    return '${isNegative ? '-' : ''}R\$ ${parts[0]}$decimal';
  }
}
