import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp se mantiene lo más simple posible.
    // Nada de ThemeColors ni configuraciones de idioma de Flutter.
    return const MaterialApp(
      title: 'Taller Multiplataforma EPN',
      debugShowCheckedModeBanner: false,
      home: NativeResourcePage(),
    );
  }
}

class NativeResourcePage extends StatefulWidget {
  const NativeResourcePage({super.key});

  @override
  State<NativeResourcePage> createState() => _NativeResourcePageState();
}

// WidgetsBindingObserver es mandatorio aquí. 
// Te permite escuchar eventos del sistema operativo (rotación, cambio de idioma).
class _NativeResourcePageState extends State<NativeResourcePage> with WidgetsBindingObserver {
  // El canal debe coincidir EXACTAMENTE con el definido en MainActivity.kt
  static const platform = MethodChannel('com.epn.taller/resources');

  // Estado inicial por defecto mientras se resuelve la promesa del canal nativo.
  String _texto = "Consultando a Android...";
  Color _textColor = Colors.black;
  Color _bgColor = Colors.white;

  @override
  void initState() {
    super.initState();
    // Registrar este widget como observador de los cambios del sistema
    WidgetsBinding.instance.addObserver(this);
    // Primera llamada al cargar la vista
    _updateFromNative();
  }

  @override
  void dispose() {
    // Evitar fugas de memoria
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Se dispara cuando rotas la pantalla o cambias el tamaño de la ventana
  @override
  void didChangeMetrics() {
    _updateFromNative();
  }

  // Se dispara cuando cambias el idioma del dispositivo
  @override
  void didChangeLocales(List<Locale>? locales) {
    _updateFromNative();
  }

  // La función core que cruza el puente hacia Kotlin/Java
  Future<void> _updateFromNative() async {
    try {
      final Map<dynamic, dynamic> result = await platform.invokeMethod('getNativeResources');
      
      setState(() {
        _texto = result['text'] ?? "Valor nulo desde Android";
        // Convertir el Hex de Android (#FFFFFF) a Color de Flutter (0xFFFFFFFF)
        _textColor = Color(int.parse((result['textColor'] as String).replaceFirst('#', '0xFF')));
        _bgColor = Color(int.parse((result['bgColor'] as String).replaceFirst('#', '0xFF')));
      });
    } on PlatformException catch (e) {
      // Si esto se muestra, tu código Kotlin está mal o el canal no coincide.
      setState(() {
        _texto = "Fallo de conexión nativa: ${e.message}";
        _textColor = Colors.red;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // La UI es estúpida a propósito. Solo refleja lo que las variables de estado digan.
    return Scaffold(
      backgroundColor: _bgColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            _texto,
            style: TextStyle(
              color: _textColor,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}