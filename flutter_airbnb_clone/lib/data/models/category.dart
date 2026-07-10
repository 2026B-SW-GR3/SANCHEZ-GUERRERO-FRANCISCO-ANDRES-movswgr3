import 'package:flutter/material.dart';

/// Categoría del Explore Bar (filtro horizontal superior).
///
/// Igual que en Airbnb, cada categoría es hand-illustrated con [IconData]
/// (Material Symbols). Para soporte de icono custom, basta con extender
/// la clase con un campo `customIconAsset`.
@immutable
class Category {
  final String id;
  final String name;
  final IconData icon;

  /// Si es `true`, se renderiza con el color sub-brand Luxe (#460479)
  /// en lugar del Ink negro por defecto.
  final bool isLuxe;

  /// Si es `true`, marca visual de "trending" / destacado.
  final bool isTrending;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    this.isLuxe = false,
    this.isTrending = false,
  });

  Category copyWith({
    String? id,
    String? name,
    IconData? icon,
    bool? isLuxe,
    bool? isTrending,
  }) =>
      Category(
        id: id ?? this.id,
        name: name ?? this.name,
        icon: icon ?? this.icon,
        isLuxe: isLuxe ?? this.isLuxe,
        isTrending: isTrending ?? this.isTrending,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          other.id == id &&
          other.name == name &&
          other.codePoint == codePoint &&
          other.isLuxe == isLuxe &&
          other.isTrending == isTrending;

  /// Compara solo el codePoint del IconData para evitar problemas de fontFamily.
  int get codePoint => icon.codePoint;

  @override
  int get hashCode => Object.hash(id, name, codePoint, isLuxe, isTrending);

  @override
  String toString() => 'Category($id, $name)';
}
