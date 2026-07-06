import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/presentation/auth_controller.dart';
import '../features/auth/presentation/login_page.dart';
import 'app_shell.dart';
import 'theme.dart';

class SistemaEfApp extends ConsumerWidget {
  const SistemaEfApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    Widget home;
    switch (auth.status) {
      case AuthStatus.bootstrapping:
        home = const _BootstrapScreen();
        break;
      case AuthStatus.unauthenticated:
        home = const LoginPage();
        break;
      case AuthStatus.authenticated:
        home = const AppShell();
        break;
    }

    return MaterialApp(
      title: 'SistemaEF Mobile',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: home,
    );
  }
}

class _BootstrapScreen extends StatelessWidget {
  const _BootstrapScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
