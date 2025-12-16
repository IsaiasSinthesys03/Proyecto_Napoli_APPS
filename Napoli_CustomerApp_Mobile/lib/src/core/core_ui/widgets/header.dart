import 'package:flutter/material.dart';
import 'dart:math';
import 'theme_toggle.dart';
import 'scratch_card.dart';

import 'package:napoli_app_v1/src/di.dart';
import '../../../features/coupons/domain/repositories/coupon_repository.dart';
import '../../../features/coupons/presentation/screens/coupon_history_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:napoli_app_v1/src/features/auth/presentation/screens/login_screen.dart';

class AppHeader extends StatelessWidget {
  final String address;
  final void Function()? onMenuTap;

  const AppHeader({super.key, required this.address, this.onMenuTap});

  void _showMenu(BuildContext context) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(300, 70, 0, 0),
      items: [
        PopupMenuItem(
          child: ListTile(
            leading: const Icon(Icons.card_giftcard),
            title: const Text('Rasca y Gana'),
            onTap: () {
              Navigator.pop(context);
              _showScratchDialog(context);
            },
          ),
        ),
        PopupMenuItem(
          child: ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Mis Cupones'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CouponHistoryScreen(),
                ),
              );
            },
          ),
        ),
        PopupMenuItem(
          child: ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Acerca de'),
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog(context);
            },
          ),
        ),
        PopupMenuItem(
          child: ListTile(
            leading: Icon(
              Icons.logout,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              'Cerrar Sesión',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog(context);
            },
          ),
        ),
      ],
    );
  }

  void _showScratchDialog(BuildContext context) {
    final coupons = ['PIZZA10', 'SAVE20', 'MEGA50'];
    final random = Random();
    final wonCoupon = coupons[random.nextInt(coupons.length)];
    final repository = getIt<CouponRepository>();
    bool revealed = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('🎉 Rasca y Gana', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Rasca la tarjeta para revelar tu cupón:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              ScratchCard(
                hiddenText: wonCoupon,
                onRevealed: () async {
                  setState(() => revealed = true);
                  // Guardar cupón en historial
                  await repository.saveCoupon(wonCoupon);
                },
              ),
              if (revealed) ...[
                const SizedBox(height: 16),
                Icon(
                  Icons.celebration,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 40,
                ),
                const SizedBox(height: 8),
                Text(
                  '¡Felicidades! Úsalo en tu carrito',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha((0.75 * 255).round()),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () async {
              // Close the dialog first
              Navigator.pop(context);
              // Clear stored session flag (and any other session-related keys as needed)
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('is_logged_in');
              // Navigate back to the login screen and remove previous routes
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Napoli Pizza', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_pizza, size: 64, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'App de pedidos UI-Only',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Versión 1.0.0',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface.withAlpha((0.6 * 255).round()),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Arquitectura V5 (feature-first)\nFlutter 3.35.6 • Dart 3.9.2',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurface.withAlpha((0.6 * 255).round()),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, left: 8.0, right: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on),
              const SizedBox(width: 8),
              SizedBox(
                width: 200,
                child: Text(address, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => _showMenu(context),
                icon: Image.asset(
                  'assets/icons/etiqueta.png',
                  width: 24,
                  height: 24,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const ThemeToggle(),
            ],
          ),
        ],
      ),
    );
  }
}
