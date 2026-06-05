import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PostScreen extends StatefulWidget {
  const PostScreen({Key? key}) : super(key: key);

  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  // Controladores de texto para los campos del formulario
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  // Estados de control de la interfaz (UI)
  bool _isLoading = false;          
  String _statusMessage = "";       
  int? _loadedPostId;               

  // MÓDULO 1 - OPERACIÓN 1: CONSULTA (GET /posts/{id})
  Future<void> _fetchPost() async {
    final String rawId = _idController.text.trim();
    final int? id = int.tryParse(rawId);

    if (id == null || id <= 0) {
      setState(() {
        _statusMessage = "Por favor, ingresa un número de ID válido (Mayor a 0).";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = "Consultando datos al servidor...";
    });

    try {
      final url = Uri.parse('https://jsonplaceholder.typicode.com/posts/$id');
      
      // Realizamos la llamada HTTP asíncrona (GET)
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          _titleController.text = data['title'] ?? '';
          _bodyController.text = data['body'] ?? '';
          _loadedPostId = id;
          _statusMessage = "Post #$id cargado exitosamente de JSONPlaceholder.";
        });
      } else {
        setState(() {
          _statusMessage = "Error: El post con ID $id no existe en el servidor (Código: ${response.statusCode}).";
          _clearForm();
        });
      }
    } catch (e) {
      // DIAGNÓSTICO EN PANTALLA: Mostramos el error nativo exacto en lugar del genérico
      setState(() {
        _statusMessage = "FALLO DE RED DETECTADO:\n\n$e\n\nSugerencia: Copia este error para depurarlo.";
        _clearForm();
      });
      // Imprimimos también el error en la terminal de VS Code
      print('[ERROR CRÍTICO] Módulo 1 HTTP GET: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // MÓDULO 1 - OPERACIÓN 2: ACTUALIZACIÓN (PUT /posts/{id})
  Future<void> _updatePost() async {
    if (_loadedPostId == null) {
      setState(() {
        _statusMessage = "Primero debes buscar un post antes de intentar actualizarlo.";
      });
      return;
    }

    final String updatedTitle = _titleController.text.trim();
    final String updatedBody = _bodyController.text.trim();

    if (updatedTitle.isEmpty || updatedBody.isEmpty) {
      setState(() {
        _statusMessage = "El título y el contenido no pueden estar vacíos para actualizar.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = "Enviando actualización mediante PUT...";
    });

    try {
      final url = Uri.parse('https://jsonplaceholder.typicode.com/posts/$_loadedPostId');

      final Map<String, dynamic> requestBody = {
        'id': _loadedPostId,
        'title': updatedTitle,
        'body': updatedBody,
        'userId': 1,
      };

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        setState(() {
          _titleController.text = responseData['title'] ?? '';
          _bodyController.text = responseData['body'] ?? '';
          _statusMessage = "¡Éxito! Servidor respondió: 200 OK.\nInterfaz de usuario sincronizada.";
        });
      } else {
        setState(() {
          _statusMessage = "Error en el servidor al actualizar (Código: ${response.statusCode}).";
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = "FALLO AL ACTUALIZAR:\n\n$e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearForm() {
    _titleController.clear();
    _bodyController.clear();
    _loadedPostId = null;
  }

  @override
  void dispose() {
    _idController.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Módulo 1: Cliente HTTP REST',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sección de Consulta
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Buscar Post por ID",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _idController,
                        decoration: const InputDecoration(
                          labelText: "ID del Post (1 al 100)",
                          hintText: "Escribe un número",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search),
                        ),
                        keyboardType: TextInputType.number,
                        enabled: !_isLoading, 
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _fetchPost,
                          icon: const Icon(Icons.cloud_download),
                          label: const Text("Obtener", style: TextStyle(fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Formulario Editable
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Formulario de Edición",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: "Título",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.title),
                        ),
                        enabled: !_isLoading, 
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _bodyController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: "Contenido del Post",
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(),
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(bottom: 60.0),
                            child: Icon(Icons.description),
                          ),
                        ),
                        enabled: !_isLoading, 
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: (_isLoading || _loadedPostId == null) ? null : _updatePost,
                          icon: const Icon(Icons.save),
                          label: const Text("Actualizar", style: TextStyle(fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey[300],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Área de estado y Feedback
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: CircularProgressIndicator(color: Colors.blueAccent),
                  ),
                ),
              
              if (_statusMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _statusMessage.contains("Éxito") || _statusMessage.contains("exitosamente")
                        ? Colors.green[50]
                        : Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _statusMessage.contains("Éxito") || _statusMessage.contains("exitosamente")
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  child: Text(
                    _statusMessage,
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: _statusMessage.contains("FALLO") ? 'monospace' : null,
                      fontWeight: FontWeight.w500,
                      color: _statusMessage.contains("Éxito") || _statusMessage.contains("exitosamente")
                          ? Colors.green[800]
                          : Colors.red[800],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}