import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wishlist_item.dart';
import '../models/sort_option.dart';
import '../models/priority.dart';
import '../services/database_service.dart';
import '../services/api_database_service.dart';
import 'auth_viewmodel.dart';

/// Proveedor de Riverpod que inyecta la implementación de DB basada en API REST.
/// El ApiDatabaseService usa Dio + SecureStorage en lugar de Hive local.
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  final authService = ref.watch(apiAuthServiceProvider);
  return ApiDatabaseService(authService);
});

class WishlistState {
  final List<WishlistItem> items;
  final SortOption sortOption;
  final bool showPurchased;

  WishlistState({
    required this.items,
    this.sortOption = SortOption.priority,
    this.showPurchased = true,
  });

  WishlistState copyWith({
    List<WishlistItem>? items,
    SortOption? sortOption,
    bool? showPurchased,
  }) {
    return WishlistState(
      items: items ?? this.items,
      sortOption: sortOption ?? this.sortOption,
      showPurchased: showPurchased ?? this.showPurchased,
    );
  }

  // Derived getters for stats
  int get totalItems => filteredItems.length;
  double get estimatedCost => filteredItems.where((i) => !i.isPurchased).fold(0, (sum, i) => sum + i.price);
  int get necessityCount => filteredItems.where((i) => i.priority == Priority.necessity).length;
  int get niceToHaveCount => filteredItems.where((i) => i.priority == Priority.niceToHave).length;
  int get nonRelevantCount => filteredItems.where((i) => i.priority == Priority.nonRelevant).length;

  List<WishlistItem> get filteredItems {
    var filtered = items.where((i) => showPurchased || !i.isPurchased).toList();
    filtered.sort((a, b) {
      switch (sortOption) {
        case SortOption.priority:
          return a.priority.index.compareTo(b.priority.index);
        case SortOption.date:
          return a.expectedDate.compareTo(b.expectedDate);
        case SortOption.priceAsc:
          return a.price.compareTo(b.price);
        case SortOption.priceDesc:
          return b.price.compareTo(a.price);
        case SortOption.name:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case SortOption.recent:
          return b.createdAt.compareTo(a.createdAt);
      }
    });
    return filtered;
  }
}

class WishlistViewModel extends StateNotifier<WishlistState> {
  final DatabaseService _dbService;

  WishlistViewModel(this._dbService) : super(WishlistState(items: [])) {
    // La carga inicial es síncrona desde la caché del servicio.
    // La primera carga real desde el servidor la dispara auth_viewmodel.dart al hacer init().
    _loadItems();
  }

  void _loadItems() {
    // Leer desde la caché en memoria del ApiDatabaseService
    final items = _dbService.getItems();
    state = state.copyWith(items: items);
  }

  /// Recarga los ítems desde el servidor y actualiza el estado de la UI.
  /// Se llama tras el init() del AuthViewModel para obtener los datos reales.
  Future<void> refreshFromServer() async {
    if (_dbService is ApiDatabaseService) {
      await (_dbService as ApiDatabaseService).fetchItemsFromServer();
    }
    _loadItems();
  }

  Future<void> addItem(WishlistItem item) async {
    await _dbService.saveItem(item);
    _loadItems();
  }

  Future<void> updateItem(WishlistItem item) async {
    await _dbService.saveItem(item);
    _loadItems();
  }

  Future<void> deleteItem(String id) async {
    await _dbService.deleteItem(id);
    _loadItems();
  }

  Future<void> togglePurchased(String id) async {
    final itemsMatch = state.items.where((i) => i.id == id);
    if (itemsMatch.isEmpty) return;
    final item = itemsMatch.first;
    final updated = item.copyWith(isPurchased: !item.isPurchased);
    await updateItem(updated);
  }

  void setSortOption(SortOption option) {
    state = state.copyWith(sortOption: option);
  }

  void toggleShowPurchased(bool show) {
    state = state.copyWith(showPurchased: show);
  }
}

final wishlistViewModelProvider = StateNotifierProvider<WishlistViewModel, WishlistState>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return WishlistViewModel(dbService);
});
