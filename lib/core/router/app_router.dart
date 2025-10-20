import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nashmi_tf/features/home/presentation/screens/home_screen.dart';
import 'package:nashmi_tf/features/main/main_navigation_screen.dart';
import 'package:nashmi_tf/features/view_all/view_all_screen.dart';
import 'package:nashmi_tf/features/search/search_screen.dart';
import 'package:nashmi_tf/features/filter/filter_screen.dart';
import 'package:nashmi_tf/features/admin/admin_screen.dart';
import 'package:nashmi_tf/features/auth/login_screen.dart';
import 'package:nashmi_tf/features/favorites/favorites_screen.dart';
import 'package:nashmi_tf/features/movies_viewing/movies_viewing_screen.dart';
import 'package:nashmi_tf/features/series_viewing/series_viewing_screen.dart';
import 'package:nashmi_tf/screens/main_screen.dart';

class AppRouter {
  static final routes = [
    GetPage(
      name: '/home',
      page: () => HomeScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/main',
      page: () => MainScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/view-all',
      page: () => ViewAllScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/search',
      page: () => SearchScreen(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: '/filter',
      page: () => FilterScreen(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: '/admin',
      page: () => AdminScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/login',
      page: () => LoginScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/favorites',
      page: () => FavoritesScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/movies-viewing',
      page: () => MoviesViewingScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/series-viewing',
      page: () => SeriesViewingScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/main-screen',
      page: () => MainScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}
