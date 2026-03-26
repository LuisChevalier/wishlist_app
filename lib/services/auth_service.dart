import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/logger_service.dart';

/// Servicio de Autenticación Local.
/// Gestiona la persistencia de la sesión mediante SharedPreferences para 
/// recordar quién fue el último usuario en iniciar sesión en el dispositivo.
/// También almacena las contraseñas de forma local mediante Hive.
class AuthService {
  static const String _userKey = 'current_user';
  static const String _authBoxName = 'users_auth_box';

  /// Inicializa la BD segura o normal donde se guardan los usuarios y contraseñas.
  Future<void> init() async {
    await Hive.openBox<String>(_authBoxName);
  }

  /// Inicia sesión o registra un nuevo usuario si no existe.
  /// Si la contraseña es incorrecta para un usuario existente, lanza una [Exception].
  Future<void> login(String username, String password) async {
    final box = Hive.box<String>(_authBoxName);
    
    // Verificamos si el usuario ya existe en nuestro registro
    if (box.containsKey(username)) {
      final storedPassword = box.get(username);
      if (storedPassword != password) {
        LoggerService.w('Intento fallido de login para el usuario: $username');
        throw Exception('Contraseña incorrecta');
      }
    } else {
      // Registro automático local la primera vez
      await box.put(username, password);
      LoggerService.i('Nuevo usuario registrado localmente: $username');
    }

    // Guardar la sesión actual
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, username);
    LoggerService.i('Usuario logueado exitosamente: $username');
  }

  /// Borra el usuario activo de las preferencias.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    LoggerService.i('Se ha cerrado la sesión del usuario actual.');
  }

  /// Obtiene el usuario activo o `null` si no hay nadie logueado.
  Future<String?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userKey);
  }
}
