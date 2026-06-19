import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class TabSalientes extends StatefulWidget {
  const TabSalientes({super.key});

  @override
  State<TabSalientes> createState() => _TabSalientesState();
}

class _TabSalientesState extends State<TabSalientes> {
  final TextEditingController _telefonoController =
      TextEditingController(text: '0987654321');

  XFile? _fotoCapturada;

  // ---------- PANEL 1: MARCADOR TELEFÓNICO ----------
  Future<void> _abrirMarcador() async {
    final telefono = _telefonoController.text.trim();
    if (telefono.isEmpty) {
      _mostrarError('Escribe un número primero');
      return;
    }

    // tel:xxxxxxxxxx → Android abre la app del teléfono con el número digitado
    final uri = Uri(scheme: 'tel', path: telefono);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _mostrarError('No hay app de teléfono instalada');
    }
  }

  // ---------- PANEL 2: TOMAR FOTO ----------
  Future<void> _tomarFoto() async {
    try {
      final picker = ImagePicker();
      final foto = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800, // limitamos tamaño para que no explote la memoria
      );

      if (foto != null) {
        setState(() {
          _fotoCapturada = foto;
        });
      }
    } catch (e) {
      _mostrarError('No se pudo abrir la cámara: $e');
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ============ PANEL 1: MARCADOR ============
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Panel 1 · Llamador Misterioso',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _telefonoController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _abrirMarcador,
                    icon: const Icon(Icons.call),
                    label: const Text('INICIAR DIAL'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ============ PANEL 2: CÁMARA ============
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Panel 2 · Foto Express',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.grey),
                      ),
                      child: _fotoCapturada == null
                          ? const Center(
                              child: Text('Sin miniatura'),
                            )
                          : Image.file(
                              File(_fotoCapturada!.path),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _tomarFoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('TOMAR FOTO'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}