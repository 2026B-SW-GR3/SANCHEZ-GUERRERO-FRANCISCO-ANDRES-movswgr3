// Archivo: lib/screens/crud_screen.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart'; // Generará IDs únicos automáticamente
import '../models/db_item.dart';
import '../repositories/local_repository.dart';
import '../repositories/sqlite_repository.dart';
import '../repositories/hive_repository.dart';

class CrudScreen extends StatefulWidget {
  const CrudScreen({Key? key}) : super(key: key);

  @override
  _CrudScreenState createState() => _CrudScreenState();
}

class _CrudScreenState extends State<CrudScreen> {
  // Instanciamos ambos repositorios
  final LocalRepository _sqliteRepo = SqliteRepository();
  final LocalRepository _hiveRepo = HiveRepository();

  // El repositorio activo será del tipo abstracto "LocalRepository"
  late LocalRepository _activeRepository;

  // Estado del Switch: false = SQL (SQLite), true = NoSQL (Hive)
  bool _isNoSqlActive = false;

  // Lista de elementos cargados actualmente
  List<DbItem> _items = [];
  bool _isLoading = false;

  // Controladores de texto para agregar nuevos elementos
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Por defecto, iniciamos en modo SQL (SQLite)
    _activeRepository = _sqliteRepo;
    _loadData();
  }

  // Carga los datos del repositorio seleccionado actualmente
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _activeRepository.init();
      final data = await _activeRepository.getAllItems();
      setState(() {
        _items = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Alterna el repositorio activo cuando el usuario mueve el Switch
  void _toggleDatabase(bool value) {
    setState(() {
      _isNoSqlActive = value;
      // Inyectamos el repositorio correspondiente de forma dinámica
      _activeRepository = _isNoSqlActive ? _hiveRepo : _sqliteRepo;
    });
    
    // Recargamos los datos instantáneamente al conmutar
    _loadData();

    // Notificación en pantalla
    final dbName = _isNoSqlActive ? "NoSQL (Hive)" : "SQL (SQLite)";
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cambiado a origen de datos: $dbName'),
        duration: const Duration(seconds: 1),
        backgroundColor: _isNoSqlActive ? Colors.green : Colors.blueAccent,
      ),
    );
  }

  // Inserta un nuevo registro en el repositorio activo
  Future<void> _addItem() async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    if (title.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, llena todos los campos')),
      );
      return;
    }

    // Generamos un ID único usando la fecha actual o UUID
    final String uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
    final newItem = DbItem(id: uniqueId, title: title, description: desc);

    await _activeRepository.insertItem(newItem);
    
    _titleController.clear();
    _descController.clear();
    Navigator.of(context).pop(); // Cerramos el modal de inserción

    _loadData(); // Recargamos la lista
  }

  // Elimina un registro del repositorio activo
  Future<void> _deleteItem(String id) async {
    await _activeRepository.deleteItem(id);
    _loadData(); // Recargamos para actualizar la pantalla
  }

  // Muestra un formulario emergente en la parte inferior de la pantalla para agregar items
  void _showAddModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Agregar Registro a: ${_isNoSqlActive ? 'NoSQL (Hive)' : 'SQL (SQLite)'}",
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold,
                  color: _isNoSqlActive ? Colors.green[800] : Colors.blue[800],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Título",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: "Descripción",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isNoSqlActive ? Colors.green : Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("Guardar Registro"),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Definimos colores dinámicos dependiendo de la base de datos seleccionada
    final Color primaryColor = _isNoSqlActive ? Colors.green : Colors.blueAccent;
    final String currentDbText = _isNoSqlActive ? "Base de datos: NoSQL (Hive)" : "Base de datos: SQL (SQLite)";

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Módulo 2: CRUD Dual',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // SWITCH EN LA APP BAR (Requisito Estricto)
          Row(
            children: [
              const Icon(Icons.storage, size: 18),
              const SizedBox(width: 4),
              Text(
                _isNoSqlActive ? "NoSQL" : "SQL", 
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Switch(
                value: _isNoSqlActive,
                onChanged: _toggleDatabase,
                activeColor: Colors.white,
                activeTrackColor: Colors.greenAccent[700],
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.blue[200],
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // INDICADOR VISUAL CLARO EN PANTALLA (Requisito de Interfaz)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            color: _isNoSqlActive ? Colors.green[50] : Colors.blue[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isNoSqlActive ? Icons.cloud_queue : Icons.dns,
                  color: _isNoSqlActive ? Colors.green[800] : Colors.blue[800],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  currentDbText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _isNoSqlActive ? Colors.green[800] : Colors.blue[800],
                  ),
                ),
              ],
            ),
          ),
          
          // LISTA DE DATOS
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text(
                              "No hay datos guardados aquí aún.\n¡Agrega un nuevo registro!",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _isNoSqlActive ? Colors.green[100] : Colors.blue[100],
                                child: Icon(
                                  _isNoSqlActive ? Icons.folder : Icons.table_chart,
                                  color: _isNoSqlActive ? Colors.green[800] : Colors.blue[800],
                                ),
                              ),
                              title: Text(
                                item.title,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(item.description),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () => _deleteItem(item.id),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddModal,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}