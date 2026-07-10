import '../models/destination.dart';

/// 20 destinos falsos para poblar el Explore Feed.
///
/// Imágenes: Unsplash (formato `?w=800&fit=crop` para ancho optimizado).
/// Si algún ID llegara a estar caído, reemplazá el `imageUrl` por cualquier
/// otro `https://images.unsplash.com/photo-{ID}` válido.
/// Alternativa de respaldo: `https://picsum.photos/seed/<dest-id>/800/800`.

const List<Destination> kMockDestinations = [
  // 1. Roma
  Destination(
    id: 'dest_01',
    name: 'Loft con terraza en Trastevere',
    location: Location(city: 'Roma', country: 'Italia', latitude: 41.89, longitude: 12.47),
    price: 89,
    rating: 4.94,
    reviewCount: 312,
    imageUrl: 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800&fit=crop',
    categoryId: 'cat_ciudades',
    isSuperhost: true,
  ),

  // 2. Tulum
  Destination(
    id: 'dest_02',
    name: 'Cabaña en la selva con cenote privado',
    location: Location(city: 'Tulum', country: 'México', latitude: 20.21, longitude: -87.46),
    price: 145,
    rating: 4.87,
    reviewCount: 184,
    imageUrl: 'https://images.unsplash.com/photo-1505691938895-1758d7feb511?w=800&fit=crop',
    categoryId: 'cat_cabanas',
    isSuperhost: true,
  ),

  // 3. Bali
  Destination(
    id: 'dest_03',
    name: 'Villa infinity pool sobre los arrozales',
    location: Location(city: 'Ubud', country: 'Indonesia', latitude: -8.50, longitude: 115.26),
    price: 220,
    rating: 5.00,
    reviewCount: 96,
    imageUrl: 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800&fit=crop',
    categoryId: 'cat_tropical',
    isSuperhost: true,
    isLuxe: true,
  ),

  // 4. CDMX
  Destination(
    id: 'dest_04',
    name: 'Loft industrial en Roma Norte',
    location: Location(city: 'Ciudad de México', country: 'México', latitude: 19.41, longitude: -99.16),
    price: 67,
    rating: 4.78,
    reviewCount: 421,
    imageUrl: 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800&fit=crop',
    categoryId: 'cat_ciudades',
  ),

  // 5. Cartagena
  Destination(
    id: 'dest_05',
    name: 'Casa colonial con patio interno',
    location: Location(city: 'Cartagena', country: 'Colombia', latitude: 10.40, longitude: -75.55),
    price: 110,
    rating: 4.91,
    reviewCount: 257,
    imageUrl: 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800&fit=crop',
    categoryId: 'cat_playa',
    isSuperhost: true,
  ),

  // 6. Bariloche
  Destination(
    id: 'dest_06',
    name: 'Cabaña alpina con vista al lago',
    location: Location(city: 'Bariloche', country: 'Argentina', latitude: -41.13, longitude: -71.31),
    price: 95,
    rating: 4.85,
    reviewCount: 134,
    imageUrl: 'https://images.unsplash.com/photo-1542718610-a1d656d1884c?w=800&fit=crop',
    categoryId: 'cat_montanas',
  ),

  // 7. Brooklyn
  Destination(
    id: 'dest_07',
    name: 'Loft industrial en Williamsburg',
    location: Location(city: 'Brooklyn', country: 'Estados Unidos', latitude: 40.71, longitude: -73.96),
    price: 175,
    rating: 4.72,
    reviewCount: 512,
    imageUrl: 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800&fit=crop',
    categoryId: 'cat_ciudades',
  ),

  // 8. Marrakech
  Destination(
    id: 'dest_08',
    name: 'Riad tradicional en la medina',
    location: Location(city: 'Marrakech', country: 'Marruecos', latitude: 31.63, longitude: -7.99),
    price: 78,
    rating: 4.96,
    reviewCount: 218,
    imageUrl: 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800&fit=crop',
    categoryId: 'cat_diseno',
    isSuperhost: true,
  ),

  // 9. Costa Rica
  Destination(
    id: 'dest_09',
    name: 'Casa del árbol en Monteverde',
    location: Location(city: 'Monteverde', country: 'Costa Rica', latitude: 10.31, longitude: -84.82),
    price: 130,
    rating: 4.89,
    reviewCount: 92,
    imageUrl: 'https://images.unsplash.com/photo-1606041011872-596597976bcc?w=800&fit=crop',
    categoryId: 'cat_cabanas',
    isSuperhost: true,
  ),

  // 10. Tokio
  Destination(
    id: 'dest_10',
    name: 'Microapartamento minimalista en Shibuya',
    location: Location(city: 'Tokio', country: 'Japón', latitude: 35.66, longitude: 139.70),
    price: 98,
    rating: 4.81,
    reviewCount: 178,
    imageUrl: 'https://images.unsplash.com/photo-1518780664697-55e3ad937233?w=800&fit=crop',
    categoryId: 'cat_ciudades',
  ),

  // 11. Provence
  Destination(
    id: 'dest_11',
    name: 'Mas de pierre con jardín de lavanda',
    location: Location(city: 'Gordes', country: 'Francia', latitude: 43.86, longitude: 5.20),
    price: 195,
    rating: 4.93,
    reviewCount: 142,
    imageUrl: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800&fit=crop',
    categoryId: 'cat_playa',
    isSuperhost: true,
    isLuxe: true,
  ),

  // 12. NY
  Destination(
    id: 'dest_12',
    name: 'Penthouse con vistas a Manhattan',
    location: Location(city: 'Nueva York', country: 'Estados Unidos', latitude: 40.78, longitude: -73.96),
    price: 410,
    rating: 4.88,
    reviewCount: 89,
    imageUrl: 'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=800&fit=crop',
    categoryId: 'cat_luxe',
    isLuxe: true,
  ),

  // 13. Oregon
  Destination(
    id: 'dest_13',
    name: 'Cabaña en el bosque con jacuzzi',
    location: Location(city: 'Portland', country: 'Estados Unidos', latitude: 45.51, longitude: -122.67),
    price: 145,
    rating: 4.92,
    reviewCount: 167,
    imageUrl: 'https://images.unsplash.com/photo-1582268611958-ebfd161ef9cf?w=800&fit=crop',
    categoryId: 'cat_cabanas',
  ),

  // 14. Aspen
  Destination(
    id: 'dest_14',
    name: 'Chalet de esquí con chimenea',
    location: Location(city: 'Aspen', country: 'Estados Unidos', latitude: 39.19, longitude: -106.82),
    price: 380,
    rating: 4.86,
    reviewCount: 76,
    imageUrl: 'https://images.unsplash.com/photo-1502786129293-79981df4e689?w=800&fit=crop',
    categoryId: 'cat_montanas',
    isLuxe: true,
  ),

  // 15. París
  Destination(
    id: 'dest_15',
    name: 'Studio bohemio en Le Marais',
    location: Location(city: 'París', country: 'Francia', latitude: 48.86, longitude: 2.36),
    price: 118,
    rating: 4.79,
    reviewCount: 298,
    imageUrl: 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=800&fit=crop',
    categoryId: 'cat_romantico',
    isSuperhost: true,
  ),

  // 16. Ibiza
  Destination(
    id: 'dest_16',
    name: 'Casa blanca ibicenca con piscina',
    location: Location(city: 'Ibiza', country: 'España', latitude: 38.91, longitude: 1.43),
    price: 245,
    rating: 4.95,
    reviewCount: 113,
    imageUrl: 'https://images.unsplash.com/photo-1499793983690-e29da59ef1c2?w=800&fit=crop',
    categoryId: 'cat_playa',
    isSuperhost: true,
    isLuxe: true,
  ),

  // 17. Atacama
  Destination(
    id: 'dest_17',
    name: 'Eco-domo bajo las estrellas',
    location: Location(city: 'San Pedro de Atacama', country: 'Chile', latitude: -22.91, longitude: -68.20),
    price: 165,
    rating: 4.97,
    reviewCount: 64,
    imageUrl: 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=800&fit=crop',
    categoryId: 'cat_tropical',
    isSuperhost: true,
  ),

  // 18. San Miguel de Allende
  Destination(
    id: 'dest_18',
    name: 'Casa colonial con rooftop',
    location: Location(city: 'San Miguel de Allende', country: 'México', latitude: 20.92, longitude: -100.74),
    price: 112,
    rating: 4.90,
    reviewCount: 246,
    imageUrl: 'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800&fit=crop',
    categoryId: 'cat_playa',
    isSuperhost: true,
  ),

  // 19. Kyoto
  Destination(
    id: 'dest_19',
    name: 'Ryokan tradicional con jardín zen',
    location: Location(city: 'Kioto', country: 'Japón', latitude: 35.01, longitude: 135.77),
    price: 285,
    rating: 4.94,
    reviewCount: 87,
    imageUrl: 'https://images.unsplash.com/photo-1528360983277-13d401cdc186?w=800&fit=crop',
    categoryId: 'cat_diseno',
    isLuxe: true,
  ),

  // 20. Patagonia
  Destination(
    id: 'dest_20',
    name: 'Refugio de montaña con glaciar',
    location: Location(city: 'El Chaltén', country: 'Argentina', latitude: -49.33, longitude: -72.89),
    price: 175,
    rating: 4.93,
    reviewCount: 51,
    imageUrl: 'https://images.unsplash.com/photo-1483728642387-6c3bdd6c93e5?w=800&fit=crop',
    categoryId: 'cat_montanas',
    isSuperhost: true,
  ),
];
