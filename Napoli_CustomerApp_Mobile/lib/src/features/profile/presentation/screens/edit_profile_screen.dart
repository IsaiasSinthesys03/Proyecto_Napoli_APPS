import 'package:flutter/material.dart';
import 'package:napoli_app_v1/l10n/arb/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:napoli_app_v1/src/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:napoli_app_v1/src/features/auth/presentation/cubit/auth_state.dart';
import '../widgets/photo_permission_dialog.dart';
import '../widgets/photo_options_bottom_sheet.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/edit_profile_form.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isUpdating = false;
  String? _selectedImagePath;
  bool _hasPhotoPermissions = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final state = context.read<AuthCubit>().state;
    if (state is Authenticated) {
      final user = state.user;
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone ?? '';
      _addressController.text = user.address ?? '';
      if (user.photoUrl != null) {
        setState(() {
          _selectedImagePath = user.photoUrl;
          _hasPhotoPermissions = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is Authenticated && _isUpdating) {
          _isUpdating = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.profileUpdated),
              backgroundColor: Theme.of(context).colorScheme.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              l10n.editProfile,
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
            actions: [
              TextButton(
                onPressed: isLoading ? null : _saveProfile,
                child: Text(
                  l10n.save,
                  style: TextStyle(
                    color: isLoading
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                        : theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Avatar del usuario
                  ProfileAvatar(
                    selectedImagePath: _selectedImagePath,
                    onChangePhoto: () => _handleChangePhoto(l10n),
                  ),
                  const SizedBox(height: 32),

                  // Formulario
                  EditProfileForm(
                    nameController: _nameController,
                    emailController: _emailController,
                    phoneController: _phoneController,
                    addressController: _addressController,
                  ),
                  const SizedBox(height: 32),

                  // Botón de guardar
                  _buildSaveButton(theme, l10n, isLoading),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSaveButton(
    ThemeData theme,
    AppLocalizations l10n,
    bool isLoading,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.onPrimary,
                  ),
                ),
              )
            : Text(
                l10n.saveChanges,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _isUpdating = true;

    final currentUser = (context.read<AuthCubit>().state as Authenticated).user;
    final user = currentUser.copyWith(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      photoUrl: _selectedImagePath,
    );

    context.read<AuthCubit>().updateProfile(user);
  }

  // Métodos para manejo de permisos y selección de fotos
  Future<void> _handleChangePhoto(AppLocalizations l10n) async {
    if (!_hasPhotoPermissions) {
      final granted = await _showPhotoPermissionDialog();
      if (granted) {
        _showPhotoOptionsDialog(l10n);
      }
    } else {
      _showPhotoOptionsDialog(l10n);
    }
  }

  Future<bool> _showPhotoPermissionDialog() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => const PhotoPermissionDialog(),
        ) ??
        false;
  }

  void _showPhotoOptionsDialog(AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => PhotoOptionsBottomSheet(
        onPhotoSelected: (imagePath) {
          setState(() {
            _hasPhotoPermissions = true;
            _selectedImagePath = imagePath.isEmpty ? null : imagePath;
          });
          Navigator.pop(context);
        },
      ),
    );
  }
}
