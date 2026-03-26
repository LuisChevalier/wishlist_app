import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../viewmodels/wishlist_viewmodel.dart';
import '../core/logger_service.dart';

/// Proveedor para inyectar AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
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
  final AuthService _authService;
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
  Future<void> login(String username, String password) async {
    state = AuthState(isLoading: true, currentUser: state.currentUser);
    try {
      await _authService.login(username, password);
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

  /// Prepara la base de datos de Hive para el usuario dado y actualiza la lista de deseos
  Future<void> _initUserDatabase(String username) async {
    final dbService = _ref.read(databaseServiceProvider);
    await dbService.init(username);
    // Invalidamos el provider de la wishlist para que se recargue con los datos del nuevo box
    _ref.invalidate(wishlistViewModelProvider);
    state = AuthState(isLoading: false, currentUser: username);
  }
}

/// Proveedor de Riverpod del AuthViewModel
final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthViewModel(authService, ref);
});
