import '../models/wishlist_collection.dart';

/// 4 wishlists "reales" del usuario con nombres temáticos y destinos ya guardados.
///
/// Estos mocks se usan:
///   1. En el WishlistPickerSheet (cuenta de items por wishlist).
///   2. En la pantalla Wishlists (lista de collections).
///   3. En los corazoncitos de las cards (para saber si un destino
///      ya está guardado en alguna colección).
final List<WishlistCollection> kMockCollections = [
  WishlistCollection(
    id: 'col_01',
    name: 'Verano 2026 🏖️',
    destinationIds: {'dest_03', 'dest_05', 'dest_16'},
    createdAt: DateTime.utc(2026, 1, 15),
  ),
  WishlistCollection(
    id: 'col_02',
    name: 'Cabañas en la montaña 🏔️',
    destinationIds: {'dest_06', 'dest_20', 'dest_13', 'dest_14'},
    createdAt: DateTime.utc(2025, 11, 20),
  ),
  WishlistCollection(
    id: 'col_03',
    name: 'Europa 2025 🎒',
    destinationIds: {'dest_15', 'dest_11', 'dest_19', 'dest_01'},
    createdAt: DateTime.utc(2025, 9, 1),
  ),
  WishlistCollection(
    id: 'col_04',
    name: 'Próximas vacaciones 💎',
    destinationIds: const {},
    createdAt: DateTime.utc(2026, 2, 1),
  ),
];

/// Helper: dado un destinationId, devuelve las wishlists que lo contienen.
List<WishlistCollection> collectionsContaining(String destinationId) {
  return kMockCollections.where((c) => c.contains(destinationId)).toList();
}
