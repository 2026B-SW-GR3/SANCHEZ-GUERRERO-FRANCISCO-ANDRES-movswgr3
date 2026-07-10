# Airbnb Clone — Flutter

Clon de la pantalla **Explore** de Airbnb. Taller en clase 8.

## Estado del proyecto

| Fase | Descripción | Estado |
|------|-------------|--------|
| 1 | Análisis (mercado, color, auditoría de listas, tipografía) | ✅ Completa |
| **2** | **Arquitectura + modelos + mock data** | ✅ **Esta entrega** |
| 3 | Implementación de la UI de Explore (Category Bar + Grid) | ⏳ Pendiente |
| 4 | Integración con backend / API real, paginación, animaciones | ⏳ Pendiente |

---

## Estructura de carpetas

```
lib/
├── main.dart                                  # Entry point + MaterialApp
├── app/                                       # Configuración global de la app
│   ├── theme/
│   │   ├── app_colors.dart                    # Tokens de color (Rausch, Babu, Ink…)
│   │   └── app_text_styles.dart               # Escala tipográfica Inter
│   └── router/                                # (Fase 3: go_router o Navigator 2.0)
│
├── core/                                      # Utilidades agnósticas del feature
│   ├── constants/                             # Strings, durations, breakpoints
│   ├── utils/                                 # Helpers puros (formatters, validators)
│   └── extensions/                            # Extensiones sobre BuildContext, String…
│
├── data/                                      # Capa de datos (modelos + repos)
│   ├── models/
│   │   ├── destination.dart                   # 🏠 Alojamiento (id, name, price, rating…)
│   │   ├── category.dart                      # 🏷️ Categoría del top-bar
│   │   └── wishlist.dart                      # ❤️ Favorito guardado
│   ├── repositories/
│   │   └── explore_repository.dart            # ⭐ Punto único de acceso a los datos
│   └── mock/
│       ├── destinations_mock.dart             # 20 destinos falsos
│       ├── categories_mock.dart               # 12 categorías
│       └── wishlists_mock.dart                # 5 favoritos de ejemplo
│
├── features/                                  # Features por dominio (feature-first)
│   └── explore/
│       ├── domain/                            # Casos de uso, interfaces de repo
│       ├── data/                              # Implementaciones de datasource
│       └── presentation/
│           ├── screens/                       # Pantallas completas
│           └── widgets/                       # Widgets reutilizables del feature
│
└── shared/                                    # Widgets compartidos entre features
    └── widgets/                               # PhotoFrame, PriceTag, RatingChip…
```

### ¿Por qué **feature-first** y no **layer-first**?

- **Layer-first** (`screens/`, `widgets/`, `models/` en raíz) era el estándar viejo. Es simple pero escala mal cuando tienes más de 3 features.
- **Feature-first** mantiene cada vertical encapsulada: si borrás `features/wishlist/`, desaparecen sus pantallas, sus widgets, sus fuentes de datos y sus casos de uso. La carpeta `shared/` y `data/models/` quedan para lo transversal.

Para este clon solo implementamos `explore/`. El resto del árbol documentado queda listo para crecer.

---

## Cómo correr el proyecto

```bash
flutter pub get
flutter run
```

Asegurate de tener Flutter 3.19+ y Dart 3.3+.

---

## Modelos

| Modelo        | Campos | Archivo |
|---------------|--------|---------|
| `Destination` | id, name, location, price, rating, reviewCount, imageUrl, categoryId, isSuperhost, isLuxe | `data/models/destination.dart` |
| `Location`    | city, country, latitude, longitude | anidado en Destination |
| `Category`    | id, name, icon (IconData), isLuxe, isTrending | `data/models/category.dart` |
| `Wishlist`    | id, destinationId, notes, createdAt | `data/models/wishlist.dart` |

Todos los modelos son **inmutables** (`@immutable`), con `copyWith`, serialización `toMap` / `fromMap`, e implementación manual de `==` y `hashCode`. Esto los hace compatibles con `setState`, `ValueNotifier`, `Riverpod`, `Bloc` o cualquier gestor de estado que decidas usar en Fase 3.

---

## Mock data

| Archivo | Cantidad | Notas |
|---------|----------|-------|
| `destinations_mock.dart` | **20 destinos** | Imágenes Unsplash (IDs públicos). Locaciones variadas: Roma, Tulum, Bali, CDMX, Bariloche, Brooklyn, Marrakech, Costa Rica, Tokio, Provence, NY, Aspen, París, Ibiza, Atacama, San Miguel de Allende, Kioto, Patagonia, Cartagena, Portland. |
| `categories_mock.dart` | **12 categorías** | OMG!, Playa, Cabañas, Piscinas, Montañas, Castillos, Tropical, Villa, Ciudades, Diseño, Romántico, Aire libre, Luxe. |
| `wishlists_mock.dart` | **5 favoritos** | Cada wishlist apunta a un destino real + nota personal. |

> 💡 Si alguna URL de Unsplash se cae, reemplazala por cualquier otro `https://images.unsplash.com/photo-{ID}`. Alternativa 100% confiable: `https://picsum.photos/seed/<dest-id>/800/800`.

---

## Repositorio

`ExploreRepository` es el único punto de entrada a los datos del feature. La UI nunca debe importar directamente de `mock/`. Cuando llegue la Fase 4, se cambia **una sola línea** (la instanciación del repo en `main.dart`) y todo el resto del código sigue igual.

---

## Próximos pasos (Fase 3)

- `lib/features/explore/presentation/screens/explore_screen.dart` con `CategoryBar` + `DestinationsGrid`
- `lib/features/explore/presentation/widgets/destination_card.dart` con foto 1:1, corazón, rating, precio
- Hero animation al tap de card → ruta a detalle (placeholder)
- State management: Riverpod (recomendado) o BLoC

---

**Fuentes:** análisis de fase 1 · estructura inspirada en [Reso Coder](https://resocoder.com/) y [Flutter Clean Architecture](https://github.com/JHBitencourt/clean_architecture).
