import 'package:flutter/material.dart';
import 'package:napoli_app_v1/l10n/arb/app_localizations.dart';
import 'package:napoli_app_v1/src/features/settings/presentation/widgets/app_settings_section.dart';
import 'package:napoli_app_v1/src/features/settings/presentation/widgets/help_section.dart';
import 'package:napoli_app_v1/src/features/settings/presentation/widgets/logout_section.dart';
import 'package:napoli_app_v1/src/features/settings/presentation/widgets/preferences_section.dart';
import 'package:napoli_app_v1/src/features/settings/presentation/widgets/user_info_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.settingsTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del usuario
            UserInfoSection(),
            SizedBox(height: 24),

            // Configuración de la aplicación
            AppSettingsSection(),
            SizedBox(height: 24),

            // Preferencias
            PreferencesSection(),
            SizedBox(height: 24),

            // Ayuda y soporte
            HelpSection(),
            SizedBox(height: 24),

            // Cerrar sesión
            LogoutSection(),
          ],
        ),
      ),
    );
  }
}
