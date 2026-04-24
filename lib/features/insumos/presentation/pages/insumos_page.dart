import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/insumo.dart';
import '../cubit/insumos_cubit.dart';
import '../cubit/insumos_state.dart';
import '../widgets/insumo_card.dart';
// import 'insumo_form_page.dart'; // Pode remover ou comentar, pois usaremos o Modal agora!

class InsumosPage extends StatefulWidget {
  const InsumosPage({super.key});

  @override
  State<InsumosPage> createState() => _InsumosPageState();
}

class _InsumosPageState extends State<InsumosPage> {
  final _searchCtrl = TextEditingController();
  bool? _filterAtivo;
  InsumoCategoria? _filterCategoria;

  // --- CORES DO PROTÓTIPO ---
  final Color bgDark = const Color(0xFF0A0A0A);
  final Color cardDark = const Color(0xFF151515);
  final Color primaryOrange = const Color(0xFFE85D33);
  final Color textSecondary = const Color(0xFF888888);

  @override
  void initState() {
    super.initState();
    context.read<InsumosCubit>().loadInsumos();
    
    // Atualiza a tela quando digitar na busca para mostrar/esconder o botão de "limpar (X)"
    _searchCtrl.addListener(() {
      setState(() {}); 
    });
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

  // --- ALTERADO PARA ABRIR O MODAL NO LUGAR DA NOVA PÁGINA ---
  void _openForm({Insumo? insumo}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<InsumosCubit>(),
        child: NovoInsumoModal(insumoParaEditar: insumo),
      ),
    );
  }

  Future<void> _confirmDelete(Insumo insumo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardDark,
        title: const Text('Excluir Insumo', style: TextStyle(color: Colors.white)),
        content: Text('Deseja excluir "${insumo.nome}"? Esta ação não pode ser desfeita.', style: TextStyle(color: textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
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
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        toolbarHeight: 80,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Insumos", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            Text("Gerencie seus materiais e custos", style: TextStyle(fontSize: 14, color: textSecondary)),
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
          // --- BARRA DE BUSCA COM DESIGN DO PROTÓTIPO ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Container(
              height: 45,
              decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(10)),
              child: TextField(
                controller: _searchCtrl,
                style: const TextStyle(color: Colors.white),
                onChanged: (value) => context.read<InsumosCubit>().searchInsumos(value),
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
                            context.read<InsumosCubit>().searchInsumos('');
                          },
                        )
                      : null,
                ),
              ),
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
                    ..showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green));
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
                  return Center(child: CircularProgressIndicator(color: primaryOrange));
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
                      color: primaryOrange,
                      backgroundColor: cardDark,
                      onRefresh: () => context.read<InsumosCubit>().loadInsumos(),
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 88, left: 16, right: 16),
                        itemCount: insumos.length,
                        itemBuilder: (_, index) {
                          final insumo = insumos[index];
                          // O seu InsumoCard foi mantido! Explicarei sobre ele abaixo.
                          return InsumoCard(
                            insumo: insumo,
                            onTap: () => _openForm(insumo: insumo),
                            onToggleAtivo: () => context.read<InsumosCubit>().toggleInsumoAtivo(insumo),
                            onDelete: () => _confirmDelete(insumo),
                          );
                        },
                      ),
                    ),
                    if (isActionLoading)
                      Positioned(
                        top: 0, left: 0, right: 0,
                        child: LinearProgressIndicator(color: primaryOrange, backgroundColor: cardDark),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      
      // --- BOTÃO FLUTUANTE (FAB) COM CORES DO PROTÓTIPO ---
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryOrange,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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

// ============================================================================
// WIDGETS AUXILIARES (Filtros, Empty View, Error View)
// Mantive a sua lógica, apenas ajustei um pouco das cores para não quebrar o Dark Mode
// ============================================================================

class _ActiveFiltersBar extends StatelessWidget {
  final bool? filterAtivo;
  final InsumoCategoria? filterCategoria;
  final VoidCallback onClear;

  const _ActiveFiltersBar({required this.filterAtivo, required this.filterCategoria, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(
        children: [
          const Icon(Icons.filter_alt, size: 16, color: Color(0xFFE85D33)),
          const SizedBox(width: 4),
          if (filterCategoria != null)
            Chip(label: Text(filterCategoria!.label, style: const TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF151515), visualDensity: VisualDensity.compact),
          if (filterCategoria != null && filterAtivo != null) const SizedBox(width: 4),
          if (filterAtivo != null)
            Chip(
              label: Text(filterAtivo! ? 'Ativos' : 'Inativos', style: const TextStyle(color: Colors.white)),
              backgroundColor: const Color(0xFF151515),
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
  final bool? filterAtivo;
  final InsumoCategoria? filterCategoria;
  final void Function(bool? ativo, InsumoCategoria? categoria) onApply;

  const _FilterSheet({required this.filterAtivo, required this.filterCategoria, required this.onApply});

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
              const Text('Filtros', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const Divider(color: Colors.white10),
          const SizedBox(height: 8),
          const Text('Status', style: TextStyle(color: Colors.white70)),
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
          const Text('Categoria', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 4,
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
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE85D33)),
            onPressed: () {
              Navigator.pop(context);
              widget.onApply(_ativo, _categoria);
            },
            child: const Text('Aplicar Filtros', style: TextStyle(color: Colors.white)),
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
          Icon(Icons.inventory_2_outlined, size: 80, color: const Color(0xFFE85D33).withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text('Nenhum insumo encontrado', style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 8),
          const Text('Adicione seu primeiro insumo', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE85D33)),
            onPressed: onAdd,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Novo Insumo', style: TextStyle(color: Colors.white)),
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
            Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            const Text('Erro ao carregar insumos', style: TextStyle(color: Colors.white, fontSize: 18), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message, style: const TextStyle(color: Colors.grey), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE85D33)),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Tentar Novamente', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// O NOSSO MODAL DE ADICIONAR (Agora integrado direto no final do arquivo)
// ============================================================================

class NovoInsumoModal extends StatefulWidget {
  final Insumo? insumoParaEditar; // Prepara para receber edição no futuro

  const NovoInsumoModal({super.key, this.insumoParaEditar});

  @override
  State<NovoInsumoModal> createState() => _NovoInsumoModalState();
}

class _NovoInsumoModalState extends State<NovoInsumoModal> {
  final _nomeController = TextEditingController();
  final _estoqueMinimoController = TextEditingController();
  final _precoUnitarioController = TextEditingController();
  String _unidadeSelecionada = InsumoUnidadeMedida.g.value;

  @override
  void initState() {
    super.initState();
    if (widget.insumoParaEditar != null) {
      _nomeController.text = widget.insumoParaEditar!.nome;
      _estoqueMinimoController.text = widget.insumoParaEditar!.estoqueMinimo.toString();
      _precoUnitarioController.text = widget.insumoParaEditar!.precoUnitario.toString();
      _unidadeSelecionada = widget.insumoParaEditar!.unidadeMedida.value;
    }
  }

  void _salvarInsumo() async {
    if (_nomeController.text.isEmpty || _estoqueMinimoController.text.isEmpty || _precoUnitarioController.text.isEmpty) return;

    // Chamamos a função saveInsumo do seu Cubit passando os parâmetros exatos que ele pede
    final sucesso = await context.read<InsumosCubit>().saveInsumo(
      id: widget.insumoParaEditar?.id, // Se for null, o Cubit sabe que é para criar. Se tiver ID, ele atualiza!
      nome: _nomeController.text,
      descricao: widget.insumoParaEditar?.descricao, 
      categoria: InsumoCategoria.materiaPrima, // (Fixo por enquanto, até criarmos o dropdown de categorias)
      unidadeMedida: InsumoUnidadeMedida.fromValue(_unidadeSelecionada),
      precoUnitario: double.parse(_precoUnitarioController.text.replaceAll(',', '.')),
      estoqueMinimo: double.parse(_estoqueMinimoController.text),
      ativo: widget.insumoParaEditar?.ativo ?? true,
    );

    // O seu Cubit retorna um 'bool' dizendo se deu certo. Só fechamos o modal se salvou com sucesso.
    if (sucesso && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color cardDark = Color(0xFF151515);
    const Color inputDark = Color(0xFF1E1E1E);
    const Color primaryOrange = Color(0xFFE85D33);
    const Color textSecondary = Color(0xFF888888);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.insumoParaEditar == null ? "Novo Insumo" : "Editar Insumo", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.close, color: textSecondary)),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(color: inputDark, borderRadius: BorderRadius.circular(10), border: Border.all(color: primaryOrange, width: 1)),
              child: TextField(
                controller: _nomeController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Nome do insumo",
                  hintStyle: TextStyle(color: textSecondary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(color: inputDark, borderRadius: BorderRadius.circular(10)),
                    child: TextField(
                      controller: _estoqueMinimoController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Estoque Mínimo",
                        hintStyle: TextStyle(color: textSecondary),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: inputDark, borderRadius: BorderRadius.circular(10)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _unidadeSelecionada,
                        dropdownColor: inputDark,
                        icon: const Icon(Icons.keyboard_arrow_down, color: textSecondary),
                        isExpanded: true,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        items: InsumoUnidadeMedida.values.map((unidade) {
                          return DropdownMenuItem<String>(value: unidade.value, child: Text(unidade.label));
                        }).toList(),
                        onChanged: (String? newValue) => setState(() => _unidadeSelecionada = newValue!),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(color: inputDark, borderRadius: BorderRadius.circular(10)),
              child: TextField(
                controller: _precoUnitarioController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Preço Unitário (R\$)",
                  hintStyle: TextStyle(color: textSecondary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primaryOrange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: _salvarInsumo,
                child: Text(widget.insumoParaEditar == null ? "Adicionar Insumo" : "Salvar Alterações", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}