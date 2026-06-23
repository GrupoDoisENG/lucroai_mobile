import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/auth/auth_session.dart';
import '../../../receitas/domain/usecases/get_receitas_usecase.dart';
import '../../domain/entities/venda.dart';
import '../../domain/usecases/criar_venda_usecase.dart';
import '../../domain/usecases/listar_vendas_usecase.dart';
import 'vendas_state.dart';

class VendasCubit extends Cubit<VendasState> {
  final CriarVendaUsecase criarVendaUsecase;
  final ListarVendasUsecase listarVendasUsecase;
  final GetReceitasUsecase getReceitasUsecase;

  VendasCubit({
    required this.criarVendaUsecase,
    required this.listarVendasUsecase,
    required this.getReceitasUsecase,
  }) : super(VendasState.initial());

  Future<void> loadInitial() async {
    emit(state.copyWith(status: VendasStatus.loading, clearErrorMessage: true));

    try {
      final receitas = await getReceitasUsecase();
      final vendas = await listarVendasUsecase(
        empresaId: AuthSession.empresaId,
        dataInicio: state.dataInicio,
        dataFim: state.dataFim,
      );

      emit(
        state.copyWith(
          status: VendasStatus.success,
          receitas: receitas,
          vendas: vendas,
          clearErrorMessage: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: VendasStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> atualizarPeriodo({
    required DateTime dataInicio,
    required DateTime dataFim,
  }) async {
    emit(
      state.copyWith(
        dataInicio: dataInicio,
        dataFim: dataFim,
        status: VendasStatus.loading,
        clearErrorMessage: true,
      ),
    );
    await carregarHistorico();
  }

  Future<void> carregarHistorico() async {
    try {
      final vendas = await listarVendasUsecase(
        empresaId: AuthSession.empresaId,
        dataInicio: state.dataInicio,
        dataFim: state.dataFim,
      );

      emit(
        state.copyWith(
          status: VendasStatus.success,
          vendas: vendas,
          clearErrorMessage: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: VendasStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<bool> registrarVenda({
    required int receitaId,
    required double quantidade,
    required double precoUnitarioReal,
  }) async {
    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      await criarVendaUsecase(
        CreateVendaRequest(
          itens: [
            CreateVendaItem(
              receitaId: receitaId,
              quantidade: quantidade,
              precoUnitarioReal: precoUnitarioReal,
            ),
          ],
        ),
      );

      emit(state.copyWith(isSubmitting: false, clearErrorMessage: true));
      await carregarHistorico();
      return true;
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          status: VendasStatus.error,
          errorMessage: e.toString(),
        ),
      );
      return false;
    }
  }
}
