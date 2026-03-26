import 'package:flutter/material.dart';
import '../../models/priority.dart';

class PriorityBadge extends StatelessWidget {
  final Priority priority;

  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: priority.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: priority.color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(priority.icon, size: 16, color: priority.color),
          const SizedBox(width: 6),
          Text(
            priority.label,
            style: TextStyle(
              color: priority.color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
