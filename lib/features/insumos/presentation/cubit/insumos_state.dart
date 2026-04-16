import '../../domain/entities/insumo.dart';

enum InsumosStatus {
  initial,
  loading,
  success,
  error,
}

class InsumosState {
  final InsumosStatus status;
  final List<Insumo> insumos;
  final String search;
  final String? errorMessage;
  final bool isSubmitting;

  const InsumosState({
    this.status = InsumosStatus.initial,
    this.insumos = const [],
    this.search = '',
    this.errorMessage,
    this.isSubmitting = false,
  });

  InsumosState copyWith({
    InsumosStatus? status,
    List<Insumo>? insumos,
    String? search,
    String? errorMessage,
    bool? isSubmitting,
    bool clearErrorMessage = false,
  }) {
    return InsumosState(
      status: status ?? this.status,
      insumos: insumos ?? this.insumos,
      search: search ?? this.search,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}