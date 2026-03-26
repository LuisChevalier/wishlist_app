import 'package:hive_flutter/hive_flutter.dart';
import '../models/wishlist_item.dart';
import '../models/priority.dart';
import '../core/logger_service.dart';

/// Protocolo (Interfaz) para el servicio de base de datos de la Wishlist.
/// Al abstraerlo, podríamos cambiar de Hive a SQLite o Firebase en el futuro sin gran fricción.
abstract class DatabaseService {
  /// Inicializa la conexión a la base de datos específica del usuario.
  Future<void> init(String userId);

  /// Obtiene todos los ítems actuales en la lista del usuario.
  List<WishlistItem> getItems();

  /// Guarda o actualiza un ítem en la base de datos.
  Future<void> saveItem(WishlistItem item);

  /// Elimina un ítem dado su ID único.
  Future<void> deleteItem(String id);
}

/// Implementación concreta de [DatabaseService] que usa Hive como motor local NoSQL.
class HiveWishlistService implements DatabaseService {
  late Box<WishlistItem> _box;

  @override
  Future<void> init(String userId) async {
    final boxName = 'wishlist_box_$userId';
    
    // Si la caja ya estaba abierta (por un cambio de sesión rápido sin reiniciar),
    // comprobamos si coincide, si no, cerramos la anterior o abrimos la nueva.
    if (Hive.isBoxOpen(boxName)) {
      _box = Hive.box<WishlistItem>(boxName);
      LoggerService.i('Caja previamente abierta reanudada: $boxName');
    } else {
      _box = await Hive.openBox<WishlistItem>(boxName);
      LoggerService.i('Caja de Hive principal abierta: $boxName');
    }

    if (_box.isEmpty) {
      LoggerService.i('La caja de $userId está vacía. Añadiendo datos de demostración.');
      // Add demo data on first launch
      final demo1 = WishlistItem(
        name: 'MacBook Pro',
        priority: Priority.necessity,
        price: 1999.0,
        purchaseLocation: 'Apple Store',
        expectedDate: DateTime.now().add(const Duration(days: 30)),
        notes: 'Chip M3 Pro, 18GB RAM - Fundamental para trabajo',
      );
      final demo2 = WishlistItem(
        name: 'Sony WH-1000XM5',
        priority: Priority.niceToHave,
        price: 279.0,
        purchaseLocation: 'Amazon',
        expectedDate: DateTime.now().add(const Duration(days: 60)),
        notes: 'Cancelación de ruido espectacular para la oficina',
      );
      await _box.put(demo1.id, demo1);
      await _box.put(demo2.id, demo2);
    }
  }

  @override
  List<WishlistItem> getItems() {
    LoggerService.d('Recuperando ${_box.length} ítems de la BD local.');
    return _box.values.toList();
  }

  @override
  Future<void> saveItem(WishlistItem item) async {
    LoggerService.d('Guardando ítem: ${item.name} (ID: ${item.id})');
    await _box.put(item.id, item);
  }

  @override
  Future<void> deleteItem(String id) async {
    LoggerService.w('Eliminando ítem con ID: $id');
    await _box.delete(id);
  }
}
