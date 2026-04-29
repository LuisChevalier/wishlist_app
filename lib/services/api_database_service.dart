import 'package:dio/dio.dart';
import '../models/wishlist_item.dart';
import '../core/logger_service.dart';
import 'database_service.dart';
import 'api_auth_service.dart';

/// Implementación del DatabaseService conectándose a la API REST.
class ApiDatabaseService implements DatabaseService {
  final ApiAuthService _authService;
  late Dio _dio;
  
  // Caché en memoria para evitar llamadas redundantes de UI si la arquitectura original de Hive lo requería de forma síncrona
  List<WishlistItem> _cachedItems = [];

  ApiDatabaseService(this._authService) {
    _dio = Dio(BaseOptions(
      // IP local de la laptop en la red WiFi. El móvil y la laptop deben estar en la misma red.
    // Para emulador Android usar: http://10.0.2.2:3000/api
    baseUrl: 'http://192.168.0.14:3000/api',
      connectTimeout: const Duration(seconds: 10),
    ));

    // Agregar un Interceptor para inyectar automáticamente el JWT a todas las peticiones
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _authService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  @override
  Future<void> init(String userId) async {
    LoggerService.i('ApiDatabaseService inicializado para carga de datos de: $userId');
    await fetchItemsFromServer();
  }

  /// Trae los ítems desde el backend y actualiza la caché local
  Future<void> fetchItemsFromServer() async {
    try {
      final response = await _dio.get('/wishlist');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _cachedItems = data.map((json) => WishlistItem.fromJson(json)).toList();
        LoggerService.i('Se obtuvieron ${_cachedItems.length} deseos de la API');
      }
    } on DioException catch (e) {
      LoggerService.e('Error al hacer pull de wishlist', error: e.response?.data ?? e.message);
      // Podríamos manejar lógica offline aquí en el futuro
    }
  }

  @override
  List<WishlistItem> getItems() {
    // La interfaz original de DatabaseService requiere devolver sincronamente la lista
    // Por eso usamos nuestra caché mapeada
    return List.unmodifiable(_cachedItems);
  }

  @override
  Future<void> saveItem(WishlistItem item) async {
    try {
      // Determinar si es un CREATE o un UPDATE en base a si el ID huele a nuevo
      // En nuestra app anterior los ID se generaban con UUID localmente
      final exists = _cachedItems.any((e) => e.id == item.id);
      
      if (exists) {
        // UPDATE
        await _dio.put('/wishlist/${item.id}', data: item.toJson());
        
        // Actualizar caché
        final index = _cachedItems.indexWhere((e) => e.id == item.id);
        if (index != -1) _cachedItems[index] = item;
        
        LoggerService.d('Ítem actualizado en API: ${item.name}');
      } else {
        // CREATE
        // En Prisma el nombre real de campo completado es "isPurchased"
        final response = await _dio.post('/wishlist', data: item.toJson());
        // Es mejor reemplazar el ID local por el ID real autogenerado de CUID si corresponde (aquí simplemente reemplazamos con la versión del server)
        final serverItem = WishlistItem.fromJson(response.data);
        _cachedItems.insert(0, serverItem);
        
        LoggerService.d('Ítem creado en API: ${item.name}');
      }
    } on DioException catch (e) {
      LoggerService.e('Error guardando ítem', error: e.response?.data ?? e.message);
      rethrow;
    }
  }

  @override
  Future<void> deleteItem(String id) async {
    try {
      await _dio.delete('/wishlist/$id');
      _cachedItems.removeWhere((item) => item.id == id);
      LoggerService.w('Ítem $id eliminado de la API');
    } on DioException catch (e) {
      LoggerService.e('Error eliminando ítem', error: e.response?.data ?? e.message);
      rethrow;
    }
  }
}
