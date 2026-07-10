import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../data/repositories/explore_repository.dart';
import '../widgets/category_bar.dart';
import '../widgets/destinations_grid.dart';
import '../widgets/search_bar_widget.dart';

/// Pantalla principal de Explore.
///
/// Usa `CustomScrollView` con `Sliver`s para combinar:
///   - SliverToBoxAdapter (search bar persistente)
///   - SliverToBoxAdapter (category bar)
///   - SliverToBoxAdapter (divider)
///   - SliverGrid (destinations)
///   - SliverToBoxAdapter (footer)
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  // ─── Filtro seleccionado ─────────────────────
  String? _selectedCategoryId;

  // ─── Wishlist cacheada a nivel de pantalla ───
  Set<String> _wishlistedIds = {};
  bool _wishlistLoaded = false;

  final _repo = ExploreRepository();

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    final ids = await _repo.getAllWishlistedDestinationIds();
    if (!mounted) return;
    setState(() {
      _wishlistedIds = ids;
      _wishlistLoaded = true;
    });
  }

  /// Recibe el destination actualizado + el Set nuevo de IDs wishlisteados.
  /// En Fase 4 real: revalidamos desde el backend.
  Future<void> _onWishlistToggle(_ignored, Set<String> newIds) async {
    if (!mounted) return;
    setState(() {
      _wishlistedIds = Set<String>.from(newIds);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          const SliverToBoxAdapter(child: AirbnbSearchBar()),
          SliverToBoxAdapter(
            child: CategoryBar(
              selectedCategoryId: _selectedCategoryId,
              onSelected: (id) {
                setState(() => _selectedCategoryId = id);
              },
            ),
          ),
          const SliverToBoxAdapter(
            child: Divider(height: 1, thickness: 1, color: AppColors.hairline),
          ),
          DestinationsSliverView(
            categoryId: _selectedCategoryId,
            wishlistedIds: _wishlistedIds,
            onWishlistToggle: _onWishlistToggle,
          ),
          if (_wishlistLoaded && _wishlistedIds.isEmpty)
            const SliverToBoxAdapter(
              child: _EmptyHint(),
            ),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Text(
          '❤️ Tocá el corazón en cualquier alojamiento para guardar tu primera wishlist.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.foggy, fontSize: 13),
        ),
      ),
    );
  }
}
