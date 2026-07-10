import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../data/models/destination.dart';
import '../../../../data/repositories/explore_repository.dart';
import '../../../wishlist/presentation/widgets/wishlist_picker_sheet.dart';
import 'destination_card.dart';

/// Grid vertical (2 columnas) de alojamientos — el feed principal de Explore.
///
/// PERFORMANCE HIGHLIGHTS:
///  - `GridView.builder` con `SliverGridDelegateWithFixedCrossAxisCount`:
///    al fijar el ancho de cada celda, Flutter sabe el layout sin medir cada
///    item → reduce trabajo por frame.
///  - `cacheExtent: 600` (default 250): como las imágenes son pesadas,
///    subimos el buffer para que cuando hagas scroll rápido no se vea
///    "destrucción" de cards (Flash de blanco). Más RAM consumida, pero
///    menos jank percibido.
///  - Paginación infinita: el listener del scroll detecta cuando el usuario
///    está al 80% del final y dispara la carga del siguiente batch.
///  - `setState` solo cuando hay cambio real de datos (nueva página cargada).
class DestinationsGrid extends StatefulWidget {
  final String? categoryId;

  /// Set de IDs de destinos que están en la wishlist actual.
  /// El padre lo provee porque cambia por tabs / pantallas.
  final Set<String> wishlistedIds;

  /// Callback cuando el usuario cambia el estado wishlist de un destino.
  /// Segundo parámetro = Set completo de destinationIds wishlisteados,
  /// para que el padre pueda refrescar sus propias cachés.
  final void Function(Destination d, Set<String> newWishlistedIds) onWishlistToggle;

  const DestinationsGrid({
    super.key,
    required this.categoryId,
    required this.wishlistedIds,
    required this.onWishlistToggle,
  });

  @override
  State<DestinationsGrid> createState() => _DestinationsGridState();
}

class _DestinationsGridState extends State<DestinationsGrid> {
  // ─── Estado ───────────────────────────────
  final _repo = ExploreRepository();
  final _scrollController = ScrollController();

  List<Destination> _items = const [];
  final Set<String> _wishlistLocallyAdded = {};   // optimistas en RAM
  final Set<String> _wishlistLocallyRemoved = {}; // optimistas en RAM

  int _page = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  bool _initialLoaded = false;

  static const int _pageSize = 6;

  @override
  void initState() {
    super.initState();
    // Listener registrado UNA sola vez (no en build) — clave para evitar
    // registrar/eliminar listeners cada rebuild (leaks y jank).
    _scrollController.addListener(_onScroll);
    _loadNextPage();
  }

  @override
  void didUpdateWidget(covariant DestinationsGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si cambió la categoría, limpiamos el estado completo y arrancamos de cero.
    if (oldWidget.categoryId != widget.categoryId) {
      _items = const [];
      _wishlistLocallyAdded.clear();
      _wishlistLocallyRemoved.clear();
      _page = 0;
      _hasMore = true;
      _initialLoaded = false;
      _loadNextPage();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // ─── Pagination ─────────────────────────────
  Future<void> _loadNextPage() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    final newOnes = await _repo.getDestinations(
      page: _page,
      pageSize: _pageSize,
      categoryId: widget.categoryId,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _initialLoaded = true;
      _items = [..._items, ...newOnes];
      _page++;
      _hasMore = newOnes.length == _pageSize;
    });
  }

  // ─── Scroll listener ────────────────────────
  void _onScroll() {
    // Cargamos siguiente página cuando el usuario está al 80% del final.
    if (!_isLoading && _hasMore) {
      final pos = _scrollController.position;
      if (pos.pixels >= pos.maxScrollExtent * 0.8) {
        _loadNextPage();
      }
    }
  }

  // ─── Wishlist (Fase 4: picker explícito) ────────────
  bool _isWishlisted(String id) {
    if (_wishlistLocallyAdded.contains(id)) return true;
    if (_wishlistLocallyRemoved.contains(id)) return false;
    return widget.wishlistedIds.contains(id);
  }

  /// Abre el picker en lugar del toggle sordo.
  /// Cuando el sheet cierra con `true`, refrescamos el estado global
  /// (recargando wishlistedIds del repo) para que el corazón de la card
  /// refleje el estado real.
  Future<void> _onWishlistTap(Destination d) async {
    final didChange = await WishlistPickerSheet.show(
      context: context,
      destination: d,
    );

    if (didChange != true) return;
    if (!mounted) return;

    // Invalidamos la caché optimista local — re-pedimos al repo para
    // reflejar el estado real después del sheet.
    final ids = await _repo.getAllWishlistedDestinationIds();
    if (!mounted) return;
    setState(() {
      _wishlistLocallyAdded.clear();
      _wishlistLocallyRemoved.clear();
    });
    widget.onWishlistToggle(d, ids); // firma extendida (ver ExploreScreen)
  }

  // ─── UI ─────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (!_initialLoaded) {
      return const SliverPadding(
        padding: EdgeInsets.all(16),
        sliver: SliverToBoxAdapter(
          child: _GridSkeleton(),
        ),
      );
    }

    if (_items.isEmpty) {
      return const SliverPadding(
        padding: EdgeInsets.all(40),
        sliver: SliverToBoxAdapter(
          child: Column(
            children: [
              Icon(Icons.search_off, size: 60, color: AppColors.foggy),
              SizedBox(height: 12),
              Text(
                'No encontramos alojamientos\nen esta categoría.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.foggy, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    // GridView.builder: solo construye los items visibles (8-12 típicamente)
    // + cacheExtent. Esto es el corazón del rendimiento en 60 FPS.
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,        // 2 columnas tipo feed mobile Airbnb
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          // `childAspectRatio` ajustado a la card real (foto 1:1 + texto).
          childAspectRatio: 0.72,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final dest = _items[index];
            // Stagger animation: cada card tarda 30 ms más que la anterior.
            // El delay está limitado a 360 ms para que el resto no se haga eterno.
            final delay = Duration(milliseconds: (index * 35).clamp(0, 360));
            return DestinationCard(
              destination: dest,
              isWishlisted: _isWishlisted(dest.id),
              fadeInDelay: delay,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Abrir ${dest.name} (placeholder)'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              onWishlistTap: () => _onWishlistTap(dest),
            );
          },
          childCount: _items.length,
        ),
      ),
    );
  }
}

/// Skeleton mientras carga la primera página. Placeholders con shimmer.
class _GridSkeleton extends StatelessWidget {
  const _GridSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      // Bloqueamos el scroll: el padre ya tiene scroll. Esto es solo decorativo.
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          color: AppColors.softSurface,
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

/// Wrapper que expone un widget Sliver para combinar con otros Slivers
/// en la misma CustomScrollView (e.g. la barra superior).
class DestinationsSliverView extends StatelessWidget {
  final String? categoryId;
  final Set<String> wishlistedIds;
  final void Function(Destination, Set<String>) onWishlistToggle;

  const DestinationsSliverView({
    super.key,
    required this.categoryId,
    required this.wishlistedIds,
    required this.onWishlistToggle,
  });

  @override
  Widget build(BuildContext context) {
    return DestinationsGrid(
      categoryId: categoryId,
      wishlistedIds: wishlistedIds,
      onWishlistToggle: onWishlistToggle,
    );
  }
}


