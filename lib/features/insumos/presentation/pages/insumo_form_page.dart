import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/insumo.dart';
import '../cubit/insumos_cubit.dart';
import '../cubit/insumos_state.dart';

class InsumoFormPage extends StatefulWidget {
  final Insumo? insumo;

  const InsumoFormPage({super.key, this.insumo});

  @override
  State<InsumoFormPage> createState() => _InsumoFormPageState();
}

class _InsumoFormPageState extends State<InsumoFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeCtrl;
  late final TextEditingController _descricaoCtrl;
  late final TextEditingController _precoCtrl;
  late final TextEditingController _estoqueCtrl;

  InsumoCategoria _categoria = InsumoCategoria.materiaPrima;
  InsumoUnidadeMedida _unidade = InsumoUnidadeMedida.kg;
  bool _ativo = true;

  bool get _isEditing => widget.insumo != null;

  @override
  void initState() {
    super.initState();
    final i = widget.insumo;
    _nomeCtrl = TextEditingController(text: i?.nome);
    _descricaoCtrl = TextEditingController(text: i?.descricao);
    _precoCtrl = TextEditingController(
      text: i != null ? i.precoUnitario.toStringAsFixed(4) : '',
    );
    _estoqueCtrl = TextEditingController(
      text: i != null ? i.estoqueMinimo.toStringAsFixed(4) : '',
    );
    if (i != null) {
      _categoria = i.categoria;
      _unidade = i.unidadeMedida;
      _ativo = i.ativo;
    }
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _descricaoCtrl.dispose();
    _precoCtrl.dispose();
    _estoqueCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await context.read<InsumosCubit>().saveInsumo(
      id: widget.insumo?.id,
      nome: _nomeCtrl.text.trim(),
      descricao: _descricaoCtrl.text.trim().isEmpty ? null : _descricaoCtrl.text.trim(),
      categoria: _categoria,
      unidadeMedida: _unidade,
      precoUnitario: double.parse(_precoCtrl.text.replaceAll(',', '.')),
      estoqueMinimo: double.parse(_estoqueCtrl.text.replaceAll(',', '.')),
      ativo: _ativo,
    );

    if (success && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Insumo' : 'Novo Insumo'),
        centerTitle: true,
      ),
      body: BlocListener<InsumosCubit, InsumosState>(
        listener: (context, state) {
          if (state is InsumoActionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        child: BlocBuilder<InsumosCubit, InsumosState>(
          builder: (context, state) {
            final isLoading = state is InsumoActionLoading;
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _nomeCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Nome *',
                            prefixIcon: Icon(Icons.inventory_2_outlined),
                            border: OutlineInputBorder(),
                          ),
                          textCapitalization: TextCapitalization.words,
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Nome é obrigatório' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descricaoCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Descrição',
                            prefixIcon: Icon(Icons.description_outlined),
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                          minLines: 1,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<InsumoCategoria>(
                          value: _categoria, // ignore: deprecated_member_use
                          decoration: const InputDecoration(
                            labelText: 'Categoria *',
                            prefixIcon: Icon(Icons.category_outlined),
                            border: OutlineInputBorder(),
                          ),
                          items: InsumoCategoria.values
                              .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
                              .toList(),
                          onChanged: (v) => setState(() => _categoria = v!),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<InsumoUnidadeMedida>(
                          value: _unidade, // ignore: deprecated_member_use
                          decoration: const InputDecoration(
                            labelText: 'Unidade de Medida *',
                            prefixIcon: Icon(Icons.straighten_outlined),
                            border: OutlineInputBorder(),
                          ),
                          items: InsumoUnidadeMedida.values
                              .map((u) => DropdownMenuItem(value: u, child: Text(u.label)))
                              .toList(),
                          onChanged: (v) => setState(() => _unidade = v!),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _precoCtrl,
                          decoration: InputDecoration(
                            labelText: 'Preço Unitário (R\$) *',
                            prefixIcon: const Icon(Icons.attach_money),
                            border: const OutlineInputBorder(),
                            suffixText: '/${_unidade.label}',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Preço é obrigatório';
                            final n = double.tryParse(v.replaceAll(',', '.'));
                            if (n == null || n < 0) return 'Informe um valor válido';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _estoqueCtrl,
                          decoration: InputDecoration(
                            labelText: 'Estoque Mínimo *',
                            prefixIcon: const Icon(Icons.warehouse_outlined),
                            border: const OutlineInputBorder(),
                            suffixText: _unidade.label,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Estoque mínimo é obrigatório';
                            final n = double.tryParse(v.replaceAll(',', '.'));
                            if (n == null || n < 0) return 'Informe um valor válido';
                            return null;
                          },
                        ),
                        if (_isEditing) ...[
                          const SizedBox(height: 8),
                          SwitchListTile(
                            value: _ativo,
                            onChanged: (v) => setState(() => _ativo = v),
                            title: const Text('Ativo'),
                            secondary: Icon(
                              _ativo ? Icons.toggle_on : Icons.toggle_off,
                              color: _ativo
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: isLoading ? null : _submit,
                          icon: const Icon(Icons.save_outlined),
                          label: Text(_isEditing ? 'Salvar Alterações' : 'Criar Insumo'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                if (isLoading)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Color(0x44000000),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
