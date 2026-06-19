import 'package:flutter/material.dart';
import 'tab_salientes.dart';
import 'tab_entrantes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Taller de Intents'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.outbond), text: 'Salientes'),
              Tab(icon: Icon(Icons.inbox), text: 'Entrantes'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            TabSalientes(),
            TabEntrantes(),
          ],
        ),
      ),
    );
  }
}