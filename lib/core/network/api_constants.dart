class ApiConstants {
  static const String baseUrl = 'http://localhost:3000';
  static const String insumos = '/insumos';
  static const String receitas = '/receitas';

  static String insumoById(String id) => '/insumos/$id';
  static String receitaById(String id) => '/receitas/$id';
}
