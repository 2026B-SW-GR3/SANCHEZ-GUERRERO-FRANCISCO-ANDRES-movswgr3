import '../models/wishlist.dart';

/// Wishlists de ejemplo — un usuario puede tener muchas, y un destino
/// puede vivir en varias. Por simplicidad académica modelamos la entidad
/// "guardado" (1 wishlist = 1 destino marcado + nota).
final List<Wishlist> kMockWishlists = [
  Wishlist(
    id: 'wl_01',
    destinationId: 'dest_03',  // Villa infinity pool · Ubud
    notes: 'Para luna de miel — revisar disponibilidad en abril',
    createdAt: DateTime.utc(2025, 11, 12, 10, 30),
  ),
  Wishlist(
    id: 'wl_02',
    destinationId: 'dest_11',  // Mas de pierre · Provence
    notes: 'Combo con visita a los viñedos de la zona',
    createdAt: DateTime.utc(2025, 11, 18, 14, 5),
  ),
  Wishlist(
    id: 'wl_03',
    destinationId: 'dest_20',  // Refugio glaciar · Patagonia
    notes: 'Reservar para trekking Fitz Roy (dic-feb)',
    createdAt: DateTime.utc(2025, 12, 1, 9, 0),
  ),
  Wishlist(
    id: 'wl_04',
    destinationId: 'dest_06',  // Cabaña alpina · Bariloche
    notes: 'Para滑雪 en julio con los chicos',
    createdAt: DateTime.utc(2025, 12, 5, 18, 45),
  ),
  Wishlist(
    id: 'wl_05',
    destinationId: 'dest_16',  // Casa ibicenca
    notes: 'Verano europeo 2026 con el grupo',
    createdAt: DateTime.utc(2025, 12, 9, 22, 10),
  ),
];
