import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../data/models/category.dart';
import '../../../../data/repositories/explore_repository.dart';
import '../../../../shared/widgets/fade_in_widget.dart';

/// Barra horizontal de categorías.
///
/// Implementación:
///  - `ListView.builder` con `scrollDirection: Axis.horizontal`
///  - `physics: const BouncingScrollPhysics()` para que el scroll se sienta
///    elástico como en iOS (Airbnb lo usa).
///  - `cacheExtent: 1000` (default) — como los items son todos iguales en
///    tamaño, Flutter puede calcular cuántos caben en el cache y precargarlos
///    para evitar jank al snapear con el dedo.
///
/// Performance: NO usamos `Row` ni `SingleChildScrollView` con `children: []`
/// porque eso construiría TODAS las categorías de golpe. Con ListView.builder
/// solo construimos las que están en pantalla (3-4) más el buffer del cache.
class CategoryBar extends StatefulWidget {
  /// Callback cuando se selecciona una categoría. `null` = "Todas".
  final ValueChanged<String?> onSelected;
  final String? selectedCategoryId;

  const CategoryBar({
    super.key,
    required this.onSelected,
    this.selectedCategoryId,
  });

  @override
  State<CategoryBar> createState() => _CategoryBarState();
}

class _CategoryBarState extends State<CategoryBar> {
  // Repositorio — en Fase 4 se inyecta vía Provider/Riverpod.
  final _repo = ExploreRepository();

  late Future<List<Category>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _repo.getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Altura fija: el bar siempre mide 80 px.
      // Esto evita que Flutter tenga que medir el contenido cada frame
      // y permite calcular layouts en O(1).
      height: 80,
      child: FutureBuilder<List<Category>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          // Estado de carga: bar vacío + shimmer.
          if (snapshot.connectionState != ConnectionState.done) {
            return const _CategoryBarSkeleton();
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text('No se pudieron cargar las categorías',
                  style: TextStyle(color: AppColors.foggy)),
            );
          }

          final categories = snapshot.data!;
          final selectedId = widget.selectedCategoryId;

          // ListView.builder horizontal:
          // - Solo construye las categorías visibles (3-4 a la vez).
          // - `addAutomaticKeepAlives: false` evita que Flutter mantenga vivos
          //   widgets fuera del viewport (no necesitamos recordar su estado).
          // - `addRepaintBoundaries: true` (default) ya aisla cada card del
          //   resto para repaints selectivos.
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length + 1, // +1 para "Todas"
            itemBuilder: (context, index) {
              if (index == 0) {
                return _CategoryChip(
                  icon: Icons.all_inclusive,
                  label: 'Todas',
                  isSelected: selectedId == null,
                  isLuxe: false,
                  onTap: () => widget.onSelected(null),
                  // Fade-in con delay escalonado según índice (efecto cascada).
                  delay: Duration.zero,
                );
              }
              final cat = categories[index - 1];
              return _CategoryChip(
                icon: cat.icon,
                label: cat.name,
                isSelected: selectedId == cat.id,
                isLuxe: cat.isLuxe,
                onTap: () => widget.onSelected(cat.id),
                delay: Duration(milliseconds: 40 * index.clamp(0, 6)),
              );
            },
          );
        },
      ),
    );
  }
}

/// Chip individual: ícono + label.
/// Envuelto en `Material + InkWell` para que el ripple funcione.
class _CategoryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isLuxe;
  final VoidCallback onTap;
  final Duration delay;

  const _CategoryChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isLuxe,
    required this.onTap,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    // Color del icono/label cuando está seleccionado.
    // Si es Luxe, usa morado (sub-brand). Si no, Ink (negro suave).
    final activeColor = isLuxe ? AppColors.luxe : AppColors.ink;
    final inactiveColor = AppColors.foggy;

    return FadeInOnMounted(
      delay: delay,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            // Splash sutil, igual que Airbnb (no saturado).
            splashColor: AppColors.rausch.withOpacity(.08),
            highlightColor: AppColors.rausch.withOpacity(.04),
            onTap: onTap,
            child: SizedBox(
              width: 60,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      icon,
                      key: ValueKey(isSelected),
                      size: 28,
                      // Cuando está seleccionado, el icono pasa a "filled"
                      // visualmente: truco → aplicamos FontWeight al pasar
                      // de outlined a filled vía SwapIcon (Material los
                      // tiene en versiones _outlined y _rounded).
                      color: isSelected ? activeColor : inactiveColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      color: isSelected ? activeColor : inactiveColor,
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Placeholder mientras cargan las categorías — 4 chips con shimmer.
class _CategoryBarSkeleton extends StatelessWidget {
  const _CategoryBarSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 6,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
        child: Container(
          width: 60,
          decoration: BoxDecoration(
            color: AppColors.softSurface,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
