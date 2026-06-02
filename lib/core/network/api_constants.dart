class ApiConstants {
  static const String baseUrl = 'http://localhost:3000';

  static const String insumos = '/insumos';
  static const String receitas = '/receitas';
  static const String vendas = '/vendas';

  static const int defaultEmpresaId = 1;

  static String insumoById(int id) => '/insumos/$id';
  static String receitaById(int id) => '/receitas/$id';
  static const String vendasDashboard = '/vendas/dashboard';

  static String estoqueByInsumoId(String insumoId) =>
      '/estoque/insumos/$insumoId';

  static String estoqueEntradaByInsumoId(String insumoId) =>
      '/estoque/insumos/$insumoId/entrada';

  static String estoqueMovimentacoesByInsumoId(String insumoId) =>
      '/estoque/insumos/$insumoId/movimentacoes';
}
