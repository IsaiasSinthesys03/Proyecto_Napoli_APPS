import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../auth/domain/entities/vehicle_type.dart';
import '../../../dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../domain/entities/driver_profile.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

/// Pantalla para editar el perfil del conductor
class EditProfileScreen extends StatefulWidget {
  final DriverProfile profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _licensePlateController;
  late VehicleType _selectedVehicleType;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    final driver = widget.profile.driver;
    _nameController = TextEditingController(text: driver.name);
    _phoneController = TextEditingController(text: driver.phone);
    _licensePlateController = TextEditingController(text: driver.licensePlate);
    _selectedVehicleType = driver.vehicleType;
    _photoUrl = driver.photoUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _licensePlateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) {
          print('🔍 DEBUG - EditProfileScreen listener: state = $state');

          if (state is ProfileUpdated) {
            print('✅ DEBUG - Profile updated successfully');
            print('📦 DEBUG - Updated driver: ${state.profile.driver.name}');

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Perfil actualizado exitosamente'),
                backgroundColor: AppColors.successGreen,
              ),
            );

            print('🔄 DEBUG - Calling DashboardCubit.initialize()');
            try {
              context.read<DashboardCubit>().initialize(state.profile.driver);
              print(
                '✅ DEBUG - DashboardCubit.initialize() called successfully',
              );
            } catch (e) {
              print('❌ DEBUG - Error calling DashboardCubit.initialize(): $e');
            }

            context.pop();
          }

          if (state is ProfileError) {
            print('❌ DEBUG - Profile error: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.errorRed,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.spacingL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Foto de perfil
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColors.primaryGreen.withValues(
                          alpha: 0.1,
                        ),
                        backgroundImage: _photoUrl != null
                            ? NetworkImage(_photoUrl!)
                            : null,
                        child: _photoUrl == null
                            ? const Icon(
                                Icons.person,
                                size: 60,
                                color: AppColors.primaryGreen,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: _pickImage,
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXL),

                // Nombre
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu nombre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.spacingL),

                // Teléfono
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    prefixIcon: Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu teléfono';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.spacingL),

                // Tipo de vehículo
                DropdownButtonFormField<VehicleType>(
                  value: _selectedVehicleType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de vehículo',
                    prefixIcon: Icon(Icons.directions_car_outlined),
                    border: OutlineInputBorder(),
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
                const SizedBox(height: AppDimensions.spacingL),

                // Placa
                TextFormField(
                  controller: _licensePlateController,
                  decoration: const InputDecoration(
                    labelText: 'Placa del vehículo',
                    prefixIcon: Icon(Icons.pin_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa la placa';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.spacingXL),

                // Botón guardar
                ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.spacingM,
                    ),
                  ),
                  child: const Text('Guardar Cambios'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _photoUrl = image.path;
      });
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final updatedDriver = widget.profile.driver.copyWith(
        name: _nameController.text,
        phone: _phoneController.text,
        vehicleType: _selectedVehicleType,
        licensePlate: _licensePlateController.text,
        photoUrl: _photoUrl,
      );

      context.read<ProfileCubit>().updateDriver(updatedDriver);
    }
  }
}
