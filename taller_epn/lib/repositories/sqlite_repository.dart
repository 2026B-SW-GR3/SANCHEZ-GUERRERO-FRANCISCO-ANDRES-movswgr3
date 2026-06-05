// Archivo: lib/repositories/sqlite_repository.dart
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import '../models/db_item.dart';
import 'local_repository.dart';

class SqliteRepository implements LocalRepository {
  sql.Database? _db;

  @override
  Future<void> init() async {
    if (_db != null) return;

    try {
      final dbPath = await sql.getDatabasesPath();
      final fullPath = path.join(dbPath, 'epn_sqlite.db');
      
      // LOG ESTRUCTURADO: INFO
      print('[INFO] [SQLite] Inicializando base de datos en ruta: $fullPath');

      _db = await sql.openDatabase(
        fullPath,
        onCreate: (db, version) {
          // LOG ESTRUCTURADO: DEBUG
          print('[DEBUG] [SQLite] Creando tabla "items" con esquema estricto relacional.');
          return db.execute(
            'CREATE TABLE items(id TEXT PRIMARY KEY, title TEXT, description TEXT)'
          );
        },
        version: 1,
      );
    } catch (e) {
      // LOG ESTRUCTURADO: ERROR
      print('[ERROR] [SQLite] Fallo crítico al inicializar la base de datos: $e');
      rethrow;
    }
  }

  @override
  Future<List<DbItem>> getAllItems() async {
    try {
      await init();
      // LOG ESTRUCTURADO: DEBUG
      print('[DEBUG] [SQLite] Ejecutando consulta SELECT sobre la tabla "items".');
      
      final List<Map<String, dynamic>> maps = await _db!.query('items');
      final items = List.generate(maps.length, (i) => DbItem.fromMap(maps[i]));
      
      // LOG ESTRUCTURADO: INFO
      print('[INFO] [SQLite] Se recuperaron exitosamente ${items.length} registros.');
      return items;
    } catch (e) {
      print('[ERROR] [SQLite] Error al realizar la consulta GET: $e');
      return [];
    }
  }

  @override
  Future<void> insertItem(DbItem item) async {
    try {
      await init();
      // LOG ESTRUCTURADO: DEBUG
      print('[DEBUG] [SQLite] Preparando inserción del item ID: ${item.id} - Título: "${item.title}".');

      await _db!.insert(
        'items',
        item.toMap(),
        conflictAlgorithm: sql.ConflictAlgorithm.replace,
      );

      // LOG ESTRUCTURADO: INFO
      print('[INFO] [SQLite] Transacción de inserción/reemplazo completada para ID: ${item.id}.');
    } catch (e) {
      print('[ERROR] [SQLite] Error en operación de escritura (INSERT): $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteItem(String id) async {
    try {
      await init();
      // LOG ESTRUCTURADO: DEBUG
      print('[DEBUG] [SQLite] Solicitando eliminación física del registro con ID: $id.');

      final count = await _db!.delete(
        'items',
        where: 'id = ?',
        whereArgs: [id],
      );

      // LOG ESTRUCTURADO: INFO
      print('[INFO] [SQLite] Eliminación completada. Registros afectados: $count.');
    } catch (e) {
      print('[ERROR] [SQLite] Error en operación de borrado (DELETE): $e');
      rethrow;
    }
  }
}