import '../../../receitas/domain/entities/receita.dart';
import '../../domain/entities/venda.dart';

enum VendasStatus { initial, loading, success, error }

class VendasState {
  final VendasStatus status;
  final List<Venda> vendas;
  final List<Receita> receitas;
  final String? errorMessage;
  final bool isSubmitting;
  final DateTime dataInicio;
  final DateTime dataFim;

  const VendasState({
    this.status = VendasStatus.initial,
    this.vendas = const [],
    this.receitas = const [],
    this.errorMessage,
    this.isSubmitting = false,
    required this.dataInicio,
    required this.dataFim,
  });

  factory VendasState.initial() {
    final now = DateTime.now();
    return VendasState(
      dataInicio: DateTime(now.year, now.month, 1),
      dataFim: DateTime(now.year, now.month + 1, 0),
    );
  }

  VendaResumo get resumo => VendaResumo.fromVendas(vendas);

  VendasState copyWith({
    VendasStatus? status,
    List<Venda>? vendas,
    List<Receita>? receitas,
    String? errorMessage,
    bool? isSubmitting,
    DateTime? dataInicio,
    DateTime? dataFim,
    bool clearErrorMessage = false,
  }) {
    return VendasState(
      status: status ?? this.status,
      vendas: vendas ?? this.vendas,
      receitas: receitas ?? this.receitas,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
    );
  }
}
