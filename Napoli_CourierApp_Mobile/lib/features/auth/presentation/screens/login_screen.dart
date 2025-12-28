import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/navigation/routes.dart';
import '../../../dashboard/presentation/cubit/dashboard_cubit.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

/// Pantalla de inicio de sesión
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }

          // Navigate to dashboard when authenticated
          if (state is Authenticated) {
            // Mostrar mensaje de éxito
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('¡Inicio de sesión exitoso!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
            // Initialize dashboard with driver data
            context.read<DashboardCubit>().initialize(state.driver);
            // Navigate to dashboard
            context.go(AppRoutes.dashboard);
          }

          // Navigate to pending approval screen
          if (state is Registered) {
            // Mostrar mensaje de éxito
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  '¡Registro exitoso! Tu cuenta está pendiente de aprobación.',
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
              ),
            );
            context.go(AppRoutes.pendingApproval, extra: state.driver);
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.spacingL),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo
                    Icon(
                      Icons.local_pizza,
                      size: 80,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: AppDimensions.spacingM),

                    // Título
                    Text(
                      'Bienvenido a',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'NAPOLI DRIVERS',
                      style: AppTextStyles.h1.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.spacingXL),

                    // Email
                    AppTextField(
                      label: 'Email',
                      hint: 'tu@email.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El email es requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimensions.spacingM),

                    // Password
                    AppTextField(
                      label: 'Contraseña',
                      hint: '••••••',
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      prefixIcon: Icons.lock,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La contraseña es requerida';
                        }
                        if (value.length < 6) {
                          return 'Mínimo 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimensions.spacingXL),

                    // Botón Login
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        return AppButton(
                          label: 'Iniciar Sesión',
                          icon: Icons.login,
                          isLoading: state is AuthLoading,
                          onPressed: _handleLogin,
                        );
                      },
                    ),
                    const SizedBox(height: AppDimensions.spacingL),

                    // Link a registro
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿No tienes cuenta? ',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            context.go(AppRoutes.register);
                          },
                          child: Text(
                            'Regístrate',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Hint de usuarios de prueba
                    const SizedBox(height: AppDimensions.spacingXL),
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.spacingM),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusSmall,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '💡 Usuarios de prueba:',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.spacingS),
                          Text(
                            '✅ Aprobado: repartidor@napoli.com',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            '⏳ Pendiente: nuevo@napoli.com',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Password: cualquiera (6+ caracteres)',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
