import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/insumo.dart';
import '../../domain/usecases/create_insumo_usecase.dart';
import '../../domain/usecases/delete_insumo_usecase.dart';
import '../../domain/usecases/get_insumos_usecase.dart';
import '../../domain/usecases/update_insumo_usecase.dart';
import 'insumos_state.dart';

class InsumosCubit extends Cubit<InsumosState> {
  final GetInsumosUsecase getInsumosUsecase;
  final CreateInsumoUsecase createInsumoUsecase;
  final UpdateInsumoUsecase updateInsumoUsecase;
  final DeleteInsumoUsecase deleteInsumoUsecase;

  Timer? _debounce;

  InsumosCubit({
    required this.getInsumosUsecase,
    required this.createInsumoUsecase,
    required this.updateInsumoUsecase,
    required this.deleteInsumoUsecase,
  }) : super(const InsumosState());

  Future<void> loadInsumos({String? search, bool showLoader = true}) async {
    if (showLoader) {
      emit(
        state.copyWith(
          status: InsumosStatus.loading,
          search: search ?? state.search,
          clearErrorMessage: true,
        ),
      );
    } else {
      emit(
        state.copyWith(search: search ?? state.search, clearErrorMessage: true),
      );
    }

    try {
      final result = await getInsumosUsecase(search: search ?? state.search);

      emit(
        state.copyWith(
          status: InsumosStatus.success,
          insumos: result,
          search: search ?? state.search,
          clearErrorMessage: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: InsumosStatus.error, errorMessage: e.toString()),
      );
    }
  }

  void onSearchChanged(String value) {
    emit(state.copyWith(search: value));
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      loadInsumos(search: value, showLoader: false);
    });
  }

  Future<void> createInsumo({
    required String nome,
    required double quantidade,
    required InsumoUnidadeMedida unidade,
    required double valorPago,
  }) async {
    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      await createInsumoUsecase(
        nome: nome,
        quantidade: quantidade,
        unidade: unidade,
        valorPago: valorPago,
      );

      emit(state.copyWith(isSubmitting: false));
      await loadInsumos(search: state.search, showLoader: false);
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: e.toString(),
          status: InsumosStatus.error,
        ),
      );
    }
  }

  Future<void> updateInsumo({
    required int id,
    String? nome,
    double? quantidade,
    InsumoUnidadeMedida? unidade,
    double? valorPago,
  }) async {
    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      await updateInsumoUsecase(
        id: id,
        nome: nome,
        quantidade: quantidade,
        unidade: unidade,
        valorPago: valorPago,
      );

      emit(state.copyWith(isSubmitting: false));
      await loadInsumos(search: state.search, showLoader: false);
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: e.toString(),
          status: InsumosStatus.error,
        ),
      );
    }
  }

  Future<void> deleteInsumo(int id) async {
    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      await deleteInsumoUsecase(id);
      emit(state.copyWith(isSubmitting: false));
      await loadInsumos(search: state.search, showLoader: false);
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: e.toString(),
          status: InsumosStatus.error,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
