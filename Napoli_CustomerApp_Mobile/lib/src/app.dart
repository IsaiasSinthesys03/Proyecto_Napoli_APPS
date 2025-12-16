import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:napoli_app_v1/l10n/arb/app_localizations.dart';
import 'di.dart';
import 'core/core_ui/theme.dart';
import 'core/core_ui/theme_controller.dart';
import 'core/core_ui/theme_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:napoli_app_v1/src/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:napoli_app_v1/src/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:napoli_app_v1/src/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:napoli_app_v1/src/features/home/presentation/cubit/business_status_cubit.dart';
import 'core/router/app_router.dart';

class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  late final ThemeController _themeController;

  @override
  void initState() {
    super.initState();
    _themeController = ThemeController();
  }

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      controller: _themeController,
      child: Builder(
        builder: (context) {
          final tc = ThemeProvider.of(context);
          return AnimatedBuilder(
            animation: tc,
            builder: (context, _) {
              return MultiBlocProvider(
                providers: [
                  // `AuthCubit` and `CartCubit` are registered as singletons
                  // in GetIt; use `BlocProvider.value` so Provider doesn't
                  // attempt to close the shared instance when widgets dispose.
                  BlocProvider.value(value: getIt<AuthCubit>()),
                  BlocProvider.value(value: getIt<CartCubit>()),
                  // These are factory-registered; allow BlocProvider to
                  // create and dispose them normally.
                  BlocProvider(create: (_) => getIt<OrdersCubit>()),
                  BlocProvider(create: (_) => getIt<BusinessStatusCubit>()),
                ],
                child: MaterialApp.router(
                  title: 'Pizzeria UI',
                  debugShowCheckedModeBanner: false,
                  theme: lightTheme,
                  darkTheme: darkTheme,
                  themeMode: tc.dark ? ThemeMode.dark : ThemeMode.light,
                  routerConfig: appRouter,
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: const [
                    Locale('es'), // Spanish
                    Locale('en'), // English
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
