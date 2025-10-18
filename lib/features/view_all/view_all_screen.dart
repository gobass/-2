import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nashmi_tf/models/movie_model.dart';
import 'package:nashmi_tf/services/supabase_service.dart';
import 'package:nashmi_tf/features/movie_details/movie_details_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:nashmi_tf/services/ad_service.dart';

class ViewAllScreen extends StatefulWidget {
  final String title;
  final String category;
  
  const ViewAllScreen({
    super.key,
    this.title = '',
    this.category = '',
  });

  @override
  State<ViewAllScreen> createState() => _ViewAllScreenState();
}

class _ViewAllScreenState extends State<ViewAllScreen> {
  List<Movie> _movies = [];
  bool _isLoading = true;
  final AdService _adService = AdService();

  @override
  void initState() {
    super.initState();
    _loadMovies();
    _adService.initialize();
  }

  Future<void> _loadMovies() async {
    setState(() => _isLoading = true);

    try {
      // Get arguments from navigation
      final args = Get.arguments as Map<String, dynamic>?;
      final category = args?['category'] ?? widget.category;

      final supabaseService = Get.find<SupabaseService>();
      List<Map<String, dynamic>> moviesData;

      switch (category) {
        case 'latest':
          moviesData = await supabaseService.getMovies(limit: 20);
          break;
        case 'most_viewed':
          moviesData = await supabaseService.getMovies(limit: 20);
          // Sort by views in descending order
          moviesData.sort((a, b) => (b['views'] ?? 0).compareTo(a['views'] ?? 0));
          break;
        case 'featured':
          moviesData = await supabaseService.getMovies(limit: 20);
          // Filter by high rating
          moviesData = moviesData.where((movie) => (movie['rating'] ?? 0) >= 4.5).toList();
          break;
        case 'series':
          moviesData = await supabaseService.getSeries(limit: 20);
          break;
        case 'movies':
          moviesData = await supabaseService.getMovies(limit: 20);
          moviesData = moviesData.where((movie) => !(movie['isSeries'] ?? false)).toList();
          break;
        case 'top_rated':
          moviesData = await supabaseService.getMovies(limit: 20);
          moviesData.sort((a, b) => (b['rating'] ?? 0).compareTo(a['rating'] ?? 0));
          break;
        case 'action_movies':
          moviesData = await supabaseService.getMovies(limit: 20);
          moviesData = moviesData.where((movie) =>
            !(movie['isSeries'] ?? false) &&
            (movie['categories'] as List?)?.contains('أكشن') == true
          ).toList();
          break;
        case 'comedy_series':
          moviesData = await supabaseService.getSeries(limit: 20);
          moviesData = moviesData.where((movie) =>
            (movie['categories'] as List?)?.contains('كوميديا') == true
          ).toList();
          break;
        case 'horror_movies':
          moviesData = await supabaseService.getMovies(limit: 20);
          moviesData = moviesData.where((movie) =>
            !(movie['isSeries'] ?? false) &&
            (movie['categories'] as List?)?.contains('رعب') == true
          ).toList();
          break;
        case 'romance_movies':
          moviesData = await supabaseService.getMovies(limit: 20);
          moviesData = moviesData.where((movie) =>
            !(movie['isSeries'] ?? false) &&
            (movie['categories'] as List?)?.contains('رومانسية') == true
          ).toList();
          break;
        case 'scifi_movies':
          moviesData = await supabaseService.getMovies(limit: 20);
          moviesData = moviesData.where((movie) =>
            !(movie['isSeries'] ?? false) &&
            (movie['categories'] as List?)?.contains('خيال علمي') == true
          ).toList();
          break;
        default:
          // Filter by category
          moviesData = await supabaseService.getMovies(limit: 50);
          moviesData = moviesData.where((movie) =>
            (movie['categories'] as List?)?.contains(category) == true
          ).toList();
      }

      final movies = moviesData.map((data) => Movie(
        id: data['id']?.toString() ?? '',
        title: data['title'] ?? '',
        description: data['description'] ?? '',
        imageURL: data['posterUrl'] ?? '',
        videoURL: data['videoUrl'] ?? '',
        category: (data['categories'] as List?)?.first ?? '',
        type: (data['isSeries'] ?? false) ? 'series' : 'movie',
        viewCount: data['views'] ?? 0,
        rating: (data['rating'] ?? 0).toDouble(),
        year: data['year'] ?? '',
        duration: data['duration'] ?? '',
        episodeCount: data['episodeCount'],
        createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
      )).toList();

      setState(() => _movies = movies);
    } catch (e) {
      print('Error loading movies: $e');
      setState(() => _movies = []);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool _isValidImageUrl(String url) {
      final uri = Uri.tryParse(url);
      if (uri == null) return false;
      if (!uri.isAbsolute) return false;
      if (!(uri.scheme == 'http' || uri.scheme == 'https')) return false;
      return true;
    }

    // Get arguments from navigation
    final args = Get.arguments as Map<String, dynamic>?;
    final title = args?['title'] ?? widget.title;
    final category = args?['category'] ?? widget.category;
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
        ? const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            ),
          )
        : _movies.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadMovies,
              color: Colors.red,
              backgroundColor: Colors.black,
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _movies.length,
                itemBuilder: (context, index) {
                  final movie = _movies[index];
                  return _buildMovieCard(movie);
                },
              ),
            ),

      // Banner Ad at bottom
      bottomNavigationBar: _adService.isBannerAdLoaded && _adService.bannerAd != null
          ? Container(
              height: _adService.bannerAd!.size.height.toDouble(),
              width: double.infinity,
              child: AdWidget(ad: _adService.bannerAd!),
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie_filter_outlined,
            color: Colors.grey[600],
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'لا توجد أفلام',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'لم يتم العثور على أفلام في هذا القسم',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieCard(Movie movie) {
    return GestureDetector(
      onTap: () => _onMovieTap(movie),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Movie Poster
            Expanded(
                child: movie.imageURL.isNotEmpty && (() {
                      final uri = Uri.tryParse(movie.imageURL);
                      return uri != null && uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
                    })()
                    ? CachedNetworkImage(
                      imageUrl: movie.imageURL,
                      fit: BoxFit.cover,
                      httpHeaders: const {
                        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                      },
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[800]!,
                        highlightColor: Colors.grey[700]!,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) {
                        // Only log errors in debug mode to avoid console spam
                        if (kDebugMode) {
                          print('Image load error for ${movie.title}: $error');
                        }
                        return _buildImageErrorWidget();
                      },
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.7),
                              ],
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Rating Badge
                              if (movie.rating != null)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.7),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          movie.rating!.toStringAsFixed(1),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              // Play Icon
                              const Center(
                                child: Icon(
                                  Icons.play_circle_outline,
                                  color: Colors.white,
                                  size: 48,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : _buildImageErrorWidget(),
            ),
            // Movie Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (movie.year != null) ...[
                        Text(
                          movie.year!,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                      if (movie.year != null && movie.duration != null)
                        Text(
                          ' • ',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      if (movie.duration != null)
                        Expanded(
                          child: Text(
                            movie.duration!,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onMovieTap(Movie movie) {
    Get.to(() => MovieDetailsScreen(movieId: movie.id), arguments: movie, transition: Transition.fadeIn);
  }

  Widget _buildImageErrorWidget() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        gradient: LinearGradient(
          colors: [Colors.red.withOpacity(0.7), Colors.grey[800]!],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image,
              color: Colors.white,
              size: 32,
            ),
            SizedBox(height: 4),
            Text(
              'صورة غير متوفرة',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
