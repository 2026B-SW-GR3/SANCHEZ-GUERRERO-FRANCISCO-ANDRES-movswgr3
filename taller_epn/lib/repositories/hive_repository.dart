// Archivo: lib/repositories/hive_repository.dart
import 'package:hive_flutter/hive_flutter.dart';
import '../models/db_item.dart';
import 'local_repository.dart';

class HiveRepository implements LocalRepository {
  Box? _box;

  @override
  Future<void> init() async {
    // Si la caja ya está abierta, no hacemos nada más
    if (_box != null) return;
    
    // Abrimos la "caja" de datos NoSQL local
    _box = await Hive.openBox('epn_nosql_box');
  }

  @override
  Future<List<DbItem>> getAllItems() async {
    await init();
    final List<DbItem> list = [];

    // Recorremos las llaves de la base de datos NoSQL
    for (var key in _box!.keys) {
      final dynamic val = _box!.get(key);
      if (val != null) {
        // Reconstruimos el objeto desde el mapa guardado en Hive
        list.add(DbItem(
          id: key.toString(),
          title: val['title'] ?? '',
          description: val['description'] ?? '',
        ));
      }
    }
    return list;
  }

  @override
  Future<void> insertItem(DbItem item) async {
    await init();
    // Guardamos el mapa indexado por el ID del objeto
    await _box!.put(item.id, {
      'title': item.title,
      'description': item.description,
    });
  }

  @override
  Future<void> deleteItem(String id) async {
    await init();
    await _box!.delete(id);
  }
}