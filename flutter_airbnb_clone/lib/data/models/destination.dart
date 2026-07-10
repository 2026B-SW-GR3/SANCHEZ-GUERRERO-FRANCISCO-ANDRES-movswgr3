import 'package:flutter/foundation.dart';

/// Datos de ubicación geográfica — opcionalmente anidados en [Destination].
@immutable
class Location {
  final String city;
  final String country;
  final double? latitude;
  final double? longitude;

  const Location({
    required this.city,
    required this.country,
    this.latitude,
    this.longitude,
  });

  /// Display string: "Roma, Italia"
  String get display => '$city, $country';

  Map<String, dynamic> toMap() => {
        'city': city,
        'country': country,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory Location.fromMap(Map<String, dynamic> map) => Location(
        city: map['city'] as String,
        country: map['country'] as String,
        latitude: (map['latitude'] as num?)?.toDouble(),
        longitude: (map['longitude'] as num?)?.toDouble(),
      );

  Location copyWith({
    String? city,
    String? country,
    double? latitude,
    double? longitude,
  }) =>
      Location(
        city: city ?? this.city,
        country: country ?? this.country,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Location &&
          other.city == city &&
          other.country == country &&
          other.latitude == latitude &&
          other.longitude == longitude;

  @override
  int get hashCode => Object.hash(city, country, latitude, longitude);

  @override
  String toString() => 'Location($display)';
}

/// Alojamiento mostrado en el Explore Feed.
///
/// Sigue el patrón de la card de Airbnb:
///   foto (1:1) → título → ubicación → precio · rating
@immutable
class Destination {
  final String id;
  final String name;
  final Location location;
  final double price;            // USD por noche
  final double rating;           // 0.0 – 5.0
  final int reviewCount;
  final String imageUrl;
  final String? categoryId;      // FK a Category
  final bool isSuperhost;
  final bool isLuxe;

  const Destination({
    required this.id,
    required this.name,
    required this.location,
    required this.price,
    required this.rating,
    required this.imageUrl,
    this.reviewCount = 0,
    this.categoryId,
    this.isSuperhost = false,
    this.isLuxe = false,
  });

  // ─── Helpers de UI ───────────────────────
  String get priceFormatted => '\$${price.toStringAsFixed(0)} USD';
  String get ratingFormatted => rating.toStringAsFixed(2);
  String get reviewCountFormatted =>
      reviewCount >= 1000 ? '${(reviewCount / 1000).toStringAsFixed(1)}K' : '$reviewCount';

  // ─── Serialización ───────────────────────
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'location': location.toMap(),
        'price': price,
        'rating': rating,
        'reviewCount': reviewCount,
        'imageUrl': imageUrl,
        'categoryId': categoryId,
        'isSuperhost': isSuperhost,
        'isLuxe': isLuxe,
      };

  factory Destination.fromMap(Map<String, dynamic> map) => Destination(
        id: map['id'] as String,
        name: map['name'] as String,
        location: Location.fromMap(map['location'] as Map<String, dynamic>),
        price: (map['price'] as num).toDouble(),
        rating: (map['rating'] as num).toDouble(),
        reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
        imageUrl: map['imageUrl'] as String,
        categoryId: map['categoryId'] as String?,
        isSuperhost: map['isSuperhost'] as bool? ?? false,
        isLuxe: map['isLuxe'] as bool? ?? false,
      );

  // ─── Inmutabilidad + updates ─────────────
  Destination copyWith({
    String? id,
    String? name,
    Location? location,
    double? price,
    double? rating,
    int? reviewCount,
    String? imageUrl,
    String? categoryId,
    bool? isSuperhost,
    bool? isLuxe,
  }) =>
      Destination(
        id: id ?? this.id,
        name: name ?? this.name,
        location: location ?? this.location,
        price: price ?? this.price,
        rating: rating ?? this.rating,
        reviewCount: reviewCount ?? this.reviewCount,
        imageUrl: imageUrl ?? this.imageUrl,
        categoryId: categoryId ?? this.categoryId,
        isSuperhost: isSuperhost ?? this.isSuperhost,
        isLuxe: isLuxe ?? this.isLuxe,
      );

  // ─── Identidad ───────────────────────────
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Destination &&
          other.id == id &&
          other.name == name &&
          other.location == location &&
          other.price == price &&
          other.rating == rating &&
          other.reviewCount == reviewCount &&
          other.imageUrl == imageUrl &&
          other.categoryId == categoryId &&
          other.isSuperhost == isSuperhost &&
          other.isLuxe == isLuxe;

  @override
  int get hashCode => Object.hash(
        id, name, location, price, rating,
        reviewCount, imageUrl, categoryId, isSuperhost, isLuxe,
      );

  @override
  String toString() =>
      'Destination($id, $name, ${priceFormatted}, ★$ratingFormatted)';
}
