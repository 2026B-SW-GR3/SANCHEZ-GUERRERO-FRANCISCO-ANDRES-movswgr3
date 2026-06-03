// Archivo: lib/services/security_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

class SecurityService {
  // Instancia de almacenamiento cifrado (Mapea a EncryptedSharedPreferences en Android)
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true, // Requisito estricto del taller
    ),
  );

  // --- 1. SHAPEDPREFERENCES (Simple No Sensible) ---
  Future<void> saveInSharedPreferences(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> getFromSharedPreferences(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  // --- 2. DATASTORE (Simulado mediante archivo asíncrono asilado) ---
  // Jetpack DataStore funciona guardando datos en un archivo local de forma asíncrona.
  // Simulamos esta arquitectura exacta escribiendo de forma segura en un JSON local.
  Future<File> _getDataStoreFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/epn_datastore.json');
  }

  Future<void> saveInDataStore(String key, String value) async {
    final file = await _getDataStoreFile();
    Map<String, dynamic> data = {};
    
    if (await file.exists()) {
      final content = await file.readAsString();
      if (content.isNotEmpty) {
        data = json.decode(content);
      }
    }
    
    data[key] = value;
    await file.writeAsString(json.encode(data));
  }

  Future<String?> getFromDataStore(String key) async {
    final file = await _getDataStoreFile();
    if (!await file.exists()) return null;
    
    final content = await file.readAsString();
    if (content.isEmpty) return null;
    
    final Map<String, dynamic> data = json.decode(content);
    return data[key]?.toString();
  }

  // --- 3. ENCRYPTED SHAREDPREFERENCES (Cifrado Automático) ---
  Future<void> saveInEncrypted(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> getFromEncrypted(String key) async {
    return await _secureStorage.read(key: key);
  }
}