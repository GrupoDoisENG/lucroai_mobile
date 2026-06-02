import 'package:equatable/equatable.dart';
import '../../domain/entities/estoque_com_insumo.dart';

abstract class EstoquesState extends Equatable {
  const EstoquesState();

  @override
  List<Object?> get props => [];
}

class EstoquesInitial extends EstoquesState {
  const EstoquesInitial();
}

class EstoquesLoading extends EstoquesState {
  const EstoquesLoading();
}

class EstoquesLoaded extends EstoquesState {
  final List<EstoqueComInsumo> estoques;
  final bool? filterBaixoEstoque;
  final String? search;

  const EstoquesLoaded({
    required this.estoques,
    this.filterBaixoEstoque,
    this.search,
  });

  @override
  List<Object?> get props => [estoques, filterBaixoEstoque, search];
}

class EstoquesError extends EstoquesState {
  final String message;

  const EstoquesError(this.message);

  @override
  List<Object?> get props => [message];
}

class EstoqueActionLoading extends EstoquesState {
  final List<EstoqueComInsumo> estoques;

  const EstoqueActionLoading(this.estoques);

  @override
  List<Object?> get props => [estoques];
}

class EstoqueActionSuccess extends EstoquesState {
  final List<EstoqueComInsumo> estoques;
  final String message;

  const EstoqueActionSuccess({
    required this.estoques,
    required this.message,
  });

  @override
  List<Object?> get props => [estoques, message];
}

class EstoqueActionError extends EstoquesState {
  final List<EstoqueComInsumo> estoques;
  final String message;

  const EstoqueActionError({
    required this.estoques,
    required this.message,
  });

  @override
  List<Object?> get props => [estoques, message];
}
