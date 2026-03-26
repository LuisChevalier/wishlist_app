import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../viewmodels/wishlist_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../models/sort_option.dart';
import '../widgets/wishlist_card.dart';
import '../widgets/stats_header.dart';
import '../widgets/empty_state.dart';
import 'add_edit_screen.dart';

/// [HomeScreen] es la pantalla principal o Dashboard del usuario.
/// Proporciona el listado principal de deseos, métricas estadísticas,
/// y opciones de filtrado, ordenado y logout.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escucha el estado completo (lista, stats, etc.) de la wishlist
    final state = ref.watch(wishlistViewModelProvider);
    // Controladores de acciones (sin escuchar cambios constantes para evitar rebuilds)
    final notifier = ref.read(wishlistViewModelProvider.notifier);

    // Escucha el estado de autenticación para desplegar el nombre
    final authState = ref.watch(authViewModelProvider);
    final userName = authState.currentUser ?? '';

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // Usamos un Container como fondo para lograr un gradiente sutil
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.3, 1.0],
            colors: [
              colorScheme.primaryContainer.withOpacity(0.3),
              colorScheme.surface,
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // AppBar moderno y expansible
              SliverAppBar(
                floating: true,
                title: Text('🌟 Wishlist de $userName', style: const TextStyle(fontWeight: FontWeight.w800)),
                actions: [
                  IconButton(
                    icon: Icon(state.showPurchased ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                    tooltip: 'Alternar visualización de compras',
                    onPressed: () => notifier.toggleShowPurchased(!state.showPurchased),
                  ),
                  PopupMenuButton<SortOption>(
                    icon: const Icon(Icons.sort_rounded),
                    tooltip: 'Criterio de Ordenación',
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    onSelected: notifier.setSortOption,
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: SortOption.priority, child: Text('Más Prioritarios')),
                      PopupMenuItem(value: SortOption.date, child: Text('Fecha Cercana')),
                      PopupMenuItem(value: SortOption.priceAsc, child: Text('Precio: Menor a Mayor')),
                      PopupMenuItem(value: SortOption.priceDesc, child: Text('Precio: Mayor a Menor')),
                      PopupMenuItem(value: SortOption.name, child: Text('Alfabético')),
                      PopupMenuItem(value: SortOption.recent, child: Text('Recién Añadidos')),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded),
                    tooltip: 'Cerrar Sesión',
                    color: colorScheme.error,
                    onPressed: () {
                      ref.read(authViewModelProvider.notifier).logout();
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              
              // Si no hay ítems, mostramos el empty state; si no, el Dashboard y el listado
              if (state.items.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    onAdd: () => _navigateToAdd(context),
                  ).animate().fadeIn(duration: 600.ms),
                )
              else ...[
                // Estadísticas Globales
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: StatsHeader(
                      totalItems: state.totalItems,
                      estimatedCost: state.estimatedCost,
                      necessityCount: state.necessityCount,
                      niceToHaveCount: state.niceToHaveCount,
                      nonRelevantCount: state.nonRelevantCount,
                    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1),
                  ),
                ),
                
                // Listado Principal
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = state.filteredItems[index];
                        return WishlistCard(
                          item: item,
                          onPurchasedToggled: (_) => notifier.togglePurchased(item.id),
                          onDismissed: () => notifier.deleteItem(item.id),
                          onTap: () => _navigateToEdit(context, item.id),
                        );
                      },
                      childCount: state.filteredItems.length,
                    ),
                  ),
                ),
                
                // Espaciador para no tapar contenido con el FAB flotante
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ],
          ),
        ),
      ),
      
      // Floating Action Button premium
      floatingActionButton: FloatingActionButton.extended(
        elevation: 6,
        onPressed: () => _navigateToAdd(context),
        icon: const Icon(Icons.add_rounded, size: 28),
        label: const Text('Añadir Deseo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ).animate().scale(delay: 500.ms, duration: 400.ms, curve: Curves.easeOutBack),
    );
  }

  /// Navega a la pantalla de creación.
  void _navigateToAdd(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddEditScreen()),
    );
  }

  /// Navega a la pantalla de edición paramétrica mediante [id].
  void _navigateToEdit(BuildContext context, String id) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddEditScreen(itemId: id)),
    );
  }
}
