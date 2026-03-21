import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/insumo.dart';
import '../../domain/usecases/create_insumo_usecase.dart';
import '../../domain/usecases/delete_insumo_usecase.dart';
import '../../domain/usecases/get_insumo_usecase.dart';
import '../../domain/usecases/get_insumos_usecase.dart';
import '../../domain/usecases/toggle_insumo_ativo_usecase.dart';
import '../../domain/usecases/update_insumo_usecase.dart';
import 'insumos_state.dart';

class InsumosCubit extends Cubit<InsumosState> {
  final GetInsumosUsecase getInsumos;
  final GetInsumoUsecase getInsumo;
  final CreateInsumoUsecase createInsumo;
  final UpdateInsumoUsecase updateInsumo;
  final DeleteInsumoUsecase deleteInsumo;
  final ToggleInsumoAtivoUsecase toggleAtivo;

  List<Insumo> _currentInsumos = [];
  bool? _filterAtivo;
  InsumoCategoria? _filterCategoria;
  String? _search;

  InsumosCubit({
    required this.getInsumos,
    required this.getInsumo,
    required this.createInsumo,
    required this.updateInsumo,
    required this.deleteInsumo,
    required this.toggleAtivo,
  }) : super(const InsumosInitial());

  Future<void> loadInsumos({
    bool? ativo,
    InsumoCategoria? categoria,
    String? search,
    bool resetFilters = false,
  }) async {
    if (resetFilters) {
      _filterAtivo = null;
      _filterCategoria = null;
      _search = null;
    } else {
      if (ativo != _filterAtivo || categoria != _filterCategoria) {
        _filterAtivo = ativo;
        _filterCategoria = categoria;
      }
      if (search != null) _search = search;
    }

    emit(const InsumosLoading());
    try {
      final result = await getInsumos(
        ativo: _filterAtivo,
        categoria: _filterCategoria,
        search: _search,
      );
      _currentInsumos = result;
      emit(InsumosLoaded(
        insumos: result,
        filterAtivo: _filterAtivo,
        filterCategoria: _filterCategoria,
        search: _search,
      ));
    } catch (e) {
      emit(InsumosError(e.toString()));
    }
  }

  Future<void> applyFilter({bool? ativo, InsumoCategoria? categoria}) async {
    _filterAtivo = ativo;
    _filterCategoria = categoria;
    await loadInsumos();
  }

  Future<void> searchInsumos(String search) async {
    _search = search.isEmpty ? null : search;
    await loadInsumos();
  }

  Future<bool> saveInsumo({
    String? id,
    required String nome,
    String? descricao,
    required InsumoCategoria categoria,
    required InsumoUnidadeMedida unidadeMedida,
    required double precoUnitario,
    required double estoqueMinimo,
    bool ativo = true,
  }) async {
    emit(InsumoActionLoading(_currentInsumos));
    try {
      if (id == null) {
        await createInsumo(
          nome: nome,
          descricao: descricao,
          categoria: categoria,
          unidadeMedida: unidadeMedida,
          precoUnitario: precoUnitario,
          estoqueMinimo: estoqueMinimo,
        );
      } else {
        await updateInsumo(
          id: id,
          nome: nome,
          descricao: descricao,
          categoria: categoria,
          unidadeMedida: unidadeMedida,
          precoUnitario: precoUnitario,
          estoqueMinimo: estoqueMinimo,
          ativo: ativo,
        );
      }

      final result = await getInsumos(
        ativo: _filterAtivo,
        categoria: _filterCategoria,
        search: _search,
      );
      _currentInsumos = result;
      emit(InsumoActionSuccess(
        insumos: result,
        message: id == null ? 'Insumo criado com sucesso!' : 'Insumo atualizado com sucesso!',
      ));
      return true;
    } catch (e) {
      emit(InsumoActionError(insumos: _currentInsumos, message: e.toString()));
      return false;
    }
  }

  Future<void> toggleInsumoAtivo(Insumo insumo) async {
    emit(InsumoActionLoading(_currentInsumos));
    try {
      await toggleAtivo(insumo.id, !insumo.ativo);
      final result = await getInsumos(
        ativo: _filterAtivo,
        categoria: _filterCategoria,
        search: _search,
      );
      _currentInsumos = result;
      final status = !insumo.ativo ? 'ativado' : 'desativado';
      emit(InsumoActionSuccess(
        insumos: result,
        message: 'Insumo $status com sucesso!',
      ));
    } catch (e) {
      emit(InsumoActionError(insumos: _currentInsumos, message: e.toString()));
    }
  }

  Future<void> removeInsumo(String id) async {
    emit(InsumoActionLoading(_currentInsumos));
    try {
      await deleteInsumo(id);
      final result = await getInsumos(
        ativo: _filterAtivo,
        categoria: _filterCategoria,
        search: _search,
      );
      _currentInsumos = result;
      emit(InsumoActionSuccess(
        insumos: result,
        message: 'Insumo excluído com sucesso!',
      ));
    } catch (e) {
      emit(InsumoActionError(insumos: _currentInsumos, message: e.toString()));
    }
  }
}
