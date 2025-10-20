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
import 'package:nashmi_tf/core/theme/app_theme.dart';
import 'package:nashmi_tf/core/theme/theme_service.dart';
import 'package:nashmi_tf/core/responsive/responsive_helper.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();
  late final AdService _adService;
  Timer? _timer;

  List<Map<String, dynamic>> _featuredContent = [];
  List<Map<String, dynamic>> _trendingMovies = [];
  List<Map<String, dynamic>> _trendingSeries = [];
  List<Map<String, dynamic>> _recentlyAdded = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _adService = Get.find<AdService>();
    _loadHomeContent();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      // Perform actions every 5 seconds
    });
  }

  Future<void> _loadHomeContent() async {
    try {
      setState(() => _isLoading = true);

      final movies = await _supabaseService.getMovies();
      final series = await _supabaseService.getSeries();

      // Featured content (mix of movies and series)
      _featuredContent = [...movies.take(3), ...series.take(3)]..shuffle();

      // Trending movies
      _trendingMovies = movies
          .where((m) => m['isTrending'] == true || (m['rating'] ?? 0) > 7.0)
          .take(10)
          .toList();

      // Trending series
      _trendingSeries = series
          .where((s) => s['isTrending'] == true || (s['rating'] ?? 0) > 7.0)
          .take(10)
          .toList();

      // Recently added
      _recentlyAdded = [...movies.take(5), ...series.take(5)]..shuffle();
    } catch (e) {
      print('Error loading home content: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _navigateToDetails(Map<String, dynamic> item) {
    if (item['isSeries'] == true) {
      Get.to(
        () => SeriesDetailsScreen(seriesId: item['id']),
        arguments: Movie.fromJson(item),
      );
    } else {
      Get.to(() => MovieDetailsScreen(movieId: item['id']));
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
            ? _LoadingView()
            : CustomScrollView(
                slivers: [
                  // Hero Banner
                  SliverToBoxAdapter(
                    child: _HeroBanner(featuredContent: _featuredContent),
                  ),

                  // Search Bar
                  SliverToBoxAdapter(child: _SearchBar()),

                  // Categories Section
                  SliverToBoxAdapter(child: _CategoriesSection()),

                  // Trending Movies
                  if (_trendingMovies.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _ContentSection(
                        title: 'أفلام رائجة',
                        items: _trendingMovies,
                        icon: Icons.movie,
                        onItemTap: _navigateToDetails,
                      ),
                    ),

                  // Trending Series
                  if (_trendingSeries.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _ContentSection(
                        title: 'مسلسلات رائجة',
                        items: _trendingSeries,
                        icon: Icons.tv,
                        onItemTap: _navigateToDetails,
                      ),
                    ),

                  // Recently Added
                  if (_recentlyAdded.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _ContentSection(
                        title: 'مضاف حديثاً',
                        items: _recentlyAdded,
                        icon: Icons.new_releases,
                        onItemTap: _navigateToDetails,
                      ),
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

// Hero Banner
class _HeroBanner extends StatefulWidget {
  final List<Map<String, dynamic>> featuredContent;

  const _HeroBanner({required this.featuredContent});

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

    if (widget.featuredContent.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
        if (_currentPage < widget.featuredContent.length - 1) {
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
    if (widget.featuredContent.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 500,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.featuredContent.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final item = widget.featuredContent[index];
              final imageUrl = item['imageURL'] ?? '';

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
                            item['title'] ?? 'محتوى مميز',
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
                          const SizedBox(height: 8),
                          Text(
                            item['description'] ??
                                'استمتع بمشاهدة هذا المحتوى المميز',
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
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (item['isSeries'] == true) {
                                Get.to(
                                  () =>
                                      SeriesDetailsScreen(seriesId: item['id']),
                                  arguments: Movie.fromJson(item),
                                );
                              } else {
                                Get.to(
                                  () => MovieDetailsScreen(movieId: item['id']),
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
          if (widget.featuredContent.length > 1)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.featuredContent.length,
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
                  'البحث عن أفلام ومسلسلات...',
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

// Categories Section
class _CategoriesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final categories = [
      {'title': 'أفلام', 'icon': Icons.movie, 'color': Colors.blue},
      {'title': 'مسلسلات', 'icon': Icons.tv, 'color': Colors.green},
      {'title': 'أنمي', 'icon': Icons.animation, 'color': Colors.purple},
      {'title': 'تركية', 'icon': Icons.flag, 'color': Colors.red},
      {'title': 'مصرية', 'icon': Icons.location_city, 'color': Colors.orange},
      {'title': 'هندية', 'icon': Icons.music_note, 'color': Colors.pink},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'التصنيفات',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      (category['color'] as Color).withOpacity(0.8),
                      (category['color'] as Color).withOpacity(0.4),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (category['color'] as Color).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      // Navigate to category
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          category['icon'] as IconData,
                          size: 32,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          category['title'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Content Section
class _ContentSection extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final IconData icon;
  final Function(Map<String, dynamic>) onItemTap;

  const _ContentSection({
    required this.title,
    required this.items,
    required this.icon,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  child: Icon(icon, color: Colors.red, size: 20),
                ),

                const SizedBox(width: 12),

                // Section Title
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
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

                // Item Count Badge
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
                    '${items.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Content List with Enhanced Container
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
                movies: items.map((item) => Movie.fromJson(item)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Loading View
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

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
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
                        Icons.home,
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
                    'جاري تحميل الصفحة الرئيسية...',
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
