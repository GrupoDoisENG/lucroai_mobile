import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/receita.dart';
import '../cubit/receitas_cubit.dart';
import '../cubit/receitas_state.dart';

class ReceitaFormPage extends StatefulWidget {
  final Receita? receita;

  const ReceitaFormPage({super.key, this.receita});

  @override
  State<ReceitaFormPage> createState() => _ReceitaFormPageState();
}

class _ReceitaFormPageState extends State<ReceitaFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _descricaoController;
  late final TextEditingController _rendimentoController;
  late final TextEditingController _custoTotalController;
  late final TextEditingController _precoVendaController;

  ReceitaCategoria _categoria = ReceitaCategoria.outros;
  bool _ativo = true;

  bool get _isEditing => widget.receita != null;

  @override
  void initState() {
    super.initState();

    final receita = widget.receita;
    _nomeController = TextEditingController(text: receita?.nome ?? '');
    _descricaoController = TextEditingController(
      text: receita?.descricao ?? '',
    );
    _rendimentoController = TextEditingController(
      text: receita?.rendimento.toString() ?? '',
    );
    _custoTotalController = TextEditingController(
      text: receita?.custoTotal.toString() ?? '',
    );
    _precoVendaController = TextEditingController(
      text: receita?.precoVenda.toString() ?? '',
    );

    if (receita != null) {
      _categoria = receita.categoria;
      _ativo = receita.ativo;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _rendimentoController.dispose();
    _custoTotalController.dispose();
    _precoVendaController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<ReceitasCubit>();
    final descricao = _descricaoController.text.trim().isEmpty
        ? null
        : _descricaoController.text.trim();

    if (_isEditing) {
      await cubit.updateReceita(
        id: widget.receita!.id,
        nome: _nomeController.text.trim(),
        descricao: descricao,
        categoria: _categoria,
        rendimento: _parseDouble(_rendimentoController.text),
        custoTotal: _parseDouble(_custoTotalController.text),
        precoVenda: _parseDouble(_precoVendaController.text),
        ativo: _ativo,
      );
    } else {
      await cubit.createReceita(
        nome: _nomeController.text.trim(),
        descricao: descricao,
        categoria: _categoria,
        rendimento: _parseDouble(_rendimentoController.text),
        custoTotal: _parseDouble(_custoTotalController.text),
        precoVenda: _parseDouble(_precoVendaController.text),
      );
    }

    if (mounted && cubit.state.errorMessage == null) {
      Navigator.pop(context);
    }
  }

  double _parseDouble(String value) {
    return double.parse(value.replaceAll(',', '.'));
  }

  String? _validateRequired(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label obrigatorio';
    return null;
  }

  String? _validateNumber(String? value, String label) {
    final requiredMessage = _validateRequired(value, label);
    if (requiredMessage != null) return requiredMessage;

    final number = double.tryParse(value!.replaceAll(',', '.'));
    if (number == null || number < 0) return 'Informe um valor valido';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Receita' : 'Nova Receita'),
        centerTitle: true,
      ),
      body: BlocListener<ReceitasCubit, ReceitasState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => _validateRequired(value, 'Nome'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descricaoController,
                  decoration: const InputDecoration(
                    labelText: 'Descricao',
                    border: OutlineInputBorder(),
                  ),
                  minLines: 1,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ReceitaCategoria>(
                  initialValue: _categoria,
                  decoration: const InputDecoration(
                    labelText: 'Categoria *',
                    border: OutlineInputBorder(),
                  ),
                  items: ReceitaCategoria.values
                      .map(
                        (categoria) => DropdownMenuItem(
                          value: categoria,
                          child: Text(categoria.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _categoria = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _rendimentoController,
                  decoration: const InputDecoration(
                    labelText: 'Rendimento *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) => _validateNumber(value, 'Rendimento'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _custoTotalController,
                  decoration: const InputDecoration(
                    labelText: 'Custo total (R\$) *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) => _validateNumber(value, 'Custo total'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _precoVendaController,
                  decoration: const InputDecoration(
                    labelText: 'Preco de venda (R\$) *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) =>
                      _validateNumber(value, 'Preco de venda'),
                ),
                if (_isEditing) ...[
                  const SizedBox(height: 8),
                  SwitchListTile(
                    value: _ativo,
                    onChanged: (value) => setState(() => _ativo = value),
                    title: const Text('Ativa'),
                  ),
                ],
                const SizedBox(height: 24),
                BlocBuilder<ReceitasCubit, ReceitasState>(
                  builder: (context, state) {
                    return FilledButton.icon(
                      onPressed: state.isSubmitting ? null : _submit,
                      icon: state.isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(_isEditing ? 'Salvar' : 'Criar Receita'),
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
}
