Rimport 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nashmi_tf/services/supabase_service.dart';
import 'package:nashmi_tf/features/home/presentation/widgets/movie_list_horizontal.dart';
import 'package:nashmi_tf/features/movie_details/movie_details_screen.dart';
import 'package:nashmi_tf/features/series_details/series_details_screen.dart';
import 'package:nashmi_tf/features/search/enhanced_search_screen.dart';
import 'package:nashmi_tf/services/ad_service.dart';
import 'package:nashmi_tf/models/movie_model.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nashmi_tf/core/theme/app_theme.dart';
import 'package:nashmi_tf/core/theme/theme_service.dart';
import 'package:nashmi_tf/core/responsive/responsive_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();
  final AdService _adService = AdService();

  List<Map<String, dynamic>> _allMovies = [];
  List<Map<String, dynamic>> _featuredMovies = [];
  List<Map<String, dynamic>> _trendingMovies = [];
  bool _isLoading = true;

  // Main sections as requested
  List<Map<String, dynamic>> turkishSeries = [];
  List<Map<String, dynamic>> egyptianSeries = [];
  List<Map<String, dynamic>> ramadanSeries = [];
  List<Map<String, dynamic>> egyptianMovies = [];
  List<Map<String, dynamic>> indianMovies = [];
  List<Map<String, dynamic>> foreignMovies = [];
  List<Map<String, dynamic>> recentlyAdded = [];

  // Additional categorized lists (kept for compatibility)
  Map<String, List<Map<String, dynamic>>> moviesByType = {};
  Map<String, List<Map<String, dynamic>>> seriesByType = {};
  Map<int, List<Map<String, dynamic>>> moviesByYear = {};
  Map<int, List<Map<String, dynamic>>> seriesByYear = {};
  Map<String, List<Map<String, dynamic>>> moviesByGenre = {};
  Map<String, List<Map<String, dynamic>>> seriesByGenre = {};
  List<Map<String, dynamic>> topRated = [];
  List<Map<String, dynamic>> favorites = [];
  List<Map<String, dynamic>> recommended = [];
  List<Map<String, dynamic>> continueWatching = [];

  @override
  void initState() {
    super.initState();
    _loadMovies();
    _adService.initialize();
  }

  Future<void> _loadMovies() async {
    try {
      setState(() => _isLoading = true);

      // Load movies and series
      final movies = await _supabaseService.getMovies();
      final series = await _supabaseService.getSeries();

      print('🔍 Movies loaded: ${movies.length}');
      print('🔍 Series loaded: ${series.length}');

      // Combine movies and series
      final allMovies = [...movies, ...series];
      print('🔍 All movies combined: ${allMovies.length}');

      // Remove duplicates by id
      final Set<String> seenIds = <String>{};
      final uniqueMovies = allMovies
          .where((movie) => seenIds.add(movie['id']))
          .toList();
      print('🔍 Unique movies: ${uniqueMovies.length}');

      // Debug: Check first few movies
      for (var i = 0; i < uniqueMovies.length && i < 5; i++) {
        final movie = uniqueMovies[i];
        print(
          '🔍 Movie $i: ${movie['title']} - categories: ${movie['categories']} - isTrending: ${movie['isTrending']} - rating: ${movie['rating']}',
        );
      }

      // Featured movies (first 5)
      _featuredMovies = uniqueMovies.take(5).toList();
      print('🔍 Featured movies: ${_featuredMovies.length}');

      // Trending movies (random selection)
      _trendingMovies = uniqueMovies
          .where(
            (movie) =>
                movie['isTrending'] == true ||
                movie['rating'] != null && (movie['rating'] as num) > 7.0,
          )
          .take(10)
          .toList();
      print('🔍 Trending movies: ${_trendingMovies.length}');

      // Main sections as requested by user

      // Turkish Series
      turkishSeries = uniqueMovies
          .where(
            (movie) =>
                movie['isSeries'] == true &&
                movie['categories'] != null &&
                (movie['categories'] as List).any(
                  (cat) =>
                      cat.toString().toLowerCase().contains('تركي') ||
                      cat.toString().toLowerCase().contains('turkish'),
                ),
          )
          .take(10)
          .toList();
      print('🔍 Turkish series: ${turkishSeries.length}');

      // Egyptian Series
      egyptianSeries = uniqueMovies
          .where(
            (movie) =>
                movie['isSeries'] == true &&
                movie['categories'] != null &&
                (movie['categories'] as List).any(
                  (cat) =>
                      cat.toString().toLowerCase().contains('مصري') ||
                      cat.toString().toLowerCase().contains('egyptian'),
                ),
          )
          .take(10)
          .toList();
      print('🔍 Egyptian series: ${egyptianSeries.length}');

      // Ramadan Series
      ramadanSeries = uniqueMovies
          .where(
            (movie) =>
                movie['isSeries'] == true &&
                movie['categories'] != null &&
                (movie['categories'] as List).any(
                  (cat) =>
                      cat.toString().toLowerCase().contains('رمضان') ||
                      cat.toString().toLowerCase().contains('ramadan'),
                ),
          )
          .take(10)
          .toList();
      print('🔍 Ramadan series: ${ramadanSeries.length}');

      // Egyptian Movies
      egyptianMovies = uniqueMovies
          .where(
            (movie) =>
                (movie['isSeries'] == false || movie['isSeries'] == null) &&
                movie['categories'] != null &&
                (movie['categories'] as List).any(
                  (cat) =>
                      cat.toString().toLowerCase().contains('مصري') ||
                      cat.toString().toLowerCase().contains('egyptian'),
                ),
          )
          .take(10)
          .toList();
      print('🔍 Egyptian movies: ${egyptianMovies.length}');

      // Indian Movies
      indianMovies = uniqueMovies
          .where(
            (movie) =>
                (movie['isSeries'] == false || movie['isSeries'] == null) &&
                movie['categories'] != null &&
                (movie['categories'] as List).any(
                  (cat) =>
                      cat.toString().toLowerCase().contains('هندي') ||
                      cat.toString().toLowerCase().contains('indian'),
                ),
          )
          .take(10)
          .toList();
      print('🔍 Indian movies: ${indianMovies.length}');

      // Foreign Movies
      foreignMovies = uniqueMovies
          .where(
            (movie) =>
                (movie['isSeries'] == false || movie['isSeries'] == null) &&
                movie['categories'] != null &&
                (movie['categories'] as List).any(
                  (cat) =>
                      cat.toString().toLowerCase().contains('أجنبي') ||
                      cat.toString().toLowerCase().contains('foreign'),
                ),
          )
          .take(10)
          .toList();
      print('🔍 Foreign movies: ${foreignMovies.length}');

      // Recently Added (latest movies by year or creation date)
      recentlyAdded =
          uniqueMovies.where((movie) => movie['year'] != null).toList()
            ..sort((a, b) {
              int yearA = int.tryParse(a['year']?.toString() ?? '0') ?? 0;
              int yearB = int.tryParse(b['year']?.toString() ?? '0') ?? 0;
              return yearB.compareTo(yearA); // Sort by year descending
            })
            ..take(10).toList();
      print('🔍 Recently added: ${recentlyAdded.length}');

      // Categorize by Type (Movies, Series) and subtypes (مصري, أجنبي, هندي)
      // Note: We use the table source and isSeries field to distinguish movies from series
      // The مصري/أجنبي/هندي categorization is based on categories array or title/tags
      moviesByType = {
        'مصري': uniqueMovies
            .where(
              (m) =>
                  (m['isSeries'] == false || m['isSeries'] == null) &&
                  ((m['categories'] as List?)?.any(
                            (cat) => cat.toString().contains('مصري'),
                          ) ==
                          true ||
                      m['title']?.toString().contains('مصري') == true),
            )
            .toList(),
        'أجنبي': uniqueMovies
            .where(
              (m) =>
                  (m['isSeries'] == false || m['isSeries'] == null) &&
                  ((m['categories'] as List?)?.any(
                            (cat) => cat.toString().contains('أجنبي'),
                          ) ==
                          true ||
                      m['title']?.toString().contains('أجنبي') == true),
            )
            .toList(),
        'هندي': uniqueMovies
            .where(
              (m) =>
                  (m['isSeries'] == false || m['isSeries'] == null) &&
                  ((m['categories'] as List?)?.any(
                            (cat) => cat.toString().contains('هندي'),
                          ) ==
                          true ||
                      m['title']?.toString().contains('هندي') == true),
            )
            .toList(),
      };
      seriesByType = {
        'مصري': uniqueMovies
            .where(
              (m) =>
                  m['isSeries'] == true &&
                  ((m['categories'] as List?)?.any(
                            (cat) => cat.toString().contains('مصري'),
                          ) ==
                          true ||
                      m['title']?.toString().contains('مصري') == true),
            )
            .toList(),
        'أجنبي': uniqueMovies
            .where(
              (m) =>
                  m['isSeries'] == true &&
                  ((m['categories'] as List?)?.any(
                            (cat) => cat.toString().contains('أجنبي'),
                          ) ==
                          true ||
                      m['title']?.toString().contains('أجنبي') == true),
            )
            .toList(),
        'هندي': uniqueMovies
            .where(
              (m) =>
                  m['isSeries'] == true &&
                  ((m['categories'] as List?)?.any(
                            (cat) => cat.toString().contains('هندي'),
                          ) ==
                          true ||
                      m['title']?.toString().contains('هندي') == true),
            )
            .toList(),
      };

      // Categorize by Year dynamically
      moviesByYear = {};
      seriesByYear = {};
      for (var movie in uniqueMovies) {
        int? year = int.tryParse(movie['year']?.toString() ?? '');
        if (year != null) {
          if (movie['isSeries'] == false || movie['isSeries'] == null) {
            moviesByYear.putIfAbsent(year, () => []).add(movie);
          } else if (movie['isSeries'] == true) {
            seriesByYear.putIfAbsent(year, () => []).add(movie);
          }
        }
      }

      // Categorize by Genre
      List<String> genres = [
        'أكشن',
        'دراما',
        'كوميدي',
        'رومانسي',
        'خيال علمي',
        'رعب',
        'مغامرة',
        'أنمي',
        'كرتون',
      ];
      moviesByGenre = {};
      seriesByGenre = {};
      for (var genre in genres) {
        moviesByGenre[genre] = uniqueMovies
            .where(
              (m) =>
                  m['categories'] != null &&
                  (m['categories'] as List).any(
                    (cat) => cat.toString().contains(genre),
                  ) &&
                  (m['isSeries'] == false || m['isSeries'] == null),
            )
            .toList();
        seriesByGenre[genre] = uniqueMovies
            .where(
              (m) =>
                  m['categories'] != null &&
                  (m['categories'] as List).any(
                    (cat) => cat.toString().contains(genre),
                  ) &&
                  m['isSeries'] == true,
            )
            .toList();
      }

      // Status / Popularity sections
      topRated = uniqueMovies
          .where((m) => m['rating'] != null && (m['rating'] as num) >= 8)
          .toList();

      // Generate recommendations based on popular and highly rated content
      _generateRecommendations(uniqueMovies);

      // favorites, continueWatching can be implemented based on user data or preferences
      favorites = [];
      continueWatching = [];

      // Fallbacks for main sections if empty
      if (turkishSeries.isEmpty) {
        turkishSeries = uniqueMovies
            .where((m) => m['isSeries'] == true)
            .skip(0)
            .take(10)
            .toList();
        print('🔍 Using fallback for Turkish series: ${turkishSeries.length}');
      }
      if (egyptianSeries.isEmpty) {
        egyptianSeries = uniqueMovies
            .where((m) => m['isSeries'] == true)
            .skip(10)
            .take(10)
            .toList();
        print(
          '🔍 Using fallback for Egyptian series: ${egyptianSeries.length}',
        );
      }
      if (ramadanSeries.isEmpty) {
        ramadanSeries = uniqueMovies
            .where((m) => m['isSeries'] == true)
            .skip(20)
            .take(10)
            .toList();
        print('🔍 Using fallback for Ramadan series: ${ramadanSeries.length}');
      }
      if (egyptianMovies.isEmpty) {
        egyptianMovies = uniqueMovies
            .where((m) => m['isSeries'] == false || m['isSeries'] == null)
            .skip(30)
            .take(10)
            .toList();
        print(
          '🔍 Using fallback for Egyptian movies: ${egyptianMovies.length}',
        );
      }
      if (indianMovies.isEmpty) {
        indianMovies = uniqueMovies
            .where((m) => m['isSeries'] == false || m['isSeries'] == null)
            .skip(40)
            .take(10)
            .toList();
        print('🔍 Using fallback for Indian movies: ${indianMovies.length}');
      }
      if (foreignMovies.isEmpty) {
        foreignMovies = uniqueMovies
            .where((m) => m['isSeries'] == false || m['isSeries'] == null)
            .skip(50)
            .take(10)
            .toList();
        print('🔍 Using fallback for foreign movies: ${foreignMovies.length}');
      }
      if (recentlyAdded.isEmpty) {
        recentlyAdded = uniqueMovies.take(10).toList();
        print('🔍 Using fallback for recently added: ${recentlyAdded.length}');
      }
    } catch (e) {
      print('Error loading movies: $e');
      Get.snackbar(
        'خطأ',
        'فشل في تحميل الأفلام',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? const _LoadingView()
          : CustomScrollView(
              slivers: [
                // Hero Banner
                SliverToBoxAdapter(
                  child: _HeroBanner(featuredMovies: _featuredMovies),
                ),

                // Search Bar
                SliverToBoxAdapter(child: _SearchBar()),

                // Main Content Sections as requested by user

                // Turkish Series
                if (turkishSeries.isNotEmpty)
                  _MovieSection(
                    title: 'مسلسلات تركية',
                    movies: turkishSeries,
                    onMovieTap: _navigateToMovieDetails,
                  ),

                // Egyptian Series
                if (egyptianSeries.isNotEmpty)
                  _MovieSection(
                    title: 'مسلسلات مصرية',
                    movies: egyptianSeries,
                    onMovieTap: _navigateToMovieDetails,
                  ),

                // Ramadan Series
                if (ramadanSeries.isNotEmpty)
                  _MovieSection(
                    title: 'مسلسلات رمضان',
                    movies: ramadanSeries,
                    onMovieTap: _navigateToMovieDetails,
                  ),

                // Egyptian Movies
                if (egyptianMovies.isNotEmpty)
                  _MovieSection(
                    title: 'أفلام مصرية',
                    movies: egyptianMovies,
                    onMovieTap: _navigateToMovieDetails,
                  ),

                // Indian Movies
                if (indianMovies.isNotEmpty)
                  _MovieSection(
                    title: 'أفلام هندية',
                    movies: indianMovies,
                    onMovieTap: _navigateToMovieDetails,
                  ),

                // Foreign Movies
                if (foreignMovies.isNotEmpty)
                  _MovieSection(
                    title: 'أفلام أجنبية',
                    movies: foreignMovies,
                    onMovieTap: _navigateToMovieDetails,
                  ),

                // Recently Added
                if (recentlyAdded.isNotEmpty)
                  _MovieSection(
                    title: 'مضاف حديثاً',
                    movies: recentlyAdded,
                    onMovieTap: _navigateToMovieDetails,
                  ),

                // Bottom spacing
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),

      // Banner Ad at bottom
      bottomNavigationBar:
          _adService.isBannerAdLoaded && _adService.bannerAd != null
          ? Container(
              height: _adService.bannerAd!.size.height.toDouble(),
              width: double.infinity,
              child: AdWidget(ad: _adService.bannerAd!),
            )
          : null,
    );
  }

  void _navigateToMovieDetails(Map<String, dynamic> movie) {
    if (movie['isSeries'] == true) {
      Get.to(
        () => SeriesDetailsScreen(seriesId: movie['id']),
        arguments: Movie.fromJson(movie),
      );
    } else {
      Get.to(() => MovieDetailsScreen(movieId: movie['id']));
    }
  }

  void _generateRecommendations(List<Map<String, dynamic>> allMovies) {
    // Simple recommendation algorithm based on ratings and trending status
    final highRatedMovies = allMovies
        .where(
          (movie) => movie['rating'] != null && (movie['rating'] as num) >= 7.5,
        )
        .toList();

    final trendingMovies = allMovies
        .where((movie) => movie['isTrending'] == true)
        .toList();

    // Combine high-rated and trending movies, remove duplicates
    final Set<String> seenIds = <String>{};
    final recommendationCandidates = [
      ...highRatedMovies,
      ...trendingMovies,
    ].where((movie) => seenIds.add(movie['id'])).toList();

    // Sort by rating (highest first) and take top 10
    recommendationCandidates.sort((a, b) {
      final ratingA = a['rating'] as num? ?? 0;
      final ratingB = b['rating'] as num? ?? 0;
      return ratingB.compareTo(ratingA);
    });

    recommended = recommendationCandidates.take(10).toList();

    print('🔍 Generated ${recommended.length} recommendations');
  }

  void _showAllSectionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.category,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'جميع الأقسام',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Main Sections
                          const Text(
                            'الأقسام الرئيسية',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildSectionItem(
                            'مسلسلات تركية',
                            Icons.tv,
                            turkishSeries.length,
                          ),
                          _buildSectionItem(
                            'مسلسلات مصرية',
                            Icons.tv,
                            egyptianSeries.length,
                          ),
                          _buildSectionItem(
                            'مسلسلات رمضان',
                            Icons.tv,
                            ramadanSeries.length,
                          ),
                          _buildSectionItem(
                            'أفلام مصرية',
                            Icons.movie,
                            egyptianMovies.length,
                          ),
                          _buildSectionItem(
                            'أفلام هندية',
                            Icons.movie,
                            indianMovies.length,
                          ),
                          _buildSectionItem(
                            'أفلام أجنبية',
                            Icons.movie,
                            foreignMovies.length,
                          ),
                          _buildSectionItem(
                            'مضاف حديثاً',
                            Icons.new_releases,
                            recentlyAdded.length,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionItem(String title, IconData icon, int count) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[800]?.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[700]!, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: Colors.red, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Enhanced Hero Carousel Widget
class _HeroBanner extends StatefulWidget {
  final List<Map<String, dynamic>> featuredMovies;

  const _HeroBanner({required this.featuredMovies});

  @override
  State<_HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<_HeroBanner> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    // Auto-scroll carousel
    if (widget.featuredMovies.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
        if (_currentPage < widget.featuredMovies.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.featuredMovies.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 500,
      child: Stack(
        children: [
          // Carousel
          PageView.builder(
            controller: _pageController,
            itemCount: widget.featuredMovies.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final movie = widget.featuredMovies[index];
              final imageUrl = movie['imageURL'] ?? '';

              return Container(
                decoration: BoxDecoration(
                  image: imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.3),
                            BlendMode.darken,
                          ),
                        )
                      : null,
                  gradient: imageUrl.isEmpty
                      ? const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.red, Colors.black],
                        )
                      : null,
                ),
                child: Stack(
                  children: [
                    // Gradient overlay
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black],
                          stops: [0.6, 1.0],
                        ),
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title with animation
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            child: Text(
                              movie['title'] ?? 'فيلم مميز',
                              key: ValueKey<String>(
                                movie['title'] ?? 'default',
                              ),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black,
                                    blurRadius: 10,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Description with animation
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            child: Text(
                              movie['description'] ??
                                  'استمتع بمشاهدة هذا الفيلم المميز',
                              key: ValueKey<String>(
                                movie['description'] ?? 'default',
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                                shadows: const [
                                  Shadow(
                                    color: Colors.black,
                                    blurRadius: 5,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Enhanced Action Buttons
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  if (movie['isSeries'] == true) {
                                    Get.to(
                                      () => SeriesDetailsScreen(
                                        seriesId: movie['id'],
                                      ),
                                      arguments: Movie.fromJson(movie),
                                    );
                                  } else {
                                    Get.to(
                                      () => MovieDetailsScreen(
                                        movieId: movie['id'],
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('شاهد الآن'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 16),

                              OutlinedButton.icon(
                                onPressed: () {
                                  // Add to favorites logic
                                  Get.snackbar(
                                    'تم الإضافة',
                                    'تم إضافة الفيلم إلى المفضلة',
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                    duration: const Duration(seconds: 2),
                                  );
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('إضافة إلى المفضلة'),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Page indicators
          if (widget.featuredMovies.length > 1)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.featuredMovies.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

          // Skip button
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              onPressed: () {
                // Skip to next movie manually
                if (_currentPage < widget.featuredMovies.length - 1) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                }
              },
              icon: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// All Sections Button Widget
class _AllSectionsButton extends StatelessWidget {
  final VoidCallback onShowAllSections;

  const _AllSectionsButton({required this.onShowAllSections});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton.icon(
        onPressed: onShowAllSections,
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.category, color: Colors.white, size: 20),
        ),
        label: const Text(
          'جميع الأقسام',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: Colors.red.withOpacity(0.3),
        ),
      ),
    );
  }
}

// Enhanced Search Bar Widget
class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.black,
      child: GestureDetector(
        onTap: () => Get.to(() => const EnhancedSearchScreen()),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[700]!, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Search Icon with Background
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.search, color: Colors.red, size: 20),
              ),

              const SizedBox(width: 16),

              // Search Text
              Expanded(
                child: Text(
                  'البحث عن أفلام، مسلسلات، ممثلين...',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Voice Search Icon with Background
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.mic, color: Colors.blue, size: 20),
              ),

              const SizedBox(width: 8),

              // Filter Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.filter_list,
                  color: Colors.green,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Enhanced Movie Section Widget
class _MovieSection extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> movies;
  final Function(Map<String, dynamic>) onMovieTap;
  final bool showViewAll;
  final VoidCallback? onViewAllPressed;
  final bool isLarge;

  const _MovieSection({
    required this.title,
    required this.movies,
    required this.onMovieTap,
    this.showViewAll = false,
    this.onViewAllPressed,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced Section Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[900]?.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[800]!, width: 1),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Section Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.movie_filter_rounded,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Section Title
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: isLarge ? 24 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Movie Count Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${movies.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  if (showViewAll) ...[
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: onViewAllPressed,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        backgroundColor: Colors.white.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'عرض الكل',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Movie List with Enhanced Container
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[900]?.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[800]!, width: 1),
              ),
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                height: 280,
                child: MovieListHorizontal(
                  movies: movies.map((m) => Movie.fromJson(m)).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Enhanced Loading View
class _LoadingView extends StatefulWidget {
  const _LoadingView();

  @override
  State<_LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<_LoadingView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Logo/Icon
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.movie_filter_rounded,
                        color: Colors.red,
                        size: 60,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Loading Text with Animation
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Text(
                    'جاري تحميل الأفلام...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Loading Dots Animation
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        double delay = index * 0.2;
                        double opacity =
                            (sin(
                                  (_animationController.value + delay) * 2 * pi,
                                ) +
                                1) /
                            2;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(opacity),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      },
                    );
                  }),
                );
              },
            ),

            const SizedBox(height: 32),

            // Progress Bar
            Container(
              width: 200,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(2),
              ),
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _animationController.value,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.red, Colors.redAccent],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Subtitle
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'يرجى الانتظار قليلاً',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
