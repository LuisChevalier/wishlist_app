import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme.dart';
import 'core/logger_service.dart';
import 'core/sound_service.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'views/screens/home_screen.dart';
import 'views/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializamos el formato de fechas en español
  await initializeDateFormatting('es', null);

  LoggerService.i('Inicializando aplicación con backend API REST...');

  // Iniciar el servicio de sonido de forma global al arrancar
  soundService.startBackgroundMusic();

  runApp(
    // ProviderScope es el contenedor raíz de Riverpod.
    // Ya no se necesita override: ApiDatabaseService se inyecta automáticamente.
    const ProviderScope(
      child: WishlistApp(),
    ),
  );
}

class WishlistApp extends ConsumerWidget {
  const WishlistApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);

    return MaterialApp(
      title: 'Wishlist App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: authState.isLoading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : (authState.currentUser != null ? const HomeScreen() : const LoginScreen()),
      debugShowCheckedModeBanner: false,
    );
  }
}
