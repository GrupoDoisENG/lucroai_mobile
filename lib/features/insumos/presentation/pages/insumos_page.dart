import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/insumo.dart';
import '../cubit/insumos_cubit.dart';
import '../cubit/insumos_state.dart';
import '../widgets/insumo_card.dart';
import 'insumo_form_page.dart';

class InsumosPage extends StatefulWidget {
  const InsumosPage({super.key});

  @override
  State<InsumosPage> createState() => _InsumosPageState();
}

class _InsumosPageState extends State<InsumosPage> {
  final _searchCtrl = TextEditingController();
  bool? _filterAtivo;
  InsumoCategoria? _filterCategoria;

  @override
  void initState() {
    super.initState();
    context.read<InsumosCubit>().loadInsumos();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Insumo> _getInsumos(InsumosState state) {
    if (state is InsumosLoaded) return state.insumos;
    if (state is InsumoActionLoading) return state.insumos;
    if (state is InsumoActionSuccess) return state.insumos;
    if (state is InsumoActionError) return state.insumos;
    return [];
  }

  void _openForm({Insumo? insumo}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<InsumosCubit>(),
          child: InsumoFormPage(insumo: insumo),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Insumo insumo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir Insumo'),
        content: Text('Deseja excluir "${insumo.nome}"? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<InsumosCubit>().removeInsumo(insumo.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insumos'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtros',
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SearchBar(
              controller: _searchCtrl,
              hintText: 'Buscar insumos...',
              leading: const Icon(Icons.search),
              trailing: [
                if (_searchCtrl.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchCtrl.clear();
                      context.read<InsumosCubit>().searchInsumos('');
                    },
                  ),
              ],
              onChanged: (value) => context.read<InsumosCubit>().searchInsumos(value),
            ),
          ),
          if (_filterAtivo != null || _filterCategoria != null)
            _ActiveFiltersBar(
              filterAtivo: _filterAtivo,
              filterCategoria: _filterCategoria,
              onClear: () {
                setState(() {
                  _filterAtivo = null;
                  _filterCategoria = null;
                });
                context.read<InsumosCubit>().applyFilter();
              },
            ),
          Expanded(
            child: BlocConsumer<InsumosCubit, InsumosState>(
              listener: (context, state) {
                if (state is InsumoActionSuccess) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(content: Text(state.message)));
                }
                if (state is InsumoActionError) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(
                      content: Text(state.message),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ));
                }
              },
              builder: (context, state) {
                if (state is InsumosLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is InsumosError) {
                  return _ErrorView(
                    message: state.message,
                    onRetry: () => context.read<InsumosCubit>().loadInsumos(),
                  );
                }

                final insumos = _getInsumos(state);
                final isActionLoading = state is InsumoActionLoading;

                if (insumos.isEmpty && !isActionLoading) {
                  return _EmptyView(onAdd: () => _openForm());
                }

                return Stack(
                  children: [
                    RefreshIndicator(
                      onRefresh: () => context.read<InsumosCubit>().loadInsumos(),
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 88),
                        itemCount: insumos.length,
                        itemBuilder: (_, index) {
                          final insumo = insumos[index];
                          return InsumoCard(
                            insumo: insumo,
                            onTap: () => _openForm(insumo: insumo),
                            onToggleAtivo: () =>
                                context.read<InsumosCubit>().toggleInsumoAtivo(insumo),
                            onDelete: () => _confirmDelete(insumo),
                          );
                        },
                      ),
                    ),
                    if (isActionLoading)
                      const Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: LinearProgressIndicator(),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Novo Insumo'),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FilterSheet(
        filterAtivo: _filterAtivo,
        filterCategoria: _filterCategoria,
        onApply: (ativo, categoria) {
          setState(() {
            _filterAtivo = ativo;
            _filterCategoria = categoria;
          });
          context.read<InsumosCubit>().applyFilter(ativo: ativo, categoria: categoria);
        },
      ),
    );
  }
}

class _ActiveFiltersBar extends StatelessWidget {
  final bool? filterAtivo;
  final InsumoCategoria? filterCategoria;
  final VoidCallback onClear;

  const _ActiveFiltersBar({
    required this.filterAtivo,
    required this.filterCategoria,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(
        children: [
          const Icon(Icons.filter_alt, size: 16),
          const SizedBox(width: 4),
          if (filterCategoria != null)
            Chip(label: Text(filterCategoria!.label), visualDensity: VisualDensity.compact),
          if (filterCategoria != null && filterAtivo != null) const SizedBox(width: 4),
          if (filterAtivo != null)
            Chip(
              label: Text(filterAtivo! ? 'Ativos' : 'Inativos'),
              visualDensity: VisualDensity.compact,
            ),
          const Spacer(),
          TextButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.clear, size: 16),
            label: const Text('Limpar'),
            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
          ),
        ],
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final bool? filterAtivo;
  final InsumoCategoria? filterCategoria;
  final void Function(bool? ativo, InsumoCategoria? categoria) onApply;

  const _FilterSheet({
    required this.filterAtivo,
    required this.filterCategoria,
    required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  bool? _ativo;
  InsumoCategoria? _categoria;

  @override
  void initState() {
    super.initState();
    _ativo = widget.filterAtivo;
    _categoria = widget.filterCategoria;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('Filtros', style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 8),
          Text('Status', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          SegmentedButton<bool?>(
            segments: const [
              ButtonSegment(value: null, label: Text('Todos')),
              ButtonSegment(value: true, label: Text('Ativos')),
              ButtonSegment(value: false, label: Text('Inativos')),
            ],
            selected: {_ativo},
            onSelectionChanged: (v) => setState(() => _ativo = v.first),
          ),
          const SizedBox(height: 16),
          Text('Categoria', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              FilterChip(
                label: const Text('Todas'),
                selected: _categoria == null,
                onSelected: (_) => setState(() => _categoria = null),
              ),
              ...InsumoCategoria.values.map(
                (c) => FilterChip(
                  label: Text(c.label),
                  selected: _categoria == c,
                  onSelected: (_) => setState(() => _categoria = c),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onApply(_ativo, _categoria);
            },
            child: const Text('Aplicar Filtros'),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyView({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(100),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum insumo encontrado',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione seu primeiro insumo',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Novo Insumo'),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar insumos',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
