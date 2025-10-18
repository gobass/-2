import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'services/supabase_service.dart';
import 'services/theme_service.dart';
import 'services/auth_service.dart';
import 'services/rating_service.dart';
import 'services/favorites_service.dart';
import 'services/continuous_watching_service.dart';
import 'views/movies_view.dart';
import 'views/ads_view.dart';
import 'views/series_view.dart';

import 'features/view_all/view_all_screen.dart';
import 'features/search/search_screen.dart';
import 'features/filter/filter_screen.dart';
import 'features/admin/admin_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/favorites/favorites_screen.dart';
import 'features/movies_viewing/movies_viewing_screen.dart';
import 'features/series_viewing/series_viewing_screen.dart';
import 'screens/main_screen.dart';
import 'injection.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print('🚀 Starting Nashmi Dashboard...');

    // Initialize Firebase with proper error handling
    await _initializeFirebase();
    print('✅ Firebase initialized successfully');

    // Initialize Services
    Get.put(SupabaseService()); // Register for both web and mobile
    // Initialize Supabase on all platforms
    final supabaseService = Get.find<SupabaseService>();
    await supabaseService.initialize();
    print('✅ Supabase initialized successfully');

    // Put RatingService and FavoritesService for GetX dependency injection
    Get.put(ThemeService());
    Get.put(AuthService());
    Get.put(RatingService());
    Get.put(FavoritesService());
    Get.put(ContinuousWatchingService());

    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
    print('Orientation set to landscape and portrait');

    runApp(const MyApp());
    print('✅ Nashmi Dashboard started successfully');
  } catch (e, stackTrace) {
    print('💥 Fatal error during initialization: $e');
    print('Stack trace: $stackTrace');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(child: Text('خطأ في تشغيل لوحة التحكم: $e')),
        ),
      ),
    );
  }
}

// Firebase initialization with duplicate app handling
Future<void> _initializeFirebase() async {
  try {
    // Check if Firebase is already initialized
    if (Firebase.apps.isNotEmpty) {
      print('Firebase already initialized, skipping...');
      return;
    }

    // Initialize Firebase with the default options
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      print('Firebase duplicate app detected, using existing instance...');
      // Firebase is already initialized, continue
      return;
    } else if (e.toString().contains('no-default-app')) {
      print('No default Firebase app found, initializing...');
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      print('Firebase initialization error: $e');
      rethrow;
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'نشمي - لوحة التحكم',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shadowColor: Color(0x1F000000),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.grey[100],
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          filled: true,
          fillColor: Colors.grey[200],
          labelStyle: TextStyle(color: Colors.black),
          hintStyle: TextStyle(color: Colors.grey[600]),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
          titleLarge: TextStyle(color: Colors.black),
        ),
      ),
      // Set Arabic as the default locale
      locale: const Locale('ar'),
      // Set text direction to RTL for Arabic
      textDirection: TextDirection.rtl,
      initialRoute: '/main',
      // Prevent navigation conflicts
      defaultTransition: Transition.native,
      opaqueRoute: Get.isOpaqueRouteDefault,
      popGesture: Get.isPopGestureEnable,
      transitionDuration: Get.defaultTransitionDuration,
      getPages: [
        GetPage(
          name: '/home',
          page: () => const HomeScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/main',
          page: () => const MainScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/view-all',
          page: () => const ViewAllScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/search',
          page: () => const SearchScreen(),
          transition: Transition.downToUp,
        ),
        GetPage(
          name: '/filter',
          page: () => const FilterScreen(),
          transition: Transition.downToUp,
        ),
        GetPage(
          name: '/admin',
          page: () => const AdminScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/login',
          page: () => const LoginScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/movies',
          page: () => MoviesView(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/series',
          page: () => SeriesView(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/favorites',
          page: () => const FavoritesScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/movies-viewing',
          page: () => const MoviesViewingScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/series-viewing',
          page: () => const SeriesViewingScreen(),
          transition: Transition.rightToLeft,
        ),

        GetPage(
          name: '/ads',
          page: () => const AdsView(),
          transition: Transition.rightToLeft,
        ),
      ],
    );
  }
}
