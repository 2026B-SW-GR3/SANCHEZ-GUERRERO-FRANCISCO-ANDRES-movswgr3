# 🏡 Airbnb Clone — Flutter

Un clon funcional de la pantalla principal de Airbnb construido con **Flutter**, enfocado en fluidez de scroll (60 FPS), arquitectura escalable por *features*, y una mejora de UX que la app original no tiene: un botón **"Deshacer"** al guardar un alojamiento en favoritos.

> 📚 Proyecto educativo realizado como parte de una asignatura de desarrollo móvil. No está afiliado, respaldado ni asociado con Airbnb, Inc.

---

## 📑 Tabla de contenidos

- [📱 Descripción del proyecto](#-descripción-del-proyecto)
- [🖼️ Capturas de pantalla](#️-capturas-de-pantalla)
- [⚡ Tecnologías utilizadas](#-tecnologías-utilizadas)
- [🗂️ Estructura del proyecto](#️-estructura-del-proyecto)
- [🚀 Instalación y ejecución](#-instalación-y-ejecución)
- [✅ La mejora: "Deshacer" al guardar en favoritos](#-la-mejora-deshacer-al-guardar-en-favoritos)
- [🙏 Conclusión y agradecimientos](#-conclusión-y-agradecimientos)

---

## 📱 Descripción del proyecto

Esta app replica la pantalla principal de Airbnb con **tres listas independientes**, cada una construida con `ListView.builder` / `GridView.builder` para que solo se rendericen los ítems visibles en pantalla (más un pequeño buffer), logrando un scroll fluido incluso con listas largas de imágenes pesadas:

- 🏷️ **Categorías horizontales** — barra de filtros tipo chip (Playas, Cabañas, Lofts, etc.).
- 🏠 **Feed vertical de alojamientos** — grid de 2 columnas con foto, nombre, ubicación, precio y rating.
- ❤️ **Wishlists** — colecciones de favoritos organizadas, con un picker para elegir en qué lista guardar cada alojamiento.

Además de recrear la experiencia visual de Airbnb, el proyecto identifica y resuelve un problema real de UX de la app original: **guardar un alojamiento por error no ofrece ninguna forma rápida de deshacerlo**. Esta versión sí la tiene. 👇

---

## 🖼️ Capturas de pantalla

<!-- 📸 Reemplazá cada línea de abajo con tus propias capturas.
     Ejemplo: ![Feed principal](docs/screenshots/feed.png) -->

| Feed principal | Categorías | Guardar en wishlist | Deshacer |
|:---:|:---:|:---:|:---:|
| _(agregá tu captura acá)_ | _(agregá tu captura acá)_ | _(agregá tu captura acá)_ | _(agregá tu captura acá)_ |

---

## ⚡ Tecnologías utilizadas

- **[Flutter](https://flutter.dev/)** — framework UI multiplataforma de Google.
- **[Dart](https://dart.dev/)** — lenguaje de programación.
- **Material 3** (`useMaterial3: true`) — sistema de diseño base de la app.
- **[cached_network_image](https://pub.dev/packages/cached_network_image)** — carga y cacheo (RAM + disco) de imágenes remotas, con `memCacheWidth` para optimizar el uso de memoria en listas largas.
- **Slivers (`CustomScrollView`, `SliverGrid`, `SliverList`)** — para combinar múltiples secciones scrolleables en una sola pantalla de forma performante.

---

## 🗂️ Estructura del proyecto

El proyecto sigue una arquitectura **feature-first** (organizada por funcionalidad, no por tipo de archivo), lo que facilita escalar la app agregando nuevas pantallas sin tocar las existentes:

```
lib/
├── app/
│   └── theme/                    # 🎨 Colores y tipografía centralizados
│       ├── app_colors.dart
│       └── app_text_styles.dart
│
├── data/                         # Capa de datos, compartida por toda la app
│   ├── models/                   # Clases de datos (Destination, Wishlist, Category, etc.)
│   ├── repositories/             # Acceso único a los datos (hoy: mocks en memoria)
│   └── mock/                     # Datos de prueba (destinos, categorías, wishlists)
│
├── features/                     # Una carpeta por funcionalidad de la app
│   ├── home/
│   │   └── presentation/screens/         # Pantalla Home
│   ├── explore/
│   │   └── presentation/
│   │       ├── screens/                  # ExploreScreen (feed principal)
│   │       └── widgets/                  # DestinationCard, DestinationsGrid, CategoryBar...
│   └── wishlist/
│       └── presentation/widgets/         # WishlistPickerSheet, WishlistsScreen
│
├── shared/
│   └── widgets/                  # Widgets reutilizables en toda la app (logo, fade-in, etc.)
│
└── main.dart                     # Punto de entrada de la app
```

**¿Por qué esta organización?**
- 🎨 `app/theme` centraliza estilos para que cambiar un color o tipografía se refleje en toda la app.
- 🗄️ `data/` es la única capa que conoce de dónde salen los datos — mañana se puede reemplazar el mock por un backend real sin tocar ninguna pantalla.
- 🧩 `features/` agrupa cada pantalla junto con sus propios widgets, en vez de mezclar todo en una carpeta genérica `screens/` y otra `widgets/` — así cada funcionalidad es autocontenida y fácil de encontrar.
- 🔁 `shared/widgets` guarda únicamente lo que se reutiliza en más de un feature.

---

## 🚀 Instalación y ejecución

### Requisitos previos
- Tener instalado el [SDK de Flutter](https://docs.flutter.dev/get-started/install).
- Un emulador Android/iOS configurado, o un dispositivo físico conectado.

### Pasos

```bash
# 1. Cloná el repositorio
git clone https://github.com/tu-usuario/tu-repositorio.git

# 2. Entrá a la carpeta del proyecto
cd tu-repositorio

# 3. Instalá las dependencias
flutter pub get

# 4. Corré la app
flutter run
```

> 💡 Puedes verificar que tu entorno esté bien configurado corriendo `flutter doctor` antes del paso 4.

---

## ✅ La mejora: "Deshacer" al guardar en favoritos

### El problema
En la app original de Airbnb, tocar el ❤️ de un alojamiento lo guarda (o lo quita) al instante, sin ninguna confirmación ni forma rápida de revertir un toque accidental. Si te equivocaste, tenés que ir manualmente a buscar el alojamiento en tu lista de guardados para sacarlo.

### La solución implementada
Al guardar (o quitar) un alojamiento de una wishlist, la app muestra un `SnackBar` con una acción **"DESHACER"** durante 4 segundos, permitiendo revertir la acción con un solo toque, sin salir del flujo en el que estabas.

#### 1. El `SnackBar` con acción

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('$verb "$colName"'),        // Ej: "Guardado \"Mis viajes 2026\""
    duration: const Duration(seconds: 4),
    action: SnackBarAction(
      label: 'DESHACER',
      onPressed: () async {
        // Revierte la acción contraria a la que se acaba de hacer
      },
    ),
  ),
);
```

`SnackBarAction` es el widget de Flutter pensado exactamente para esto: agrega un botón de texto dentro del snackbar que ejecuta un callback al tocarlo, sin necesidad de armar un diseño custom.

#### 2. Cómo se decide qué revertir

Cada vez que el usuario guarda o quita un alojamiento, la app recuerda **qué acción se acaba de hacer** (`add` o `remove`) y en qué colección. El botón "Deshacer" simplemente ejecuta la acción contraria:

```dart
if (action == 'add') {
  await repo.removeFromCollection(collectionId: col.id, destinationId: destination.id);
} else {
  await repo.addToCollection(collectionId: col.id, destinationId: destination.id);
}
```

#### 3. El desafío real: mantener la UI sincronizada

El botón "Deshacer" vive dentro del snackbar, que sigue visible **después** de que la pantalla donde elegiste la wishlist ya se cerró. Esto significa que, al tocar "Deshacer", no hay ningún `setState` "a mano" al que volver para repintar el corazón en el feed.

La solución fue encadenar un **callback de refresco** desde el feed hacia el snackbar:

1. El feed (`DestinationsGrid`) le pasa una función `onUndo` al abrir el selector de wishlist.
2. Esa función simplemente vuelve a leer del repositorio cuáles son los alojamientos guardados, y actualiza el estado del feed.
3. Cuando el usuario toca "Deshacer", después de revertir el dato en el repositorio, se ejecuta esa función `onUndo` — logrando que el corazón en el feed se actualice al instante, sin importar que la pantalla que lo mostró ya no exista.

De esta forma, tanto guardar como deshacer terminan pasando por el mismo camino de sincronización, evitando que la UI y los datos reales queden desincronizados. 🔄

---

## 🙏 Conclusión y agradecimientos

Este proyecto fue una gran oportunidad para practicar arquitectura escalable en Flutter, optimización de listas largas para mantener 60 FPS, y — sobre todo — pensar en UX más allá de la réplica visual: identificar una fricción real en un producto que usamos todos los días y proponer una solución concreta.

Gracias por llegar hasta acá y explorar el repositorio. Si tenés sugerencias, encontrás un bug, o simplemente querés charlar sobre alguna decisión de diseño, ¡las *issues* y *pull requests* son bienvenidas! ⭐

---

<p align="center">Hecho con 💛 y Flutter</p>