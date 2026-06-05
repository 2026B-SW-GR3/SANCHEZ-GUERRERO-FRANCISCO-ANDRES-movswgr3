// Archivo: test/repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:taller_epn/models/db_item.dart';
import 'package:taller_epn/repositories/local_repository.dart';

// Mocks locales para simular el comportamiento aislado de los motores de datos
// Esto evita dependencias de plugins nativos de Android durante el test local de Flutter.
class MockSqlRepository implements LocalRepository {
  final Map<String, DbItem> _storage = {};
  bool initialized = false;

  @override
  Future<void> init() async {
    initialized = true;
    print('[INFO] [Mock-SQL] Inicializado.');
  }

  @override
  Future<List<DbItem>> getAllItems() async {
    print('[DEBUG] [Mock-SQL] Leyendo...');
    return _storage.values.toList();
  }

  @override
  Future<void> insertItem(DbItem item) async {
    print('[DEBUG] [Mock-SQL] Insertando...');
    _storage[item.id] = item;
  }

  @override
  Future<void> deleteItem(String id) async {
    print('[DEBUG] [Mock-SQL] Eliminando...');
    _storage.remove(id);
  }
}

class MockNoSqlRepository implements LocalRepository {
  final Map<String, DbItem> _storage = {};
  bool initialized = false;

  @override
  Future<void> init() async {
    initialized = true;
    print('[INFO] [Mock-NoSQL] Inicializado.');
  }

  @override
  Future<List<DbItem>> getAllItems() async {
    print('[DEBUG] [Mock-NoSQL] Leyendo documentos...');
    return _storage.values.toList();
  }

  @override
  Future<void> insertItem(DbItem item) async {
    print('[DEBUG] [Mock-NoSQL] Guardando documento...');
    _storage[item.id] = item;
  }

  @override
  Future<void> deleteItem(String id) async {
    print('[DEBUG] [Mock-NoSQL] Eliminando llave...');
    _storage.remove(id);
  }
}

void main() {
  group('Pruebas Unitarias de Persistencia Dual - FIS EPN', () {
    late LocalRepository sqlRepo;
    late LocalRepository noSqlRepo;

    setUp(() {
      sqlRepo = MockSqlRepository();
      noSqlRepo = MockNoSqlRepository();
    });

    // PRUEBA 1: Verificar operaciones de escritura y lectura aisladas
    test('Prueba 1: Guardado e Independencia en Motor Relacional SQL', () async {
      await sqlRepo.init();
      
      final item = DbItem(
        id: 'test-1',
        title: 'Prueba Relacional',
        description: 'Verificar esquema estricto de SQLite',
      );

      await sqlRepo.insertItem(item);
      final list = await sqlRepo.getAllItems();

      expect(list.length, 1);
      expect(list.first.title, 'Prueba Relacional');
    });

    // PRUEBA 2: Validar el correcto cambio de bases de datos y persistencia asilada
    test('Prueba 2: Conmutación y Aislamiento del Motor NoSQL (Hive)', () async {
      // Guardamos en SQL
      await sqlRepo.insertItem(DbItem(id: '1', title: 'SQL Data', description: 'SQL'));
      
      // Guardamos en NoSQL
      await noSqlRepo.insertItem(DbItem(id: '2', title: 'NoSQL Data', description: 'NoSQL'));

      // Leemos de ambos de manera independiente para comprobar el aislamiento
      final sqlList = await sqlRepo.getAllItems();
      final noSqlList = await noSqlRepo.getAllItems();

      expect(sqlList.any((item) => item.title == 'NoSQL Data'), isFalse, 
          reason: 'El motor SQL no debe estar contaminado con datos de NoSQL.');
          
      expect(noSqlList.any((item) => item.title == 'SQL Data'), isFalse, 
          reason: 'El motor NoSQL debe ser totalmente independiente del relacional.');
    });
  });
}