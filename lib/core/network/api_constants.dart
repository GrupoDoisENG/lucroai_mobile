import 'package:flutter/foundation.dart';

class ApiConstants {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'http://10.0.2.2:3000',
      _ => 'http://localhost:3000',
    };
  }

  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String insumos = '/insumos';

  static String insumoById(int id) => '/insumos/$id';
}
