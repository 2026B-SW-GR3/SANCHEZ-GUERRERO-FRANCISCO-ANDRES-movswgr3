import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

/// SearchBar persistente inspirado en Airbnb:
/// Píldora con sombra muy sutil (es lo que hace Airbnb — sin shadow pesada).
///
/// Estructura visual:
///   ┌──────────────────────────────┐
///   │  ¿Dónde?                    │ ← label grande
///   │  Cualquier lugar · Fechas · Huéspedes   ← caption gris
///   └──────────────────────────────┘
///
/// Al tap, navega a la pantalla de búsqueda completa (no implementada).
class AirbnbSearchBar extends StatelessWidget {
  const AirbnbSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Material(
        // Material con shadow suave: la "card" de búsqueda de Airbnb
        // tiene elevación 2 con sombra ligera.
        color: AppColors.canvas,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(.08),
        borderRadius: BorderRadius.circular(32),
        child: InkWell(
          borderRadius: BorderRadius.circular(32),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Abrir búsqueda completa (Fase 4)'),
                duration: Duration(seconds: 1),
              ),
            );
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¿Dónde quieres ir?',
                        style: TextStyle(
                          color: AppColors.ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Cualquier lugar · Fechas · Huéspedes',
                        style: TextStyle(
                          color: AppColors.foggy,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                // Orbe Rausch con icono de búsqueda (signature de Airbnb).
                _SearchOrb(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Orbe de búsqueda rojo — círculo sólido con un icono blanco adentro.
/// Es el elemento de marca más reconocible de la UI.
class _SearchOrb extends StatelessWidget {
  const _SearchOrb();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: AppColors.rausch,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.search, color: AppColors.canvas, size: 22),
    );
  }
}
