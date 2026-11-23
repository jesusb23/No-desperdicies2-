import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'screens/inicio_screen.dart';
import 'screens/login_screen.dart';
import 'services/alimento_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const NoDesperdiciesApp());
}

class NoDesperdiciesApp extends StatelessWidget {
  const NoDesperdiciesApp({super.key});

  @override
  Widget build(BuildContext context) {
    const verde = Color(0xFF159957);

    return MaterialApp(
      title: 'No Desperdicies',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: verde, primary: verde),
        scaffoldBackgroundColor: const Color(0xFFF8FAF8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8FAF8),
          foregroundColor: Color(0xFF18352A),
          elevation: 0,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: verde,
          foregroundColor: Colors.white,
        ),
      ),
      // Si hay sesión iniciada muestra la app; si no, el login.
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final usuario = snapshot.data;
          if (usuario == null) return const LoginScreen();

          // La key hace que al cambiar de usuario se cree un servicio nuevo.
          return _SesionIniciada(key: ValueKey(usuario.uid), uid: usuario.uid);
        },
      ),
    );
  }
}

/// Crea el servicio de alimentos del usuario que inició sesión.
class _SesionIniciada extends StatefulWidget {
  final String uid;

  const _SesionIniciada({super.key, required this.uid});

  @override
  State<_SesionIniciada> createState() => _SesionIniciadaState();
}

class _SesionIniciadaState extends State<_SesionIniciada> {
  late final AlimentoService _servicio;

  @override
  void initState() {
    super.initState();
    _servicio = AlimentoService(uid: widget.uid);
  }

  @override
  void dispose() {
    _servicio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InicioScreen(servicio: _servicio);
  }
}
