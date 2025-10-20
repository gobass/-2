import 'package:get_it/get_it.dart';
import 'services/firebase_service.dart';
import 'services/auth_service.dart';
import 'services/theme_service.dart';
import 'services/supabase_service.dart';
import 'services/ad_service.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  // Register services
  getIt.registerLazySingleton<FirebaseService>(() => FirebaseService.instance);
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<ThemeService>(() => ThemeService());
  getIt.registerLazySingleton<SupabaseService>(() => SupabaseService());
  getIt.registerLazySingleton<AdService>(() => AdService());
}
