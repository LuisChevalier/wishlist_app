import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'priority.dart';

part 'wishlist_item.g.dart';

@HiveType(typeId: 0)
class WishlistItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final Priority priority;

  @HiveField(3)
  final double price;

  @HiveField(4)
  final String purchaseLocation;

  @HiveField(5)
  final DateTime expectedDate;

  @HiveField(6)
  final String notes;

  @HiveField(7)
  final bool isPurchased;

  @HiveField(8)
  final DateTime createdAt;

  WishlistItem({
    String? id,
    required this.name,
    required this.priority,
    required this.price,
    required this.purchaseLocation,
    required this.expectedDate,
    this.notes = '',
    this.isPurchased = false,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  WishlistItem copyWith({
    String? name,
    Priority? priority,
    double? price,
    String? purchaseLocation,
    DateTime? expectedDate,
    String? notes,
    bool? isPurchased,
  }) {
    return WishlistItem(
      id: id,
      name: name ?? this.name,
      priority: priority ?? this.priority,
      price: price ?? this.price,
      purchaseLocation: purchaseLocation ?? this.purchaseLocation,
      expectedDate: expectedDate ?? this.expectedDate,
      notes: notes ?? this.notes,
      isPurchased: isPurchased ?? this.isPurchased,
      createdAt: createdAt,
    );
  }
}
