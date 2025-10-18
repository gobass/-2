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

class SeriesViewingScreen extends StatefulWidget {
  const SeriesViewingScreen({super.key});

  @override
  State<SeriesViewingScreen> createState() => _SeriesViewingScreenState();
}

class _SeriesViewingScreenState extends State<SeriesViewingScreen> {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();
  final AdService _adService = AdService();

  List<Map<String, dynamic>> _allSeries = [];
  List<Map<String, dynamic>> _featuredSeries = [];
  List<Map<String, dynamic>> _trendingSeries = [];
  bool _isLoading = true;

  // Series sections
  List<Map<String, dynamic>> turkishSeries = [];
  List<Map<String, dynamic>> egyptianSeries = [];
  List<Map<String, dynamic>> syrianSeries = [];
  List<Map<String, dynamic>> animeSeries = [];
  List<Map<String, dynamic>> ramadanSeries = [];
  List<Map<String, dynamic>> recentlyAddedSeries = [];

  @override
  void initState() {
    super.initState();
    _loadSeries();
    _adService.initialize();
  }

  Future<void> _loadSeries() async {
    try {
      setState(() => _isLoading = true);

      final series = await _supabaseService.getSeries();

      print('🔍 Series loaded: ${series.length}');

      // Filter only series
      final allSeries = series.where((s) => s['isSeries'] == true).toList();
      print('🔍 Filtered series: ${allSeries.length}');

      // Featured series (first 5)
      _featuredSeries = allSeries.take(5).toList();
      print('🔍 Featured series: ${_featuredSeries.length}');

      // Trending series (random selection)
      _trendingSeries = allSeries
          .where(
            (series) =>
                series['isTrending'] == true ||
                series['rating'] != null && (series['rating'] as num) > 7.0,
          )
          .take(10)
          .toList();
      print('🔍 Trending series: ${_trendingSeries.length}');

      // Turkish Series
      turkishSeries = allSeries
          .where(
            (series) =>
                series['categories'] != null &&
                (series['categories'] as List).any(
                  (cat) =>
                      cat.toString().toLowerCase().contains('تركي') ||
                      cat.toString().toLowerCase().contains('turkish'),
                ),
          )
          .take(10)
          .toList();
      print('🔍 Turkish series: ${turkishSeries.length}');

      // Egyptian Series
      egyptianSeries = allSeries
          .where(
            (series) =>
                series['categories'] != null &&
                (series['categories'] as List).any(
                  (cat) =>
                      cat.toString().toLowerCase().contains('مصري') ||
                      cat.toString().toLowerCase().contains('egyptian'),
                ),
          )
          .take(10)
          .toList();
      print('🔍 Egyptian series: ${egyptianSeries.length}');

      // Syrian Series
      syrianSeries = allSeries
          .where(
            (series) =>
                series['categories'] != null &&
                (series['categories'] as List).any(
                  (cat) =>
                      cat.toString().toLowerCase().contains('سوري') ||
                      cat.toString().toLowerCase().contains('syrian'),
                ),
          )
          .take(10)
          .toList();
      print('🔍 Syrian series: ${syrianSeries.length}');

      // Anime Series
      animeSeries = allSeries
          .where(
            (series) =>
                series['categories'] != null &&
                (series['categories'] as List).any(
                  (cat) =>
                      cat.toString().toLowerCase().contains('انمي') ||
                      cat.toString().toLowerCase().contains('anime'),
                ),
          )
          .take(10)
          .toList();
      print('🔍 Anime series: ${animeSeries.length}');

      // Ramadan Series
      ramadanSeries = allSeries
          .where(
            (series) =>
                series['categories'] != null &&
                (series['categories'] as List).any(
                  (cat) =>
                      cat.toString().toLowerCase().contains('رمضان') ||
                      cat.toString().toLowerCase().contains('ramadan'),
                ),
          )
          .take(10)
          .toList();
      print('🔍 Ramadan series: ${ramadanSeries.length}');

      // Recently Added Series
      recentlyAddedSeries = allSeries.take(10).toList();
      print('🔍 Recently added series: ${recentlyAddedSeries.length}');

      // Fallbacks
      if (turkishSeries.isEmpty) {
        turkishSeries = allSeries.skip(0).take(10).toList();
      }
      if (egyptianSeries.isEmpty) {
        egyptianSeries = allSeries.skip(10).take(10).toList();
      }
      if (syrianSeries.isEmpty) {
        syrianSeries = allSeries.skip(30).take(10).toList();
      }
      if (animeSeries.isEmpty) {
        animeSeries = allSeries.skip(40).take(10).toList();
      }
      if (ramadanSeries.isEmpty) {
        ramadanSeries = allSeries.skip(20).take(10).toList();
      }
      if (recentlyAddedSeries.isEmpty) {
        recentlyAddedSeries = allSeries.take(10).toList();
      }
    } catch (e) {
      print('Error loading series: $e');
      Get.snackbar(
        'خطأ',
        'فشل في تحميل المسلسلات',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToSeriesDetails(Map<String, dynamic> series) {
    Get.to(
      () => SeriesDetailsScreen(seriesId: series['id']),
      arguments: Movie.fromJson(series),
    );
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
                  child: _HeroBanner(featuredSeries: _featuredSeries),
                ),

                // Search Bar
                SliverToBoxAdapter(child: _SearchBar()),

                // Series Sections
                if (turkishSeries.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _SeriesSection(
                      title: 'مسلسلات تركية',
                      series: turkishSeries,
                      onSeriesTap: _navigateToSeriesDetails,
                    ),
                  ),

                if (egyptianSeries.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _SeriesSection(
                      title: 'مسلسلات مصرية',
                      series: egyptianSeries,
                      onSeriesTap: _navigateToSeriesDetails,
                    ),
                  ),

                SliverToBoxAdapter(
                  child: _SeriesSection(
                    title: 'مسلسلات سورية',
                    series: syrianSeries,
                    onSeriesTap: _navigateToSeriesDetails,
                  ),
                ),

                SliverToBoxAdapter(
                  child: _SeriesSection(
                    title: 'مسلسلات أنمي',
                    series: animeSeries,
                    onSeriesTap: _navigateToSeriesDetails,
                  ),
                ),

                if (ramadanSeries.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _SeriesSection(
                      title: 'مسلسلات رمضان',
                      series: ramadanSeries,
                      onSeriesTap: _navigateToSeriesDetails,
                    ),
                  ),

                if (recentlyAddedSeries.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _SeriesSection(
                      title: 'مضاف حديثاً',
                      series: recentlyAddedSeries,
                      onSeriesTap: _navigateToSeriesDetails,
                    ),
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
}

// Hero Banner for Series
class _HeroBanner extends StatefulWidget {
  final List<Map<String, dynamic>> featuredSeries;

  const _HeroBanner({required this.featuredSeries});

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

    if (widget.featuredSeries.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
        if (_currentPage < widget.featuredSeries.length - 1) {
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
    if (widget.featuredSeries.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 500,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.featuredSeries.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final series = widget.featuredSeries[index];
              final imageUrl = series['imageURL'] ?? '';

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
                          colors: [Colors.blue, Colors.black],
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
                            series['title'] ?? 'مسلسل مميز',
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
                            series['description'] ??
                                'استمتع بمشاهدة هذا المسلسل المميز',
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
                              Get.to(
                                () =>
                                    SeriesDetailsScreen(seriesId: series['id']),
                                arguments: Movie.fromJson(series),
                              );
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
          if (widget.featuredSeries.length > 1)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.featuredSeries.length,
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
      color: Colors.white,
      child: GestureDetector(
        onTap: () => Get.to(() => const EnhancedSearchScreen()),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[300]!, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
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
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.search, color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'البحث عن مسلسلات...',
                  style: TextStyle(
                    color: Colors.grey[600],
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

// Series Section
class _SeriesSection extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> series;
  final Function(Map<String, dynamic>) onSeriesTap;

  const _SeriesSection({
    required this.title,
    required this.series,
    required this.onSeriesTap,
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
                  child: const Icon(Icons.tv, color: Colors.red, size: 20),
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
                    '${series.length}',
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
                movies: series.map((s) => Movie.fromJson(s)).toList(),
              ),
            ),
          ),
        ],
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
                      child: const Icon(Icons.tv, color: Colors.red, size: 60),
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
                    'جاري تحميل المسلسلات...',
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
