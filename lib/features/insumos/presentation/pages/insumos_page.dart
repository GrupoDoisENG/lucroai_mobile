import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/insumo.dart';
import '../cubit/insumos_cubit.dart';
import '../cubit/insumos_state.dart';
import '../widgets/insumo_card.dart';
import '../widgets/insumos_search_bar.dart';

class InsumosPage extends StatefulWidget {
  const InsumosPage({super.key});

  @override
  State<InsumosPage> createState() => _InsumosPageState();
}

class _InsumosPageState extends State<InsumosPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<InsumosCubit>();
      if (cubit.state.status == InsumosStatus.initial) {
        cubit.loadInsumos();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openFormDialog({Insumo? insumo}) async {
    final nomeController = TextEditingController(text: insumo?.nome ?? '');
    final descricaoController = TextEditingController(
      text: insumo?.descricao ?? '',
    );
    final quantidadeController = TextEditingController(
      text: insumo?.quantidadeEmbalagem?.toString() ?? '',
    );
    final precoEmbalagemController = TextEditingController(
      text: insumo?.precoEmbalagem?.toString() ?? '',
    );
    final precoUnitarioController = TextEditingController(
      text: insumo?.precoUnitario.toString() ?? '',
    );
    final estoqueMinimoController = TextEditingController(
      text: insumo?.estoqueMinimo.toString() ?? '',
    );

    InsumoCategoria categoria = insumo?.categoria ?? InsumoCategoria.outros;
    InsumoUnidadeMedida unidade =
        insumo?.unidadeMedida ?? InsumoUnidadeMedida.gramas;

    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void atualizarCustoUnitario() {
              final quantidade = _parseDouble(quantidadeController.text);
              final precoEmbalagem = _parseDouble(
                precoEmbalagemController.text,
              );

              if (quantidade == null ||
                  quantidade <= 0 ||
                  precoEmbalagem == null) {
                return;
              }

              precoUnitarioController.text = (precoEmbalagem / quantidade)
                  .toStringAsFixed(4);
            }

            return Dialog(
              backgroundColor: const Color(0xFF111111),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          insumo == null ? 'Novo insumo' : 'Editar insumo',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInput(
                          controller: nomeController,
                          label: 'Nome',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe o nome';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildInput(
                          controller: descricaoController,
                          label: 'Descricao',
                        ),
                        const SizedBox(height: 12),
                        _buildDropdown<InsumoCategoria>(
                          label: 'Categoria',
                          value: categoria,
                          items: InsumoCategoria.values,
                          itemLabel: (item) => item.label,
                          onChanged: (value) {
                            if (value != null) {
                              setModalState(() {
                                categoria = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildDropdown<InsumoUnidadeMedida>(
                          label: 'Unidade',
                          value: unidade,
                          items: InsumoUnidadeMedida.values,
                          itemLabel: (item) => item.label,
                          onChanged: (value) {
                            if (value != null) {
                              setModalState(() {
                                unidade = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInput(
                                controller: quantidadeController,
                                label: 'Qtd. embalagem',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                onChanged: (_) => atualizarCustoUnitario(),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildInput(
                                controller: precoEmbalagemController,
                                label: 'Preco embalagem',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                onChanged: (_) => atualizarCustoUnitario(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInput(
                                controller: precoUnitarioController,
                                label: 'Preco unitario',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Obrigatorio';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildInput(
                                controller: estoqueMinimoController,
                                label: 'Estoque minimo',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Obrigatorio';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFF2B2B2B),
                                  ),
                                  foregroundColor: Colors.white70,
                                  minimumSize: const Size.fromHeight(46),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Cancelar'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (!formKey.currentState!.validate()) {
                                    return;
                                  }

                                  final navigator = Navigator.of(dialogContext);
                                  final cubit = context.read<InsumosCubit>();
                                  final nome = nomeController.text.trim();
                                  final descricao = descricaoController.text
                                      .trim();
                                  final quantidade = _parseDouble(
                                    quantidadeController.text,
                                  );
                                  final precoEmbalagem = _parseDouble(
                                    precoEmbalagemController.text,
                                  );
                                  final precoUnitario =
                                      _parseDouble(
                                        precoUnitarioController.text,
                                      ) ??
                                      0;
                                  final estoqueMinimo =
                                      _parseDouble(
                                        estoqueMinimoController.text,
                                      ) ??
                                      0;

                                  if (insumo == null) {
                                    await cubit.createInsumo(
                                      nome: nome,
                                      descricao: descricao.isEmpty
                                          ? null
                                          : descricao,
                                      categoria: categoria,
                                      unidadeMedida: unidade,
                                      precoUnitario: precoUnitario,
                                      estoqueMinimo: estoqueMinimo,
                                      quantidadeEmbalagem: quantidade,
                                      precoEmbalagem: precoEmbalagem,
                                    );
                                  } else {
                                    await cubit.updateInsumo(
                                      id: insumo.id,
                                      nome: nome,
                                      descricao: descricao.isEmpty
                                          ? null
                                          : descricao,
                                      categoria: categoria,
                                      unidadeMedida: unidade,
                                      precoUnitario: precoUnitario,
                                      estoqueMinimo: estoqueMinimo,
                                      quantidadeEmbalagem: quantidade,
                                      precoEmbalagem: precoEmbalagem,
                                    );
                                  }

                                  if (mounted) {
                                    navigator.pop();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF6B3D),
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size.fromHeight(46),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  insumo == null ? 'Salvar' : 'Atualizar',
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
          },
        );
      },
    );

    nomeController.dispose();
    descricaoController.dispose();
    quantidadeController.dispose();
    precoEmbalagemController.dispose();
    precoUnitarioController.dispose();
    estoqueMinimoController.dispose();
  }

  Future<void> _confirmDelete(Insumo insumo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111111),
          title: const Text(
            'Excluir insumo',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Deseja excluir "${insumo.nome}"?',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Excluir',
                style: TextStyle(color: Color(0xFFFF6B3D)),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      await context.read<InsumosCubit>().deleteInsumo(insumo.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: BlocConsumer<InsumosCubit, InsumosState>(
        listener: (context, state) {
          if (state.errorMessage != null &&
              state.errorMessage!.trim().isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color(0xFF1B1B1B),
                content: Text(
                  state.errorMessage!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: RefreshIndicator(
              color: const Color(0xFFFF6B3D),
              backgroundColor: const Color(0xFF111111),
              onRefresh: () => context.read<InsumosCubit>().loadInsumos(
                search: state.search,
                showLoader: false,
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                children: [
                  const Text(
                    'Insumos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Gerencie seus materiais e custos',
                    style: TextStyle(color: Color(0xFF7C7C7C), fontSize: 12.5),
                  ),
                  const SizedBox(height: 18),
                  InsumosSearchBar(
                    controller: _searchController,
                    onChanged: (value) {
                      context.read<InsumosCubit>().onSearchChanged(value);
                    },
                    onAdd: () => _openFormDialog(),
                  ),
                  const SizedBox(height: 16),
                  if (state.status == InsumosStatus.loading &&
                      state.insumos.isEmpty) ...[
                    const SizedBox(height: 80),
                    const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF6B3D),
                      ),
                    ),
                  ] else if (state.status == InsumosStatus.error &&
                      state.insumos.isEmpty) ...[
                    const SizedBox(height: 80),
                    const Center(
                      child: Text(
                        'Nao foi possivel carregar os insumos.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ] else if (state.insumos.isEmpty) ...[
                    const SizedBox(height: 80),
                    const Center(
                      child: Text(
                        'Nenhum insumo encontrado.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ] else ...[
                    ...state.insumos.map(
                      (insumo) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InsumoCard(
                          insumo: insumo,
                          onTap: () => _openFormDialog(insumo: insumo),
                          onDelete: () => _confirmDelete(insumo),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF8A8A8A)),
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

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T item) itemLabel,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      onChanged: onChanged,
      dropdownColor: const Color(0xFF171717),
      style: const TextStyle(color: Colors.white),
      iconEnabledColor: const Color(0xFFFF6B3D),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF8A8A8A)),
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
      items: items
          .map(
            (item) =>
                DropdownMenuItem<T>(value: item, child: Text(itemLabel(item))),
          )
          .toList(),
    );
  }

  double? _parseDouble(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    if (normalized.isEmpty) {
      return null;
    }
    return double.tryParse(normalized);
  }
}
