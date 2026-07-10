import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

/// Logo simplificado de Airbnb (texto estilizado).
///
/// En la app real es el símbolo Bélo (formas personalizadas). Para este clon
/// académico usamos el wordmark textual con la tipografía Inter y color Rausch,
/// ya que replicar el Bélo requiere un SVG/Path complejo.
class AirbnbLogo extends StatelessWidget {
  /// Tamaño del texto: 22 (header), 32 (splash), etc.
  final double size;

  /// Color del logo (por defecto Rausch).
  final Color color;

  const AirbnbLogo({
    super.key,
    this.size = 22,
    this.color = AppColors.rausch,
  });

  @override
  Widget build(BuildContext context) {
    // Importante: usamos `RichText` + `TextSpan` para mezclar pesos dentro del
    // mismo wordmark (la "b" final suele ir en negrita como brand mark).
    return Text(
      'airbnb',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: color,
        fontSize: size,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.6, // apretado para look de marca
        height: 1.0,
      ),
    );
  }
}

/// Avatar circular que aparece en la esquina derecha del AppBar.
/// Equivale al menú de usuario de Airbnb (versión simplificada).
class ProfileButton extends StatelessWidget {
  const ProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Material(
        // Material necesario para que el InkWell tenga superficie donde pintar el ripple.
        color: AppColors.canvas,
        shape: const CircleBorder(
          side: BorderSide(color: AppColors.hairline, width: 1),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Abrir perfil (placeholder)')),
            );
          },
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(Icons.person_outline, size: 22, color: AppColors.ink),
          ),
        ),
      ),
    );
  }
}

