import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:napoli_app_v1/src/core/core_ui/theme.dart';
import 'package:napoli_app_v1/src/core/core_ui/widgets/order_stepper.dart';
import 'package:napoli_app_v1/src/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:napoli_app_v1/src/di.dart';

import 'package:napoli_app_v1/l10n/app_localizations.dart';

class OrderPlacedScreen extends StatefulWidget {
  const OrderPlacedScreen({super.key});

  @override
  State<OrderPlacedScreen> createState() => _OrderPlacedScreenState();
}

class _OrderPlacedScreenState extends State<OrderPlacedScreen> {
  int _currentStep = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startOrderProgress();
  }

  void _startOrderProgress() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentStep < 3) {
        setState(() {
          _currentStep++;
        });
      } else {
        timer.cancel();
        _showRatingDialog();
      }
    });
  }

  void _showRatingDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          children: [
            Icon(
              Icons.star_rounded,
              color: Theme.of(context).colorScheme.secondary,
              size: 60,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.orderDelivered,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.rateExperience,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withAlpha((0.7 * 255).round()),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: const Icon(Icons.star_rounded),
                  iconSize: 36,
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  color: Theme.of(context).colorScheme.secondary,
                  onPressed: () {
                    Navigator.of(context).pop();
                    _finishOrder();
                  },
                );
              }),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _finishOrder();
            },
            child: Text(
              l10n.later,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withAlpha((0.6 * 255).round()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _finishOrder() {
    // Limpiamos el carrito antes de volver a la pantalla principal
    getIt<CartCubit>().clearCart();

    context.go('/home');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.orderStatus,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.colorScheme.primary),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(
                  l10n.exitTracking,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Text(
                  l10n.exitTrackingMessage,
                  style: theme.textTheme.bodyMedium,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      l10n.cancel,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withAlpha(
                          (0.6 * 255).round(),
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _finishOrder();
                    },
                    child: Text(
                      l10n.exit,
                      style: TextStyle(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiary,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      l10n.orderNumber(
                        (DateTime.now().millisecondsSinceEpoch % 10000)
                            .toString(),
                      ),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            OrderStepper(currentStep: _currentStep),
            const SizedBox(height: 30),
            if (_currentStep == 2) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withAlpha((0.1 * 255).round()),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primary,
                      child: Icon(
                        Icons.person,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Carlos Rodríguez',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            l10n.yourDeliveryMan,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withAlpha(
                                (0.6 * 255).round(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.phone),
                      color: theme.colorScheme.primary,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                _currentStep == 0
                    ? l10n.statusReceived
                    : _currentStep == 1
                    ? l10n.statusPreparing
                    : _currentStep == 2
                    ? l10n.statusOnWay
                    : l10n.statusEnjoy,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(
                    (0.7 * 255).round(),
                  ),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
            _buildETACard(theme, l10n),
            const SizedBox(height: 30),
            _buildStepAnimation(),
            const SizedBox(height: 30),
            _buildHelpButton(theme),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildETACard(ThemeData theme, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.timer_outlined,
              color: theme.colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.estimatedTime, // "Tiempo estimado: 25-35 min"
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '14:30 PM - 14:45 PM', // Hora simulada
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepAnimation() {
    String assetName;
    switch (_currentStep) {
      case 0:
        assetName = 'ConfirmingOrder.json';
        break;
      case 1:
        assetName = 'chef-making-pizza.json';
        break;
      case 2:
        assetName = 'PizzaDelivery.json';
        break;
      case 3:
      default:
        assetName = 'PizzaLoading.json';
        break;
    }

    return SizedBox(
      height: 250,
      child: Lottie.asset('assets/animation/$assetName', fit: BoxFit.contain),
    );
  }

  Widget _buildHelpButton(ThemeData theme) {
    return TextButton.icon(
      onPressed: () {
        // Acción de ayuda
      },
      style: TextButton.styleFrom(
        foregroundColor: theme.disabledColor,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
      icon: const Icon(Icons.support_agent, size: 20),
      label: const Text('¿Necesitas ayuda con tu pedido?'),
    );
  }
}
