import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/auth/auth_session.dart';
import '../../../producoes/domain/usecases/listar_producoes_usecase.dart';
import '../../../receitas/domain/usecases/get_receitas_usecase.dart';
import '../../domain/entities/venda.dart';
import '../../domain/usecases/atualizar_status_venda_usecase.dart';
import '../../domain/usecases/criar_venda_usecase.dart';
import '../../domain/usecases/listar_vendas_usecase.dart';
import 'vendas_state.dart';

class VendasCubit extends Cubit<VendasState> {
  final CriarVendaUsecase criarVendaUsecase;
  final ListarVendasUsecase listarVendasUsecase;
  final GetReceitasUsecase getReceitasUsecase;
  final AtualizarStatusVendaUsecase atualizarStatusVendaUsecase;
  final ListarProducoesUsecase listarProducoesUsecase;

  VendasCubit({
    required this.criarVendaUsecase,
    required this.listarVendasUsecase,
    required this.getReceitasUsecase,
    required this.atualizarStatusVendaUsecase,
    required this.listarProducoesUsecase,
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

  /// Cria a venda no backend com os itens do carrinho.
  /// Retorna a [Venda] em status PENDENTE para confirmação, ou null em caso de erro.
  Future<Venda?> registrarVenda(List<ItemCarrinho> itens) async {
    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      final venda = await criarVendaUsecase(
        CreateVendaRequest(
          itens: itens
              .map(
                (i) => CreateVendaItem(
                  receitaId: i.receita.id,
                  quantidade: i.quantidade,
                  precoUnitarioReal: i.precoUnitario,
                ),
              )
              .toList(),
        ),
      );

      emit(state.copyWith(isSubmitting: false, clearErrorMessage: true));
      return venda;
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          status: VendasStatus.error,
          errorMessage: e.toString(),
        ),
      );
      return null;
    }
  }

  /// Verifica se há estoque de produto acabado suficiente para concluir a venda.
  /// Retorna uma mensagem de erro se insuficiente, null se ok.
  Future<String?> verificarEstoqueParaVenda(Venda venda) async {
    final receitas = state.receitas;

    for (final item in venda.itens) {
      try {
        final producoes = await listarProducoesUsecase(receitaId: item.receitaId);

        final receita = receitas.where((r) => r.id == item.receitaId).firstOrNull;
        final rendimento = receita?.rendimento ?? 1.0;

        final totalProduzidoUnidades = producoes.fold<double>(
          0,
          (sum, p) => sum + (p.quantidade * rendimento),
        );

        final totalVendidoConcluido = state.vendas
            .where((v) => v.status == 'CONCLUIDA')
            .expand((v) => v.itens)
            .where((i) => i.receitaId == item.receitaId)
            .fold<double>(0, (sum, i) => sum + i.quantidade);

        final disponivel = totalProduzidoUnidades - totalVendidoConcluido;

        if (disponivel < item.quantidade) {
          final receitaNome = receita?.nome ?? 'Receita #${item.receitaId}';
          return 'Estoque insuficiente para "$receitaNome": '
              'disponível ${disponivel.toStringAsFixed(0)}, '
              'solicitado ${item.quantidade.toStringAsFixed(0)}. '
              'Registre uma produção antes de concluir.';
        }
      } catch (_) {
        // Se a consulta falhar, deixa o backend validar
      }
    }
    return null;
  }

  /// Atualiza o status de uma venda para CONCLUIDA ou CANCELADA.
  Future<bool> atualizarStatus(int vendaId, String status) async {
    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      await atualizarStatusVendaUsecase(vendaId, status);
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
