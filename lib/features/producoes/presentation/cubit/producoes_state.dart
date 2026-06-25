import 'package:equatable/equatable.dart';

import '../../../../features/gastos_indiretos/domain/entities/gasto_indireto.dart';
import '../../../../features/receitas/domain/entities/receita.dart';
import '../../domain/entities/producao.dart';

enum ProducoesStatus { initial, loading, success, error }

class ProducoesState extends Equatable {
  final List<Producao> producoes;
  final List<Receita> receitas;
  final List<GastoIndireto> gastosIndiretos;
  final ProducoesStatus status;
  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;

  const ProducoesState({
    required this.producoes,
    required this.receitas,
    required this.gastosIndiretos,
    required this.status,
    required this.isSubmitting,
    this.errorMessage,
    this.successMessage,
  });

  factory ProducoesState.initial() => const ProducoesState(
        producoes: [],
        receitas: [],
        gastosIndiretos: [],
        status: ProducoesStatus.initial,
        isSubmitting: false,
      );

  ProducoesState copyWith({
    List<Producao>? producoes,
    List<Receita>? receitas,
    List<GastoIndireto>? gastosIndiretos,
    ProducoesStatus? status,
    bool? isSubmitting,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return ProducoesState(
      producoes: producoes ?? this.producoes,
      receitas: receitas ?? this.receitas,
      gastosIndiretos: gastosIndiretos ?? this.gastosIndiretos,
      status: status ?? this.status,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearMessages ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        producoes,
        receitas,
        gastosIndiretos,
        status,
        isSubmitting,
        errorMessage,
        successMessage,
      ];
}
