import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/continuous_watching_service.dart';
import '../../models/movie_model.dart';
import '../movie_details/movie_details_screen.dart';

class ContinueWatchingSection extends StatelessWidget {
  const ContinueWatchingSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final continuousWatchingService = ContinuousWatchingService.instance;

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
              const Icon(Icons.play_circle_filled, color: Colors.blue, size: 24),
              const SizedBox(width: 8),
              const Text(
                'متابعة المشاهدة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          FutureBuilder<List<Map<String, dynamic>>>(
            future: _getContinueWatchingMovies(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                );
              }

              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return Column(
                  children: [
                    Icon(
                      Icons.movie_filter,
                      color: Colors.grey[600],
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'لا توجد أفلام للمتابعة',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ابدأ بمشاهدة فيلم ليظهر هنا',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              }

              final movies = snapshot.data!;

              return SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    return _buildContinueWatchingItem(movie, context);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getContinueWatchingMovies() async {
    try {
      final continuousWatchingService = ContinuousWatchingService.instance;
      final continueList = continuousWatchingService.getContinueWatchingList();

      // Here you would typically fetch the actual movie data from your service
      // For now, we'll return the continue list items
      return continueList;
    } catch (e) {
      print('Error getting continue watching movies: $e');
      return [];
    }
  }

  Widget _buildContinueWatchingItem(Map<String, dynamic> movieData, BuildContext context) {
    final progress = (movieData['progress'] ?? 0.0).toDouble();

    return Container(
      width: 140,
      margin: const EdgeInsets.only(left: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Movie Thumbnail with Progress Indicator
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[800],
                image: const DecorationImage(
                  image: AssetImage('assets/images/movie_placeholder.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  // Progress Bar
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        gradient: const LinearGradient(
                          colors: [Colors.blue, Colors.lightBlue],
                        ),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress / 100,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Play Button Overlay
                  Center(
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),

                  // Progress Text
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${progress.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Movie Title
          Text(
            movieData['movieId'] ?? 'فيلم غير معروف',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 4),

          // Progress Text
          Text(
            'تم المشاهدة ${progress.toStringAsFixed(0)}%',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
