import 'package:flutter/foundation.dart';

/// Wishlist item — un alojamiento guardado por un usuario con nota personal.
///
/// En Airbnb las wishlists son colecciones; cada item es una asociación
/// (destinationId, wishlistId) + nota opcional. Para mantener la simplicidad
/// académica, modelamos aquí la entidad "guardado" directamente.
@immutable
class Wishlist {
  final String id;
  final String destinationId;
  final String notes;
  final DateTime createdAt;

  const Wishlist({
    required this.id,
    required this.destinationId,
    required this.notes,
    required this.createdAt,
  });

  Wishlist copyWith({
    String? id,
    String? destinationId,
    String? notes,
    DateTime? createdAt,
  }) =>
      Wishlist(
        id: id ?? this.id,
        destinationId: destinationId ?? this.destinationId,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'destinationId': destinationId,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Wishlist.fromMap(Map<String, dynamic> map) => Wishlist(
        id: map['id'] as String,
        destinationId: map['destinationId'] as String,
        notes: map['notes'] as String? ?? '',
        createdAt: DateTime.parse(map['createdAt'] as String),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Wishlist &&
          other.id == id &&
          other.destinationId == destinationId &&
          other.notes == notes &&
          other.createdAt == createdAt;

  @override
  int get hashCode => Object.hash(id, destinationId, notes, createdAt);

  @override
  String toString() =>
      'Wishlist($id, dest=$destinationId, notes="$notes")';
}
