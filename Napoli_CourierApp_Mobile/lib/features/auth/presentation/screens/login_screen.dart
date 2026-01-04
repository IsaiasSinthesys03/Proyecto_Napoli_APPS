import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/navigation/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../dashboard/presentation/cubit/dashboard_cubit.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

/// Pantalla de inicio de sesión
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenStateWithAnimation();
}

class _LoginScreenStateWithAnimation extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
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
      body: Stack(
        children: [
          // Fondo Animado
          Positioned.fill(
            child: CustomPaint(
              painter: _LoginBackgroundPainter(
                animation: _animationController,
                color1: AppColors.primaryGreen,
                color2: AppColors.accentBeigeLight,
              ),
            ),
          ),

          BlocListener<AuthCubit, AuthState>(
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('¡Inicio de sesión exitoso!'),
                    backgroundColor: AppColors.successGreen,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
                context.read<DashboardCubit>().initialize(state.driver);
                context.go(AppRoutes.dashboard);
              }

              if (state is Registered) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      '¡Registro exitoso! Tu cuenta está pendiente de aprobación.',
                    ),
                    backgroundColor: AppColors.successGreen,
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Flotante
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(
                              0,
                              math.sin(
                                    _animationController.value * math.pi * 2,
                                  ) *
                                  8,
                            ),
                            child: Transform.rotate(
                              angle:
                                  math.sin(
                                    _animationController.value * math.pi * 2,
                                  ) *
                                  0.04,
                              child: child,
                            ),
                          );
                        },
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.primaryRed.withValues(
                                alpha: 0.6,
                              ),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryRed.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 12,
                                spreadRadius: 1,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.local_pizza,
                              size: 56,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingL),

                      // Textos de Bienvenida
                      Text(
                        'Bienvenido a',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        'NAPOLI DRIVERS',
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w900,
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingS),
                      Container(
                        width: 120,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.primaryRed.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXL),

                      // Tarjeta de Formulario
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Pestañas Visuales
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text(
                                          'INICIAR',
                                          style: AppTextStyles.bodyLarge
                                              .copyWith(
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.primaryGreen,
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          height: 3,
                                          width: 48,
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryGreen,
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () =>
                                          context.go(AppRoutes.register),
                                      child: Column(
                                        children: [
                                          Text(
                                            'REGISTRARSE',
                                            style: AppTextStyles.bodyLarge
                                                .copyWith(
                                                  fontWeight: FontWeight.w800,
                                                  color: AppColors
                                                      .textSecondaryLight
                                                      .withValues(alpha: 0.6),
                                                ),
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            height: 3,
                                            width: 48,
                                            color: Colors.transparent,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppDimensions.spacingL),

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
                                    color: AppColors.textSecondaryLight,
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
                              const SizedBox(height: AppDimensions.spacingS),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '¿Olvidaste tu contraseña?',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.primaryRed,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppDimensions.spacingXL),

                              // Botón Login
                              BlocBuilder<AuthCubit, AuthState>(
                                builder: (context, state) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: AppColors.accentBeige.withValues(
                                          alpha: 0.35,
                                        ),
                                      ),
                                    ),
                                    child: AppButton(
                                      label: 'INGRESAR',
                                      icon: Icons.login,
                                      isLoading: state is AuthLoading,
                                      onPressed: _handleLogin,
                                      // AppButton uses ElevatedButtonTheme which we updated
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: AppDimensions.spacingL),

                              // Botones Sociales (Visual Only)
                              Text(
                                'O inicia sesión con',
                                style: AppTextStyles.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppDimensions.spacingM),
                              Row(
                                children: [
                                  Expanded(
                                    child: _SocialButton(
                                      label: 'Google',
                                      color: AppColors.primaryGreen,
                                      icon: Icons.g_mobiledata,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _SocialButton(
                                      label: 'Facebook',
                                      color: AppColors.primaryRed,
                                      icon: Icons.facebook,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Hint de usuarios de prueba
                      const SizedBox(height: AppDimensions.spacingXL),
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.spacingM),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusSmall,
                          ),
                          border: Border.all(
                            color: AppColors.primaryGreen.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '💡 Usuarios de prueba:',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.spacingS),
                            Text(
                              '✅ Aprobado: repartidor@napoli.com',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              '⏳ Pendiente: nuevo@napoli.com',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textDark,
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
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _SocialButton({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginBackgroundPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color1;
  final Color color2;

  _LoginBackgroundPainter({
    required this.animation,
    required this.color1,
    required this.color2,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [color1, color2],
    );
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));

    // Olas suaves
    final paint = Paint()
      ..color = AppColors.accentBeige.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
        i,
        size.height * 0.7 +
            math.sin(
                  (i / size.width * 2 * math.pi) +
                      (animation.value * 2 * math.pi),
                ) *
                20,
      );
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);

    // Círculos flotantes
    final circlePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(
        size.width * 0.2,
        size.height * 0.3 + math.sin(animation.value * math.pi * 2) * 20,
      ),
      40,
      circlePaint,
    );

    canvas.drawCircle(
      Offset(
        size.width * 0.8,
        size.height * 0.6 + math.cos(animation.value * math.pi * 2) * 30,
      ),
      60,
      circlePaint,
    );

    // Blob naranja
    final blobPaint = Paint()
      ..color = AppColors.fireOrange.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    canvas.drawCircle(
      Offset(
        size.width * 0.9 + math.sin(animation.value * math.pi) * 20,
        size.height * 0.1,
      ),
      80,
      blobPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
