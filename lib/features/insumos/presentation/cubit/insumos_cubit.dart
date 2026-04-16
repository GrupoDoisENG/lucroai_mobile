import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/insumo.dart';
import '../../domain/usecases/create_insumo_usecase.dart';
import '../../domain/usecases/delete_insumo_usecase.dart';
import '../../domain/usecases/get_insumo_usecase.dart';
import '../../domain/usecases/get_insumos_usecase.dart';
import '../../domain/usecases/update_insumo_usecase.dart';
import 'insumos_state.dart';

class InsumosCubit extends Cubit<InsumosState> {
  final GetInsumosUsecase getInsumos;
  final GetInsumoUsecase getInsumo;
  final CreateInsumoUsecase createInsumo;
  final UpdateInsumoUsecase updateInsumo;
  final DeleteInsumoUsecase deleteInsumo;

  List<Insumo> _allInsumos = [];
  String? _search;

  InsumosCubit({
    required this.getInsumos,
    required this.getInsumo,
    required this.createInsumo,
    required this.updateInsumo,
    required this.deleteInsumo,
  }) : super(const InsumosInitial());

  Future<void> loadInsumos() async {
    emit(const InsumosLoading());
    try {
      _allInsumos = await getInsumos();
      emit(InsumosLoaded(insumos: _applySearch(_allInsumos), search: _search));
    } catch (e) {
      emit(InsumosError(e.toString()));
    }
  }

  void searchInsumos(String search) {
    _search = search.isEmpty ? null : search;
    emit(InsumosLoaded(insumos: _applySearch(_allInsumos), search: _search));
  }

  Future<bool> saveInsumo({
    int? id,
    required String nome,
    required double quantidade,
    required InsumoUnidadeMedida unidade,
    required double valorPago,
    double? quantidadeDisponivel,
    double? quantidadeMinima,
  }) async {
    emit(InsumoActionLoading(_applySearch(_allInsumos)));
    try {
      if (id == null) {
        await createInsumo(
          nome: nome,
          quantidade: quantidade,
          unidade: unidade,
          valorPago: valorPago,
          quantidadeDisponivel: quantidadeDisponivel,
          quantidadeMinima: quantidadeMinima,
        );
      } else {
        await updateInsumo(
          id: id,
          nome: nome,
          quantidade: quantidade,
          unidade: unidade,
          valorPago: valorPago,
          quantidadeDisponivel: quantidadeDisponivel,
          quantidadeMinima: quantidadeMinima,
        );
      }

      _allInsumos = await getInsumos();
      final visibleInsumos = _applySearch(_allInsumos);
      emit(
        InsumoActionSuccess(
          insumos: visibleInsumos,
          message: id == null
              ? 'Insumo criado com sucesso!'
              : 'Insumo atualizado com sucesso!',
        ),
      );
      return true;
    } catch (e) {
      emit(
        InsumoActionError(
          insumos: _applySearch(_allInsumos),
          message: e.toString(),
        ),
      );
      return false;
    }
  }

  /*
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
  */

  Future<void> removeInsumo(int id) async {
    emit(InsumoActionLoading(_applySearch(_allInsumos)));
    try {
      await deleteInsumo(id);
      _allInsumos = await getInsumos();
      emit(
        InsumoActionSuccess(
          insumos: _applySearch(_allInsumos),
          message: 'Insumo excluido com sucesso!',
        ),
      );
    } catch (e) {
      emit(
        InsumoActionError(
          insumos: _applySearch(_allInsumos),
          message: e.toString(),
        ),
      );
    }
  }

  List<Insumo> _applySearch(List<Insumo> insumos) {
    final search = _search?.toLowerCase();
    if (search == null || search.isEmpty) return insumos;

    return insumos
        .where((insumo) => insumo.nome.toLowerCase().contains(search))
        .toList();
  }
}
