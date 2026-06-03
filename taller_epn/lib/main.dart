// Archivo: lib/main.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'post_screen.dart';               // Módulo 1 (Red)
import 'screens/crud_screen.dart';         // Módulo 2 (CRUD Dual)
import 'screens/secrets_screen.dart';     // Módulo 3 (Almacenamiento Seguro)

void main() async {
  // Asegura la inicialización de los componentes nativos de Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Hive de manera asíncrona para el Módulo 2
  await Hive.initFlutter();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taller EPN - Solución Completa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: Colors.blueAccent,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // Lista con las 3 pantallas de cada módulo del Taller
  final List<Widget> _screens = [
    const PostScreen(),     // Índice 0
    const CrudScreen(),     // Índice 1
    const SecretsScreen(),  // Índice 2 (Nuevo Módulo)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud_sync),
            label: 'Módulo 1 (Red)',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storage),
            label: 'Módulo 2 (CRUD)',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.security),
            label: 'Módulo 3 (Seguridad)',
          ),
        ],
      ),
    );
  }
}