import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/receita.dart';
import '../../domain/usecases/create_receita_usecase.dart';
import '../../domain/usecases/delete_receita_usecase.dart';
import '../../domain/usecases/get_receitas_usecase.dart';
import '../../domain/usecases/toggle_receita_ativo_usecase.dart';
import '../../domain/usecases/update_receita_usecase.dart';
import 'receitas_state.dart';

class ReceitasCubit extends Cubit<ReceitasState> {
  final GetReceitasUsecase getReceitasUsecase;
  final CreateReceitaUsecase createReceitaUsecase;
  final UpdateReceitaUsecase updateReceitaUsecase;
  final DeleteReceitaUsecase deleteReceitaUsecase;
  final ToggleReceitaAtivoUsecase toggleReceitaAtivoUsecase;

  Timer? _debounce;

  ReceitasCubit({
    required this.getReceitasUsecase,
    required this.createReceitaUsecase,
    required this.updateReceitaUsecase,
    required this.deleteReceitaUsecase,
    required this.toggleReceitaAtivoUsecase,
  }) : super(const ReceitasState());

  Future<void> loadReceitas({String? search, bool showLoader = true}) async {
    if (showLoader) {
      emit(
        state.copyWith(
          status: ReceitasStatus.loading,
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
      final result = await getReceitasUsecase(
        search: search ?? state.search,
        ativo: true,
      );

      emit(
        state.copyWith(
          status: ReceitasStatus.success,
          receitas: result,
          search: search ?? state.search,
          clearErrorMessage: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ReceitasStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void onSearchChanged(String value) {
    emit(state.copyWith(search: value));
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      loadReceitas(search: value, showLoader: false);
    });
  }

  Future<void> createReceita({
    required String nome,
    String? descricao,
    required ReceitaCategoria categoria,
    required double rendimento,
    required double custoTotal,
    required double precoVenda,
  }) async {
    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      await createReceitaUsecase(
        nome: nome,
        descricao: descricao,
        categoria: categoria,
        rendimento: rendimento,
        custoTotal: custoTotal,
        precoVenda: precoVenda,
      );

      emit(state.copyWith(isSubmitting: false));
      await loadReceitas(search: state.search, showLoader: false);
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: e.toString(),
          status: ReceitasStatus.error,
        ),
      );
    }
  }

  Future<void> updateReceita({
    required String id,
    String? nome,
    String? descricao,
    ReceitaCategoria? categoria,
    double? rendimento,
    double? custoTotal,
    double? precoVenda,
    bool? ativo,
  }) async {
    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      await updateReceitaUsecase(
        id: id,
        nome: nome,
        descricao: descricao,
        categoria: categoria,
        rendimento: rendimento,
        custoTotal: custoTotal,
        precoVenda: precoVenda,
        ativo: ativo,
      );

      emit(state.copyWith(isSubmitting: false));
      await loadReceitas(search: state.search, showLoader: false);
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: e.toString(),
          status: ReceitasStatus.error,
        ),
      );
    }
  }

  Future<void> deleteReceita(String id) async {
    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      await deleteReceitaUsecase(id);
      emit(state.copyWith(isSubmitting: false));
      await loadReceitas(search: state.search, showLoader: false);
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: e.toString(),
          status: ReceitasStatus.error,
        ),
      );
    }
  }

  Future<void> toggleAtivo(String id, bool ativo) async {
    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      await toggleReceitaAtivoUsecase(id, ativo);
      emit(state.copyWith(isSubmitting: false));
      await loadReceitas(search: state.search, showLoader: false);
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: e.toString(),
          status: ReceitasStatus.error,
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
