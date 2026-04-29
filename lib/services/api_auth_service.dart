import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/logger_service.dart';

/// Servicio de Autenticación mediante API REST (Node.js).
/// Remplaza el antiguo AuthService local de Hive por peticiones reales al servidor.
class ApiAuthService {
  final Dio _dio = Dio(BaseOptions(
    // IP local de la laptop en la red WiFi. El móvil y la laptop deben estar en la misma red.
    // Para emulador Android usar: http://10.0.2.2:3000/api
    baseUrl: 'http://192.168.0.14:3000/api',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // Instancia del almacenamiento seguro del sistema (Keychain/Keystore/Credential Manager)
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Claves bajo las que guardamos el token y el nombre de usuario en SecureStorage
  static const String _tokenKey = 'auth_token';
  static const String _userKey  = 'current_user';

  // ─── Token en memoria de sesión ───────────────────────────────────────────
  // El JWT siempre se almacena temporalmente para las peticiones del ciclo actual.
  // rememberMe decide si persiste al reiniciar la app.
  String? _sessionToken;

  /// Inicialización del servicio: no requiere operaciones asíncronas pesadas.
  Future<void> init() async {
    LoggerService.i('ApiAuthService inicializado');
  }

  /// Inicia sesión (o registra automáticamente si el user no existe) comunicando con el backend.
  Future<void> login(String username, String password, {bool rememberMe = false}) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'username': username,
        'password': password,
      });

      final token = response.data['token'] as String;
      _sessionToken = token; // Siempre guardamos en memoria para peticiones inmediatas

      if (rememberMe) {
        // Con "Recuérdame": guardamos token y usuario en almacenamiento seguro → sobrevive reinicios
        await _secureStorage.write(key: _tokenKey, value: token);
        await _secureStorage.write(key: _userKey, value: username);
        LoggerService.i('Login exitoso con persistencia activada para: $username');
      } else {
        // Sin "Recuérdame": borramos cualquier sesión previa persistida, solo usamos la memoria
        await _secureStorage.delete(key: _tokenKey);
        await _secureStorage.delete(key: _userKey);
        LoggerService.i('Login exitoso sin persistencia: $username');
      }

    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // El usuario no existe: lo registramos automáticamente (comportamiento original de Hive)
        LoggerService.w('Usuario no encontrado. Intentando registro automático...');
        await _registerAndLogin(username, password, rememberMe);
      } else {
        throw Exception(e.response?.data['error'] ?? 'Error de conexión con el servidor');
      }
    }
  }

  Future<void> _registerAndLogin(String username, String password, bool rememberMe) async {
    try {
      await _dio.post('/auth/register', data: {
        'username': username,
        'password': password,
      });
      LoggerService.i('Nuevo usuario registrado en el servidor: $username');
      await login(username, password, rememberMe: rememberMe);
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Error al registrar usuario en el servidor');
    }
  }

  /// Cierra sesión: borra todo (memoria y almacenamiento persistente).
  Future<void> logout() async {
    _sessionToken = null;
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _userKey);
    LoggerService.i('Sesión cerrada. Token eliminado.');
  }

  /// Devuelve el usuario persistido SOLO si hay también un token guardado (rememberMe activo).
  /// Si no hay token, aunque haya usuario, devuelve null → el usuario debe hacer login de nuevo.
  Future<String?> getCurrentUser() async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) return null; // Sin token no hay sesión válida

    final username = await _secureStorage.read(key: _userKey);
    if (username != null) {
      _sessionToken = token; // Restaurar el token en memoria para las peticiones de API
      LoggerService.i('Sesión restaurada para: $username');
    }
    return username;
  }

  /// Obtiene el token JWT activo (en memoria o del SecureStorage si hay sesión persistida).
  Future<String?> getToken() async {
    return _sessionToken ?? await _secureStorage.read(key: _tokenKey);
  }
}

