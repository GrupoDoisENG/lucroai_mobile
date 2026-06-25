import '../../domain/entities/gasto_indireto.dart';

enum GastosIndiretosStatus { initial, loading, success, error }

class GastosIndiretosState {
  final GastosIndiretosStatus status;
  final List<GastoIndireto> gastos;
  final String? errorMessage;
  final bool isSubmitting;

  const GastosIndiretosState({
    this.status = GastosIndiretosStatus.initial,
    this.gastos = const [],
    this.errorMessage,
    this.isSubmitting = false,
  });

  double get totalGastos =>
      gastos.fold(0, (sum, g) => sum + g.valor);

  GastosIndiretosState copyWith({
    GastosIndiretosStatus? status,
    List<GastoIndireto>? gastos,
    String? errorMessage,
    bool? isSubmitting,
    bool clearError = false,
  }) {
    return GastosIndiretosState(
      status: status ?? this.status,
      gastos: gastos ?? this.gastos,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}
