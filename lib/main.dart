import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection_container.dart';
import 'features/insumos/presentation/cubit/insumos_cubit.dart';

// Importando a nossa Tela Base (com a Nav Bar) direto da pasta core oficial
import 'core/presentation/pages/main_screen.dart';

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
        // Configurando o Dark Mode com o Laranja do protótipo
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE85D33),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      // O BlocProvider envolve a MainScreen, garantindo que o estado de Insumos
      // esteja disponível quando a MainScreen puxar a InsumosPage.
      home: BlocProvider(
        create: (_) => sl<InsumosCubit>(),
        child: const MainScreen(),
      ),
    );
  }
}