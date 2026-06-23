import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../insumos/domain/entities/insumo.dart';
import '../../../insumos/presentation/cubit/insumos_cubit.dart';
import '../../../insumos/presentation/cubit/insumos_state.dart';
import '../../domain/entities/receita.dart';
import '../cubit/receitas_cubit.dart';
import '../cubit/receitas_state.dart';
import '../cubit/simulacao_cubit.dart';
import '../widgets/receita_card.dart';
import '../widgets/receitas_search_bar.dart';
import 'simulacao_page.dart';

class _InsumoEntry {
  final int insumoId;
  final TextEditingController quantidadeController;

  _InsumoEntry({required this.insumoId, required this.quantidadeController});

  void dispose() => quantidadeController.dispose();
}

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
    final cubit = context.read<ReceitasCubit>();
    final insumosCubit = context.read<InsumosCubit>();

    if (insumosCubit.state.status == InsumosStatus.initial) {
      insumosCubit.loadInsumos();
    }

    // ValueNotifier keeps the dialog reactive to insumos loading
    // without nesting BlocBuilder inside StatefulBuilder (which causes assertion errors)
    final insumosNotifier = ValueNotifier<InsumosState>(insumosCubit.state);
    final subscription = insumosCubit.stream.listen((state) {
      insumosNotifier.value = state;
    });

    final nomeController = TextEditingController(text: receita?.nome ?? '');
    final rendimentoController = TextEditingController(
      text: receita != null ? receita.rendimento.toString() : '',
    );
    final margemLucroController = TextEditingController(
      text: receita == null || receita.margemLucro <= 0
          ? ''
          : (receita.margemLucro * 100).toStringAsFixed(0),
    );

    InsumoUnidadeMedida unidadeRendimento =
        receita?.unidadeRendimento ?? InsumoUnidadeMedida.unidades;
    final formKey = GlobalKey<FormState>();

    final List<_InsumoEntry> insumosEntries = receita?.itens
            .map(
              (item) => _InsumoEntry(
                insumoId: item.insumoId,
                quantidadeController:
                    TextEditingController(text: item.quantidade.toString()),
              ),
            )
            .toList() ??
        [];

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return ValueListenableBuilder<InsumosState>(
              valueListenable: insumosNotifier,
              builder: (_, insumosState, __) {
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
                              receita == null
                                  ? 'Nova receita'
                                  : 'Editar receita',
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
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInput(
                                    controller: rendimentoController,
                                    label: 'Rendimento',
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    validator: (value) =>
                                        _validatePositiveNumber(
                                      value,
                                      'Obrigatorio',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child:
                                      _buildDropdown<InsumoUnidadeMedida>(
                                    label: 'Unidade',
                                    value: unidadeRendimento,
                                    items: InsumoUnidadeMedida.values,
                                    itemLabel: (item) => item.label,
                                    onChanged: (value) {
                                      if (value != null) {
                                        setModalState(() {
                                          unidadeRendimento = value;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildInput(
                              controller: margemLucroController,
                              label: 'Margem de lucro (%)',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return null;
                                }
                                return _validateNonNegativeNumber(
                                  value,
                                  'Valor invalido',
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Insumos',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (insumosEntries.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 6),
                                child: Text(
                                  'Nenhum insumo adicionado.',
                                  style: TextStyle(
                                    color: Color(0xFF5C5C5C),
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            else
                              ...insumosEntries.map(
                                (entry) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: _buildInsumoRow(
                                    entry: entry,
                                    insumos: insumosState.insumos,
                                    onRemove: () => setModalState(
                                      () => insumosEntries.remove(entry),
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 4),
                            _buildAddInsumoButton(
                              insumosState: insumosState,
                              insumosEntries: insumosEntries,
                              setModalState: setModalState,
                            ),
                            if (receita != null) ...[
                              const SizedBox(height: 16),
                              const Divider(color: Color(0xFF272727)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildReadOnlyInfo(
                                      label: 'Custo producao',
                                      value:
                                          'R\$ ${receita.custoProducao.toStringAsFixed(2)}',
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildReadOnlyInfo(
                                      label: 'Custo unitario',
                                      value:
                                          'R\$ ${receita.custoUnitario.toStringAsFixed(2)}',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildReadOnlyInfo(
                                label: 'Preco sugerido',
                                value:
                                    'R\$ ${receita.precoSugerido.toStringAsFixed(2)}',
                              ),
                            ],
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

                                      final navigator =
                                          Navigator.of(dialogContext);
                                      final nome = nomeController.text.trim();
                                      final rendimento =
                                          _parseDouble(
                                            rendimentoController.text,
                                          ) ??
                                          0;
                                      final margemRaw = _parseDouble(
                                        margemLucroController.text,
                                      );
                                      final margemLucro =
                                          (margemRaw ?? 0) / 100;
                                      final insumos = insumosEntries
                                          .map(
                                            (e) => ReceitaItemInput(
                                              insumoId: e.insumoId,
                                              quantidade:
                                                  _parseDouble(
                                                    e.quantidadeController.text,
                                                  ) ??
                                                  0,
                                            ),
                                          )
                                          .toList();

                                      if (receita == null) {
                                        await cubit.createReceita(
                                          nome: nome,
                                          rendimento: rendimento,
                                          unidadeRendimento: unidadeRendimento,
                                          margemLucro: margemLucro,
                                          insumos: insumos,
                                        );
                                      } else {
                                        await cubit.updateReceita(
                                          id: receita.id,
                                          nome: nome,
                                          rendimento: rendimento,
                                          unidadeRendimento: unidadeRendimento,
                                          margemLucro: margemLucro,
                                          insumos: insumos,
                                        );
                                      }

                                      if (dialogContext.mounted) {
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
      },
    );

    subscription.cancel();
    insumosNotifier.dispose();
    nomeController.dispose();
    rendimentoController.dispose();
    margemLucroController.dispose();
    for (final entry in insumosEntries) {
      entry.dispose();
    }
  }

  Widget _buildAddInsumoButton({
    required InsumosState insumosState,
    required List<_InsumoEntry> insumosEntries,
    required StateSetter setModalState,
  }) {
    if (insumosState.status == InsumosStatus.loading) {
      return const Center(
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFFFF6B3D),
          ),
        ),
      );
    }

    final available = insumosState.insumos
        .where((i) => !insumosEntries.any((e) => e.insumoId == i.id))
        .toList();

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: available.isEmpty
            ? null
            : () async {
                final entry =
                    await _showAddInsumoDialog(available: available);
                if (entry != null) {
                  setModalState(() => insumosEntries.add(entry));
                }
              },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF2B2B2B)),
          foregroundColor: const Color(0xFFFF6B3D),
          disabledForegroundColor: const Color(0xFF3C3C3C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.add, size: 18),
        label: Text(
          available.isEmpty && insumosState.insumos.isNotEmpty
              ? 'Todos os insumos adicionados'
              : 'Adicionar insumo',
        ),
      ),
    );
  }

  Widget _buildInsumoRow({
    required _InsumoEntry entry,
    required List<Insumo> insumos,
    required VoidCallback onRemove,
  }) {
    Insumo? insumo;
    for (final i in insumos) {
      if (i.id == entry.insumoId) {
        insumo = i;
        break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF272727)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insumo?.nome ?? 'Insumo #${entry.insumoId}',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
                if (insumo != null)
                  Text(
                    insumo.unidade.label,
                    style: const TextStyle(
                      color: Color(0xFF7C7C7C),
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: TextFormField(
              controller: entry.quantidadeController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              textAlign: TextAlign.center,
              validator: (v) => _validatePositiveNumber(v, 'Invalido'),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                filled: true,
                fillColor: const Color(0xFF111111),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF272727)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF272727)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFFF6B3D)),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.redAccent),
                ),
              ),
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            icon: const Icon(Icons.close, size: 18, color: Color(0xFF7C7C7C)),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }

  Future<_InsumoEntry?> _showAddInsumoDialog({
    required List<Insumo> available,
  }) async {
    Insumo selected = available.first;
    final formKey = GlobalKey<FormState>();
    // Use String local em vez de TextEditingController: evita o problema de
    // dispose prematuro — showDialog resolve quando Navigator.pop é chamado,
    // mas a animação de saída do diálogo ainda executa por ~300ms. Chamar
    // controller.dispose() nesse intervalo causa "controller used after disposed"
    // em TextFormField.didUpdateWidget ao tentar re-registrar o listener.
    String qtdText = '';

    return showDialog<_InsumoEntry>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSubState) {
            return Dialog(
              backgroundColor: const Color(0xFF111111),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Adicionar insumo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown<Insumo>(
                        label: 'Insumo',
                        value: selected,
                        items: available,
                        itemLabel: (i) => i.nome,
                        onChanged: (v) {
                          if (v != null) setSubState(() => selected = v);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: '',
                        onChanged: (v) => qtdText = v,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (v) =>
                            _validatePositiveNumber(v, 'Obrigatorio'),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Quantidade',
                          labelStyle:
                              const TextStyle(color: Color(0xFF8A8A8A)),
                          filled: true,
                          fillColor: const Color(0xFF171717),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Color(0xFF272727)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Color(0xFF272727)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Color(0xFFFF6B3D)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFF2B2B2B),
                                ),
                                foregroundColor: Colors.white70,
                                minimumSize: const Size.fromHeight(44),
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
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  Navigator.of(ctx).pop(
                                    _InsumoEntry(
                                      insumoId: selected.id,
                                      quantidadeController:
                                          TextEditingController(text: qtdText),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF6B3D),
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(44),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Adicionar'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openSimulacaoPage(Receita receita) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => sl<SimulacaoCubit>(),
          child: SimulacaoPage(receita: receita),
        ),
      ),
    );
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
                    'Gerencie insumos, rendimento, margem e custo automatico',
                    style:
                        TextStyle(color: Color(0xFF7C7C7C), fontSize: 12.5),
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
                          onSimular: () => _openSimulacaoPage(receita),
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

  Widget _buildReadOnlyInfo({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF272727)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(itemLabel(item)),
            ),
          )
          .toList(),
    );
  }

  String? _validatePositiveNumber(String? value, String message) {
    final parsed = _parseDouble(value ?? '');
    if (parsed == null || parsed <= 0) return message;
    return null;
  }

  String? _validateNonNegativeNumber(String? value, String message) {
    final parsed = _parseDouble(value ?? '');
    if (parsed == null || parsed < 0) return message;
    return null;
  }

  double? _parseDouble(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }
}
