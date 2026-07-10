import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../data/models/destination.dart';
import '../../../../shared/widgets/fade_in_widget.dart';

/// Card individual de un alojamiento.
///
/// Estructura visual (idéntica a Airbnb):
///   ┌─────────────────────────┐
///   │       [FOTO 1:1]        │
///   │              ♥ (heart)  │  ← Tappable, animación spring
///   ├─────────────────────────┤
///   │ Nombre                   │
///   │ Ubicación                │  ← gris
///   │ $120 USD por noche       │
///   │ ★ 4.94                   │
///   └─────────────────────────┘
///
/// PERFORMANCE: el widget está cubierto de comments explicando cada decisión.
class DestinationCard extends StatelessWidget {
  final Destination destination;
  final bool isWishlisted;
  final VoidCallback? onTap;
  final VoidCallback? onWishlistTap;
  final Duration fadeInDelay;

  const DestinationCard({
    super.key,
    required this.destination,
    required this.isWishlisted,
    required this.onTap,
    required this.onWishlistTap,
    required this.fadeInDelay,
  });

  @override
  Widget build(BuildContext context) {
    // RepaintBoundary: aísla el repaint de esta card del resto del scroll.
    // Si la foto se está cargando y dispara un repaint local, las otras cards
    // y el padre NO se re-pintan. Crítico para 60 FPS en listas largas.
    return RepaintBoundary(
      child: FadeInOnMounted(
        delay: fadeInDelay,
        child: Material(
          color: AppColors.canvas,
          borderRadius: BorderRadius.circular(14),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            // Splash de Material — el ripple aparece en toda la card al tap.
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PhotoArea(destination: destination, isWishlisted: isWishlisted, onWishlistTap: onWishlistTap),
                _InfoArea(destination: destination),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoArea extends StatelessWidget {
  final Destination destination;
  final bool isWishlisted;
  final VoidCallback? onWishlistTap;

  const _PhotoArea({
    required this.destination,
    required this.isWishlisted,
    required this.onWishlistTap,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      // Airbnb usa aspect ratio 1:1 en el feed mobile principal.
      aspectRatio: 1,
      child: Stack(
        children: [
          Positioned.fill(
            child: _CachedImage(url: destination.imageUrl),
          ),
          Positioned(
            top: 10, right: 10,
            child: _HeartButton(isFilled: isWishlisted, onTap: onWishlistTap),
          ),
        ],
      ),
    );
  }
}

class _CachedImage extends StatelessWidget {
  final String url;
  const _CachedImage({required this.url});

  @override
  Widget build(BuildContext context) {
    // CachedNetworkImage con memCacheWidth:
    //   - En vez de descargar la imagen al tamaño original (4K = 48 MB en RAM),
    //     forzamos a Flutter a decodificarla a 800 px de ancho.
    //   - El cache vive en RAM (rápido) y disco (persistente entre sesiones).
    //   - En el placeholder: shimmer suave para que la card no salte de tamaño.
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      memCacheWidth: 800,           // <-- clave para 60 FPS
      maxWidthDiskCache: 1200,
      fadeInDuration: const Duration(milliseconds: 250),
      placeholder: (context, _) => Container(
        color: AppColors.softSurface,
        child: const Center(
          child: SizedBox(
            width: 18, height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.foggy,
            ),
          ),
        ),
      ),
      errorWidget: (context, _, __) => Container(
        color: AppColors.softSurface,
        child: const Center(
          child: Icon(Icons.image_not_supported_outlined, color: AppColors.foggy),
        ),
      ),
    );
  }
}

class _HeartButton extends StatefulWidget {
  final bool isFilled;
  final VoidCallback? onTap;
  const _HeartButton({required this.isFilled, required this.onTap});

  @override
  State<_HeartButton> createState() => _HeartButtonState();
}

class _HeartButtonState extends State<_HeartButton>
    with SingleTickerProviderStateMixin {
  // Animación tipo "spring" al tap: el corazón escala de 1 → 1.3 → 1.
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 320),
    vsync: this,
    lowerBound: 0,
    upperBound: 1,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _bounce() {
    _controller
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    // Material + InkWell: el ripple se ve solo en el círculo de 32 px.
    return Material(
      color: Colors.black.withOpacity(.35),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: widget.onTap == null ? null : () {
          widget.onTap!();
          _bounce();
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              // Curva spring: 0 → 1.3 → 1 usando una parábola simple.
              final t = _controller.value;
              final scale = t == 0 ? 1.0 : (1 + 0.3 * 4 * t * (1 - t));
              return Transform.scale(scale: scale, child: child);
            },
            child: Icon(
              widget.isFilled ? Icons.favorite : Icons.favorite_border,
              size: 18,
              color: widget.isFilled ? AppColors.rausch : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoArea extends StatelessWidget {
  final Destination destination;
  const _InfoArea({required this.destination});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Airbnb muestra el nombre completo y la ubicación en dos líneas.
          Text(
            destination.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            destination.location.display,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.foggy,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          // Precio: la cifra va en bold.
          RichText(
            text: TextSpan(
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.2,
                fontFamily: 'Inter',
              ),
              children: [
                TextSpan(
                  text: '\$${destination.price.toStringAsFixed(0)} ',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const TextSpan(text: 'USD por noche'),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.star, size: 12, color: AppColors.ink),
              const SizedBox(width: 4),
              Text(
                destination.ratingFormatted,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (destination.isSuperhost) ...[
                const SizedBox(width: 6),
                const Text(
                  '· Superanfitrión',
                  style: TextStyle(
                    color: AppColors.foggy,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
