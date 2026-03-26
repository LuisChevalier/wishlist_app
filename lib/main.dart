import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme.dart';
import 'core/logger_service.dart';
import 'models/wishlist_item.dart';
import 'models/priority.dart';
import 'services/database_service.dart';
import 'viewmodels/wishlist_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'views/screens/home_screen.dart';
import 'views/screens/login_screen.dart';

import 'core/sound_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  
  // Register adapters that will be generated
  Hive.registerAdapter(WishlistItemAdapter());
  Hive.registerAdapter(PriorityAdapter());
  
  LoggerService.i('Inicializando aplicación Riverpod & Hive...');

  final dbService = HiveWishlistService();

  await initializeDateFormatting('es', null);

  // Iniciar el servicio de sonido de forma global al arrancar
  soundService.startBackgroundMusic();

  runApp(
    ProviderScope(
      overrides: [
        databaseServiceProvider.overrideWithValue(dbService),
      ],
      child: const WishlistApp(),
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
