import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/auth/auth_session.dart';
import 'core/di/injection_container.dart';
import 'features/estoques/presentation/cubit/estoques_cubit.dart';
import 'features/insumos/presentation/cubit/insumos_cubit.dart';

// Importando a nossa Tela Base (com a Nav Bar) direto da pasta core oficial
import 'core/presentation/pages/main_screen.dart';
import 'features/auth/data/auth_remote_datasource.dart';
import 'features/auth/presentation/pages/login_page.dart';

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
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE85D33),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      // O BlocProvider envolve a MainScreen, garantindo que o estado de Insumos
      // esteja disponível quando a MainScreen puxar a InsumosPage.
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Future<void> _login(String email, String senha) async {
    final token = await sl<AuthRemoteDatasource>().login(
      email: email,
      senha: senha,
    );
    AuthSession.start(token);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthSession.isAuthenticated) {
      return LoginPage(onLogin: _login);
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<InsumosCubit>()),
        BlocProvider(create: (_) => sl<EstoquesCubit>()),
      ],
      child: const MainScreen(),
    );
  }
}
