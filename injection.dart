import 'package:get/get.dart';
import 'services/supabase_service.dart';
import 'services/theme_service.dart';
import 'services/auth_service.dart';
import 'services/rating_service.dart';
import 'services/favorites_service.dart';

/// Initialize all dependencies for the application
Future<void> init() async {
  // Core Services
  Get.put(SupabaseService());
  Get.put(ThemeService());
  Get.put(AuthService());
  Get.put(RatingService());
  Get.put(FavoritesService());

  // Initialize Supabase
  final supabaseService = Get.find<SupabaseService>();
  await supabaseService.initialize();
}
