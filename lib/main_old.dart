import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nashmi_tf/features/home/presentation/screens/home_screen.dart';
import 'package:nashmi_tf/features/main/main_navigation_screen.dart';
import 'package:nashmi_tf/features/splash/splash_screen.dart';
import 'package:nashmi_tf/services/ad_service.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AdService _adService = AdService();

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Nashmi TF',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AdService _adService = AdService();
  bool _isLoading = true;
  String _loadingMessage = 'جاري تحميل التطبيق...';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize Firebase (optional, continue even if it fails)
      setState(() => _loadingMessage = 'جاري الاتصال بالخادم...');
      try {
        // Check if Firebase is already initialized to avoid duplicate app error
        if (Firebase.apps.isEmpty) {
          await Firebase.initializeApp();
          print('Firebase initialized in splash screen');
        } else {
          print('Firebase already initialized, skipping...');
        }
      } catch (e) {
        if (e.toString().contains('duplicate-app')) {
          print(
            'Firebase duplicate app detected in splash screen, using existing instance...',
          );
        } else {
          print('Firebase initialization failed: $e');
        }
      }

      // Initialize AdMob (optional, continue even if it fails)
      setState(() => _loadingMessage = 'جاري تحميل الإعلانات...');
      try {
        await _adService.initialize();
      } catch (e) {
        print('AdMob initialization failed: $e');
      }

      // Simulate loading data
      setState(() => _loadingMessage = 'جاري تحميل البيانات...');
      await Future.delayed(const Duration(seconds: 2));

      // Navigate to Home Screen
      if (mounted) {
        setState(() => _isLoading = false);
        Get.offAll(() => HomeScreen());
      }
    } catch (e) {
      // Even if there's an error, still navigate to home
      print('Error during initialization: $e');
      if (mounted) {
        Get.offAll(() => HomeScreen());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback if logo image is not found
                    return Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red, Colors.red.shade700],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Text(
                          'نشمي TF',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 40),
            // App Name
            const Text(
              'نشمي TF',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 12),
            // Tagline
            const Text(
              'أفضل الأفلام والمسلسلات',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 60),
            // Loading Indicator
            if (_isLoading) ...[
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  strokeWidth: 4,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _loadingMessage,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
