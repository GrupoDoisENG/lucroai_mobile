class ApiConstants {
  static const String baseUrl = 'http://localhost:3000';
  static const String insumos = '/insumos';
  static const String receitas = '/receitas';
  static const int defaultEmpresaId = 1;

  static String insumoById(String id) => '/insumos/$id';
  static String receitaById(String id) => '/receitas/$id';

  static String estoqueByInsumoId(String insumoId) =>
      '/estoque/insumos/$insumoId';

  static String estoqueEntradaByInsumoId(String insumoId) =>
      '/estoque/insumos/$insumoId/entrada';

  static String estoqueMovimentacoesByInsumoId(String insumoId) =>
      '/estoque/insumos/$insumoId/movimentacoes';
}
