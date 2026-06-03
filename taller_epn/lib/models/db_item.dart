// Archivo: lib/models/db_item.dart

class DbItem {
  final String id;
  final String title;
  final String description;

  DbItem({
    required this.id,
    required this.title,
    required this.description,
  });

  // Convierte el objeto en un Mapa (JSON) para guardarlo fácilmente en SQLite o NoSQL
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
    };
  }

  // Crea un objeto DbItem a partir de un Mapa (por ejemplo, al leer de la base de datos)
  factory DbItem.fromMap(Map<String, dynamic> map) {
    return DbItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
    );
  }
}