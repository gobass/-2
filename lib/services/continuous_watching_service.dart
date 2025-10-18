import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ContinuousWatchingService extends GetxService {
  static ContinuousWatchingService get instance => Get.find<ContinuousWatchingService>();

  late SharedPreferences _prefs;
  static const String _watchingHistoryKey = 'continuous_watching_history';
  static const String _continueWatchingKey = 'continue_watching_list';

  @override
  void onInit() {
    super.onInit();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Save watching progress
  Future<void> saveWatchingProgress(String movieId, Duration position, Duration duration) async {
    try {
      await _initPrefs();
      final history = getWatchingHistory();
      final progress = (position.inSeconds / duration.inSeconds) * 100;

      // Only save if progress is between 5% and 95% (avoid saving very beginning or end)
      if (progress > 5 && progress < 95) {
        history[movieId] = {
          'position': position.inSeconds,
          'duration': duration.inSeconds,
          'lastWatched': DateTime.now().toIso8601String(),
          'progress': progress,
        };

        await _prefs.setString(_watchingHistoryKey, jsonEncode(history));
        await _updateContinueWatchingList(movieId, progress);
      }
    } catch (e) {
      print('Error saving watching progress: $e');
    }
  }

  // Get watching history
  Map<String, dynamic> getWatchingHistory() {
    try {
      final historyString = _prefs.getString(_watchingHistoryKey);
      if (historyString != null) {
        return jsonDecode(historyString);
      }
      return {};
    } catch (e) {
      print('Error getting watching history: $e');
      return {};
    }
  }

  // Get continue watching list (sorted by last watched)
  List<Map<String, dynamic>> getContinueWatchingList() {
    try {
      final continueListString = _prefs.getString(_continueWatchingKey);
      if (continueListString != null) {
        final continueList = jsonDecode(continueListString);

        // Sort by last watched (most recent first)
        continueList.sort((a, b) {
          final aTime = DateTime.parse(a['lastWatched']);
          final bTime = DateTime.parse(b['lastWatched']);
          return bTime.compareTo(aTime);
        });

        return continueList;
      }
      return [];
    } catch (e) {
      print('Error getting continue watching list: $e');
      return [];
    }
  }

  // Update continue watching list
  Future<void> _updateContinueWatchingList(String movieId, double progress) async {
    try {
      await _initPrefs();
      final continueList = getContinueWatchingList();
      final existingIndex = continueList.indexWhere((item) => item['movieId'] == movieId);

      final item = {
        'movieId': movieId,
        'progress': progress,
        'lastWatched': DateTime.now().toIso8601String(),
      };

      if (existingIndex >= 0) {
        continueList[existingIndex] = item;
      } else {
        continueList.add(item);
      }

      // Keep only last 20 items
      if (continueList.length > 20) {
        continueList.removeRange(20, continueList.length);
      }

      await _prefs.setString(_continueWatchingKey, jsonEncode(continueList));
    } catch (e) {
      print('Error updating continue watching list: $e');
    }
  }

  // Remove from continue watching
  Future<void> removeFromContinueWatching(String movieId) async {
    try {
      await _initPrefs();
      final continueList = getContinueWatchingList();
      continueList.removeWhere((item) => item['movieId'] == movieId);
      await _prefs.setString(_continueWatchingKey, jsonEncode(continueList));

      // Also remove from history
      final history = getWatchingHistory();
      history.remove(movieId);
      await _prefs.setString(_watchingHistoryKey, jsonEncode(history));
    } catch (e) {
      print('Error removing from continue watching: $e');
    }
  }

  // Clear all watching history
  Future<void> clearAllHistory() async {
    try {
      await _initPrefs();
      await _prefs.remove(_watchingHistoryKey);
      await _prefs.remove(_continueWatchingKey);
    } catch (e) {
      print('Error clearing history: $e');
    }
  }

  // Get saved position for a movie
  Duration? getSavedPosition(String movieId, Duration totalDuration) {
    try {
      final history = getWatchingHistory();
      final movieData = history[movieId];

      if (movieData != null && movieData['position'] != null) {
        final positionSeconds = movieData['position'];
        return Duration(seconds: positionSeconds);
      }

      return null;
    } catch (e) {
      print('Error getting saved position: $e');
      return null;
    }
  }

  // Check if movie should be in continue watching
  bool shouldShowInContinueWatching(String movieId) {
    try {
      final continueList = getContinueWatchingList();
      return continueList.any((item) => item['movieId'] == movieId);
    } catch (e) {
      return false;
    }
  }

  // Get progress percentage for a movie
  double getProgressPercentage(String movieId) {
    try {
      final continueList = getContinueWatchingList();
      final item = continueList.firstWhere(
        (item) => item['movieId'] == movieId,
        orElse: () => {'progress': 0.0},
      );
      return (item['progress'] ?? 0.0).toDouble();
    } catch (e) {
      return 0.0;
    }
  }
}
