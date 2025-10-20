import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nashmi_tf/features/movie_details/movie_details_screen.dart';
import 'package:nashmi_tf/features/series_details/series_details_screen.dart';
import 'package:nashmi_tf/models/movie_model.dart';
import 'package:nashmi_tf/services/ad_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class MovieListHorizontal extends StatelessWidget {
  final List<Movie> movies;
  final AdService _adService = AdService();

  MovieListHorizontal({super.key, required this.movies});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return _buildMovieItem(context, movie);
        },
      ),
    );
  }

  Widget _buildMovieItem(BuildContext context, Movie movie) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          // Show interstitial ad occasionally when navigating to movie details
          if (_adService.shouldShowInterstitial()) {
            _adService.showInterstitialAd(() {
              if (movie.type == 'series') {
                Get.to(
                  () => SeriesDetailsScreen(seriesId: movie.id),
                  arguments: movie,
                  transition: Transition.fadeIn,
                );
              } else {
                Get.to(
                  () => MovieDetailsScreen(movieId: movie.id),
                  arguments: movie,
                  transition: Transition.fadeIn,
                );
              }
            });
          } else {
            if (movie.type == 'series') {
              Get.to(
                () => SeriesDetailsScreen(seriesId: movie.id),
                arguments: movie,
                transition: Transition.fadeIn,
              );
            } else {
              Get.to(
                () => MovieDetailsScreen(movieId: movie.id),
                arguments: movie,
                transition: Transition.fadeIn,
              );
            }
          }
        },
        child: SizedBox(
          width: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Movie Poster
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 200,
                  width: 140,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: movie.imageURL.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: movie.imageURL,
                          fit: BoxFit.cover,
                          httpHeaders: const {
                            'User-Agent':
                                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                          },
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[800]!,
                            highlightColor: Colors.grey[700]!,
                            child: Container(
                              height: 200,
                              width: 140,
                              color: Colors.grey,
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              _buildPlaceholder(),
                          memCacheWidth:
                              280, // Cache smaller version for performance
                          memCacheHeight: 400,
                        )
                      : _buildPlaceholder(),
                ),
              ),
              const SizedBox(height: 12),
              // Movie Title
              Text(
                movie.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Rating and Year
              Row(
                children: [
                  if (movie.rating != null) ...[
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      movie.rating!.toStringAsFixed(1),
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                  const Spacer(),
                  if (movie.year != null)
                    Text(
                      movie.year!,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
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
            Icon(Icons.movie, color: Colors.white, size: 40),
            SizedBox(height: 8),
            Text(
              'صورة غير متوفرة',
              style: TextStyle(color: Colors.white, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
