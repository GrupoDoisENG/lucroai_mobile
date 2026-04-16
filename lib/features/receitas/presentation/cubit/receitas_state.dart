import '../../domain/entities/receita.dart';

enum ReceitasStatus { initial, loading, success, error }

class ReceitasState {
  final ReceitasStatus status;
  final List<Receita> receitas;
  final String search;
  final String? errorMessage;
  final bool isSubmitting;

  const ReceitasState({
    this.status = ReceitasStatus.initial,
    this.receitas = const [],
    this.search = '',
    this.errorMessage,
    this.isSubmitting = false,
  });

  ReceitasState copyWith({
    ReceitasStatus? status,
    List<Receita>? receitas,
    String? search,
    String? errorMessage,
    bool? isSubmitting,
    bool clearErrorMessage = false,
  }) {
    return ReceitasState(
      status: status ?? this.status,
      receitas: receitas ?? this.receitas,
      search: search ?? this.search,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}
