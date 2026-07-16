import '../models/destination.dart';
import '../models/category.dart';
import '../models/wishlist.dart';
import '../models/wishlist_collection.dart';
import '../mock/categories_mock.dart';
import '../mock/destinations_mock.dart';
import '../mock/wishlist_collections_mock.dart';
import '../mock/wishlists_mock.dart';

class ExploreRepository {
  // Constructor privado: solo esta clase puede construir la instancia real.
  ExploreRepository._internal();

  // La única instancia que va a existir en toda la app.
  static final ExploreRepository _instance = ExploreRepository._internal();

  // Factory: cada `ExploreRepository()` devuelve _instance en vez de crear
  // un objeto nuevo. Para el resto del código esto es transparente — se
  // sigue escribiendo `ExploreRepository()` como siempre.
  factory ExploreRepository() => _instance;

  // ────────────────────────────────────────
  // Runtime mutable state (para soportar optimistic updates).
  // En producción, esto vive en el backend con caché local.
  // Ahora que la clase es singleton, este campo es efectivamente
  // compartido por TODA la app.
  // ────────────────────────────────────────
  final List<WishlistCollection> _runtimeCollections =
      List.of(kMockCollections);

  // ─── Categorías ───────────────────────────────────
  Future<List<Category>> getCategories() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return kMockCategories;
  }

  // ─── Destinos ─────────────────────────────────────
  Future<List<Destination>> getDestinations({
    int page = 0,
    int pageSize = 10,
    String? categoryId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    final filtered = categoryId == null
        ? kMockDestinations
        : kMockDestinations
            .where((d) => d.categoryId == categoryId)
            .toList(growable: false);

    final from = page * pageSize;
    if (from >= filtered.length) return const [];

    final to = (from + pageSize).clamp(0, filtered.length);
    return filtered.sublist(from, to);
  }

  Future<Destination?> getDestinationById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    try {
      return kMockDestinations.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  // ─── Wishlists (sistema legacy) ───────────────────
  Future<List<Wishlist>> getWishlists() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return kMockWishlists;
  }

  Future<Set<String>> getWishlistedIds() async {
    final wishlists = await getWishlists();
    return wishlists.map((w) => w.destinationId).toSet();
  }

  Future<Wishlist> addToWishlist({
    required String destinationId,
    String notes = '',
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return Wishlist(
      id: 'wl_${DateTime.now().microsecondsSinceEpoch}',
      destinationId: destinationId,
      notes: notes,
      createdAt: DateTime.now().toUtc(),
    );
  }

  // ─── WishlistCollections (Fase 4 — el verdadero fix) ───

  /// Lista todas las wishlists del usuario. Son MUTABLES: las llamadas a
  /// [addToCollection] / [removeFromCollection] / [createCollection] modifican
  /// el estado interno.
  Future<List<WishlistCollection>> getCollections() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    // Devolvemos copia para que el caller no pueda mutar el estado interno.
    return List.unmodifiable(_runtimeCollections);
  }

  /// True si el destino está guardado en AL MENOS una colección.
  Future<bool> isDestinationWishlisted(String destinationId) async {
    return _runtimeCollections.any((c) => c.contains(destinationId));
  }

  /// Set de destinoIds wishlisteados (agregando todos los Set de cada colección).
  Future<Set<String>> getAllWishlistedDestinationIds() async {
    final all = <String>{};
    for (final c in _runtimeCollections) {
      all.addAll(c.destinationIds);
    }
    return all;
  }

  Future<WishlistCollection> addToCollection({
    required String collectionId,
    required String destinationId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    final i = _runtimeCollections.indexWhere((c) => c.id == collectionId);
    if (i == -1) {
      throw StateError('Collection $collectionId not found');
    }
    final updated = _runtimeCollections[i].copyWith(
      destinationIds: {..._runtimeCollections[i].destinationIds, destinationId},
    );
    _runtimeCollections[i] = updated;
    return updated;
  }

  Future<WishlistCollection> removeFromCollection({
    required String collectionId,
    required String destinationId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    final i = _runtimeCollections.indexWhere((c) => c.id == collectionId);
    if (i == -1) {
      throw StateError('Collection $collectionId not found');
    }
    final next = Set<String>.from(_runtimeCollections[i].destinationIds)
      ..remove(destinationId);
    final updated = _runtimeCollections[i].copyWith(destinationIds: next);
    _runtimeCollections[i] = updated;
    return updated;
  }

  Future<WishlistCollection> createCollection({required String name}) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    final created = WishlistCollection(
      id: 'col_${DateTime.now().microsecondsSinceEpoch}',
      name: name.isEmpty ? 'Nueva wishlist' : name,
      destinationIds: const {},
      createdAt: DateTime.now().toUtc(),
    );
    _runtimeCollections.add(created);
    return created;
  }
}