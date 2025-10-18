import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nashmi_tf/models/movie_model.dart';
import 'package:nashmi_tf/features/video_player/video_player_screen.dart';
import 'package:nashmi_tf/features/video_player/dailymotion_player.dart';
import 'package:nashmi_tf/services/favorites_service.dart';
import 'package:nashmi_tf/services/ad_service.dart';
import 'package:nashmi_tf/services/rating_service.dart';
import 'package:nashmi_tf/services/supabase_service.dart';
import 'package:nashmi_tf/core/theme/app_theme.dart';

class MovieDetailsScreen extends StatefulWidget {
  final String movieId;

  const MovieDetailsScreen({super.key, required this.movieId});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  Movie? _movie;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMovieData();
  }

  Future<void> _loadMovieData() async {
    try {
      // First try to get movie from arguments
      final Movie? movieFromArgs = Get.arguments as Movie?;
      if (movieFromArgs != null) {
        setState(() {
          _movie = movieFromArgs;
          _isLoading = false;
        });
        print('🎬 Loaded movie from arguments: ${_movie?.videoURL}');
        return;
      }

      // If no arguments, fetch from Supabase
      final supabaseService = Get.find<SupabaseService>();
      final movieData = await supabaseService.getMovieById(widget.movieId);

      if (movieData != null) {
        setState(() {
          _movie = Movie.fromJson(movieData);
          _isLoading = false;
        });
        print('🎬 Loaded movie from Supabase: ${movieData['videoURL']}');
      } else {
        setState(() {
          _error = 'لم يتم العثور على الفيلم';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'حدث خطأ في تحميل بيانات الفيلم';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    if (_error != null || _movie == null) {
      return _buildNotFoundScreen();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // Enhanced App Bar with Movie Poster Background
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Movie Poster Background
                  CachedNetworkImage(
                    imageUrl: _movie!.imageURL,
                    fit: BoxFit.cover,
                    httpHeaders: const {
                      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                    },
                    placeholder: (context, url) => Container(
                      color: Colors.grey[900],
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[900],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.broken_image, color: Colors.grey, size: 48),
                          const SizedBox(height: 8),
                          Text(
                            'صورة غير متوفرة',
                            style: TextStyle(color: Colors.grey[400], fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Enhanced Gradient overlay with multiple layers
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.3),
                          Colors.black.withValues(alpha: 0.8),
                          Colors.black,
                        ],
                      ),
                    ),
                  ),

                  // Movie Title Overlay (top)
                  Positioned(
                    top: 120,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _getCategoryName(_movie!.category),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _movie!.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: 10,
                                color: Colors.black,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (_movie!.rating != null) ...[
                              const Icon(Icons.star, color: Colors.amber, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                _movie!.rating!.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                            if (_movie!.year != null) ...[
                              Text(
                                _movie!.year!,
                                style: const TextStyle(color: Colors.white70, fontSize: 16),
                              ),
                              const SizedBox(width: 16),
                            ],
                            if (_movie!.duration != null)
                              Text(
                                _movie!.duration!,
                                style: const TextStyle(color: Colors.white70, fontSize: 16),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Enhanced Action Buttons (bottom)
                  Positioned(
                    bottom: 30,
                    left: 20,
                    right: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Favorite Button
                        Obx(() {
                          final favoritesService = FavoritesService.instance;
                          final isFavorite = favoritesService.isFavorite(_movie!.id);

                          return Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: FloatingActionButton(
                              heroTag: "favorite",
                              onPressed: () => favoritesService.toggleFavorite(_movie!),
                              backgroundColor: isFavorite ? Colors.red : Colors.grey[800]!,
                              foregroundColor: Colors.white,
                              child: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                size: 24,
                              ),
                            ),
                          );
                        }),

                        const SizedBox(width: 16),

                        // Main Play Button
                        Expanded(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.red, Color(0xFFE53E3E)],
                              ),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () => _playMovie(_movie!),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.play_arrow, size: 24),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'تشغيل الفيلم',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Share Button
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: FloatingActionButton(
                            heroTag: "share",
                            onPressed: () => _shareMovie(_movie!),
                            backgroundColor: Colors.grey[800]!,
                            foregroundColor: Colors.white,
                            child: const Icon(Icons.share, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Enhanced Movie Details Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.red, Color(0xFFE53E3E)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () => _playMovie(_movie!),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.play_arrow, size: 20),
                            label: const Text('تشغيل الفيلم', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () => _addToWatchlist(_movie!),
                          icon: const Icon(Icons.add, color: Colors.white, size: 24),
                          padding: const EdgeInsets.all(14),
                          tooltip: 'إضافة للقائمة',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Movie Description Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[800]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.description, color: Colors.red, size: 24),
                            const SizedBox(width: 8),
                            const Text(
                              'القصة',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _movie!.description,
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 16,
                            height: 1.7,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Enhanced Movie Info Section
                  _buildEnhancedInfoSection(),

                  const SizedBox(height: 24),

                  // Cast & Crew Section
                  _buildCastSection(),

                  const SizedBox(height: 24),

                  // Enhanced User Rating Section
                  _buildEnhancedRatingSection(),

                  const SizedBox(height: 32),

                  // Related Movies Section
                  _buildRelatedMoviesSection(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            ),
            SizedBox(height: 16),
            Text(
              'جاري تحميل بيانات الفيلم...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'خطأ',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              _error ?? 'لم يتم العثور على الفيلم',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'يرجى المحاولة مرة أخرى',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<InfoItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: items.map((item) => _buildInfoItem(item)).toList(),
          ),
        ),
      ],
    );
  }



  Widget _buildInfoItem(InfoItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[800]!,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item.label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
          ),
          Text(
            item.value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(String category) {
    switch (category.toLowerCase()) {
      case 'action':
        return 'أكشن';
      case 'comedy':
        return 'كوميديا';
      case 'drama':
        return 'دراما';
      case 'horror':
        return 'رعب';
      case 'romance':
        return 'رومانسية';
      case 'scifi':
        return 'خيال علمي';
      default:
        return category;
    }
  }

  void _playMovie(Movie movie) {
    final adService = AdService();

    bool isDailymotion = false;
    try {
      final uri = Uri.parse(movie.videoURL);
      if (uri.host.contains('dailymotion.com') || uri.host.contains('dai.ly')) {
        isDailymotion = true;
      }
    } catch (_) {}

    if (movie.rating != null && movie.rating! > 4.5) {
      adService.showRewardedAd((rewardEarned) {
        if (rewardEarned) {
          if (isDailymotion) {
            Get.to(() => DailymotionPlayer(
              videoUrl: movie.videoURL,
              movieTitle: movie.title,
            ));
          } else {
            Get.to(() => VideoPlayerScreen(
              videoUrl: movie.videoURL,
              movieTitle: movie.title,
            ));
          }

          Get.snackbar(
            'تم فتح المحتوى المميز!',
            'شكراً لك، استمتع بالمشاهدة',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            icon: const Icon(Icons.star, color: Colors.white),
          );
        } else {
          Get.snackbar(
            'لم يتم فتح المحتوى',
            'يجب مشاهدة الإعلان لفتح المحتوى المميز',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            icon: const Icon(Icons.lock, color: Colors.white),
          );
        }
      });
    } else {
      if (adService.shouldShowInterstitial()) {
        adService.showInterstitialAd(() {
          if (isDailymotion) {
            Get.to(() => DailymotionPlayer(
              videoUrl: movie.videoURL,
              movieTitle: movie.title,
            ));
          } else {
            Get.to(() => VideoPlayerScreen(
              videoUrl: movie.videoURL,
              movieTitle: movie.title,
            ));
          }
        });
      } else {
        if (isDailymotion) {
          Get.to(() => DailymotionPlayer(
            videoUrl: movie.videoURL,
            movieTitle: movie.title,
          ));
        } else {
          Get.to(() => VideoPlayerScreen(
            videoUrl: movie.videoURL,
            movieTitle: movie.title,
          ));
        }
      }
    }
  }

  void _addToWatchlist(Movie movie) {
    Get.snackbar(
      'تم الحفظ',
      'تم إضافة "${movie.title}" إلى قائمتك',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: const Icon(Icons.check, color: Colors.white),
    );
  }

  void _shareMovie(Movie movie) {
    // Share movie functionality
    Get.snackbar(
      'مشاركة',
      'جاري مشاركة "${movie.title}"...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      icon: const Icon(Icons.share, color: Colors.white),
    );
  }

  Widget _buildEnhancedInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blue, size: 24),
              const SizedBox(width: 8),
              const Text(
                'معلومات الفيلم',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoGrid([
            InfoItem('التصنيف', _getCategoryName(_movie!.category)),
            if (_movie!.viewCount != null)
              InfoItem('المشاهدات', '${_movie!.viewCount} مشاهدة'),
            if (_movie!.year != null)
              InfoItem('سنة الإصدار', _movie!.year!),
            if (_movie!.duration != null)
              InfoItem('المدة', _movie!.duration!),
            InfoItem('الجودة', 'HD'),
            InfoItem('الصوت', 'عربي'),
          ]),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(List<InfoItem> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 3,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.label,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCastSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.people, color: Colors.green, size: 24),
              const SizedBox(width: 8),
              const Text(
                'الممثلون والطاقم',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'قريباً - سيتم إضافة معلومات الممثلين والطاقم',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedRatingSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withValues(alpha: 0.1),
            Colors.orange.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 24),
              const SizedBox(width: 8),
              const Text(
                'تقييمك للفيلم',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Obx(() {
            final ratingService = RatingService.instance;
            final userRating = ratingService.getUserRating(_movie!.id);

            return Column(
              children: [
                // Average Rating Display
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'متوسط التقييم',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              _movie!.rating?.toStringAsFixed(1) ?? '0.0',
                              style: const TextStyle(
                                color: Colors.amber,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'من 5',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // User Rating
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'تقييمك الشخصي',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (userRating != null) ...[
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < userRating ? Icons.star : Icons.star_border,
                                color: index < userRating ? Colors.amber : Colors.grey,
                                size: 20,
                              );
                            }),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${userRating.toStringAsFixed(1)}/5',
                            style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ] else ...[
                          const Text(
                            'لم تقم بالتقييم بعد',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Rating Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      RatingService.instance.showRatingDialog(_movie!.id, _movie!.title);
                    },
                    icon: const Icon(Icons.star_rate, size: 18),
                    label: Text(userRating != null ? 'تعديل التقييم' : 'قيم الفيلم الآن'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRelatedMoviesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.movie_filter, color: Colors.purple, size: 24),
              const SizedBox(width: 8),
              const Text(
                'أفلام مشابهة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'قريباً - سيتم إضافة قسم الأفلام المشابهة',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class InfoItem {
  final String label;
  final String value;

  InfoItem(this.label, this.value);
}
