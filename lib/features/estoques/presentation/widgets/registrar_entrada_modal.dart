import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/estoque_com_insumo.dart';
import '../cubit/estoques_cubit.dart';
import '../cubit/estoques_state.dart';

class RegistrarEntradaModal extends StatefulWidget {
  final EstoqueComInsumo estoque;

  const RegistrarEntradaModal({
    super.key,
    required this.estoque,
  });

  @override
  State<RegistrarEntradaModal> createState() => _RegistrarEntradaModalState();
}

class _RegistrarEntradaModalState extends State<RegistrarEntradaModal> {
  late TextEditingController _quantidadeCtrl;
  final Color primaryOrange = const Color(0xFFE85D33);
  final Color bgDark = const Color(0xFF0A0A0A);
  final Color cardDark = const Color(0xFF151515);
  final Color textSecondary = const Color(0xFF888888);

  @override
  void initState() {
    super.initState();
    _quantidadeCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _quantidadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Cabeçalho
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Registrar Entrada',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Informações do insumo
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bgDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withAlpha(50)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Insumo',
                        style: TextStyle(
                          fontSize: 12,
                          color: textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.estoque.insumoNome,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quantidade Atual',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: textSecondary,
                                ),
                              ),
                              Text(
                                '${widget.estoque.quantidadeDisponivel.toStringAsFixed(2)} ${widget.estoque.insumoUnidade}',
                                style: const TextStyle(
                                  fontSize: 13,
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
                                  fontSize: 11,
                                  color: textSecondary,
                                ),
                              ),
                              Text(
                                '${widget.estoque.quantidadeMinima.toStringAsFixed(2)} ${widget.estoque.insumoUnidade}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Campo de quantidade
                Text(
                  'Quantidade a Adicionar',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _quantidadeCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Ex: 10.5',
                    hintStyle: TextStyle(color: textSecondary),
                    filled: true,
                    fillColor: bgDark,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.withAlpha(50)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.withAlpha(50)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE85D33), width: 2),
                    ),
                    suffixText: widget.estoque.insumoUnidade,
                    suffixStyle: TextStyle(color: textSecondary),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Botão de confirmar
                BlocConsumer<EstoquesCubit, EstoquesState>(
                  listener: (context, state) {
                    if (state is EstoqueActionSuccess) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.green,
                          ),
                        );
                    }
                    if (state is EstoqueActionError) {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: Theme.of(context).colorScheme.error,
                          ),
                        );
                    }
                  },
                  builder: (context, state) {
                    final isLoading = state is EstoqueActionLoading;
                    return SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: isLoading ? null : _registrarEntrada,
                        style: FilledButton.styleFrom(
                          backgroundColor: primaryOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          disabledBackgroundColor: Colors.grey.withAlpha(100),
                        ),
                        child: isLoading
                            ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white.withAlpha(200),
                                ),
                              ),
                            )
                            : const Text(
                              'Confirmar Entrada',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _registrarEntrada() {
    final quantidade = double.tryParse(_quantidadeCtrl.text);
    
    if (quantidade == null || quantidade <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite uma quantidade válida'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    context.read<EstoquesCubit>().registrarEntradaManual(
      insumoId: widget.estoque.insumoId,
      quantidade: quantidade,
    );
  }
}
