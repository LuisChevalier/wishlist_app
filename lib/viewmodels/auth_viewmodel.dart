import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_auth_service.dart';
import '../services/database_service.dart';
import '../viewmodels/wishlist_viewmodel.dart';
import '../core/logger_service.dart';

/// Proveedor para inyectar ApiAuthService
final apiAuthServiceProvider = Provider<ApiAuthService>((ref) {
  return ApiAuthService();
});

/// Estado de autenticación para representar si hay sesión activa, error o estamos cargando
class AuthState {
  final bool isLoading;
  final String? currentUser;
  final String? error;

  AuthState({this.isLoading = true, this.currentUser, this.error});
}

/// ViewModel encargado de gestionar el flujo de usuarios con contraseñas.
class AuthViewModel extends StateNotifier<AuthState> {
  final ApiAuthService _authService;
  final Ref _ref;

  AuthViewModel(this._authService, this._ref) : super(AuthState(isLoading: true)) {
    _checkLoginStatus();
  }

  /// Verifica en local si ya existe un usuario recordado, e inicializa el Hive box de Auth
  Future<void> _checkLoginStatus() async {
    try {
      await _authService.init();
      final user = await _authService.getCurrentUser();
      if (user != null && user.isNotEmpty) {
        // Iniciar BD para este usuario y setear estado
        await _initUserDatabase(user);
      } else {
        state = AuthState(isLoading: false, currentUser: null);
      }
    } catch (e) {
      LoggerService.e('Error crítico al inicializar el servicio de autenticación', error: e);
      state = AuthState(isLoading: false, currentUser: null, error: 'Fallo al inicializar base de datos.');
    }
  }

  /// Inicia sesión con el nombre de usuario y contraseña
  Future<void> login(String username, String password, {bool rememberMe = false}) async {
    state = AuthState(isLoading: true, currentUser: state.currentUser);
    try {
      await _authService.login(username, password, rememberMe: rememberMe);
      await _initUserDatabase(username);
    } catch (e) {
      state = AuthState(isLoading: false, currentUser: null, error: e.toString());
      rethrow; // Lanzamos la excepción para que el UI pueda reaccionar al instante
    }
  }

  /// Cierra sesión del usuario
  Future<void> logout() async {
    state = AuthState(isLoading: true, currentUser: state.currentUser);
    await _authService.logout();
    state = AuthState(isLoading: false, currentUser: null);
  }

  /// Prepara el servicio de datos para el usuario dado y actualiza la lista de deseos mediante la API.
  Future<void> _initUserDatabase(String username) async {
    final dbService = _ref.read(databaseServiceProvider);

    // Inicializamos el servicio (el ApiDatabaseService hace una llamada a la API aquí)
    await dbService.init(username);

    // Invalidar el provider fuerza una nueva creación del WishlistViewModel con el servicio actualizado
    _ref.invalidate(wishlistViewModelProvider);

    // Disparamos una recarga desde el servidor para llenar la UI con los datos reales
    await _ref.read(wishlistViewModelProvider.notifier).refreshFromServer();

    state = AuthState(isLoading: false, currentUser: username);
  }
}

/// Proveedor de Riverpod del AuthViewModel
final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  final authService = ref.watch(apiAuthServiceProvider);
  return AuthViewModel(authService, ref);
});
