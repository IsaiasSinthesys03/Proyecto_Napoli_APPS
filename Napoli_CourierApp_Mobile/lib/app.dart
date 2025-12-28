import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/di/injection.dart';
import 'core/navigation/app_router.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/dashboard/presentation/cubit/dashboard_cubit.dart';

/// Root widget de la aplicación
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AuthCubit>()..checkAuthStatus()),
        BlocProvider(create: (_) => getIt<DashboardCubit>()),
      ],
      child: MaterialApp.router(
        title: 'Napoli Drivers',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.getLightTheme(),
        darkTheme: AppTheme.getDarkTheme(),
        themeMode: ThemeMode.light,
        routerConfig: appRouter,
      ),
    );
  }
}
