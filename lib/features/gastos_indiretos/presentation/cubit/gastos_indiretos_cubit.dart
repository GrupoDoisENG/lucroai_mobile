import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/gasto_indireto.dart';
import '../../domain/usecases/create_gasto_indireto_usecase.dart';
import '../../domain/usecases/delete_gasto_indireto_usecase.dart';
import '../../domain/usecases/get_gastos_indiretos_usecase.dart';
import '../../domain/usecases/update_gasto_indireto_usecase.dart';
import 'gastos_indiretos_state.dart';

class GastosIndiretosCubit extends Cubit<GastosIndiretosState> {
  final GetGastosIndiretosUsecase getGastosIndiretos;
  final CreateGastoIndiretoUsecase createGastoIndireto;
  final UpdateGastoIndiretoUsecase updateGastoIndireto;
  final DeleteGastoIndiretoUsecase deleteGastoIndireto;

  GastosIndiretosCubit({
    required this.getGastosIndiretos,
    required this.createGastoIndireto,
    required this.updateGastoIndireto,
    required this.deleteGastoIndireto,
  }) : super(const GastosIndiretosState());

  Future<void> loadGastos() async {
    emit(
      state.copyWith(
        status: GastosIndiretosStatus.loading,
        clearError: true,
      ),
    );

    try {
      final result = await getGastosIndiretos();
      emit(
        state.copyWith(
          status: GastosIndiretosStatus.success,
          gastos: result,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: GastosIndiretosStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> criar({
    required String descricao,
    required double valor,
    required MetodoRateio metodoRateio,
  }) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));

    try {
      await createGastoIndireto(
        descricao: descricao,
        valor: valor,
        metodoRateio: metodoRateio,
      );
      emit(state.copyWith(isSubmitting: false));
      await loadGastos();
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          status: GastosIndiretosStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> atualizar({
    required int id,
    String? descricao,
    double? valor,
    MetodoRateio? metodoRateio,
  }) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));

    try {
      await updateGastoIndireto(
        id: id,
        descricao: descricao,
        valor: valor,
        metodoRateio: metodoRateio,
      );
      emit(state.copyWith(isSubmitting: false));
      await loadGastos();
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          status: GastosIndiretosStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> deletar(int id) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));

    try {
      await deleteGastoIndireto(id);
      emit(state.copyWith(isSubmitting: false));
      await loadGastos();
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          status: GastosIndiretosStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
