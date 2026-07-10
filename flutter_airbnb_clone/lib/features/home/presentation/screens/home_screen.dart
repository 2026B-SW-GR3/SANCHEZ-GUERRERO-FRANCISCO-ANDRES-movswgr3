import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/airbnb_logo.dart';
import '../../../explore/presentation/screens/explore_screen.dart';
import '../../../wishlist/presentation/wishlists_screen.dart';

/// Pantalla raíz de la app.
///
/// Maneja:
///  - AppBar global con logo Airbnb (leading) y perfil (action).
///  - `IndexedStack` mantiene el estado de cada tab al cambiar (no se
///    reconstruye la pantalla cuando cambiás de Explore a Wishlists y
///    viceversa — los scrolls y loadings se preservan).
///  - `BottomNavigationBar` con 2 ítems.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // `const` porque no necesitan estado mutable: se construyen una sola vez.
  // IndexedStack las mantiene "vivas" en memoria pero solo pinta la activa.
  static const _pages = [
    ExploreScreen(),
    WishlistsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,

      // ─────────────────────────────────────────
      // AppBar global: logo a la izquierda, perfil a la derecha.
      // ─────────────────────────────────────────
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Center(child: AirbnbLogo(size: 22)),
          ),
          leadingWidth: 110,
          actions: const [ProfileButton()],
        ),
      ),

      // ─────────────────────────────────────────
      // Body: IndexedStack para preservar estado entre tabs.
      // - IndexedStack > PageView aquí porque no queremos swipe-to-change
      //   ni animaciones entre tabs (Airbnb no las usa).
      // - `Scaffold` interno de cada tab provee su propio contexto visual.
      // ─────────────────────────────────────────
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      // ─────────────────────────────────────────
      // BottomNavigationBar fija.
      // `type: fixed` mantiene todos los labels visibles (no se ocultan al
      // seleccionar — eso es lo que hace Airbnb).
      // ─────────────────────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.canvas,
        selectedItemColor: AppColors.rausch,
        unselectedItemColor: AppColors.foggy,
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite, color: AppColors.rausch),
            label: 'Wishlists',
          ),
        ],
      ),
    );
  }
}
