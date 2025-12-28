import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:napoli_app_v1/src/core/core_ui/widgets/app_scaffold.dart';
import 'package:napoli_app_v1/src/core/core_ui/theme.dart';
import 'package:napoli_app_v1/src/features/home/presentation/screens/home_screen.dart';
import 'package:napoli_app_v1/l10n/app_localizations.dart';

/// Simple standalone Register screen. The app's primary login UI uses the
/// combined tabbed screen but this file provides an independent registration
/// screen for navigation flow or deep links.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordCtrl.text != _confirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.passwordsDoNotMatch),
        ),
      );
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  String? _emailValidator(String? v) {
    if (v == null || v.isEmpty) {
      return AppLocalizations.of(context)!.emailRequired;
    }
    if (!RegExp(r"^[\w-.]+@([\w-]+\.)+[\w-]{2,4}").hasMatch(v)) {
      return AppLocalizations.of(context)!.emailInvalid;
    }
    return null;
  }

  String? _passwordValidator(String? v) {
    if (v == null || v.isEmpty) {
      return AppLocalizations.of(context)!.enterPassword;
    }
    if (v.length < 6) return AppLocalizations.of(context)!.passwordMinLength;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Simple header with back button so this screen fits inside AppScaffold
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  BackButton(),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.registerScreenTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.nameLabel,
                    ),
                    validator: (v) => v == null || v.isEmpty
                        ? AppLocalizations.of(context)!.nameRequired
                        : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.emailLabel,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: _emailValidator,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordCtrl,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.passwordLabel,
                    ),
                    obscureText: true,
                    validator: _passwordValidator,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _confirmCtrl,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(
                        context,
                      )!.confirmPasswordLabel,
                    ),
                    obscureText: true,
                    validator: (v) => v == null || v.isEmpty
                        ? AppLocalizations.of(context)!.confirmPasswordRequired
                        : null,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: _PressableScale(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: AppColors.white,
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
                        onPressed: _loading ? null : _register,
                        child: _loading
                            ? const CircularProgressIndicator()
                            : Text(AppLocalizations.of(context)!.createAccount),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PressableScale extends StatefulWidget {
  final Widget child;
  const _PressableScale({required this.child});

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  double _scale = 1.0;
  void _down([TapDownDetails? _]) => setState(() => _scale = 0.96);
  void _up([dynamic _]) => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) => _down(details),
      onTapCancel: () => _up(),
      onTapUp: (details) => _up(details),
      onTap: null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}
