import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/theme/app_colors.dart';
import '../../../data/models/destination.dart';
import '../../../data/models/wishlist_collection.dart';
import '../../../data/repositories/explore_repository.dart';
import '../../../shared/widgets/fade_in_widget.dart';

/// Pantalla de Wishlists (versión Fase 4).
///
/// Ahora muestra el modelo real de WishlistCollection: cada fila representa
/// una wishlist del usuario con:
///   - nombre + emoji
///   - preview collage 2x2 con las primeras 4 imágenes guardadas
///   - count de items + ícono de privacidad
///   - chevron para abrir detalle (placeholder)
class WishlistsScreen extends StatefulWidget {
  const WishlistsScreen({super.key});

  @override
  State<WishlistsScreen> createState() => _WishlistsScreenState();
}

class _WishlistsScreenState extends State<WishlistsScreen> {
  final _repo = ExploreRepository();
  late Future<_WishlistViewData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_WishlistViewData> _load() async {
    final collections = await _repo.getCollections();
    // Hidratamos cada collection con hasta 4 destinos (preview).
    final List<List<Destination>> previews = [];
    final List<Destination> allDestinations = [];
    for (final c in collections) {
      final List<Destination> items = [];
      for (final id in c.destinationIds.take(4)) {
        final d = await _repo.getDestinationById(id);
        if (d != null) {
          items.add(d);
          if (!allDestinations.any((x) => x.id == d.id)) {
            allDestinations.add(d);
          }
        }
      }
      previews.add(items);
    }
    return _WishlistViewData(collections, previews, allDestinations);
  }

  /// Refresca toda la pantalla (pull-to-refresh manual vía botón).
  void _refresh() {
    HapticFeedback.selectionClick();
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text(
          'Mis wishlists',
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.ink),
            onPressed: _refresh,
            tooltip: 'Refrescar',
          ),
        ],
      ),
      body: FutureBuilder<_WishlistViewData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const _WishlistsSkeleton();
          }
          if (!snapshot.hasData) return const _EmptyState();

          final data = snapshot.data!;
          final collections = data.collections;

          if (collections.isEmpty) {
            return const _EmptyState();
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Text(
                    '${collections.length} wishlists · ${data.allDestinations.length} alojamientos guardados',
                    style: const TextStyle(
                      color: AppColors.foggy,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SliverList.builder(
                itemCount: collections.length,
                itemBuilder: (context, i) {
                  final c = collections[i];
                  final preview = i < data.previews.length
                      ? data.previews[i]
                      : const <Destination>[];
                  return FadeInOnMounted(
                    delay: Duration(milliseconds: 40 * i),
                    child: _CollectionRow(
                      collection: c,
                      preview: preview,
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }
}

class _WishlistViewData {
  final List<WishlistCollection> collections;
  final List<List<Destination>> previews;
  final List<Destination> allDestinations;
  _WishlistViewData(this.collections, this.previews, this.allDestinations);
}

class _CollectionRow extends StatelessWidget {
  final WishlistCollection collection;
  final List<Destination> preview;

  const _CollectionRow({
    required this.collection,
    required this.preview,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Abrir "${collection.name}" (Fase 4 placeholder)'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.hairline),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _CollagePreview(destinations: preview),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        collection.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        collection.count == 0
                            ? 'Vacía'
                            : '${collection.count} ${collection.count == 1 ? 'alojamiento guardado' : 'alojamientos guardados'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.foggy,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (collection.isPrivate)
                            const Padding(
                              padding: EdgeInsets.only(right: 6),
                              child: Icon(Icons.lock_outline,
                                  size: 14, color: AppColors.foggy),
                            ),
                          Text(
                            collection.isPrivate ? 'Privada' : 'Compartida',
                            style: const TextStyle(
                              color: AppColors.foggy,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.foggy),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CollagePreview extends StatelessWidget {
  final List<Destination> destinations;
  const _CollagePreview({required this.destinations});

  @override
  Widget build(BuildContext context) {
    final size = 72.0;
    if (destinations.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.softSurface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Icon(Icons.collections_outlined,
              color: AppColors.foggy, size: 24),
        ),
      );
    }
    // 2x2 collage con las primeras 4 imágenes (o 1 grande si hay solo 1).
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: size,
        height: size,
        child: GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 1.5,
          crossAxisSpacing: 1.5,
          children: List.generate(4, (i) {
            if (i >= destinations.length) {
              return Container(color: AppColors.softSurface);
            }
            final d = destinations[i];
            return CachedNetworkImage(
              imageUrl: d.imageUrl,
              fit: BoxFit.cover,
              memCacheWidth: 200,
              placeholder: (_, __) => Container(color: AppColors.softSurface),
              errorWidget: (_, __, ___) => Container(color: AppColors.softSurface),
            );
          }),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_border, size: 80, color: AppColors.foggy),
            const SizedBox(height: 16),
            const Text(
              'Aún no creaste ninguna wishlist.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.ink, fontSize: 16, fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tocá el corazón en cualquier alojamiento y elegí una wishlist existente o creá una nueva.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.foggy, fontSize: 13, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _WishlistsSkeleton extends StatelessWidget {
  const _WishlistsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.softSurface,
          borderRadius: BorderRadius.circular(14),
        ),
        height: 96,
      ),
    );
  }
}
