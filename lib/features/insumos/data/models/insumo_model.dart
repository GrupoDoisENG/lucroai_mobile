import '../../../../core/network/api_constants.dart';
import '../../../../core/auth/auth_session.dart';
import '../../domain/entities/insumo.dart';

class InsumoModel extends Insumo {
  const InsumoModel({
    required super.id,
    required super.nome,
    super.descricao,
    required super.categoria,
    required super.unidadeMedida,
    required super.precoUnitario,
    required super.estoqueMinimo,
    required super.ativo,
    required super.criadoEm,
    required super.atualizadoEm,
  });

  factory InsumoModel.fromJson(Map<String, dynamic> json) {
    final unidade = (json['unidade'] ?? json['unidade_medida'] ?? 'UN')
        .toString()
        .toLowerCase();
    final dataCriacao = json['dataCriacao'] ?? json['criado_em'];

    return InsumoModel(
      id: json['id'].toString(),
      nome: json['nome'] as String,
      descricao: json['descricao'] as String?,
      categoria: json['categoria'] != null
          ? InsumoCategoria.fromValue(json['categoria'] as String)
          : InsumoCategoria.materiaPrima,
      unidadeMedida: InsumoUnidadeMedida.fromValue(unidade),
      precoUnitario: double.parse(
        (json['preco_unitario'] ??
                json['precoUnitario'] ??
                json['custoUnitario'])
            .toString(),
      ),
      estoqueMinimo: double.parse(
        (json['estoque_minimo'] ?? json['quantidadeDisponivel'] ?? 0)
            .toString(),
      ),
      ativo: json['ativo'] as bool? ?? true,
      criadoEm: DateTime.parse(dataCriacao as String),
      atualizadoEm: DateTime.parse(
        (json['atualizado_em'] ?? dataCriacao) as String,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'empresaId': AuthSession.empresaId ?? ApiConstants.defaultEmpresaId,
      'nome': nome,
      'quantidadeBaseCusto': 1,
      'quantidadeDisponivelInicial': estoqueMinimo,
      'unidade': _toBackendUnidade(unidadeMedida),
      'valorPago': precoUnitario,
    };
  }

  static Map<String, dynamic> toJsonCreate({
    required String nome,
    String? descricao,
    required InsumoCategoria categoria,
    required InsumoUnidadeMedida unidadeMedida,
    required double precoUnitario,
    required double estoqueMinimo,
  }) {
    return {
      'empresaId': AuthSession.empresaId ?? ApiConstants.defaultEmpresaId,
      'nome': nome,
      'quantidadeBaseCusto': 1,
      'quantidadeDisponivelInicial': estoqueMinimo,
      'unidade': _toBackendUnidade(unidadeMedida),
      'valorPago': precoUnitario,
    };
  }

  static Map<String, dynamic> toJsonUpdate({
    String? nome,
    String? descricao,
    InsumoCategoria? categoria,
    InsumoUnidadeMedida? unidadeMedida,
    double? precoUnitario,
    double? estoqueMinimo,
    bool? ativo,
  }) {
    return {
      if (nome != null) 'nome': nome,
      if (unidadeMedida != null) 'unidade': _toBackendUnidade(unidadeMedida),
      if (precoUnitario != null) 'valorPago': precoUnitario,
      if (precoUnitario != null) 'quantidadeBaseCusto': 1,
    };
  }

  static String _toBackendUnidade(InsumoUnidadeMedida unidade) {
    return switch (unidade) {
      InsumoUnidadeMedida.g => 'G',
      InsumoUnidadeMedida.kg => 'KG',
      InsumoUnidadeMedida.ml => 'ML',
      InsumoUnidadeMedida.l => 'L',
      InsumoUnidadeMedida.un => 'UN',
      _ => 'UN',
    };
  }
}
