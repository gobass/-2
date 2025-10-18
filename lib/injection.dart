import 'package:get_it/get_it.dart';
import 'package:nashmi_tf/services/firebase_service.dart';
import 'package:nashmi_tf/services/auth_service.dart';
import 'package:nashmi_tf/services/theme_service.dart';
import 'package:nashmi_tf/services/supabase_service.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  // Register services
  getIt.registerLazySingleton<FirebaseService>(() => FirebaseService.instance);
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<ThemeService>(() => ThemeService());
  getIt.registerLazySingleton<SupabaseService>(() => SupabaseService());
}
