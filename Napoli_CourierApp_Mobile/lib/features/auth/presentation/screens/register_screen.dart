import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
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
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _licensePlateController.dispose();
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
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          } else if (state is Registered) {
            // Navegar a pantalla de espera
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo
                    Icon(
                      Icons.local_pizza,
                      size: 60,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: AppDimensions.spacingM),

                    // Título
                    Text(
                      'Únete a Napoli',
                      style: AppTextStyles.h2.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Regístrate como repartidor',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.spacingXL),

                    // Foto de perfil
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            border: Border.all(
                              color: theme.colorScheme.primary,
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
                                  size: 40,
                                  color: theme.colorScheme.primary,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingS),
                    Text(
                      'Toca para agregar foto',
                      style: AppTextStyles.caption.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
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
                            _obscureConfirmPassword = !_obscureConfirmPassword;
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
                        fillColor: theme.inputDecorationTheme.fillColor,
                        border: theme.inputDecorationTheme.border,
                        enabledBorder: theme.inputDecorationTheme.enabledBorder,
                        focusedBorder: theme.inputDecorationTheme.focusedBorder,
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
                        return AppButton(
                          label: 'Registrarse',
                          icon: Icons.person_add,
                          isLoading: state is AuthLoading,
                          onPressed: _handleRegister,
                        );
                      },
                    ),
                    const SizedBox(height: AppDimensions.spacingL),

                    // Link a login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿Ya tienes cuenta? ',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            context.go(AppRoutes.login);
                          },
                          child: Text(
                            'Inicia Sesión',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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
