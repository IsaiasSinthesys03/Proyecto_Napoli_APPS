import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/navigation/routes.dart';
import '../../domain/entities/vehicle_type.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'pending_approval_screen.dart';

/// Pantalla de registro de nuevos repartidores
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenStateWithAnimation();
}

class _RegisterScreenStateWithAnimation extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _licensePlateController = TextEditingController();

  VehicleType _selectedVehicleType = VehicleType.moto;
  File? _profileImage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
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
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _licensePlateController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().register(
        restaurantId: AppConfig.getRestaurantId(),
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
        vehicleType: _selectedVehicleType.name,
        licensePlate: _licensePlateController.text.trim().toUpperCase(),
        photoUrl: _profileImage?.path,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Fondo Animado (Mismo que Login)
          Positioned.fill(
            child: CustomPaint(
              painter: _RegisterBackgroundPainter(
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
              } else if (state is Registered) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => PendingApprovalScreen(driver: state.driver),
                  ),
                );
              }
            },
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimensions.spacingL),
                  child: Column(
                    children: [
                      // Título
                      Text(
                        'Únete a Napoli',
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimensions.spacingS),
                      Text(
                        'Regístrate como repartidor',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textDark.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
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
                                    child: GestureDetector(
                                      onTap: () => context.go(AppRoutes.login),
                                      child: Column(
                                        children: [
                                          Text(
                                            'INICIAR',
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
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text(
                                          'REGISTRARSE',
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
                                ],
                              ),
                              const SizedBox(height: AppDimensions.spacingL),

                              // Foto de perfil
                              Center(
                                child: GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.inputFillLight,
                                      border: Border.all(
                                        color: AppColors.primaryGreen,
                                        width: 2,
                                      ),
                                    ),
                                    child: _profileImage != null
                                        ? ClipOval(
                                            child: Image.file(
                                              _profileImage!,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Icon(
                                            Icons.add_a_photo,
                                            size: 30,
                                            color: AppColors.primaryGreen,
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppDimensions.spacingS),
                              Text(
                                'Foto de perfil',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondaryLight,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppDimensions.spacingL),

                              // Nombre
                              AppTextField(
                                label: 'Nombre Completo',
                                hint: 'Juan Pérez',
                                controller: _nameController,
                                prefixIcon: Icons.person,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'El nombre es requerido';
                                  }
                                  if (value.length < 3) {
                                    return 'Mínimo 3 caracteres';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppDimensions.spacingM),

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
                                  final emailRegex = RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  );
                                  if (!emailRegex.hasMatch(value)) {
                                    return 'Email inválido';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppDimensions.spacingM),

                              // Teléfono
                              AppTextField(
                                label: 'Teléfono',
                                hint: '+5491123456789',
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                prefixIcon: Icons.phone,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'El teléfono es requerido';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppDimensions.spacingM),

                              // Contraseña
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
                              const SizedBox(height: AppDimensions.spacingM),

                              // Confirmar Contraseña
                              AppTextField(
                                label: 'Confirmar Contraseña',
                                hint: '••••••',
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                prefixIcon: Icons.lock_outline,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Confirma tu contraseña';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Las contraseñas no coinciden';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppDimensions.spacingM),

                              // Tipo de Vehículo
                              DropdownButtonFormField<VehicleType>(
                                value: _selectedVehicleType,
                                decoration: InputDecoration(
                                  labelText: 'Tipo de Vehículo',
                                  prefixIcon: const Icon(Icons.directions_car),
                                  filled: true,
                                  fillColor:
                                      theme.inputDecorationTheme.fillColor,
                                  border: theme.inputDecorationTheme.border,
                                  enabledBorder:
                                      theme.inputDecorationTheme.enabledBorder,
                                  focusedBorder:
                                      theme.inputDecorationTheme.focusedBorder,
                                ),
                                items: VehicleType.values.map((type) {
                                  return DropdownMenuItem(
                                    value: type,
                                    child: Text(type.displayName),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedVehicleType = value;
                                    });
                                  }
                                },
                              ),
                              const SizedBox(height: AppDimensions.spacingM),

                              // Placa/Patente
                              AppTextField(
                                label: 'Placa/Patente',
                                hint: 'ABC123',
                                controller: _licensePlateController,
                                prefixIcon: Icons.confirmation_number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'La placa es requerida';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppDimensions.spacingXL),

                              // Botón Registrarse
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
                                      label: 'REGISTRARSE',
                                      icon: Icons.person_add,
                                      isLoading: state is AuthLoading,
                                      onPressed: _handleRegister,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
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

class _RegisterBackgroundPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color1;
  final Color color2;

  _RegisterBackgroundPainter({
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

    // Olas suaves (invertidas para variación)
    final paint = Paint()
      ..color = AppColors.accentBeige.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
        i,
        size.height * 0.8 +
            math.cos(
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
