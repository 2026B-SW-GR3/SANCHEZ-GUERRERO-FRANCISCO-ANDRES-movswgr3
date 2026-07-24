import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const RepartidorApp());
}

class RepartidorApp extends StatelessWidget {
  const RepartidorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Repartidor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E3192),
          background: const Color(0xFFF5F5F7),
        ),
        useMaterial3: true,
      ),
      home: const PantallaPrincipal(),
    );
  }
}

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  // --- VARIABLES DE ESTADO ---
  bool _esperandoPedido = true;
  String _estadoTexto = 'Esperando asignación de pedido...';
  
  // Coordenadas
  LatLng? _restauranteUbicacion;
  LatLng? _clienteUbicacion;
  LatLng? _miUbicacionActual;

  // Controladores y suscripciones
  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionStream;

  // Canal de comunicación con Kotlin
  static const platform = MethodChannel('com.tu_equipo.app/repartidor_channel');

  // Marcadores del mapa
  Set<Marker> _marcadores = {};

  @override
  void initState() {
    super.initState();
    _solicitarPermisosYGPS();
    _configurarEscuchaMethodChannel();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  // 1. GESTIÓN DE PERMISOS Y GPS EN TIEMPO REAL
  Future<void> _solicitarPermisosYGPS() async {
    var status = await Permission.location.request();
    
    if (status.isGranted) {
      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((Position position) {
        _miUbicacionActual = LatLng(position.latitude, position.longitude);
        _actualizarMarcadorRepartidor(); // Actualiza el marcador azul sin romper los otros
      });
    } else {
      setState(() {
        _estadoTexto = 'Se requieren permisos de ubicación para trabajar.';
      });
    }
  }

  // 2. ESCUCHAR A KOTLIN (INTENT DE APP 1)
  void _configurarEscuchaMethodChannel() {
    platform.setMethodCallHandler((call) async {
      if (call.method == "recibirPedido") {
        final Map<dynamic, dynamic> args = call.arguments;
        
        setState(() {
          _restauranteUbicacion = LatLng(args['rest_lat'], args['rest_lng']);
          _clienteUbicacion = LatLng(args['client_lat'], args['client_lng']);
          _esperandoPedido = false; 
        });
        
        _configurarMarcadoresRuta();
      }
    });
  }

  // 3. CONFIGURAR MARCADORES (Garantiza el repintado del mapa)
  void _configurarMarcadoresRuta() {
    // Creamos un Set totalmente nuevo para forzar a GoogleMap a redibujar
    final Set<Marker> nuevosMarcadores = {};
    
    if (_restauranteUbicacion != null) {
      nuevosMarcadores.add(Marker(
        markerId: const MarkerId('restaurante'),
        position: _restauranteUbicacion!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Restaurante (Origen)'),
      ));
    }

    if (_clienteUbicacion != null) {
      nuevosMarcadores.add(Marker(
        markerId: const MarkerId('cliente'),
        position: _clienteUbicacion!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Cliente (Destino)'),
      ));
    }
    
    setState(() {
      _marcadores = nuevosMarcadores;
    });
    
    _actualizarMarcadorRepartidor();
  }

  // Actualizar mi posición (Azul) dinámicamente
  void _actualizarMarcadorRepartidor() {
    if (_miUbicacionActual == null) return;

    setState(() {
      // Clonamos el Set actual para modificarlo y forzar el refresco
      final Set<Marker> actualizados = Set.from(_marcadores);
      actualizados.removeWhere((m) => m.markerId.value == 'repartidor');
      
      actualizados.add(Marker(
        markerId: const MarkerId('repartidor'),
        position: _miUbicacionActual!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Tú'),
      ));
      
      _marcadores = actualizados;
    });
  }

  // 4. ACCIONES DE BOTONES
  void _centrarEnMiUbicacion() {
    if (_miUbicacionActual != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_miUbicacionActual!, 16.0),
      );
    }
  }

  Future<void> _iniciarRutaYEnviarAApp3() async {
    if (_miUbicacionActual == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Buscando señal GPS, espera...')),
      );
      return;
    }

    try {
      final String resultado = await platform.invokeMethod('enviarUbicacionApp3', {
        'lat': _miUbicacionActual!.latitude,
        'lng': _miUbicacionActual!.longitude,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resultado), backgroundColor: Colors.green),
      );
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.message}"), backgroundColor: Colors.red),
      );
    }
  }

  // --- BOTÓN DE PRUEBA (SOLO PARA DESARROLLO) ---
  void _simularLlegadaDePedido() {
    setState(() {
      _restauranteUbicacion = const LatLng(-0.180653, -78.467834);
      _clienteUbicacion = const LatLng(-0.175553, -78.472834);
      _esperandoPedido = false;
    });
    
    _configurarMarcadoresRuta();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Repartidor', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report, color: Colors.grey),
            onPressed: _simularLlegadaDePedido,
            tooltip: 'Simular Intent de App 1',
          )
        ],
      ),
      body: SafeArea(
        child: _esperandoPedido ? _buildPantallaEspera() : _buildPantallaMapa(),
      ),
    );
  }

  // INTERFAZ 1: Espera
  Widget _buildPantallaEspera() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            _estadoTexto,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // INTERFAZ 2: Mapa
  Widget _buildPantallaMapa() {
    return Stack(
      children: [
        GoogleMap(
          // ¡CLAVE! Si ya hay un restaurante, centramos el mapa ahí en vez de en ti
          initialCameraPosition: CameraPosition(
            target: _restauranteUbicacion ?? _miUbicacionActual ?? const LatLng(0, 0),
            zoom: 13.5, // Un poco más alejado para que se vean más elementos
          ),
          markers: _marcadores,
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          onMapCreated: (controller) => _mapController = controller,
        ),
        
        Positioned(
          bottom: 20,
          right: 20,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: 'btn1',
                backgroundColor: Colors.white,
                onPressed: _centrarEnMiUbicacion,
                child: const Icon(Icons.my_location, color: Colors.black87),
              ),
              const SizedBox(height: 15),
              ExtendedFloatingActionButton(
                onPressed: _iniciarRutaYEnviarAApp3,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ExtendedFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  
  const ExtendedFloatingActionButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: 'btn2',
      backgroundColor: const Color(0xFF2E3192),
      onPressed: onPressed,
      icon: const Icon(Icons.navigation, color: Colors.white),
      label: const Text('Iniciar Ruta', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}
