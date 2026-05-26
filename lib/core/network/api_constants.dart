class ApiConstants {
  static const String baseUrl = 'http://localhost:3000';
  static const String insumos = '/insumos';
  static const String receitas = '/receitas';
  static const String vendas = '/vendas';

  static String insumoById(int id) => '/insumos/$id';
  static String receitaById(int id) => '/receitas/$id';
  static String vendasDashboard = '/vendas/dashboard';
}
