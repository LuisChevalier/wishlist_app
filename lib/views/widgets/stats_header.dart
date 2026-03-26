import 'package:flutter/material.dart';
import '../../models/priority.dart';

class StatsHeader extends StatelessWidget {
  final int totalItems;
  final double estimatedCost;
  final int necessityCount;
  final int niceToHaveCount;
  final int nonRelevantCount;

  const StatsHeader({
    super.key,
    required this.totalItems,
    required this.estimatedCost,
    required this.necessityCount,
    required this.niceToHaveCount,
    required this.nonRelevantCount,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Resumen de wishlist: $totalItems deseos en total. Coste estimado de ${estimatedCost.toStringAsFixed(0)} euros. $necessityCount necesidades, $niceToHaveCount caprichos y $nonRelevantCount no relevantes.',
      container: true,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ExcludeSemantics(
                  child: Text(
                    '$totalItems deseos',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                ExcludeSemantics(
                  child: Text(
                    '€${estimatedCost.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ExcludeSemantics(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatBadge(context, '$necessityCount', Priority.necessity.color, Priority.necessity.icon),
                  _buildStatBadge(context, '$niceToHaveCount', Priority.niceToHave.color, Priority.niceToHave.icon),
                  _buildStatBadge(context, '$nonRelevantCount', Priority.nonRelevant.color, Priority.nonRelevant.icon),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge(BuildContext context, String text, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
