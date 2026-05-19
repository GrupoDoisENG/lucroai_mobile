import 'package:flutter/foundation.dart';

class ApiConstants {
  static const String _baseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  static const int defaultEmpresaId = int.fromEnvironment(
    'EMPRESA_ID',
    defaultValue: 1,
  );

  static String get baseUrl {
    if (_baseUrlOverride.isNotEmpty) return _baseUrlOverride;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  static const String insumos = '/insumos';
  static String insumoById(String id) => '/insumos/$id';

  static String estoqueByInsumoId(String insumoId) =>
      '/estoque/insumos/$insumoId';
  static String estoqueEntradaByInsumoId(String insumoId) =>
      '/estoque/insumos/$insumoId/entrada';
  static String estoqueMovimentacoesByInsumoId(String insumoId) =>
      '/estoque/insumos/$insumoId/movimentacoes';
}
