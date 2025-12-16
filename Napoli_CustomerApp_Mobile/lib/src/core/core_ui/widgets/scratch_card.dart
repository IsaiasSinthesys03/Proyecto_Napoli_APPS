import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'scratch_painters.dart';
import 'scratch_overlay.dart';

/// Widget de scratch card mejorado con sonidos y efectos visuales
class ScratchCard extends StatefulWidget {
  final String hiddenText;
  final VoidCallback? onRevealed;

  const ScratchCard({super.key, required this.hiddenText, this.onRevealed});

  @override
  State<ScratchCard> createState() => _ScratchCardState();
}

class _ScratchCardState extends State<ScratchCard>
    with SingleTickerProviderStateMixin {
  final List<Offset> _scratchedPoints = [];
  // final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRevealed = false;
  bool _isScratching = false;
  double _scratchProgress = 0.0;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  static const _revealThreshold = 60;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 50),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 3).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    // _audioPlayer.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _playScratchSound() {
    // Nota: Por ahora sin asset de sonido, pero la estructura está lista
    // _audioPlayer.play(AssetSource('sounds/scratch.mp3'), volume: 0.3);
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isScratching = true;
    });
    _playScratchSound();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isRevealed) return;

    setState(() {
      _scratchedPoints.add(details.localPosition);
      _scratchProgress = math.min(
        _scratchedPoints.length / _revealThreshold,
        1.0,
      );

      if (_scratchedPoints.length > _revealThreshold && !_isRevealed) {
        _isRevealed = true;
        _isScratching = false;
        widget.onRevealed?.call();
      }
    });

    // Efecto de vibración visual
    _shakeController.forward(from: 0);
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isScratching = false;
      _scratchedPoints.add(Offset.infinite); // Marcador para separar trazos
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            _shakeAnimation.value * (math.Random().nextBool() ? 1 : -1),
            0,
          ),
          child: child,
        );
      },
      child: GestureDetector(
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: Builder(
          builder: (context) {
            // Usar MediaQuery en lugar de LayoutBuilder para evitar consultas intrínsecas
            final screenW = MediaQuery.of(context).size.width;
            final cardWidth = math.min(screenW * 0.9, 320.0);
            final maxCardHeight = MediaQuery.of(context).size.height * 0.45;
            final cardHeight = math.min(
              cardWidth * 0.64,
              maxCardHeight,
            ); // limitar altura para diálogos
            final scale =
                cardWidth / 280.0; // factor para escalar iconos y textos
            final theme = Theme.of(context);

            return Container(
              width: cardWidth,
              height: cardHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20 * scale),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withValues(alpha: 0.2),
                    blurRadius: 12 * scale,
                    offset: Offset(0, 6 * scale),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20 * scale),
                child: Stack(
                  children: [
                    // Contenido oculto (el cupón) - fondo sólido para cuando se revele
                    Container(
                      color: theme.colorScheme.surface,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.card_giftcard,
                              size: 48 * scale,
                              color: theme.colorScheme.primary,
                            ),
                            SizedBox(height: 12 * scale),
                            Text(
                              widget.hiddenText,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 32 * scale,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                                letterSpacing: 3 * scale,
                                shadows: [
                                  Shadow(
                                    color: theme.shadowColor.withValues(
                                      alpha: 0.08,
                                    ),
                                    offset: Offset(2 * scale, 2 * scale),
                                    blurRadius: 4 * scale,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 8 * scale),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16 * scale,
                                vertical: 6 * scale,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(20 * scale),
                              ),
                              child: Text(
                                '¡GANASTE!',
                                style: TextStyle(
                                  fontSize: 16 * scale,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                  letterSpacing: 2 * scale,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Capa de scratch (se va revelando)
                    if (!_isRevealed)
                      CustomPaint(
                        painter: ScratchPainter(
                          _scratchedPoints,
                          strokeWidth: 45 * scale,
                          circleRadius: 22.5 * scale,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            // Usar un degradado verde -> rojo para la capa superior del rasca
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.secondary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Textura de puntos plateados
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: TexturePainter(
                                    scale,
                                    theme.colorScheme.onSurface.withValues(
                                      alpha: 0.08,
                                    ),
                                  ),
                                ),
                              ),
                              // Instrucciones
                              ScratchOverlay(
                                isScratching: _isScratching,
                                isRevealed: _isRevealed,
                                scratchProgress: _scratchProgress,
                                scale: scale,
                                cardWidth: cardWidth,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
