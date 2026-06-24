class ApiConstants {
  static const String authBaseUrl       = 'http://localhost:3001';
  static const String catalogBaseUrl    = 'http://localhost:3002';
  static const String recipeBaseUrl     = 'http://localhost:3003';
  static const String operationsBaseUrl = 'http://localhost:3004';
  static const String salesBaseUrl      = 'http://localhost:3005';

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
