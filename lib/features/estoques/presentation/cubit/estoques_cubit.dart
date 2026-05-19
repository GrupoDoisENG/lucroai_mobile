import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/estoque_com_insumo.dart';
import '../../domain/entities/movimentacao_estoque.dart';
import '../../domain/usecases/get_estoques_usecase.dart';
import '../../domain/usecases/registrar_entrada_estoque_usecase.dart';
import '../../domain/usecases/get_movimentacoes_usecase.dart';
import 'estoques_state.dart';

class EstoquesCubit extends Cubit<EstoquesState> {
  final GetEstoquesUsecase getEstoques;
  final RegistrarEntradaEstoqueUsecase registrarEntrada;
  final GetMovimentacoesUsecase getMovimentacoes;

  List<EstoqueComInsumo> _currentEstoques = [];
  bool? _filterBaixoEstoque;
  String? _search;

  EstoquesCubit({
    required this.getEstoques,
    required this.registrarEntrada,
    required this.getMovimentacoes,
  }) : super(const EstoquesInitial());

  Future<void> loadEstoques({
    bool? filterBaixoEstoque,
    String? search,
    bool resetFilters = false,
  }) async {
    if (resetFilters) {
      _filterBaixoEstoque = null;
      _search = null;
    } else {
      if (filterBaixoEstoque != null) _filterBaixoEstoque = filterBaixoEstoque;
      if (search != null) _search = search;
    }

    emit(const EstoquesLoading());
    try {
      final estoques = await getEstoques();
      _currentEstoques = estoques;
      
      // Aplicar filtros
      List<EstoqueComInsumo> filtered = estoques;
      if (_filterBaixoEstoque == true) {
        filtered = filtered.where((e) => e.isBaixoEstoque).toList();
      }
      if (_search != null && _search!.isNotEmpty) {
        filtered = filtered.where((e) => 
          e.insumoNome.toLowerCase().contains(_search!.toLowerCase()) ||
          e.insumoCategoria.toLowerCase().contains(_search!.toLowerCase())
        ).toList();
      }

      emit(EstoquesLoaded(
        estoques: filtered,
        filterBaixoEstoque: _filterBaixoEstoque,
        search: _search,
      ));
    } catch (e) {
      emit(EstoquesError(e.toString()));
    }
  }

  Future<void> applyFilter({bool? filterBaixoEstoque}) async {
    _filterBaixoEstoque = filterBaixoEstoque;
    await loadEstoques();
  }

  Future<void> searchEstoques(String search) async {
    _search = search.isEmpty ? null : search;
    await loadEstoques();
  }

  Future<void> registrarEntradaManual({
    required String insumoId,
    required double quantidade,
  }) async {
    emit(EstoqueActionLoading(_currentEstoques));
    try {
      await registrarEntrada(
        insumoId: insumoId,
        quantidade: quantidade,
        origem: OrigemMovimentacao.compra,
      );
      await loadEstoques();
      emit(EstoqueActionSuccess(
        estoques: _currentEstoques,
        message: 'Entrada de estoque registrada com sucesso',
      ));
    } catch (e) {
      emit(EstoqueActionError(
        estoques: _currentEstoques,
        message: 'Erro ao registrar entrada: ${e.toString()}',
      ));
    }
  }

  Future<List<MovimentacaoEstoque>> obterMovimentacoes({
    String? insumoId,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    try {
      return await getMovimentacoes(
        insumoId: insumoId,
        dataInicio: dataInicio,
        dataFim: dataFim,
      );
    } catch (e) {
      rethrow;
    }
  }

  List<EstoqueComInsumo> _getEstoques(EstoquesState state) {
    if (state is EstoquesLoaded) return state.estoques;
    if (state is EstoqueActionLoading) return state.estoques;
    if (state is EstoqueActionSuccess) return state.estoques;
    if (state is EstoqueActionError) return state.estoques;
    return [];
  }
}
