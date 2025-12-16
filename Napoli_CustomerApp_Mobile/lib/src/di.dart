import 'package:get_it/get_it.dart';
import 'core/di/injection.dart';

final getIt = GetIt.instance;

Future<void> initDi() async {
  await configureDependencies(environment: 'prod');
}
