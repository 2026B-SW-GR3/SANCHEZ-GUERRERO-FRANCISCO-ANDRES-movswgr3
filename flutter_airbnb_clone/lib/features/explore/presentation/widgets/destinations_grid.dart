import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../data/models/destination.dart';
import '../../../../data/repositories/explore_repository.dart';
import '../../../wishlist/presentation/widgets/wishlist_picker_sheet.dart';
import 'destination_card.dart';

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

  // ─── Constantes de layout (compartidas por el grid real y el skeleton) ──
  static const int _crossAxisCount = 2;
  static const double _crossAxisSpacing = 16;
  static const double _mainAxisSpacing = 16;
  static const double _horizontalPadding = 16; // por lado (izquierda/derecha)

  /// Alto fijo, en píxeles lógicos, del bloque de texto bajo la foto
  /// (`_InfoArea` en destination_card.dart), INCLUYENDO su padding vertical.
  ///
  /// Medido a partir de los estilos actuales de `_InfoArea`:
  ///   nombre      14 * 1.2  = 16.8
  ///   gap                   =  2.0
  ///   ubicación   12 * 1.2  = 14.4
  ///   gap                   =  6.0
  ///   precio      14 * 1.2  = 16.8
  ///   gap                   =  4.0
  ///   fila rating           ≈ 14.4
  ///   padding (10 + 12)     = 22.0
  ///   ─────────────────────────────
  ///   total                 ≈ 96.4 px
  ///
  /// Dejamos ~14 px de colchón extra (hasta 110) por si el usuario tiene el
  /// tamaño de fuente del sistema aumentado (accesibilidad) o por pequeñas
  /// diferencias de métricas de fuente entre Android/iOS.
  ///
  /// IMPORTANTE: si en el futuro agregás o quitás una línea en `_InfoArea`
  /// (ej. una línea de distancia, o fechas), actualizá este valor también,
  /// o el overflow puede volver a aparecer.
  static const double _infoAreaHeight = 110;

  /// Calcula el alto exacto que necesita cada celda del grid, dado el ancho
  /// total disponible (`crossAxisExtent` del sliver padre, ANTES de aplicar
  /// el padding horizontal — por eso lo restamos acá).
  static double _mainAxisExtentFor(double crossAxisExtent) {
    final totalSpacing =
        (_horizontalPadding * 2) + (_crossAxisSpacing * (_crossAxisCount - 1));
    final columnWidth = (crossAxisExtent - totalSpacing) / _crossAxisCount;
    final photoHeight = columnWidth; // _PhotoArea usa AspectRatio 1:1
    return photoHeight + _infoAreaHeight;
  }

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
    // SliverLayoutBuilder nos da el ancho real disponible (crossAxisExtent)
    // de la sliver ANTES de aplicar el padding del SliverPadding de abajo;
    // por eso _mainAxisExtentFor resta el padding y el spacing manualmente.
    return SliverLayoutBuilder(
      builder: (context, sliverConstraints) {
        final mainAxisExtent =
            _mainAxisExtentFor(sliverConstraints.crossAxisExtent);

        if (!_initialLoaded) {
          return SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: _GridSkeleton(mainAxisExtent: mainAxisExtent),
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
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _crossAxisCount, // 2 columnas tipo feed mobile Airbnb
              mainAxisSpacing: _mainAxisSpacing,
              crossAxisSpacing: _crossAxisSpacing,
              // Alto EXACTO en píxeles, calculado arriba — reemplaza al
              // antiguo `childAspectRatio: 0.72` que causaba el overflow.
              mainAxisExtent: mainAxisExtent,
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
      },
    );
  }
}

/// Skeleton mientras carga la primera página. Placeholders con shimmer.
///
/// Recibe `mainAxisExtent` calculado por el padre para que los placeholders
/// tengan EXACTAMENTE el mismo alto que las cards reales — así no hay un
/// "salto" de layout (jump) cuando termina de cargar la primera página.
class _GridSkeleton extends StatelessWidget {
  final double mainAxisExtent;
  const _GridSkeleton({required this.mainAxisExtent});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      // Bloqueamos el scroll: el padre ya tiene scroll. Esto es solo decorativo.
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _DestinationsGridState._crossAxisCount,
        mainAxisSpacing: _DestinationsGridState._mainAxisSpacing,
        crossAxisSpacing: _DestinationsGridState._crossAxisSpacing,
        mainAxisExtent: mainAxisExtent,
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