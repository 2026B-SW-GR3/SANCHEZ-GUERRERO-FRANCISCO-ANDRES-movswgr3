import 'package:flutter/material.dart';

/// Widget que aplica un **fade-in con opcional slide-up** cuando se monta.
///
/// ¿Por qué es clave para rendimiento?
///
/// - Solo se anima UNA VEZ: al construirse el widget (que ocurre cuando la
///   card entra al viewport del ListView.builder).
/// - Usa `AnimatedBuilder` con `child` para que SOLO el `Opacity` se
///   reconstruya por frame. El hijo real no se rebuildea.
/// - Una vez terminada la animación (controller.value == 1), el AnimationController
///   ya no hace nada — no consume CPU.
///
/// Stagger pattern: si pasas un `delay`, varias cards pueden aparecer
/// escalonadas (efecto cascada) sin sobrecargar la pipeline.
class FadeInOnMounted extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;

  /// Si `true`, agrega un pequeño slide vertical (8 px hacia arriba)
  /// al fade, dando sensación de "flotar hacia adentro".
  final bool withSlide;

  const FadeInOnMounted({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 380),
    this.delay = Duration.zero,
    this.withSlide = true,
  });

  @override
  State<FadeInOnMounted> createState() => _FadeInOnMountedState();
}

class _FadeInOnMountedState extends State<FadeInOnMounted>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: widget.duration,
    vsync: this,
    value: 0,
  );

  @override
  void initState() {
    super.initState();
    // Programamos la animación DESPUÉS del primer frame para no trabar
    // el primer paint. Si esto se ejecuta en initState() sincrónicamente,
    // el primer frame incluiría la animación parcialmente ejecutada.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.delay == Duration.zero) {
        _controller.forward();
      } else {
        Future.delayed(widget.delay, () {
          if (mounted) _controller.forward();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // AnimatedBuilder con child: el `child` no se reconstruye por frame,
    // solo el builder (que es barato: un Opacity + Transform.translate).
    // Esto es fundamental para 60 FPS — el SlideTransform es O(1) por frame.
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        // Curva de salida: la animación arranca suave y se asienta al final
        // (igual que la curva `easeOutCubic`).
        final eased = 1 - (1 - t) * (1 - t) * (1 - t);
        return Opacity(
          opacity: eased,
          child: widget.withSlide
              ? Transform.translate(
                  offset: Offset(0, 8 * (1 - eased)),
                  child: child,
                )
              : child,
        );
      },
      child: widget.child,
    );
  }
}
