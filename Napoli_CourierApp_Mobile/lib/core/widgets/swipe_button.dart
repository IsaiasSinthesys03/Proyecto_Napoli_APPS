import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';

class SwipeButton extends StatefulWidget {
  final String label;
  final VoidCallback onSwipe;
  final Color activeColor;
  final Color thumbColor;
  final Color textColor;
  final IconData icon;
  final bool isEnabled;

  const SwipeButton({
    super.key,
    required this.label,
    required this.onSwipe,
    this.activeColor = AppColors.primaryGreen,
    this.thumbColor = AppColors.white,
    this.textColor = AppColors.white,
    this.icon = Icons.chevron_right,
    this.isEnabled = true,
  });

  @override
  State<SwipeButton> createState() => _SwipeButtonState();
}

class _SwipeButtonState extends State<SwipeButton> {
  double _dragValue = 0.0;
  bool _isConfirmed = false;
  final double _height = 56.0;
  final double _padding = 4.0;

  @override
  void didUpdateWidget(SwipeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.label != oldWidget.label) {
      setState(() {
        _isConfirmed = false;
        _dragValue = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final draggableWidth = maxWidth - _height;

        return Container(
          height: _height,
          decoration: BoxDecoration(
            color: widget.isEnabled
                ? widget.activeColor
                : AppColors.dividerLight,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: (widget.isEnabled ? widget.activeColor : Colors.grey)
                    .withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  widget.label.toUpperCase(),
                  style: AppTextStyles.button.copyWith(
                    color: widget.isEnabled
                        ? widget.textColor
                        : AppColors.textSecondaryLight,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              if (widget.isEnabled && !_isConfirmed)
                Positioned(
                  left: _dragValue,
                  top: _padding,
                  bottom: _padding,
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      setState(() {
                        _dragValue = (_dragValue + details.delta.dx).clamp(
                          0.0,
                          draggableWidth,
                        );
                      });
                    },
                    onHorizontalDragEnd: (details) {
                      if (_dragValue >= draggableWidth * 0.85) {
                        setState(() {
                          _dragValue = draggableWidth;
                          _isConfirmed = true;
                        });
                        widget.onSwipe();
                      } else {
                        setState(() {
                          _dragValue = 0.0;
                        });
                      }
                    },
                    child: Container(
                      width: _height - (_padding * 2),
                      height: _height - (_padding * 2),
                      decoration: BoxDecoration(
                        color: widget.thumbColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.activeColor,
                        size: 24,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
