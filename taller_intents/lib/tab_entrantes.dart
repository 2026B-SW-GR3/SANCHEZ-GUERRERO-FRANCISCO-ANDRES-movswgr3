import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_handler/share_handler.dart';

class TabEntrantes extends StatefulWidget {
  const TabEntrantes({super.key});

  @override
  State<TabEntrantes> createState() => _TabEntrantesState();
}

class _TabEntrantesState extends State<TabEntrantes> {
  String? _textoRecibido;
  String? _rutaImagen;
  String _estado = 'Esperando datos externos...';
  bool _esImagen = false;

  @override
  void initState() {
    super.initState();
    _escucharShares();
  }

  void _escucharShares() async {
    // 1) Cold start: la app SE ABRIÓ desde un share
    final handler = ShareHandlerPlatform.instance;
    final initial = await handler.getInitialSharedMedia();
    if (initial != null && mounted) {
      _procesar(initial);
    }

    // 2) Warm start: la app YA estaba abierta y llega un share nuevo
    handler.sharedMediaStream.listen((media) {
      if (mounted) _procesar(media);
    });
  }

  void _procesar(SharedMedia media) {
    setState(() {
      // Caso 1: nos compartieron TEXTO
      if (media.content != null && media.content!.isNotEmpty) {
        _textoRecibido = media.content;
        _rutaImagen = null;
        _esImagen = false;
        _estado = 'Recibí un TEXTO';
      }
      // Caso 2: nos compartieron ARCHIVOS (imagen, video, etc.)
      else if (media.attachments != null && media.attachments!.isNotEmpty) {
        final adjunto = media.attachments!.first;
        if (adjunto?.type == SharedAttachmentType.image) {
          _rutaImagen = adjunto?.path;
          _textoRecibido = null;
          _esImagen = true;
          _estado = 'Recibí una IMAGEN';
        } else {
          _estado = 'Recibí un archivo (${adjunto?.type.name})';
        }
      }
    });
  }

  void _limpiar() {
    setState(() {
      _textoRecibido = null;
      _rutaImagen = null;
      _esImagen = false;
      _estado = 'Esperando datos externos...';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ============ INDICADOR DE ESTADO ============
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _esImagen
                  ? Colors.orange.shade100
                  : (_textoRecibido != null
                      ? Colors.green.shade100
                      : Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  _esImagen
                      ? Icons.image
                      : (_textoRecibido != null
                          ? Icons.text_fields
                          : Icons.hourglass_empty),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text('Estado: $_estado')),
                if (_textoRecibido != null || _rutaImagen != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _limpiar,
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ============ CAJA DE TEXTO ============
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Receptor de Chismes (texto)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    constraints: const BoxConstraints(minHeight: 100),
                    child: Text(
                      _textoRecibido ??
                          (_esImagen
                              ? '⚠️ El último dato recibido es una imagen, no texto.'
                              : 'Comparte algo desde otra app para ver el texto aquí.'),
                      style: TextStyle(
                        color: _textoRecibido != null
                            ? Colors.black87
                            : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ============ CONTENEDOR DE IMAGEN ============
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lector de Imágenes',
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
                      child: _rutaImagen != null
                          ? Image.file(File(_rutaImagen!), fit: BoxFit.cover)
                          : Center(
                              child: Text(
                                _textoRecibido != null
                                    ? '⚠️ El último dato recibido es texto, no imagen.'
                                    : 'Comparte una foto desde otra app.',
                                textAlign: TextAlign.center,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ============ INSTRUCCIONES ============
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('📋 ¿Cómo probar?',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text('1. Abre Chrome o WhatsApp.'),
                  Text('2. Comparte un enlace o foto.'),
                  Text('3. Elige "Taller de Intents" en la lista.'),
                  Text('4. Si ya está abierta, NO debe crashear.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}