import 'dart:async';
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

class MoviesViewingScreen extends StatefulWidget {
  const MoviesViewingScreen({super.key});

  @override
  State<MoviesViewingScreen> createState() => _MoviesViewingScreenState();
}

class _MoviesViewingScreenState extends State<MoviesViewingScreen> {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();
  late final AdService _adService;

  List<Map<String, dynamic>> _allMovies = [];
  List<Map<String, dynamic>> _featuredMovies = [];
  List<Map<String, dynamic>> _trendingMovies = [];
  bool _isLoading = true;

  // Movies sections
  List<Map<String, dynamic>> egyptianMovies = [];
  List<Map<String, dynamic>> indianMovies = [];
  List<Map<String, dynamic>> foreignMovies = [];
  List<Map<String, dynamic>> recentlyAddedMovies = [];

  @override
  void initState() {
    super.initState();
    _adService = Get.find<AdService>();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    try {
      setState(() => _isLoading = true);

      final movies = await _supabaseService.getMovies();

      print('🔍 Movies loaded: ${movies.length}');

      // Filter only movies (not series)
      final allMovies = movies.where((m) => m['isSeries'] != true).toList();
      print('🔍 Filtered movies: ${allMovies.length}');

      // Featured movies (first 5)
      _featuredMovies = allMovies.take(5).toList();
      print('🔍 Featured movies: ${_featuredMovies.length}');

      // Trending movies (random selection)
      _trendingMovies = allMovies
          .where(
            (movie) =>
                movie['isTrending'] == true ||
                movie['rating'] != null && (movie['rating'] as num) > 7.0,
          )
          .take(10)
          .toList();
      print('🔍 Trending movies: ${_trendingMovies.length}');

      // Egyptian Movies
      egyptianMovies = allMovies
          .where(
            (movie) =>
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
      indianMovies = allMovies
          .where(
            (movie) =>
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
      foreignMovies = allMovies
          .where(
            (movie) =>
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

      // Recently Added Movies
      recentlyAddedMovies = allMovies.take(10).toList();
      print('🔍 Recently added movies: ${recentlyAddedMovies.length}');

      // Fallbacks
      if (egyptianMovies.isEmpty) {
        egyptianMovies = allMovies.skip(0).take(10).toList();
      }
      if (indianMovies.isEmpty) {
        indianMovies = allMovies.skip(10).take(10).toList();
      }
      if (foreignMovies.isEmpty) {
        foreignMovies = allMovies.skip(20).take(10).toList();
      }
      if (recentlyAddedMovies.isEmpty) {
        recentlyAddedMovies = allMovies.take(10).toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A2E), // Dark blue
              Color(0xFF16213E), // Darker blue
              Color(0xFF0F3460), // Navy blue
              Color(0xFF533483), // Purple accent
            ],
          ),
        ),
        child: _isLoading
            ? _ModernLoadingView()
            : CustomScrollView(
                slivers: [
                  // Hero Banner
                  SliverToBoxAdapter(
                    child: _HeroBanner(featuredMovies: _featuredMovies),
                  ),

                  // Search Bar
                  SliverToBoxAdapter(child: _SearchBar()),

                  // Movies Sections with modern design
                  if (egyptianMovies.isNotEmpty)
                    _ModernMoviesSection(
                      title: 'أفلام مصرية',
                      movies: egyptianMovies,
                      onMovieTap: _navigateToMovieDetails,
                      icon: Icons.location_city,
                      gradientColors: [Colors.orange, Colors.red],
                    ),

                  if (indianMovies.isNotEmpty)
                    _ModernMoviesSection(
                      title: 'أفلام هندية',
                      movies: indianMovies,
                      onMovieTap: _navigateToMovieDetails,
                      icon: Icons.music_note,
                      gradientColors: [Colors.pink, Colors.purple],
                    ),

                  if (foreignMovies.isNotEmpty)
                    _ModernMoviesSection(
                      title: 'أفلام أجنبية',
                      movies: foreignMovies,
                      onMovieTap: _navigateToMovieDetails,
                      icon: Icons.language,
                      gradientColors: [Colors.blue, Colors.indigo],
                    ),

                  if (recentlyAddedMovies.isNotEmpty)
                    _ModernMoviesSection(
                      title: 'مضاف حديثاً',
                      movies: recentlyAddedMovies,
                      onMovieTap: _navigateToMovieDetails,
                      icon: Icons.new_releases,
                      gradientColors: [Colors.green, Colors.teal],
                    ),

                  // Bottom spacing
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
      ),

      // Banner Ad at bottom
      bottomNavigationBar: Container(
        height: 60,
        child: _adService.getBannerAdWidget(),
      ),
    );
  }
}

// Hero Banner for Movies
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
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie['title'] ?? 'فيلم مميز',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: const [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            movie['description'] ??
                                'استمتع بمشاهدة هذا الفيلم المميز',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                              shadows: const [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 5,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
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
                                  () =>
                                      MovieDetailsScreen(movieId: movie['id']),
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
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
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
        ],
      ),
    );
  }
}

// Search Bar
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.search, color: Colors.red, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'البحث عن أفلام...',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Modern Loading View
class _ModernLoadingView extends StatefulWidget {
  const _ModernLoadingView();

  @override
  State<_ModernLoadingView> createState() => _ModernLoadingViewState();
}

class _ModernLoadingViewState extends State<_ModernLoadingView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * pi).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
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
            // Animated Movie Icon
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.red, Colors.pink, Colors.purple],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.movie,
                        color: Colors.white,
                        size: 64,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Loading Text with Gradient
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.red, Colors.pink, Colors.purple],
                    ).createShader(bounds),
                    child: const Text(
                      'جاري تحميل الأفلام...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Modern Progress Indicator
            Container(
              width: 200,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(3),
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
                          colors: [Colors.red, Colors.pink, Colors.purple],
                        ),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
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
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
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

// Modern Movies Section
class _ModernMoviesSection extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> movies;
  final Function(Map<String, dynamic>) onMovieTap;
  final IconData icon;
  final List<Color> gradientColors;

  _ModernMoviesSection({
    required this.title,
    required this.movies,
    required this.onMovieTap,
    required this.icon,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modern Section Header with Gradient
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors[0].withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Animated Icon Container
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),

                  const SizedBox(width: 16),

                  // Section Title with Shadow
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Color.fromRGBO(0, 0, 0, 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Count Badge with Gradient
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${movies.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Movies List with Glass Effect
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 300,
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
