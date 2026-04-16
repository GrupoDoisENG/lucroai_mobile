import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/insumo.dart';
import '../../domain/usecases/create_insumo_usecase.dart';
import '../../domain/usecases/delete_insumo_usecase.dart';
import '../../domain/usecases/get_insumos_usecase.dart';
import '../../domain/usecases/toggle_insumo_ativo_usecase.dart';
import '../../domain/usecases/update_insumo_usecase.dart';
import 'insumos_state.dart';

class InsumosCubit extends Cubit<InsumosState> {
  final GetInsumosUsecase getInsumosUsecase;
  final CreateInsumoUsecase createInsumoUsecase;
  final UpdateInsumoUsecase updateInsumoUsecase;
  final DeleteInsumoUsecase deleteInsumoUsecase;
  final ToggleInsumoAtivoUsecase toggleInsumoAtivoUsecase;

  Timer? _debounce;

  InsumosCubit({
    required this.getInsumosUsecase,
    required this.createInsumoUsecase,
    required this.updateInsumoUsecase,
    required this.deleteInsumoUsecase,
    required this.toggleInsumoAtivoUsecase,
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
        state.copyWith(
          search: search ?? state.search,
          clearErrorMessage: true,
        ),
      );
    }

    try {
      final result = await getInsumosUsecase(
        search: search ?? state.search,
        ativo: true,
      );

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
        state.copyWith(
          status: InsumosStatus.error,
          errorMessage: e.toString(),
        ),
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
    String? descricao,
    required InsumoCategoria categoria,
    required InsumoUnidadeMedida unidadeMedida,
    required double precoUnitario,
    required double estoqueMinimo,
    double? quantidadeEmbalagem,
    double? precoEmbalagem,
  }) async {
    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      await createInsumoUsecase(
        nome: nome,
        descricao: descricao,
        categoria: categoria,
        unidadeMedida: unidadeMedida,
        precoUnitario: precoUnitario,
        estoqueMinimo: estoqueMinimo,
        quantidadeEmbalagem: quantidadeEmbalagem,
        precoEmbalagem: precoEmbalagem,
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
    required String id,
    String? nome,
    String? descricao,
    InsumoCategoria? categoria,
    InsumoUnidadeMedida? unidadeMedida,
    double? precoUnitario,
    double? estoqueMinimo,
    bool? ativo,
    double? quantidadeEmbalagem,
    double? precoEmbalagem,
  }) async {
    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      await updateInsumoUsecase(
        id: id,
        nome: nome,
        descricao: descricao,
        categoria: categoria,
        unidadeMedida: unidadeMedida,
        precoUnitario: precoUnitario,
        estoqueMinimo: estoqueMinimo,
        ativo: ativo,
        quantidadeEmbalagem: quantidadeEmbalagem,
        precoEmbalagem: precoEmbalagem,
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

  Future<void> deleteInsumo(String id) async {
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

  Future<void> toggleAtivo(String id, bool ativo) async {
    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      await toggleInsumoAtivoUsecase(id, ativo);
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
