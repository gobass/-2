import 'package:flutter/material.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/movies_viewing/movies_viewing_screen.dart';
import '../features/series_viewing/series_viewing_screen.dart';
import '../features/favorites/favorites_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = <Widget>[
    HomeScreen(),
    MoviesViewingScreen(),
    SeriesViewingScreen(),
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
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'أفلام'),
          BottomNavigationBarItem(icon: Icon(Icons.tv), label: 'مسلسلات'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'المفضلة'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}
