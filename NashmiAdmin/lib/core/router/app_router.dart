import 'package:get/get.dart';
import 'package:nashmi_admin_v2/views/login_view.dart';
import 'package:nashmi_admin_v2/views/home_view.dart';

import 'package:nashmi_admin_v2/views/movies/movies_view.dart';
import 'package:nashmi_admin_v2/views/series/series_view.dart';
import 'package:nashmi_admin_v2/views/ads/ads_view_enhanced_clean.dart';
import 'package:nashmi_admin_v2/views/users/users_view.dart';
import 'package:nashmi_admin_v2/views/settings_view.dart';
import 'package:nashmi_admin_v2/views/reports_view.dart';
import 'package:nashmi_admin_v2/views/categories/categories_view.dart';
import 'package:nashmi_admin_v2/views/hardware_view.dart';

class AppRouter {
  static const String login = '/login';
  static const String home = '/home';
  static const String movies = '/movies';
  static const String series = '/series';
  static const String ads = '/ads';
  static const String users = '/users';
  static const String settings = '/settings';
  static const String reports = '/reports';
  static const String categories = '/categories';
  static const String hardware = '/hardware';

  static final routes = [
    GetPage(
      name: login,
      page: () => LoginView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: home,
      page: () => HomeView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: movies,
      page: () => MoviesView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: series,
      page: () => SeriesView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: ads,
      page: () => AdsViewEnhancedClean(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: users,
      page: () => UsersView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: settings,
      page: () => SettingsView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: reports,
      page: () => ReportsView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: categories,
      page: () => CategoriesView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: hardware,
      page: () => HardwareView(),
      transition: Transition.fadeIn,
    ),
  ];
}
