import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection_container.dart';
import 'features/insumos/presentation/cubit/insumos_cubit.dart';
import 'features/insumos/presentation/pages/app_shell_page.dart';

void main() {
  initDependencies();
  runApp(const LucroAiApp());
}

class LucroAiApp extends StatelessWidget {
  const LucroAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LucroAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF050505),
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF6B3D),
          secondary: Color(0xFFFF6B3D),
          surface: Color(0xFF111111),
        ),
      ),
      home: BlocProvider(
        create: (_) => sl<InsumosCubit>(),
        child: const AppShellPage(),
      ),
    );
  }
}