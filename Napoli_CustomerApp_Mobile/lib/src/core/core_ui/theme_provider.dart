import 'package:flutter/widgets.dart';
import 'theme_controller.dart';

/// A lightweight provider for ThemeController that avoids external packages.
class ThemeProvider extends InheritedNotifier<ThemeController> {
  const ThemeProvider({super.key, required ThemeController controller, required super.child})
      : super(notifier: controller);

  static ThemeController of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<ThemeProvider>();
    if (provider == null) {
      // Return a default controller to avoid null checks in widgets.
      return ThemeController();
    }
    return provider.notifier!;
  }
}
