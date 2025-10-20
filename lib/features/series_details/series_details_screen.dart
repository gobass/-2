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

class SeriesDetailsScreen extends StatefulWidget {
  final String seriesId;

  const SeriesDetailsScreen({super.key, required this.seriesId});

  @override
  State<SeriesDetailsScreen> createState() => _SeriesDetailsScreenState();
}

class _SeriesDetailsScreenState extends State<SeriesDetailsScreen> {
  Movie? _series;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _episodes = [];

  @override
  void initState() {
    super.initState();
    _loadSeriesData();
  }

  Future<void> _loadSeriesData() async {
    try {
      // First try to get series from arguments
      final Movie? seriesFromArgs = Get.arguments as Movie?;
      if (seriesFromArgs != null) {
        setState(() {
          _series = seriesFromArgs;
          _isLoading = false;
        });
        _loadEpisodes();
        print('🎬 Loaded series from arguments: ${_series?.videoURL}');
        return;
      }

      // If no arguments, fetch from Supabase
      final supabaseService = Get.find<SupabaseService>();
      final seriesData = await supabaseService.getMovieById(widget.seriesId);

      if (seriesData != null) {
        setState(() {
          _series = Movie.fromJson(seriesData);
          _isLoading = false;
        });
        _loadEpisodes();
        print('🎬 Loaded series from Supabase: ${seriesData['videoURL']}');
      } else {
        setState(() {
          _error = 'لم يتم العثور على المسلسل';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'حدث خطأ في تحميل بيانات المسلسل';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadEpisodes() async {
    if (_series == null) return;

    try {
      final supabaseService = Get.find<SupabaseService>();
      final episodes = await supabaseService.getEpisodesBySeries(_series!.id);

      if (episodes.isNotEmpty) {
        setState(() {
          _episodes = episodes
              .map(
                (episode) => {
                  'id': episode['id'],
                  'title':
                      episode['title'] ??
                      'الحلقة ${episode['episodeNumber'] ?? 'غير محدد'}',
                  'description': episode['description'] ?? 'وصف الحلقة',
                  'video_url': episode['videoUrl'] ?? episode['videoURL'] ?? '',
                  'episodeNumber': episode['episodeNumber'] ?? 0,
                  'duration': episode['duration'] ?? '',
                },
              )
              .toList();
        });
        print('🎬 Loaded ${episodes.length} episodes from database');
      } else {
        // Fallback to sample episodes if no episodes found in database
        setState(() {
          _episodes = [
            {
              'title': 'الحلقة 1',
              'description': 'البداية...',
              'video_url': _series!.videoURL,
              'episodeNumber': 1,
            },
            {
              'title': 'الحلقة 2',
              'description': 'تطور الأحداث...',
              'video_url': _series!.videoURL,
              'episodeNumber': 2,
            },
            {
              'title': 'الحلقة 3',
              'description': 'الذروة...',
              'video_url': _series!.videoURL,
              'episodeNumber': 3,
            },
          ];
        });
        print('🎬 No episodes found in database, using sample episodes');
      }
    } catch (e) {
      print('Error loading episodes: $e');
      // Fallback to sample episodes on error
      setState(() {
        _episodes = [
          {
            'title': 'الحلقة 1',
            'description': 'البداية...',
            'video_url': _series!.videoURL,
            'episodeNumber': 1,
          },
          {
            'title': 'الحلقة 2',
            'description': 'تطور الأحداث...',
            'video_url': _series!.videoURL,
            'episodeNumber': 2,
          },
          {
            'title': 'الحلقة 3',
            'description': 'الذروة...',
            'video_url': _series!.videoURL,
            'episodeNumber': 3,
          },
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    if (_error != null || _series == null) {
      return _buildNotFoundScreen();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // Enhanced App Bar with Series Poster Background
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Series Poster Background
                  CachedNetworkImage(
                    imageUrl: _series!.imageURL,
                    fit: BoxFit.cover,
                    httpHeaders: const {
                      'User-Agent':
                          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
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
                          const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                            size: 48,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'صورة غير متوفرة',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Enhanced Gradient overlay
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

                  // Series Title Overlay
                  Positioned(
                    top: 120,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'مسلسل',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _series!.title,
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
                            if (_series!.rating != null) ...[
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _series!.rating!.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                            if (_series!.year != null) ...[
                              Text(
                                _series!.year!,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                            Text(
                              '${_episodes.length} حلقة',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Action Buttons
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
                          final isFavorite = favoritesService.isFavorite(
                            _series!.id,
                          );

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
                              onPressed: () =>
                                  favoritesService.toggleFavorite(_series!),
                              backgroundColor: isFavorite
                                  ? Colors.red
                                  : Colors.grey[800]!,
                              foregroundColor: Colors.white,
                              child: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 24,
                              ),
                            ),
                          );
                        }),

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
                            onPressed: () => _shareSeries(_series!),
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

          // Series Details Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Series Description
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
                            const Icon(
                              Icons.description,
                              color: Colors.red,
                              size: 24,
                            ),
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
                          _series!.description,
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

                  // Episodes Section
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
                            const Icon(
                              Icons.playlist_play,
                              color: Colors.blue,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'الحلقات',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_episodes.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_episodes.isEmpty)
                          const Center(
                            child: Text(
                              'لا توجد حلقات متاحة حالياً',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _episodes.length,
                            itemBuilder: (context, index) {
                              final episode = _episodes[index];
                              return _buildEpisodeItem(episode, index + 1);
                            },
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Series Info
                  _buildEnhancedInfoSection(),

                  const SizedBox(height: 24),

                  // User Rating Section
                  _buildEnhancedRatingSection(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEpisodeItem(Map<String, dynamic> episode, int episodeNumber) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '$episodeNumber',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        title: Text(
          episode['title'] ?? 'الحلقة $episodeNumber',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          episode['description'] ?? 'وصف الحلقة',
          style: TextStyle(color: Colors.grey[400]),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.play_arrow, color: Colors.red),
          onPressed: () => _playEpisode(episode),
        ),
        onTap: () => _playEpisode(episode),
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
              'جاري تحميل بيانات المسلسل...',
              style: TextStyle(color: Colors.white, fontSize: 16),
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
        title: const Text('خطأ', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              _error ?? 'لم يتم العثور على المسلسل',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'يرجى المحاولة مرة أخرى',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      ),
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
                'معلومات المسلسل',
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
            InfoItem('التصنيف', _getCategoryName(_series!.category)),
            if (_series!.viewCount != null)
              InfoItem('المشاهدات', '${_series!.viewCount} مشاهدة'),
            if (_series!.year != null) InfoItem('سنة الإصدار', _series!.year!),
            InfoItem('عدد الحلقات', '${_episodes.length}'),
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
                'تقييمك للمسلسل',
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
            final userRating = ratingService.getUserRating(_series!.id);

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
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _series!.rating?.toStringAsFixed(1) ?? '0.0',
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
                                index < userRating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: index < userRating
                                    ? Colors.amber
                                    : Colors.grey,
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
                            style: TextStyle(color: Colors.grey, fontSize: 14),
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
                      RatingService.instance.showRatingDialog(
                        _series!.id,
                        _series!.title,
                      );
                    },
                    icon: const Icon(Icons.star_rate, size: 18),
                    label: Text(
                      userRating != null ? 'تعديل التقييم' : 'قيم المسلسل الآن',
                    ),
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

  void _playEpisode(Map<String, dynamic> episode) {
    final videoUrl = episode['video_url'] ?? '';
    if (videoUrl.isEmpty) {
      Get.snackbar('خطأ', 'رابط الفيديو غير متوفر');
      return;
    }

    final adService = AdService();

    bool isDailymotion = false;
    try {
      final uri = Uri.parse(videoUrl);
      if (uri.host.contains('dailymotion.com') || uri.host.contains('dai.ly')) {
        isDailymotion = true;
      }
    } catch (_) {}

    if (adService.shouldShowInterstitial()) {
      adService.showInterstitialAd(() {
        if (isDailymotion) {
          Get.to(
            () => DailymotionPlayer(
              videoUrl: videoUrl,
              movieTitle: episode['title'] ?? 'الحلقة',
            ),
          );
        } else {
          Get.to(
            () => VideoPlayerScreen(
              videoUrl: videoUrl,
              movieTitle: episode['title'] ?? 'الحلقة',
            ),
          );
        }
      });
    } else {
      if (isDailymotion) {
        Get.to(
          () => DailymotionPlayer(
            videoUrl: videoUrl,
            movieTitle: episode['title'] ?? 'الحلقة',
          ),
        );
      } else {
        Get.to(
          () => VideoPlayerScreen(
            videoUrl: videoUrl,
            movieTitle: episode['title'] ?? 'الحلقة',
          ),
        );
      }
    }
  }

  void _shareSeries(Movie series) {
    Get.snackbar(
      'مشاركة',
      'جاري مشاركة "${series.title}"...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      icon: const Icon(Icons.share, color: Colors.white),
    );
  }
}

class InfoItem {
  final String label;
  final String value;

  InfoItem(this.label, this.value);
}
