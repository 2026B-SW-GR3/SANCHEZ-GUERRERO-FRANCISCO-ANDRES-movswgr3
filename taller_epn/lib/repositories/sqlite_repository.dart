// Archivo: lib/repositories/sqlite_repository.dart
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import '../models/db_item.dart';
import 'local_repository.dart';

class SqliteRepository implements LocalRepository {
  sql.Database? _db;

  @override
  Future<void> init() async {
    // Si la base de datos ya está abierta, no hacemos nada más
    if (_db != null) return;

    // Obtenemos la ruta por defecto para almacenar bases de datos en Android
    final dbPath = await sql.getDatabasesPath();
    
    // Abrimos (o creamos) la base de datos en el archivo 'epn_sqlite.db'
    _db = await sql.openDatabase(
      path.join(dbPath, 'epn_sqlite.db'),
      onCreate: (db, version) {
        // Creamos la tabla 'items' si la base de datos no existía previamente
        return db.execute(
          'CREATE TABLE items(id TEXT PRIMARY KEY, title TEXT, description TEXT)'
        );
      },
      version: 1,
    );
  }

  @override
  Future<List<DbItem>> getAllItems() async {
    await init(); // Aseguramos que la DB esté abierta
    final List<Map<String, dynamic>> maps = await _db!.query('items');
    
    // Mapeamos los resultados crudos a nuestra lista de objetos DbItem
    return List.generate(maps.length, (i) => DbItem.fromMap(maps[i]));
  }

  @override
  Future<void> insertItem(DbItem item) async {
    await init();
    await _db!.insert(
      'items',
      item.toMap(),
      // Si el ID ya existe en SQLite, reemplazamos la información vieja por la nueva
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteItem(String id) async {
    await init();
    await _db!.delete(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}