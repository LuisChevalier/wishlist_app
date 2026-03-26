import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'priority.g.dart';

@HiveType(typeId: 1)
enum Priority {
  @HiveField(0)
  necessity,
  @HiveField(1)
  niceToHave,
  @HiveField(2)
  nonRelevant,
}

extension PriorityExtension on Priority {
  String get label {
    switch (this) {
      case Priority.necessity:
        return 'Necesidad';
      case Priority.niceToHave:
        return 'Imprescindible';
      case Priority.nonRelevant:
        return 'No relevante';
    }
  }

  Color get color {
    switch (this) {
      case Priority.necessity:
        return Colors.red;
      case Priority.niceToHave:
        return Colors.amber;
      case Priority.nonRelevant:
        return Colors.grey;
    }
  }

  IconData get icon {
    switch (this) {
      case Priority.necessity:
        return Icons.error_outline;
      case Priority.niceToHave:
        return Icons.star_border;
      case Priority.nonRelevant:
        return Icons.remove_circle_outline;
    }
  }
}
