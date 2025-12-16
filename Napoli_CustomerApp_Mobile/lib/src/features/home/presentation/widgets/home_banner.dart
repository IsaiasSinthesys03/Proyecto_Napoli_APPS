import 'package:flutter/material.dart';
import 'package:napoli_app_v1/src/core/core_ui/theme.dart';
import 'package:napoli_app_v1/src/core/services/promotion_service.dart';
import 'package:napoli_app_v1/src/di.dart';
import 'dart:math' as math;

/// Dynamic banner that fetches promotions from Supabase.
/// Shows nothing if no active promotions exist.
class HomeBanner extends StatefulWidget {
  const HomeBanner({super.key});

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bannerController;
  late final Animation<double> _bannerAnim;
  Promotion? _promotion;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _bannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _bannerAnim = CurvedAnimation(
      parent: _bannerController,
      curve: Curves.easeInOut,
    );
    _loadPromotion();
  }

  Future<void> _loadPromotion() async {
    try {
      final promotionService = getIt<PromotionService>();
      final promotion = await promotionService.getFeaturedPromotion();
      if (mounted) {
        setState(() {
          _promotion = promotion;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Hide banner while loading or if no promotion exists
    if (_isLoading || _promotion == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final promotion = _promotion!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AnimatedBuilder(
        animation: _bannerAnim,
        builder: (context, child) {
          final dx = math.sin(_bannerAnim.value * math.pi * 2) * 6;
          final opacity = 0.9 + 0.1 * _bannerAnim.value;
          return Transform.translate(
            offset: Offset(dx, 0),
            child: Opacity(opacity: opacity, child: child),
          );
        },
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background - use banner image if available, otherwise gradient
                if (promotion.bannerUrl != null)
                  Image.network(
                    promotion.bannerUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildGradient(),
                  )
                else
                  _buildGradient(),
                // Content overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.black.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                ),
                // Text content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icons/etiqueta.png',
                        width: 44,
                        height: 44,
                        color: AppColors.white,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        promotion.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w800,
                          shadows: [
                            Shadow(
                              color: AppColors.black.withValues(alpha: 0.3),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        promotion.discountDescription,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.white,
                          shadows: [
                            Shadow(
                              color: AppColors.black.withValues(alpha: 0.25),
                              offset: const Offset(0, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradient() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.fireOrange,
            AppColors.primaryRed,
            AppColors.toastedRed,
          ],
        ),
      ),
    );
  }
}
