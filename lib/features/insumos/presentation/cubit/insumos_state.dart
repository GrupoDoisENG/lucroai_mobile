import 'package:equatable/equatable.dart';
import '../../domain/entities/insumo.dart';

abstract class InsumosState extends Equatable {
  const InsumosState();

  @override
  List<Object?> get props => [];
}

class InsumosInitial extends InsumosState {
  const InsumosInitial();
}

class InsumosLoading extends InsumosState {
  const InsumosLoading();
}

class InsumosLoaded extends InsumosState {
  final List<Insumo> insumos;
  final bool? filterAtivo;
  final InsumoCategoria? filterCategoria;
  final String? search;

  const InsumosLoaded({
    required this.insumos,
    this.filterAtivo,
    this.filterCategoria,
    this.search,
  });

  @override
  List<Object?> get props => [insumos, filterAtivo, filterCategoria, search];
}

class InsumosError extends InsumosState {
  final String message;

  const InsumosError(this.message);

  @override
  List<Object?> get props => [message];
}

class InsumoActionLoading extends InsumosState {
  final List<Insumo> insumos;

  const InsumoActionLoading(this.insumos);

  @override
  List<Object?> get props => [insumos];
}

class InsumoActionSuccess extends InsumosState {
  final List<Insumo> insumos;
  final String message;

  const InsumoActionSuccess({required this.insumos, required this.message});

  @override
  List<Object?> get props => [insumos, message];
}

class InsumoActionError extends InsumosState {
  final List<Insumo> insumos;
  final String message;

  const InsumoActionError({required this.insumos, required this.message});

  @override
  List<Object?> get props => [insumos, message];
}
