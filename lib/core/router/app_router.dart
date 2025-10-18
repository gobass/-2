import 'package:get/get.dart';
import 'package:nashmi_tf/features/home/presentation/screens/home_screen.dart';
import 'package:nashmi_tf/features/movie_details/movie_details_screen.dart';
import 'package:nashmi_tf/features/search/search_screen.dart';
import 'package:nashmi_tf/features/splash/splash_screen.dart';
import 'package:nashmi_tf/features/view_all/view_all_screen.dart';
import 'package:nashmi_tf/features/filter/filter_screen.dart';
import 'package:nashmi_tf/features/main/main_navigation_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String home = '/home';
  static const String movieDetails = '/movie-details';
  static const String videoPlayer = '/video-player';
  static const String search = '/search';
  static const String viewAll = '/view-all';
  static const String filter = '/filter';

  static List<GetPage> routes = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
      transition: Transition.fade,
    ),
    GetPage(
      name: home,
      page: () => const MainNavigationScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: movieDetails,
      page: () {
        // If movie object is passed in arguments, use it
        final movieId = Get.parameters['movieId'] ?? '';
        return MovieDetailsScreen(movieId: movieId);
      },
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: search,
      page: () => const SearchScreen(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: viewAll,
      page: () => const ViewAllScreen(title: '', category: ''),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: filter,
      page: () => const FilterScreen(),
      transition: Transition.downToUp,
    ),
  ];
}