import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/di/injection.dart';
import 'core/network/supabase_config.dart';
import 'app.dart';

void main() async {
  // Asegurar inicialización de Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase
  await SupabaseConfig.initialize();

  // Inicializar dependencias
  await initDependencies();

  // Configurar orientación (solo portrait)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configurar barra de estado
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const App());
}
