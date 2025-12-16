import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:napoli_app_v1/l10n/arb/app_localizations.dart';
import 'package:napoli_app_v1/src/core/core_ui/theme.dart';
import 'package:napoli_app_v1/src/core/core_ui/widgets/app_scaffold.dart';
import 'package:napoli_app_v1/src/di.dart';
import 'package:napoli_app_v1/src/features/auth/presentation/widgets/auth_footer.dart';
import 'package:napoli_app_v1/src/features/auth/presentation/widgets/auth_tab_selector.dart';
import 'package:napoli_app_v1/src/features/auth/presentation/widgets/login_logo.dart';
import 'package:napoli_app_v1/src/features/auth/presentation/widgets/social_login_buttons.dart';
import '../../presentation/cubit/auth_cubit.dart';
import '../../presentation/cubit/auth_state.dart';
import '../widgets/login_background_painter.dart';
import '../widgets/login_form.dart';
import '../widgets/register_form.dart';

/// Login screen adapted from the design references in `ideas-diseno`.
/// This implementation follows the project's architecture and uses
/// the centralized theme/colors. It contains a tabbed Login/Register UI
/// and a social login strip. Registration is also supported and will
/// set a local flag in SharedPreferences for demo purposes.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthCubit>(),
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            context.go('/home');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        child: const _LoginScreenContent(),
      ),
    );
  }
}

class _LoginScreenContent extends StatefulWidget {
  const _LoginScreenContent();

  @override
  State<_LoginScreenContent> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<_LoginScreenContent>
    with SingleTickerProviderStateMixin {
  bool _isSignIn = true;

  late final AnimationController _bgController;
  late final Animation<double> _bgAnimation;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _bgAnimation = CurvedAnimation(
      parent: _bgController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      body: Stack(
        children: [
          // Animated custom painted background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgAnimation,
              builder: (context, child) => CustomPaint(
                painter: LoginBackgroundPainter(
                  _bgAnimation.value,
                  colorScheme,
                ),
              ),
            ),
          ),

          // Foreground content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo with subtle floating + rotation animation
                  LoginLogo(animation: _bgAnimation),
                  const SizedBox(height: 18),
                  Text(
                    l10n.welcomeTo,
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'BARRIO NAPOLI',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // subtle red accent divider to balance the palette
                  Container(
                    height: 4,
                    width: 120,
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Card with tabs
                  AnimatedBuilder(
                    animation: _bgAnimation,
                    builder: (context, child) {
                      // small entrance translate driven by bg animation
                      final ty =
                          (1 - _bgAnimation.value) * 8; // slides up slightly
                      final op = 0.9 + 0.1 * _bgAnimation.value;
                      return Transform.translate(
                        offset: Offset(0, ty),
                        child: Opacity(
                          opacity: op,
                          child: AnimatedScale(
                            scale: _isSignIn ? 1.0 : 0.995,
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadowColor.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Tabs
                          AuthTabSelector(
                            isSignIn: _isSignIn,
                            onTabSelected: (value) =>
                                setState(() => _isSignIn = value),
                          ),

                          const SizedBox(height: 18),

                          // Animated form
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _isSignIn
                                ? const LoginForm()
                                : const RegisterForm(),
                          ),

                          const SizedBox(height: 16),

                          // Social strip
                          const SocialLoginButtons(),

                          const SizedBox(height: 12),

                          // Footer link
                          AuthFooter(
                            isSignIn: _isSignIn,
                            onTap: () => setState(() => _isSignIn = !_isSignIn),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
