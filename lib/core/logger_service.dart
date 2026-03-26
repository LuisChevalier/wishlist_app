import 'package:logger/logger.dart';

/// Servicio centralizado de Logger para toda la aplicación.
/// Este Singleton asegura que usemos la misma configuración de trazabilidad
/// en todos lados. Útil para entornos de desarrollo y producción.
class LoggerService {
  LoggerService._(); // Constructor privado
  static final LoggerService _instance = LoggerService._();
  factory LoggerService() => _instance;

  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0, // No imprimir llamadas al método para no saturar consola
      errorMethodCount: 5, // Imprimir rastros de error
      lineLength: 80, // Ancho de la línea
      colors: true, // Colores en la terminal
      printEmojis: true, // Imprimir emojis pertinentes al nivel (ℹ️, ⚠️, ❌)
      printTime: false // No es necesario si la consola del IDE ya lo marca
    ),
  );

  /// Registra un mensaje de nivel DEBUG, ideal para trazar valores de variables.
  static void d(dynamic message) {
    _instance._logger.d(message);
  }

  /// Registra un mensaje de nivel INFO, útil para eventos generales de la app.
  static void i(dynamic message) {
    _instance._logger.i(message);
  }

  /// Registra un mensaje de nivel WARNING para posibles problemas o situaciones anómalas sin llegar a fallar.
  static void w(dynamic message) {
    _instance._logger.w(message);
  }

  /// Registra un error crítico o excepción capturada.
  static void e(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    _instance._logger.e(message, error: error, stackTrace: stackTrace);
  }
}
