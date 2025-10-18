import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nashmi_tf/features/home/presentation/screens/home_screen.dart';
import 'package:nashmi_tf/features/series/series_screen.dart';
import 'package:nashmi_tf/features/favorites/favorites_screen.dart';
import 'package:nashmi_tf/services/ad_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  final AdService _adService = AdService();

  @override
  void initState() {
    super.initState();
    _adService.initialize();
  }

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    SeriesScreen(),
    FavoritesScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
          BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: Colors.grey[900],
            selectedItemColor: Colors.red,
            unselectedItemColor: Colors.grey[400],
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'الرئيسية',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.tv), label: 'المسلسلات'),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                label: 'المفضلة',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
