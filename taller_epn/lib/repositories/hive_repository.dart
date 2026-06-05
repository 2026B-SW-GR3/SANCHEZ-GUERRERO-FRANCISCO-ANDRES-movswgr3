// Archivo: lib/repositories/hive_repository.dart
import 'package:hive_flutter/hive_flutter.dart';
import '../models/db_item.dart';
import 'local_repository.dart';

class HiveRepository implements LocalRepository {
  Box? _box;

  @override
  Future<void> init() async {
    if (_box != null) return;
    
    try {
      // LOG ESTRUCTURADO: INFO
      print('[INFO] [Hive-NoSQL] Abriendo caja de persistencia: "epn_nosql_box".');
      _box = await Hive.openBox('epn_nosql_box');
    } catch (e) {
      // LOG ESTRUCTURADO: ERROR
      print('[ERROR] [Hive-NoSQL] Error al abrir la caja persistente: $e');
      rethrow;
    }
  }

  @override
  Future<List<DbItem>> getAllItems() async {
    try {
      await init();
      // LOG ESTRUCTURADO: DEBUG
      print('[DEBUG] [Hive-NoSQL] Leyendo llaves dinámicas del almacén de objetos.');
      
      final List<DbItem> list = [];
      for (var key in _box!.keys) {
        final dynamic val = _box!.get(key);
        if (val != null) {
          list.add(DbItem(
            id: key.toString(),
            title: val['title'] ?? '',
            description: val['description'] ?? '',
          ));
        }
      }

      // LOG ESTRUCTURADO: INFO
      print('[INFO] [Hive-NoSQL] Recuperación reactiva completada. Total: ${list.length} documentos.');
      return list;
    } catch (e) {
      print('[ERROR] [Hive-NoSQL] Fallo al leer registros NoSQL: $e');
      return [];
    }
  }

  @override
  Future<void> insertItem(DbItem item) async {
    try {
      await init();
      // LOG ESTRUCTURADO: DEBUG
      print('[DEBUG] [Hive-NoSQL] Escribiendo par clave-valor en disco: ${item.id}.');

      await _box!.put(item.id, {
        'title': item.title,
        'description': item.description,
      });

      // LOG ESTRUCTURADO: INFO
      print('[INFO] [Hive-NoSQL] Documento persistido exitosamente en Hive. Clave: ${item.id}.');
    } catch (e) {
      print('[ERROR] [Hive-NoSQL] Fallo al escribir documento: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteItem(String id) async {
    try {
      await init();
      // LOG ESTRUCTURADO: DEBUG
      print('[DEBUG] [Hive-NoSQL] Solicitando remover la llave: $id del Box.');

      await _box!.delete(id);

      // LOG ESTRUCTURADO: INFO
      print('[INFO] [Hive-NoSQL] Clave removida de forma segura de la memoria NoSQL: $id.');
    } catch (e) {
      print('[ERROR] [Hive-NoSQL] Fallo al eliminar clave del Box: $e');
      rethrow;
    }
  }
}