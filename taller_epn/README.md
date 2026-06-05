Proyecto Integrador: Red, Persistencia Dual y Seguridad Móvil

📋 Descripción del Proyecto

Este proyecto consiste en una aplicación móvil híbrida desarrollada en Flutter que integra comunicación de red asíncrona mediante servicios web externos (REST API), una arquitectura de persistencia local híbrida con conmutación dinámica en caliente (SQL vs NoSQL), y mecanismos nativos de almacenamiento seguro en el sistema operativo Android.

La aplicación está diseñada bajo principios estrictos de desacoplamiento de capas lógicas, experiencia de usuario fluida (con control de estados de carga) y auditoría mediante trazas y logs estructurados.

🛠️ Módulos Implementados

🌐 Módulo 1: Conectividad y Consumo REST (JSONPlaceholder)

Consulta Asíncrona (GET): Recuperación reactiva de publicaciones individuales usando el ID ingresado por el usuario.

Actualización Simulada (PUT): Modificación local de datos y envío de carga útil JSON. Sincronización visual condicionada a la obtención del código de estado 200 OK emitido por el servidor.

Control de Hilos y Estados de Carga: Deshabilitación interactiva de widgets y campos de entrada de datos mientras las llamadas de red están en tránsito (preventing UI blocking/overlapping).

🗄️ Módulo 2: Arquitectura de Persistencia Dual (SQL vs NoSQL)

Patrón Repositorio: Abstracción unificada mediante una interfaz común para aislar las capas lógicas de renderizado de la base de datos real.

Persistencia Relacional (SQL): Almacenamiento estructurado bajo esquema rígido mediante SQLite (sqflite).

Persistencia No Relacional (NoSQL): Almacenamiento ágil de objetos estructurados mediante Hive.

Conmutación en Tiempo de Ejecución: Selector interactivo (Switch) en la App Bar que redefine el puntero del repositorio en caliente y redibuja la interfaz de usuario de forma instantánea.

Logs de Auditoría: Trazabilidad estricta impresa en consola con etiquetas descriptivas ([INFO], [DEBUG], [ERROR]).

🔐 Módulo 3: Almacenamiento Seguro y Transaccional

Implementación de persistencia local tipo clave-valor orientada a la seguridad física del terminal (sin listar llaves, bajo principio de conocimiento previo):

SharedPreferences: Almacenamiento rápido no sensible en texto plano nativo de Android.

DataStore (Simulado): Almacenamiento moderno, asíncrono y reactivo basado en lecturas/escrituras aisladas que evita bloqueos del hilo de UI.

EncryptedSharedPreferences: Cifrado automático simétrico a nivel de disco (AES-256 SIV para llaves y AES-128 GCM para valores) apoyado en las APIs nativas de Google Tink e integrado mediante el Android Keystore.

🏗️ Patrones de Diseño & Arquitectura

Desacoplamiento Lógico (Repository Pattern)

La interfaz de usuario no conoce qué base de datos está operando por debajo. El switch de la App Bar interactúa directamente con el contrato definido en LocalRepository, permitiendo inyectar dinámicamente la dependencia correspondiente:

abstract class LocalRepository {
  Future<void> init();
  Future<List<DbItem>> getAllItems();
  Future<void> insertItem(DbItem item);
  Future<void> deleteItem(String id);
}


🚀 Requisitos e Instalación

Prerrequisitos

Flutter SDK: >=3.0.0

Dart SDK: >=3.0.0

Android SDK: API Level 23 (Android 6.0) o superior para soporte de almacenamiento cifrado.

Dispositivo Físico: Con depuración USB habilitada en opciones de desarrollador.

Configuración del Manifiesto de Android (Acceso a Red)

Asegúrese de que el permiso de Internet esté debidamente declarado en el manifiesto principal (android/app/src/main/AndroidManifest.xml) justo antes de la etiqueta <application>:

<uses-permission android:name="android.permission.INTERNET"/>


Instale y sincronice los paquetes de Flutter registrados en el pubspec.yaml:

flutter pub get


Ejecute una limpieza profunda del motor de compilación por seguridad:

flutter clean


Conecte su terminal Android por USB (verifique su detección con flutter devices) y compile en vivo:

flutter run


🧪 Pruebas Unitarias Automatizadas

El proyecto cuenta con una suite de pruebas para verificar el aislamiento y la conmutación de repositorios locales sin dependencias del emulador.

Para ejecutar los tests automáticos locales de Dart, abra la consola en la raíz de su proyecto y corra:

flutter test test/repository_test.dart


Resultado Esperado de la Terminal:

00:01 +2: Pruebas Unitarias de Persistencia Dual - FIS EPN: Prueba 1: Guardado e Independencia en Motor Relacional SQL
00:01 +2: Pruebas Unitarias de Persistencia Dual - FIS EPN: Prueba 2: Conmutación y Aislamiento del Motor NoSQL (Hive)
00:01 +2: All tests passed!
