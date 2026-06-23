import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/auth/auth_session.dart';
import 'core/di/injection_container.dart';
import 'core/local/local_datasource.dart';
import 'core/presentation/pages/main_screen.dart';
import 'features/auth/data/auth_remote_datasource.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/estoques/presentation/cubit/estoques_cubit.dart';
import 'features/gastos_indiretos/presentation/cubit/gastos_indiretos_cubit.dart';
import 'features/insumos/presentation/cubit/insumos_cubit.dart';
import 'features/receitas/presentation/cubit/receitas_cubit.dart';
import 'features/vendas/presentation/cubit/vendas_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  initDependencies(prefs: prefs);
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
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF050505),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF6B3D),
          secondary: Color(0xFFFF6B3D),
          surface: Color(0xFF111111),
        ),
      ),
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    AuthSession.onUnauthorized = () {
      sl<LocalDatasource>().clearToken();
      if (mounted) setState(() {});
    };
    _tryRestoreSession();
  }

  @override
  void dispose() {
    AuthSession.onUnauthorized = null;
    super.dispose();
  }

  Future<void> _tryRestoreSession() async {
    final token = await sl<LocalDatasource>().loadToken();
    if (token != null) {
      AuthSession.start(token);
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _login(String email, String senha) async {
    final token = await sl<AuthRemoteDatasource>().login(
      email: email,
      senha: senha,
    );

    await sl<LocalDatasource>().saveToken(token);
    AuthSession.start(token);

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!AuthSession.isAuthenticated) {
      return LoginPage(onLogin: _login);
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<InsumosCubit>()),
        BlocProvider(create: (_) => sl<ReceitasCubit>()),
        BlocProvider(create: (_) => sl<VendasCubit>()),
        BlocProvider(create: (_) => sl<EstoquesCubit>()),
        BlocProvider(create: (_) => sl<GastosIndiretosCubit>()),
      ],
      child: const MainScreen(),
    );
  }
}
