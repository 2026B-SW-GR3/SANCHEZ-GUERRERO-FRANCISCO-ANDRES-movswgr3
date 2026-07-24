package com.example.app_repartidor

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    // 1. Definimos el nombre del canal de comunicación. DEBE ser igual en Flutter.
    private val CHANNEL = "com.tu_equipo.app/repartidor_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 2. CONFIGURAMOS PARA ESCUCHAR LO QUE MANDA FLUTTER (Enviar a App 3)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "enviarUbicacionApp3") {
                // Obtenemos las coordenadas enviadas desde Dart
                val lat = call.argument<Double>("lat") ?: 0.0
                val lng = call.argument<Double>("lng") ?: 0.0

                // Creamos el Intent para la App 3 (Central de Control)
                val intentApp3 = Intent("com.tu_equipo.app.UBICACION_EN_VIVO")
                // ¡IMPORTANTE! Aquí va el paquete real de la App 3 de tu compañero
                intentApp3.setPackage("com.example.app_central") 
                intentApp3.putExtra("driver_lat", lat)
                intentApp3.putExtra("driver_lng", lng)
                intentApp3.putExtra("estado_ruta", "EN_CAMINO")

                try {
                    startActivity(intentApp3)
                    result.success("Ubicación enviada a App 3 exitosamente")
                } catch (e: Exception) {
                    result.error("ERROR", "No se pudo abrir App 3. ¿Está instalada?", null)
                }
            } else {
                result.notImplemented()
            }
        }

        // 3. Revisamos si la app se abrió mediante un Intent de la App 1
        handleIntent(intent)
    }

    // 4. Esta función atrapa Intents si la app ya estaba abierta en segundo plano
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    // 5. FUNCIÓN QUE ATRAPA EL INTENT DE LA APP 1 Y SE LO MANDA A FLUTTER
    private fun handleIntent(intent: Intent) {
        if (intent.action == "com.tu_equipo.app.NUEVO_PEDIDO") {
            // Extraemos los datos enviados por el Restaurante
            val restLat = intent.getDoubleExtra("rest_lat", 0.0)
            val restLng = intent.getDoubleExtra("rest_lng", 0.0)
            val clientLat = intent.getDoubleExtra("client_lat", 0.0)
            val clientLng = intent.getDoubleExtra("client_lng", 0.0)

            // Empaquetamos en un Map para mandarlo a Flutter
            val dataParaFlutter = mapOf(
                "rest_lat" to restLat,
                "rest_lng" to restLng,
                "client_lat" to clientLat,
                "client_lng" to clientLng
            )

            // Enviamos la info a Flutter por el canal
            flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                MethodChannel(messenger, CHANNEL).invokeMethod("recibirPedido", dataParaFlutter)
            }
        }
    }
}