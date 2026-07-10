import 'package:flutter/foundation.dart';

/// WishlistCollection — una wishlist "con nombre" del usuario.
///
/// Modelo completo (a diferencia del antiguo [Wishlist] que era solo una
/// asociación destino-nota):
///   - `name`: nombre editable que el usuario le da
///   - `destinationIds`: Set de IDs de alojamientos guardados
///   - `isPrivate`: si la wishlist es solo para el usuario o compartida
///
/// El campo `count` deriva del tamaño del Set — se actualiza solo.
/// `contains(destinationId)` es O(1) por usar Set internamente.
@immutable
class WishlistCollection {
  final String id;
  final String name;
  final Set<String> destinationIds;
  final DateTime createdAt;
  final bool isPrivate;

  const WishlistCollection({
    required this.id,
    required this.name,
    required this.destinationIds,
    required this.createdAt,
    this.isPrivate = true,
  });

  int get count => destinationIds.length;
  bool contains(String destinationId) => destinationIds.contains(destinationId);

  WishlistCollection copyWith({
    String? id,
    String? name,
    Set<String>? destinationIds,
    DateTime? createdAt,
    bool? isPrivate,
  }) =>
      WishlistCollection(
        id: id ?? this.id,
        name: name ?? this.name,
        destinationIds: destinationIds ?? this.destinationIds,
        createdAt: createdAt ?? this.createdAt,
        isPrivate: isPrivate ?? this.isPrivate,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WishlistCollection &&
          other.id == id &&
          other.name == name &&
          _setEquals(other.destinationIds, destinationIds) &&
          other.createdAt == createdAt &&
          other.isPrivate == isPrivate;

  @override
  int get hashCode =>
      Object.hash(id, name, destinationIds.length, createdAt, isPrivate);

  @override
  String toString() => 'WishlistCollection($id, "$name", $count items)';
}

bool _setEquals(Set<String> a, Set<String> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (final v in a) {
    if (!b.contains(v)) return false;
  }
  return true;
}
