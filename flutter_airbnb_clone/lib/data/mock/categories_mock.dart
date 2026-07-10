import 'package:flutter/material.dart';
import '../models/category.dart';

/// 12 categorías fake para poblar el Category Bar superior.
///
/// En la app real, Airbnb carga ~30+ categorías (OMG!, Cabins, Beachfront…)
/// ordenadas dinámicamente. Aquí dejamos 12 que cubren los verticales más
/// reconocibles y mapean 1-a-1 con los `categoryId` de `destinations_mock.dart`.
const List<Category> kMockCategories = [
  // ─── Top featured ─────────────────────────
  Category(
    id: 'cat_omg',
    name: 'OMG!',
    icon: Icons.bolt_rounded,
    isTrending: true,
  ),

  // ─── Alojamiento ──────────────────────────
  Category(id: 'cat_playa',     name: 'Playa',       icon: Icons.beach_access_rounded),
  Category(id: 'cat_cabanas',   name: 'Cabañas',     icon: Icons.cabin_rounded),
  Category(id: 'cat_piscinas',  name: 'Piscinas',    icon: Icons.pool_rounded),
  Category(id: 'cat_montanas',  name: 'Montañas',    icon: Icons.landscape_rounded),
  Category(id: 'cat_castillos', name: 'Castillos',   icon: Icons.castle_rounded),
  Category(id: 'cat_tropical',  name: 'Tropical',    icon: Icons.wb_sunny_rounded),
  Category(id: 'cat_villa',     name: 'Villa',       icon: Icons.villa_rounded),
  Category(id: 'cat_ciudades',  name: 'Ciudades',    icon: Icons.location_city_rounded),
  Category(id: 'cat_diseno',    name: 'Diseño',      icon: Icons.architecture_rounded),
  Category(id: 'cat_romantico', name: 'Romántico',   icon: Icons.favorite_outline_rounded),
  Category(id: 'cat_bosque',    name: 'Aire libre',  icon: Icons.forest_rounded),

  // ─── Sub-colecciones de marca ─────────────
  Category(
    id: 'cat_luxe',
    name: 'Luxe',
    icon: Icons.star_rounded,
    isLuxe: true,
  ),
];
