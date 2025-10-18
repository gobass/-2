import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class RatingService extends GetxController {
  static RatingService get instance => Get.find();
  
  final RxMap<String, double> _userRatings = <String, double>{}.obs;
  
  Map<String, double> get userRatings => _userRatings;

  @override
  void onInit() {
    super.onInit();
    _loadUserRatings();
  }

  Future<void> _loadUserRatings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ratingsJson = prefs.getString('user_ratings') ?? '{}';
      final ratingsMap = Map<String, dynamic>.from(jsonDecode(ratingsJson));
      
      _userRatings.value = ratingsMap.map(
        (key, value) => MapEntry(key, value.toDouble()),
      );
    } catch (e) {
      print('Error loading user ratings: $e');
    }
  }

  Future<void> _saveUserRatings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ratingsJson = jsonEncode(_userRatings);
      await prefs.setString('user_ratings', ratingsJson);
    } catch (e) {
      print('Error saving user ratings: $e');
    }
  }

  double? getUserRating(String movieId) {
    return _userRatings[movieId];
  }

  bool hasUserRated(String movieId) {
    return _userRatings.containsKey(movieId);
  }

  Future<void> rateMovie(String movieId, String movieTitle, double rating) async {
    try {
      _userRatings[movieId] = rating;
      await _saveUserRatings();
      
      Get.snackbar(
        'تم التقييم',
        'تم تقييم "$movieTitle" بـ ${rating.toStringAsFixed(1)} نجمة',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.star, color: Colors.white),
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('Error rating movie: $e');
      Get.snackbar(
        'خطأ',
        'فشل في حفظ التقييم',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void showRatingDialog(String movieId, String movieTitle) {
    double currentRating = getUserRating(movieId) ?? 0.0;
    double tempRating = currentRating > 0 ? currentRating : 3.0;

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.amber, Colors.orange],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.star,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'تقييم الفيلم',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  movieTitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),
                
                // نجوم التقييم
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          tempRating = index + 1.0;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          index < tempRating ? Icons.star : Icons.star_border,
                          color: index < tempRating ? Colors.amber : Colors.grey,
                          size: 36,
                        ),
                      ),
                    );
                  }),
                ),
                
                const SizedBox(height: 12),
                
                // عرض التقييم الرقمي
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${tempRating.toStringAsFixed(1)} / 5.0',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                if (currentRating > 0) ...[
                  const SizedBox(height: 12),
                  Text(
                    'تقييمك السابق: ${currentRating.toStringAsFixed(1)} نجمة',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'إلغاء',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              rateMovie(movieId, movieTitle, tempRating);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'تقييم',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  List<String> getTopRatedMovies() {
    // ترتيب الأفلام حسب التقييم (تنازلي)
    final sortedRatings = _userRatings.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedRatings.take(10).map((e) => e.key).toList();
  }

  double getAverageUserRating() {
    if (_userRatings.isEmpty) return 0.0;
    
    double total = _userRatings.values.fold(0.0, (sum, rating) => sum + rating);
    return total / _userRatings.length;
  }

  int getTotalRatingsCount() {
    return _userRatings.length;
  }
}
