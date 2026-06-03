// Archivo: lib/repositories/local_repository.dart
import '../models/db_item.dart';

abstract class LocalRepository {
  // Inicializa la base de datos correspondiente (abre archivos o crea tablas)
  Future<void> init();

  // Obtiene todos los elementos guardados
  Future<List<DbItem>> getAllItems();

  // Inserta o actualiza un elemento
  Future<void> insertItem(DbItem item);

  // Elimina un elemento por su ID único
  Future<void> deleteItem(String id);
}