import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../insumos/domain/entities/insumo.dart';
import '../../domain/entities/receita.dart';
import '../../domain/usecases/create_receita_usecase.dart';
import '../../domain/usecases/delete_receita_usecase.dart';
import '../../domain/usecases/get_receitas_usecase.dart';
import '../../domain/usecases/update_receita_usecase.dart';
import 'receitas_state.dart';

class ReceitasCubit extends Cubit<ReceitasState> {
  final GetReceitasUsecase getReceitasUsecase;
  final CreateReceitaUsecase createReceitaUsecase;
  final UpdateReceitaUsecase updateReceitaUsecase;
  final DeleteReceitaUsecase deleteReceitaUsecase;

  Timer? _debounce;

  ReceitasCubit({
    required this.getReceitasUsecase,
    required this.createReceitaUsecase,
    required this.updateReceitaUsecase,
    required this.deleteReceitaUsecase,
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
      final result = await getReceitasUsecase(search: search ?? state.search);

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
    required int empresaId,
    required String nome,
    required double rendimento,
    required InsumoUnidadeMedida unidadeRendimento,
    required double custoProducao,
    required double custoUnitario,
    required double margemLucro,
    required double precoSugerido,
    List<ReceitaItem> itens = const [],
  }) async {
    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      await createReceitaUsecase(
        empresaId: empresaId,
        nome: nome,
        rendimento: rendimento,
        unidadeRendimento: unidadeRendimento,
        custoProducao: custoProducao,
        custoUnitario: custoUnitario,
        margemLucro: margemLucro,
        precoSugerido: precoSugerido,
        itens: itens,
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
    required int id,
    String? nome,
    double? rendimento,
    InsumoUnidadeMedida? unidadeRendimento,
    double? custoProducao,
    double? custoUnitario,
    double? margemLucro,
    double? precoSugerido,
    List<ReceitaItem>? itens,
  }) async {
    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      await updateReceitaUsecase(
        id: id,
        nome: nome,
        rendimento: rendimento,
        unidadeRendimento: unidadeRendimento,
        custoProducao: custoProducao,
        custoUnitario: custoUnitario,
        margemLucro: margemLucro,
        precoSugerido: precoSugerido,
        itens: itens,
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

  Future<void> deleteReceita(int id) async {
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

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
