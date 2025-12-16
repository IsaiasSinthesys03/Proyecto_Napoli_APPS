import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  final void Function()? onCartTap;

  const AppFooter({super.key, this.onCartTap});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).colorScheme.primary,
      onPressed: onCartTap,
      child: const Icon(Icons.shopping_bag_outlined),
    );
  }
}
