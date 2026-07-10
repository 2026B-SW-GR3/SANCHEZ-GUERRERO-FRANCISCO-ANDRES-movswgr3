// Test de smoke: la app debe arrancar sin crashear.
//
// El test que viene por defecto en `flutter create` referencia una clase
// `MyApp` que ya no existe (renombramos a `AirbnbCloneApp`).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:airbnb_clone/main.dart';

void main() {
  testWidgets('La app boota sin lanzar excepciones', (WidgetTester tester) async {
    await tester.pumpWidget(const AirbnbCloneApp());
    // Confirmá que el MaterialApp está montado.
    expect(find.byType(MaterialApp), findsOneWidget);
    // Confirmá que el Scaffold raíz (HomeScreen) está montado.
    expect(find.byType(Scaffold), findsWidgets);
  });
}
