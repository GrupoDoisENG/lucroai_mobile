import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../features/gastos_indiretos/domain/usecases/get_gastos_indiretos_usecase.dart';
import '../../../../features/receitas/domain/usecases/get_receitas_usecase.dart';
import '../../domain/usecases/listar_producoes_usecase.dart';
import '../../domain/usecases/registrar_producao_usecase.dart';
import 'producoes_state.dart';

class ProducoesCubit extends Cubit<ProducoesState> {
  final RegistrarProducaoUsecase registrarProducaoUsecase;
  final ListarProducoesUsecase listarProducoesUsecase;
  final GetReceitasUsecase getReceitasUsecase;
  final GetGastosIndiretosUsecase getGastosIndiretosUsecase;

  ProducoesCubit({
    required this.registrarProducaoUsecase,
    required this.listarProducoesUsecase,
    required this.getReceitasUsecase,
    required this.getGastosIndiretosUsecase,
  }) : super(ProducoesState.initial());

  Future<void> loadInitial() async {
    if (state.status == ProducoesStatus.loading) return;
    emit(state.copyWith(status: ProducoesStatus.loading, clearMessages: true));
    try {
      final receitas = await getReceitasUsecase();
      final gastos = await getGastosIndiretosUsecase();
      final producoes = await listarProducoesUsecase();
      emit(state.copyWith(
        status: ProducoesStatus.success,
        receitas: receitas,
        gastosIndiretos: gastos,
        producoes: producoes,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProducoesStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<bool> registrar({
    required int receitaId,
    required int quantidade,
    List<int>? gastoIndiretoIds,
  }) async {
    emit(state.copyWith(isSubmitting: true, clearMessages: true));
    try {
      await registrarProducaoUsecase(
        receitaId: receitaId,
        quantidade: quantidade,
        gastoIndiretoIds: gastoIndiretoIds,
      );
      final producoes = await listarProducoesUsecase();
      emit(state.copyWith(
        isSubmitting: false,
        producoes: producoes,
        successMessage: 'Produção registrada com sucesso',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
      return false;
    }
  }

  Future<void> reloadProducoes() async {
    try {
      final producoes = await listarProducoesUsecase();
      emit(state.copyWith(producoes: producoes));
    } catch (_) {}
  }
}
