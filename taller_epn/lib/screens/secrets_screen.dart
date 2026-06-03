// Archivo: lib/screens/secrets_screen.dart
import 'package:flutter/material.dart';
import '../services/security_service.dart';

class SecretsScreen extends StatefulWidget {
  const SecretsScreen({Key? key}) : super(key: key);

  @override
  _SecretsScreenState createState() => _SecretsScreenState();
}

class _SecretsScreenState extends State<SecretsScreen> {
  final SecurityService _securityService = SecurityService();

  // Controladores de los campos de texto
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();

  // Opciones de almacenamiento disponibles (Excluyendo Keystore por directiva del taller)
  final List<String> _mechanisms = [
    'SharedPreferences',
    'DataStore',
    'EncryptedSharedPreferences',
  ];

  // Opción seleccionada por defecto
  late String _selectedMechanism;

  // Estados visuales
  String _retrievedValue = "";
  String _statusMessage = "";
  bool _isSuccessMessage = true;

  @override
  void initState() {
    super.initState();
    _selectedMechanism = _mechanisms[0]; // Iniciamos con SharedPreferences
  }

  // Guarda un secreto en el mecanismo seleccionado
  Future<void> _saveSecret() async {
    final key = _keyController.text.trim();
    final value = _valueController.text.trim();

    if (key.isEmpty || value.isEmpty) {
      _showFeedback("Error: Ambos campos (Llave y Valor) son obligatorios para guardar.", false);
      return;
    }

    try {
      if (_selectedMechanism == 'SharedPreferences') {
        await _securityService.saveInSharedPreferences(key, value);
      } else if (_selectedMechanism == 'DataStore') {
        await _securityService.saveInDataStore(key, value);
      } else if (_selectedMechanism == 'EncryptedSharedPreferences') {
        await _securityService.saveInEncrypted(key, value);
      }

      setState(() {
        _valueController.clear(); // Limpiamos el valor por seguridad
        _retrievedValue = "";     // Limpiamos búsquedas previas
      });

      _showFeedback("¡Éxito! Secreto guardado correctamente en: $_selectedMechanism", true);
    } catch (e) {
      _showFeedback("Error al guardar el secreto: $e", false);
    }
  }

  // Recupera un secreto usando solo la llave (Búsqueda ciega)
  Future<void> _retrieveSecret() async {
    final key = _keyController.text.trim();

    if (key.isEmpty) {
      _showFeedback("Error: Debes ingresar una Llave para buscar.", false);
      return;
    }

    try {
      String? result;

      if (_selectedMechanism == 'SharedPreferences') {
        result = await _securityService.getFromSharedPreferences(key);
      } else if (_selectedMechanism == 'DataStore') {
        result = await _securityService.getFromDataStore(key);
      } else if (_selectedMechanism == 'EncryptedSharedPreferences') {
        result = await _securityService.getFromEncrypted(key);
      }

      setState(() {
        if (result != null && result.isNotEmpty) {
          _retrievedValue = result;
          _showFeedback("¡Secreto encontrado exitosamente!", true);
        } else {
          _retrievedValue = "";
          // REQUISITO ESTRICTO: Informar que no existe sin listar los demás secretos
          _showFeedback("Secreto no encontrado en $_selectedMechanism. Verifica la llave.", false);
        }
      });
    } catch (e) {
      _showFeedback("Error al recuperar el secreto: $e", false);
    }
  }

  // Muestra un banner visual de información al usuario
  void _showFeedback(String message, bool isSuccess) {
    setState(() {
      _statusMessage = message;
      _isSuccessMessage = isSuccess;
    });
  }

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Módulo 3: Secretos y Seguridad',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título Académico Informativo
              Card(
                color: Colors.indigo[50],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    children: [
                      Icon(Icons.security, color: Colors.indigo[800], size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Búsqueda Ciega de Secretos\n"
                          "Cifra y guarda datos en compartimentos nativos de Android.",
                          style: TextStyle(
                            fontSize: 13, 
                            fontWeight: FontWeight.w500, 
                            color: Colors.indigo[900]
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Formulario Principal de Secretos
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Almacenamiento Seguro",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo),
                      ),
                      const SizedBox(height: 16),

                      // Campo: Llave (Key)
                      TextField(
                        controller: _keyController,
                        decoration: const InputDecoration(
                          labelText: "Llave (Key)",
                          hintText: "Ej: token_jwt_api",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.vpn_key),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Campo: Valor (Value)
                      TextField(
                        controller: _valueController,
                        decoration: const InputDecoration(
                          labelText: "Valor (Value)",
                          hintText: "Ej: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.password),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Selector de Mecanismo de Almacenamiento (Dropdown)
                      DropdownButtonFormField<String>(
                        value: _selectedMechanism,
                        decoration: const InputDecoration(
                          labelText: "Compartimento de Android",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.layers),
                        ),
                        items: _mechanisms.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedMechanism = newValue!;
                            _statusMessage = ""; // Reseteamos mensajes
                            _retrievedValue = "";
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      // Botones de Operación en fila
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: ElevatedButton.icon(
                                onPressed: _saveSecret,
                                icon: const Icon(Icons.save),
                                label: const Text("Guardar"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: ElevatedButton.icon(
                                onPressed: _retrieveSecret,
                                icon: const Icon(Icons.search),
                                label: const Text("Recuperar"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[800],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Área de Resultado de Búsqueda
              if (_retrievedValue.isNotEmpty)
                Card(
                  color: Colors.green[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.green),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.lock_open, color: Colors.green, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "Secreto Desencriptado - $_selectedMechanism",
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.green, height: 20),
                        SelectableText(
                          _retrievedValue,
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            color: Colors.green[900],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Banner de Mensaje de Estado
              if (_statusMessage.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isSuccessMessage ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isSuccessMessage ? Colors.green : Colors.red,
                    ),
                  ),
                  child: Text(
                    _statusMessage,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _isSuccessMessage ? Colors.green[800] : Colors.red[800],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}