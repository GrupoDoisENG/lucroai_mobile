class ApiConstants {
  // Android emulator: 10.0.2.2 = host (localhost da máquina).
  // Em web/desktop troque para 'localhost'.
  static const String authBaseUrl       = 'http://10.0.2.2:3001';
  static const String catalogBaseUrl    = 'http://10.0.2.2:3002';
  static const String recipeBaseUrl     = 'http://10.0.2.2:3003';
  static const String operationsBaseUrl = 'http://10.0.2.2:3004';
  static const String salesBaseUrl      = 'http://10.0.2.2:3005';

  static const String insumos  = '/insumos';
  static const String receitas = '/receitas';
  static const String vendas   = '/vendas';

  static String vendaStatus(int id)   => '/vendas/$id/status';
  static String insumoById(int id)    => '/insumos/$id';
  static String receitaById(int id)         => '/receitas/$id';
  static String receitaSimular(int id)      => '/receitas/$id/simular';

  static const String gastosIndiretos       = '/gastos-indiretos';
  static String gastoIndiretoPorId(int id)  => '/gastos-indiretos/$id';
  static const String vendasDashboard = '/vendas/dashboard';

  static String estoqueByInsumoId(String insumoId) =>
      '/estoque/insumos/$insumoId';

  static String estoqueEntradaByInsumoId(String insumoId) =>
      '/estoque/insumos/$insumoId/entrada';

  static String estoqueMovimentacoesByInsumoId(String insumoId) =>
      '/estoque/insumos/$insumoId/movimentacoes';

  static const String producoes = '/producoes';
}
