import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../models/wishlist_item.dart';
import '../../models/priority.dart';
import 'priority_badge.dart';

/// [WishlistCard] es el componente visual (Widget) destinado a exhibir 
/// detalladamente un ítem de la lista de deseos.
/// Construido con un enfoque de alto nivel UI/UX (sobras suaves, feedback táctil, 
/// y bordes radiados considerables) para una experiencia premium.
class WishlistCard extends StatelessWidget {
  /// El modelo de datos del ítem a representar.
  final WishlistItem item;

  /// Callback [Function] disparado al marcar/desmarcar el ítem como comprado.
  final ValueChanged<bool?> onPurchasedToggled;

  /// Callback [Function] disparado al deslizar el ítem para eliminarlo.
  final VoidCallback onDismissed;

  /// Callback [Function] disparado al presionar la tarjeta (para editar).
  final VoidCallback onTap;

  /// Constructor con parámetros inyectados de tipo requerido.
  const WishlistCard({
    super.key,
    required this.item,
    required this.onPurchasedToggled,
    required this.onDismissed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Formateador de moneda configurado para Euros locales (es_ES)
    final currencyFormatter = NumberFormat.currency(symbol: '€', decimalDigits: 0, locale: 'es');
    final priorityColor = item.priority.color;
    final theme = Theme.of(context);

    // Color condicional dependiendo si ya fue comprado
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.bold,
      decoration: item.isPurchased ? TextDecoration.lineThrough : null,
      color: item.isPurchased ? theme.colorScheme.onSurface.withOpacity(0.5) : theme.colorScheme.onSurface,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      // Dismissible habilita la eliminación mediante el gesto "Swipe to Dismiss"
      child: Dismissible(
        key: Key(item.id),
        direction: DismissDirection.endToStart,
        background: _buildDismissBackground(theme),
        onDismissed: (_) => onDismissed(),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: item.isPurchased 
                  ? Colors.transparent 
                  : theme.colorScheme.shadow.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Card(
            margin: EdgeInsets.zero,
            color: item.isPurchased 
               ? theme.colorScheme.surfaceVariant.withOpacity(0.5) 
               : theme.colorScheme.surface,
            elevation: 0, // La sombra se maneja en el Container padre para mayor control
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(
                color: item.isPurchased 
                  ? Colors.transparent 
                  : theme.colorScheme.outlineVariant.withOpacity(0.5),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              // Tinta al presionar
              splashColor: priorityColor.withOpacity(0.1),
              highlightColor: priorityColor.withOpacity(0.05),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Banda lateral del color de prioridad
                    Container(
                      width: 8,
                      decoration: BoxDecoration(
                        color: item.isPurchased ? Colors.grey.shade400 : priorityColor,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.name,
                                    style: titleStyle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  currencyFormatter.format(item.price),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: item.isPurchased ? Colors.grey : theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                // Badge de prioridad animado
                                PriorityBadge(priority: item.priority)
                                  .animate(target: item.isPurchased ? 1 : 0)
                                  .desaturate(end: 1),
                                const Spacer(),
                                // Etiqueta de tienda si existe
                                if (item.purchaseLocation.isNotEmpty) ...[
                                  Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade500),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      item.purchaseLocation,
                                      style: TextStyle(
                                        fontSize: 13, 
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade500
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ]
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Checkbox customizado y ampliado para mejor zona táctil
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: Center(
                        child: Transform.scale(
                          scale: 1.3,
                          child: Checkbox(
                            value: item.isPurchased,
                            onChanged: onPurchasedToggled,
                            activeColor: theme.colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            side: BorderSide(
                              color: theme.colorScheme.outline.withOpacity(0.5),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, duration: 400.ms, curve: Curves.easeOutQuad),
      ),
    );
  }

  /// Construye el fondo visible durante el gesto de deslizamiento (Swipe to Dismiss)
  Widget _buildDismissBackground(ThemeData theme) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.error,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 32),
    );
  }
}
