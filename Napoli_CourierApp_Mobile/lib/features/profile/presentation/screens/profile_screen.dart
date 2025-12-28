import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/di/injection.dart';
import '../../../dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../../dashboard/presentation/cubit/dashboard_state.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/settings_section.dart';

/// Pantalla de perfil del conductor
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtener la instancia singleton del cubit
    final cubit = getIt<ProfileCubit>();

    // Cargar perfil si es necesario (si no tiene driver ID o si queremos refrescar)
    final dashboardState = context.read<DashboardCubit>().state;
    if (dashboardState is DashboardLoaded) {
      // Solo cargar si no se ha cargado o si el ID es diferente
      // Opcional: podrías verificar cubit.state para decidir si cargar
      cubit.loadProfile(dashboardState.driver.id);
    }

    return BlocProvider.value(
      value: cubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Perfil'),
          automaticallyImplyLeading: false,
        ),
        body: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is ProfileUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Perfil actualizado exitosamente'),
                  backgroundColor: AppColors.successGreen,
                ),
              );
              // Recargar perfil
              context.read<ProfileCubit>().reloadProfile();
            }

            if (state is ProfilePasswordChanged) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Contraseña cambiada exitosamente'),
                  backgroundColor: AppColors.successGreen,
                ),
              );
              // Volver al perfil
              context.read<ProfileCubit>().reloadProfile();
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const LoadingIndicator();
            }

            if (state is ProfileError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.errorRed,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: AppTextStyles.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        final dashboardState = context
                            .read<DashboardCubit>()
                            .state;
                        if (dashboardState is DashboardLoaded) {
                          context.read<ProfileCubit>().loadProfile(
                            dashboardState.driver.id,
                          );
                        }
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (state is ProfileLoaded || state is ProfileUpdated) {
              final profile = state is ProfileLoaded
                  ? state.profile
                  : (state as ProfileUpdated).profile;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header con foto y estadísticas
                    ProfileHeader(
                      profile: profile,
                      onEditPressed: () {
                        context.push('/profile/edit', extra: profile);
                      },
                    ),

                    Padding(
                      padding: const EdgeInsets.all(AppDimensions.spacingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Información personal
                          ProfileInfoCard(profile: profile),
                          const SizedBox(height: AppDimensions.spacingL),

                          // Configuración
                          SettingsSection(
                            profile: profile,
                            onNotificationsChanged: (value) {
                              context.read<ProfileCubit>().updateSettings({
                                'notificationsEnabled': value,
                              });
                            },
                            onChangePasswordPressed: () {
                              _showChangePasswordDialog(context);
                            },
                          ),
                          const SizedBox(height: AppDimensions.spacingL),

                          // Botón de cerrar sesión
                          OutlinedButton.icon(
                            onPressed: () => _showLogoutDialog(context),
                            icon: const Icon(Icons.logout),
                            label: const Text('Cerrar Sesión'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.errorRed,
                              side: const BorderSide(color: AppColors.errorRed),
                              padding: const EdgeInsets.symmetric(
                                vertical: AppDimensions.spacingM,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cambiar Contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordController,
              decoration: const InputDecoration(
                labelText: 'Contraseña actual',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: AppDimensions.spacingM),
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(
                labelText: 'Nueva contraseña',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: AppDimensions.spacingM),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirmar contraseña',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (newPasswordController.text !=
                  confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Las contraseñas no coinciden'),
                    backgroundColor: AppColors.errorRed,
                  ),
                );
                return;
              }

              context.read<ProfileCubit>().changePassword(
                oldPasswordController.text,
                newPasswordController.text,
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Cambiar'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<ProfileCubit>().logout();
              if (context.mounted) {
                Navigator.pop(dialogContext);
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}
