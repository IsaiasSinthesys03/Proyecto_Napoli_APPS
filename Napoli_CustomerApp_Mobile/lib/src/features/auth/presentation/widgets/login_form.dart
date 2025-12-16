import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:napoli_app_v1/l10n/arb/app_localizations.dart';
import 'package:napoli_app_v1/src/core/core_ui/theme.dart';
import 'package:napoli_app_v1/src/core/core_ui/widgets/pressable_scale.dart';
import 'package:napoli_app_v1/src/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:napoli_app_v1/src/features/auth/presentation/cubit/auth_state.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _doSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthCubit>().login(
      _emailController.text,
      _passwordController.text,
    );
  }

  String? _emailValidator(String? v) {
    if (v == null || v.isEmpty) return 'Ingresa tu correo';
    if (!RegExp(r"^[\w-.]+@([\w-]+\.)+[\w-]{2,4}").hasMatch(v)) {
      return 'Correo inválido';
    }
    return null;
  }

  String? _passwordValidator(String? v) {
    if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
    if (v.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey('signin'),
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: l10n.emailLabel,
              prefixIcon: const Icon(Icons.email),
            ),
            validator: _emailValidator,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: l10n.passwordLabel,
              prefixIcon: const Icon(Icons.lock),
            ),
            validator: _passwordValidator,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Función de recuperar contraseña aún no implementada',
                    ),
                  ),
                );
              },
              child: Text(
                l10n.forgotPassword,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.secondary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                final isLoading = state is AuthLoading;
                return PressableScale(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: BorderSide(
                        color: AppColors.accentBeige.withAlpha(
                          (0.35 * 255).round(),
                        ),
                      ),
                      elevation: 3,
                    ),
                    onPressed: isLoading ? null : _doSignIn,
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : Text(l10n.signInTab),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
