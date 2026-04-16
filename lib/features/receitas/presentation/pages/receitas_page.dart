import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/receita.dart';
import '../cubit/receitas_cubit.dart';
import '../cubit/receitas_state.dart';
import '../widgets/receita_card.dart';
import '../widgets/receitas_search_bar.dart';

class ReceitasPage extends StatefulWidget {
  const ReceitasPage({super.key});

  @override
  State<ReceitasPage> createState() => _ReceitasPageState();
}

class _ReceitasPageState extends State<ReceitasPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<ReceitasCubit>();
      if (cubit.state.status == ReceitasStatus.initial) {
        cubit.loadReceitas();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openFormDialog({Receita? receita}) async {
    final nomeController = TextEditingController(text: receita?.nome ?? '');
    final descricaoController = TextEditingController(
      text: receita?.descricao ?? '',
    );
    final rendimentoController = TextEditingController(
      text: receita?.rendimento.toString() ?? '',
    );
    final custoTotalController = TextEditingController(
      text: receita?.custoTotal.toString() ?? '',
    );
    final precoVendaController = TextEditingController(
      text: receita?.precoVenda.toString() ?? '',
    );

    ReceitaCategoria categoria = receita?.categoria ?? ReceitaCategoria.outros;
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                          receita == null ? 'Nova receita' : 'Editar receita',
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
                        _buildDropdown<ReceitaCategoria>(
                          label: 'Categoria',
                          value: categoria,
                          items: ReceitaCategoria.values,
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
                        _buildInput(
                          controller: rendimentoController,
                          label: 'Rendimento',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe o rendimento';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInput(
                                controller: custoTotalController,
                                label: 'Custo total',
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
                                controller: precoVendaController,
                                label: 'Preco venda',
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

                                  final cubit = context.read<ReceitasCubit>();
                                  final nome = nomeController.text.trim();
                                  final descricao = descricaoController.text
                                      .trim();
                                  final rendimento =
                                      _parseDouble(rendimentoController.text) ??
                                      0;
                                  final custoTotal =
                                      _parseDouble(custoTotalController.text) ??
                                      0;
                                  final precoVenda =
                                      _parseDouble(precoVendaController.text) ??
                                      0;

                                  if (receita == null) {
                                    await cubit.createReceita(
                                      nome: nome,
                                      descricao: descricao.isEmpty
                                          ? null
                                          : descricao,
                                      categoria: categoria,
                                      rendimento: rendimento,
                                      custoTotal: custoTotal,
                                      precoVenda: precoVenda,
                                    );
                                  } else {
                                    await cubit.updateReceita(
                                      id: receita.id,
                                      nome: nome,
                                      descricao: descricao.isEmpty
                                          ? null
                                          : descricao,
                                      categoria: categoria,
                                      rendimento: rendimento,
                                      custoTotal: custoTotal,
                                      precoVenda: precoVenda,
                                    );
                                  }

                                  if (dialogContext.mounted) {
                                    Navigator.of(dialogContext).pop();
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
                                  receita == null ? 'Salvar' : 'Atualizar',
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
    rendimentoController.dispose();
    custoTotalController.dispose();
    precoVendaController.dispose();
  }

  Future<void> _confirmDelete(Receita receita) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111111),
          title: const Text(
            'Excluir receita',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Deseja excluir "${receita.nome}"?',
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
      await context.read<ReceitasCubit>().deleteReceita(receita.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: BlocConsumer<ReceitasCubit, ReceitasState>(
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
              onRefresh: () => context.read<ReceitasCubit>().loadReceitas(
                search: state.search,
                showLoader: false,
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                children: [
                  const Text(
                    'Receitas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Gerencie suas receitas e margens',
                    style: TextStyle(color: Color(0xFF7C7C7C), fontSize: 12.5),
                  ),
                  const SizedBox(height: 18),
                  ReceitasSearchBar(
                    controller: _searchController,
                    onChanged: (value) {
                      context.read<ReceitasCubit>().onSearchChanged(value);
                    },
                    onAdd: () => _openFormDialog(),
                  ),
                  const SizedBox(height: 16),
                  if (state.status == ReceitasStatus.loading &&
                      state.receitas.isEmpty) ...[
                    const SizedBox(height: 80),
                    const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF6B3D),
                      ),
                    ),
                  ] else if (state.status == ReceitasStatus.error &&
                      state.receitas.isEmpty) ...[
                    const SizedBox(height: 80),
                    const Center(
                      child: Text(
                        'Nao foi possivel carregar as receitas.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ] else if (state.receitas.isEmpty) ...[
                    const SizedBox(height: 80),
                    const Center(
                      child: Text(
                        'Nenhuma receita encontrada.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ] else ...[
                    ...state.receitas.map(
                      (receita) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ReceitaCard(
                          receita: receita,
                          onTap: () => _openFormDialog(receita: receita),
                          onDelete: () => _confirmDelete(receita),
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
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
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
