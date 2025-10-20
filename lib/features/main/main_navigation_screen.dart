import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nashmi_tf/features/home/presentation/screens/home_screen.dart';
import 'package:nashmi_tf/features/favorites/favorites_screen.dart';
import 'package:nashmi_tf/services/ad_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:async';
import 'run_program_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  final AdService _adService = AdService();
  Timer? _fiveMinuteTimer;

  @override
  void initState() {
    super.initState();
    _adService.initialize();
    _startFiveMinuteTimer();
  }

  static List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    FavoritesScreen(),
    RunProgramScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _startFiveMinuteTimer() {
    _fiveMinuteTimer?.cancel();
    _fiveMinuteTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      print('5-minute timer triggered - loading banner ad');
      _adService.loadBannerAd();
    });
  }

  @override
  void dispose() {
    _fiveMinuteTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Banner Ad
          if (_adService.isBannerAdLoaded && _adService.bannerAd != null)
            Container(
              height: _adService.bannerAd!.size.height.toDouble(),
              width: double.infinity,
              child: AdWidget(ad: _adService.bannerAd!),
            ),

          // Bottom Navigation Bar
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1A1A2E), // Dark blue
                  Color(0xFF16213E), // Darker blue
                  Color(0xFF0F3460), // Navy blue
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              backgroundColor: Colors.transparent,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white.withOpacity(0.7),
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'الرئيسية',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite),
                  label: 'المفضلة',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.play_arrow),
                  label: 'شغل برنامج',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
