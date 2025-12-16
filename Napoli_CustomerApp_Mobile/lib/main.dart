import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:napoli_app_v1/src/core/router/app_router.dart';
import 'package:napoli_app_v1/src/core/network/supabase_config.dart';
import 'src/app.dart';
import 'src/di.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      await SupabaseConfig.initialize();
      await initDi();
      runApp(const AppEntry());
    },
    (error, stack) {
      debugPrint('Global Error: $error');
      debugPrint('Stack Trace: $stack');
      // Ensure navigation happens after the frame is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        appRouter.go('/error', extra: error);
      });
    },
  );
}
