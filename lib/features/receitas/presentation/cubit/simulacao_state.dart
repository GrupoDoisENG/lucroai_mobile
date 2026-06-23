import '../../domain/entities/simulacao_result.dart';

enum SimulacaoStatus { initial, loading, success, error }

class SimulacaoState {
  final SimulacaoStatus status;
  final SimulacaoResult? result;
  final String? errorMessage;

  const SimulacaoState({
    this.status = SimulacaoStatus.initial,
    this.result,
    this.errorMessage,
  });

  SimulacaoState copyWith({
    SimulacaoStatus? status,
    SimulacaoResult? result,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SimulacaoState(
      status: status ?? this.status,
      result: result ?? this.result,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
