import 'package:flutter/material.dart';

// Definimos una constante global para el color Esmeralda personalizado (Hex: 10B981)
// Esto soluciona por completo el error de "Colors.emerald isn't defined"
const Color _emeraldColor = Color(0xFF10B981);

// Nuevas constantes de color de la paleta clara solicitada
const Color _bgColor = Color(0xFFFDFBF7);
const Color _textColor = Color(0xFF2C3238);
const Color _buttonColor = Color(0xFF043353);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      restorationScopeId: 'app_root',
      title: 'Taller de Ciclo de Vida',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light, // Cambiamos al tema claro
        scaffoldBackgroundColor: _bgColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _buttonColor,
          brightness: Brightness.light,
          primary: _buttonColor,
          secondary: const Color(0xFF0B5282), // Azul complementario
          surface: Colors.white, 
        ),
      ),
      home: const CounterPage(),
    );
  }
}

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> 
    with RestorationMixin, WidgetsBindingObserver {
  
  // Mantenemos la lógica de persistencia intacta
  final RestorableInt _counter = RestorableInt(0);

  @override
  String? get restorationId => 'counter_page_state';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_counter, 'counter_value');
  }

  @override
  void initState() {
    super.initState();
    debugPrint('=== LIFECYCLE: initState() -> equivalente a onCreate/onStart ===');
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    debugPrint('=== LIFECYCLE: dispose() -> equivalente a onDestroy ===');
    WidgetsBinding.instance.removeObserver(this);
    _counter.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint('LIFECYCLE: AppLifecycleState.resumed -> equivalente a onResume');
        break;
      case AppLifecycleState.inactive:
        debugPrint('LIFECYCLE: AppLifecycleState.inactive -> equivalente a onPause');
        break;
      case AppLifecycleState.hidden:
        debugPrint('LIFECYCLE: AppLifecycleState.hidden -> la UI ya no es visible');
        break;
      case AppLifecycleState.paused:
        debugPrint('LIFECYCLE: AppLifecycleState.paused -> equivalente a onStop');
        break;
      case AppLifecycleState.detached:
        debugPrint('LIFECYCLE: AppLifecycleState.detached -> equivalente a onDestroy (Engine detached)');
        break;
    }
  }

  void _incrementCounter() {
    setState(() {
      _counter.value++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: _bgColor, // Usamos el nuevo color de fondo
      appBar: AppBar(
        title: const Text(
          'DASHBOARD DE PERSISTENCIA',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: _textColor, // Texto oscuro en el AppBar
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: SafeArea(
        // SOLUCIÓN: Center + SingleChildScrollView evitan el overflow en horizontal (image_121ebd.jpg)
        // y permiten hacer scroll verticalmente cuando la pantalla no tiene suficiente altura.
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(), // Efecto de rebote agradable al hacer scroll
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  
                  // 1. PANTALLA DIGITAL (Muestra el número aumentando)
                  Container(
                    width: 280,
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white, // Tarjeta blanca para el tema claro
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: _buttonColor.withValues(alpha: 0.1),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _buttonColor.withValues(alpha: 0.05), // Sombra muy sutil
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'VALOR REGISTRADO',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: _buttonColor.withValues(alpha: 0.7),
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${_counter.value}',
                          style: TextStyle(
                            fontSize: 84,
                            fontWeight: FontWeight.w900,
                            color: _textColor, // Nuevo color de texto (#2C3238)
                            letterSpacing: -2,
                            height: 1.1,
                            shadows: [
                              Shadow(
                                color: _buttonColor.withValues(alpha: 0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 60),

                  // 2. BOTÓN CIRCULAR TÁCTIL EN EL MEDIO
                  GestureDetector(
                    onTap: _incrementCounter,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            _buttonColor, // Color principal solicitado (#043353)
                            Color(0xFF135A8C), // Variación un poco más clara para dar relieve
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _buttonColor.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add_rounded,
                          size: 56,
                          color: Colors.white, // Ícono blanco para buen contraste
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),

                  // 3. INDICADOR ACADÉMICO DE ESTADO PERSISTENTE
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0x1A10B981), // Mantenemos el fondo esmeralda claro
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0x4D10B981),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: _emeraldColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'RestorationMixin Activo',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF059669), // Verde un poco más oscuro para leerse bien en fondo claro
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}