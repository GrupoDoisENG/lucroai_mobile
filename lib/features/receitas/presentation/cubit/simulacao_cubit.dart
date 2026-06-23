import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/simular_receita_usecase.dart';
import 'simulacao_state.dart';

class SimulacaoCubit extends Cubit<SimulacaoState> {
  final SimularReceitaUsecase simularReceitaUsecase;

  SimulacaoCubit({required this.simularReceitaUsecase})
      : super(const SimulacaoState());

  Future<void> simular({
    required int receitaId,
    double? novoCusto,
    double? novoPreco,
    int? volume,
  }) async {
    emit(state.copyWith(status: SimulacaoStatus.loading, clearError: true));

    try {
      final result = await simularReceitaUsecase(
        id: receitaId,
        novoCusto: novoCusto,
        novoPreco: novoPreco,
        volume: volume,
      );

      emit(state.copyWith(status: SimulacaoStatus.success, result: result));
    } catch (e) {
      emit(
        state.copyWith(
          status: SimulacaoStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
