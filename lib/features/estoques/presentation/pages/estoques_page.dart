import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/estoque_com_insumo.dart';
import '../cubit/estoques_cubit.dart';
import '../cubit/estoques_state.dart';
import '../widgets/estoque_card.dart';
import '../widgets/registrar_entrada_modal.dart';

class EstoquesPage extends StatefulWidget {
  const EstoquesPage({super.key});

  @override
  State<EstoquesPage> createState() => _EstoquesPageState();
}

class _EstoquesPageState extends State<EstoquesPage> {
  final _searchCtrl = TextEditingController();
  bool? _filterBaixoEstoque;

  final Color bgDark = const Color(0xFF0A0A0A);
  final Color cardDark = const Color(0xFF151515);
  final Color primaryOrange = const Color(0xFFE85D33);
  final Color textSecondary = const Color(0xFF888888);

  @override
  void initState() {
    super.initState();
    context.read<EstoquesCubit>().loadEstoques();
    _searchCtrl.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<EstoqueComInsumo> _getEstoques(EstoquesState state) {
    if (state is EstoquesLoaded) return state.estoques;
    if (state is EstoqueActionLoading) return [];
    if (state is EstoqueActionSuccess) return state.estoques;
    if (state is EstoqueActionError) return state.estoques;
    return [];
  }

  void _openRegistrarEntradaModal(EstoqueComInsumo estoque) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<EstoquesCubit>(),
        child: RegistrarEntradaModal(estoque: estoque),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        toolbarHeight: 80,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Estoque",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Acompanhe disponibilidade e alertas",
              style: TextStyle(
                fontSize: 14,
                color: textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: primaryOrange),
            tooltip: 'Filtros',
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de busca
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: cardDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _searchCtrl,
                style: const TextStyle(color: Colors.white),
                onChanged: (value) =>
                    context.read<EstoquesCubit>().searchEstoques(value),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: textSecondary, size: 20),
                  hintText: "Buscar insumos...",
                  hintStyle: TextStyle(color: textSecondary, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          color: textSecondary,
                          onPressed: () {
                            _searchCtrl.clear();
                            context.read<EstoquesCubit>().searchEstoques('');
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),

          // Filtros ativos
          if (_filterBaixoEstoque != null)
            _ActiveFiltersBar(
              filterBaixoEstoque: _filterBaixoEstoque,
              onClear: () {
                setState(() {
                  _filterBaixoEstoque = null;
                });
                context.read<EstoquesCubit>().applyFilter();
              },
            ),

          // Lista de estoques
          Expanded(
            child: BlocConsumer<EstoquesCubit, EstoquesState>(
              listener: (context, state) {
                if (state is EstoqueActionSuccess) {
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
                if (state is EstoquesLoading) {
                  return Center(
                    child: CircularProgressIndicator(color: primaryOrange),
                  );
                }

                if (state is EstoquesError) {
                  return _ErrorView(
                    message: state.message,
                    onRetry: () =>
                        context.read<EstoquesCubit>().loadEstoques(),
                  );
                }

                final estoques = _getEstoques(state);
                final isActionLoading = state is EstoqueActionLoading;

                if (estoques.isEmpty && !isActionLoading) {
                  return _EmptyView();
                }

                return Stack(
                  children: [
                    RefreshIndicator(
                      color: primaryOrange,
                      backgroundColor: cardDark,
                      onRefresh: () =>
                          context.read<EstoquesCubit>().loadEstoques(),
                      child: ListView.builder(
                        padding:
                            const EdgeInsets.only(top: 8, bottom: 88, left: 0, right: 0),
                        itemCount: estoques.length,
                        itemBuilder: (_, index) {
                          final estoque = estoques[index];
                          return EstoqueCard(
                            estoque: estoque,
                            onTapRegistrarEntrada: () =>
                                _openRegistrarEntradaModal(estoque),
                          );
                        },
                      ),
                    ),
                    if (isActionLoading)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: LinearProgressIndicator(
                          color: primaryOrange,
                          backgroundColor: cardDark,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FilterSheet(
        filterBaixoEstoque: _filterBaixoEstoque,
        onApply: (filterBaixoEstoque) {
          setState(() {
            _filterBaixoEstoque = filterBaixoEstoque;
          });
          context.read<EstoquesCubit>().applyFilter(
            filterBaixoEstoque: filterBaixoEstoque,
          );
        },
      ),
    );
  }
}

// ============================================================================
// WIDGETS AUXILIARES
// ============================================================================

class _ActiveFiltersBar extends StatelessWidget {
  final bool? filterBaixoEstoque;
  final VoidCallback onClear;

  const _ActiveFiltersBar({
    required this.filterBaixoEstoque,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(
        children: [
          const Icon(Icons.filter_alt, size: 16, color: Color(0xFFE85D33)),
          const SizedBox(width: 4),
          if (filterBaixoEstoque == true)
            const Chip(
              label: Text(
                'Baixo Estoque',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Color(0xFF151515),
              visualDensity: VisualDensity.compact,
            ),
          const Spacer(),
          TextButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.clear, size: 16, color: Colors.grey),
            label: const Text('Limpar', style: TextStyle(color: Colors.grey)),
            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
          ),
        ],
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final bool? filterBaixoEstoque;
  final Function(bool?) onApply;

  const _FilterSheet({
    required this.filterBaixoEstoque,
    required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late bool? _tempFilter;

  @override
  void initState() {
    super.initState();
    _tempFilter = widget.filterBaixoEstoque;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filtros',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Status do Estoque',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  title: const Text(
                    'Apenas Estoque Baixo',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: _tempFilter == true,
                  onChanged: (value) {
                    setState(() {
                      _tempFilter = value == true ? true : null;
                    });
                  },
                  activeColor: const Color(0xFFE85D33),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  widget.onApply(_tempFilter);
                  Navigator.pop(context);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFE85D33),
                ),
                child: const Text('Aplicar Filtros'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Nenhum estoque encontrado',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comece adicionando insumos',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.withAlpha(200),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
          const SizedBox(height: 16),
          const Text(
            'Erro ao carregar estoques',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.withAlpha(200),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE85D33),
            ),
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }
}
