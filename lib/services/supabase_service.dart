import 'dart:convert';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io' show File;

class SupabaseService extends GetxService {
  SupabaseClient get _supabase => Supabase.instance.client;

  // Supabase configuration
  static const String supabaseUrl = 'https://ohhomkhnzsozopwwnmfw.supabase.co';
  static String get supabaseAnonKey => const String.fromEnvironment('SUPABASE_KEY', defaultValue: '');

  Future<void> initialize() async {
    try {
      String anonKey;

      if (!kIsWeb) {
        // Try to read from assets first (mobile)
        try {
          final configContent = await rootBundle.loadString('assets/supabase_config.json');
          final config = jsonDecode(configContent);
          anonKey = config['supabaseAnonKey'];
          print('🔑 Loaded Supabase key from assets');
        } catch (_) {
          // Fallback to environment variable
          anonKey = supabaseAnonKey;
          print('🔑 Loaded Supabase key from environment variable');
        }
      } else {
        // On web, try to load from assets or environment variable
        try {
          final configContent = await rootBundle.loadString('assets/supabase_config.json');
          final config = jsonDecode(configContent);
          anonKey = config['supabaseAnonKey'];
          print('🔑 Loaded Supabase key from assets');
        } catch (_) {
          anonKey = supabaseAnonKey;
          print('🔑 Loaded Supabase key from environment variable (web fallback)');
        }
      }

      print('🔑 Supabase URL: $supabaseUrl');
      print('🔑 Supabase Key Length: ${anonKey.length}');

      if (anonKey.isEmpty) {
        throw Exception('Supabase key is not configured. Please check supabase_config.json or SUPABASE_KEY environment variable');
      }

      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: anonKey,
      );

      print('✅ Supabase initialized successfully');
    } catch (e) {
      print('❌ Failed to initialize Supabase: $e');
      throw Exception('Failed to initialize Supabase: $e');
    }
  }

  // Movie methods
  Future<void> addMovie(Map<String, dynamic> movieData) async {
    try {
      await _supabase.from('movies').insert(movieData);
    } catch (e) {
      throw Exception('Failed to add movie: $e');
    }
  }

  Future<void> updateMovie(String movieId, Map<String, dynamic> movieData) async {
    try {
      await _supabase.from('movies').update(movieData).eq('id', movieId);
    } catch (e) {
      throw Exception('Failed to update movie: $e');
    }
  }

  Future<void> deleteMovie(String movieId) async {
    try {
      await _supabase.from('movies').delete().eq('id', movieId);
    } catch (e) {
      throw Exception('Failed to delete movie: $e');
    }
  }

  // Enhanced movie methods with URL validation
  Future<List<Map<String, dynamic>>> getMovies({int? limit}) async {
    try {
      var query = _supabase
          .from('movies')
          .select()
          .order('createdat', ascending: false);
      if (limit != null) {
        query = query.limit(limit);
      }
      final response = await query;

      // Check if response is empty or null
      if (response == null || response.isEmpty) {
        print('No movies found in database');
        return [];
      }

      // Validate and sanitize URLs, and map field names from admin panel format
      final sanitizedMovies = response.map((movie) {
        // Ensure movie is not null
        if (movie == null) return null;

        print('Processing movie: ${movie['title'] ?? 'Unknown'}'); // Debug print

        return {
          'id': movie['id'] ?? '',
          'title': movie['title'] ?? 'عنوان غير معروف',
          'description': movie['description'] ?? 'وصف غير متوفر',
          'categories': movie['categories'] ?? [],
          'imageURL': _sanitizeUrl(movie['posterUrl'] ?? movie['imageURL'] ?? ''),
          'videoURL': _sanitizeUrl(movie['videoUrl'] ?? movie['videoURL'] ?? ''),
          'rating': movie['rating'],
          'year': movie['year'],
          'duration': movie['duration'],
          'isTrending': movie['isTrending'] ?? false,
          'isSeries': movie['isSeries'] ?? false,
          'createdAt': movie['createdat'] ?? DateTime.now().toIso8601String(),
        };
      }).whereType<Map<String, dynamic>>().toList(); // Filter out null movies

      return sanitizedMovies;
    } catch (e) {
      print('Error loading movies: $e');
      // Return empty list instead of throwing exception
      return [];
    }
  }

  Future<Map<String, dynamic>?> getMovieById(String movieId) async {
    try {
      final response = await _supabase
          .from('movies')
          .select()
          .eq('id', movieId)
          .single();

      if (response.isEmpty) return null;

      // Validate and sanitize URLs
      return {
        ...response,
        'imageURL': _sanitizeUrl(response['imageURL'] ?? ''),
        'videoURL': _sanitizeUrl(response['videoURL'] ?? ''),
      };
    } catch (e) {
      print('Failed to get movie by ID: $e');
      return null;
    }
  }

  // Series methods
  Future<void> addSeries(Map<String, dynamic> seriesData) async {
    try {
      await _supabase.from('movies').insert(seriesData);
    } catch (e) {
      throw Exception('Failed to add series: $e');
    }
  }

  Future<void> updateSeries(String seriesId, Map<String, dynamic> seriesData) async {
    try {
      await _supabase.from('movies').update(seriesData).eq('id', seriesId);
    } catch (e) {
      throw Exception('Failed to update series: $e');
    }
  }

  Future<void> deleteSeries(String seriesId) async {
    try {
      await _supabase.from('movies').delete().eq('id', seriesId);
    } catch (e) {
      throw Exception('Failed to delete series: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getSeries({int? limit}) async {
    try {
      var query = _supabase
          .from('series')
          .select()
          .order('createdat', ascending: false);
      if (limit != null) {
        query = query.limit(limit);
      }
      final response = await query;

      // Check if response is empty or null
      if (response == null || response.isEmpty) {
        print('No series found in database');
        return [];
      }

      // Sanitize URLs and map admin panel field names to app field names
      final sanitizedSeries = response.map((series) {
        // Ensure series is not null
        if (series == null) return null;

        return {
          'id': series['id'] ?? '',
          'title': series['title'] ?? 'عنوان غير معروف',
          'description': series['description'] ?? 'وصف غير متوفر',
          'categories': series['categories'] ?? [],
          'imageURL': _sanitizeUrl(series['posterUrl'] ?? series['imageURL'] ?? ''),
          'videoURL': _sanitizeUrl(series['videoUrl'] ?? series['videoURL'] ?? ''),
          'rating': series['rating'],
          'year': series['year'],
          'duration': series['duration'],
          'isTrending': series['isTrending'] ?? false,
          'isSeries': series['isSeries'] ?? true,
          'createdAt': series['createdat'] ?? DateTime.now().toIso8601String(),
        };
      }).whereType<Map<String, dynamic>>().toList(); // Filter out null series

      return sanitizedSeries;
    } catch (e) {
      print('Error loading series: $e');
      // Return empty list instead of throwing exception
      return [];
    }
  }

  // Episode methods
  Future<void> addEpisode(Map<String, dynamic> episodeData) async {
    try {
      await _supabase.from('episodes').insert(episodeData);
    } catch (e) {
      throw Exception('Failed to add episode: $e');
    }
  }

  Future<void> deleteEpisode(String episodeId) async {
    try {
      await _supabase.from('episodes').delete().eq('id', episodeId);
    } catch (e) {
      throw Exception('Failed to delete episode: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getEpisodesBySeries(String seriesId) async {
    try {
      final response = await _supabase
          .from('episodes')
          .select()
          .eq('seriesId', seriesId)
          .order('episodeNumber', ascending: true);
      return response ?? [];
    } catch (e) {
      print('Error loading episodes: $e');
      return [];
    }
  }

  // Ads methods
  Future<void> addAd(Map<String, dynamic> adData) async {
    try {
      await _supabase.from('ads').insert(adData);
    } catch (e) {
      throw Exception('Failed to add ad: $e');
    }
  }

  Future<void> updateAd(String adId, Map<String, dynamic> adData) async {
    try {
      await _supabase.from('ads').update(adData).eq('id', adId);
    } catch (e) {
      throw Exception('Failed to update ad: $e');
    }
  }

  Future<void> deleteAd(String adId) async {
    try {
      await _supabase.from('ads').delete().eq('id', adId);
    } catch (e) {
      throw Exception('Failed to delete ad: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getActiveAds() async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await _supabase
          .from('ads')
          .select()
          .eq('is_active', true)
          .lte('start_at', now)
          .gte('end_at', now);
      return response ?? [];
    } catch (e) {
      print('Error loading active ads: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllAds() async {
    try {
      final response = await _supabase
          .from('ads')
          .select()
          .order('createdat', ascending: false);
      return response ?? [];
    } catch (e) {
      print('Error loading ads: $e');
      return [];
    }
  }

  // Statistics methods - simplified approach
  Future<int> getMoviesCount() async {
    try {
      final response = await _supabase
          .from('movies')
          .select();
      return response?.length ?? 0;
    } catch (e) {
      print('Error getting movies count: $e');
      return 0;
    }
  }

  Future<int> getSeriesCount() async {
    try {
      final response = await _supabase
          .from('series')
          .select();
      return response?.length ?? 0;
    } catch (e) {
      print('Error getting series count: $e');
      return 0;
    }
  }

  Future<int> getActiveAdsCount() async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await _supabase
          .from('ads')
          .select()
          .eq('is_active', true)
          .lte('start_at', now)
          .gte('end_at', now);
      return response?.length ?? 0;
    } catch (e) {
      print('Error getting active ads count: $e');
      return 0;
    }
  }

  // File upload methods
  Future<String> uploadImage(String path, List<int> bytes) async {
    try {
      final response = await _supabase.storage.from('images').uploadBinary(path, Uint8List.fromList(bytes));
      final publicUrl = _supabase.storage.from('images').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<String> uploadVideo(String path, List<int> bytes) async {
    try {
      final response = await _supabase.storage.from('videos').uploadBinary(path, Uint8List.fromList(bytes));
      final publicUrl = _supabase.storage.from('videos').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload video: $e');
    }
  }

  // Categories methods
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      // Since categories are stored as arrays in movies table, we'll return static categories
      // In a real app, you might want to extract unique categories from movies
      return [
        {'id': 'action', 'name': 'أكشن', 'description': 'أفلام الإثارة والأكشن'},
        {'id': 'comedy', 'name': 'كوميديا', 'description': 'أفلام مضحكة ومسلية'},
        {'id': 'drama', 'name': 'دراما', 'description': 'أفلام درامية مؤثرة'},
        {'id': 'horror', 'name': 'رعب', 'description': 'أفلام الرعب والتشويق'},
        {'id': 'romance', 'name': 'رومانسية', 'description': 'أفلام رومانسية'},
        {'id': 'scifi', 'name': 'خيال علمي', 'description': 'أفلام الخيال العلمي'},
        {'id': 'thriller', 'name': 'إثارة', 'description': 'أفلام الإثارة والتشويق'},
      ];
    } catch (e) {
      print('Error getting categories: $e');
      return [];
    }
  }

  // Helper methods for URL validation
  bool _isValidUrl(String url) {
    if (url.isEmpty) return false;
    try {
      final uri = Uri.parse(url.trim());
      return uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  String _sanitizeUrl(String url) {
    final trimmedUrl = url.trim();
    if (!_isValidUrl(trimmedUrl)) {
      return url; // Return original URL if invalid to avoid emptying valid but unusual URLs
    }
    return trimmedUrl;
  }

  // Real-time subscriptions
  Stream<List<Map<String, dynamic>>> watchMovies() {
    return _supabase
        .from('movies')
        .stream(primaryKey: ['id'])
        .order('createdat', ascending: false);
  }

  Stream<List<Map<String, dynamic>>> watchAds() {
    return _supabase
        .from('ads')
        .stream(primaryKey: ['id'])
        .order('createdat', ascending: false);
  }

  Stream<List<Map<String, dynamic>>> watchSeries() {
    return _supabase
        .from('series')
        .stream(primaryKey: ['id'])
        .order('createdat', ascending: false);
  }

  // App Config methods
  Future<Map<String, String>> getAppConfig() async {
    try {
      final response = await _supabase
          .from('app_config')
          .select('config_key, config_value');
      return Map.fromEntries(response.map((item) => MapEntry(item['config_key'], item['config_value'])));
    } catch (e) {
      print('Error getting app config: $e');
      return {};
    }
  }

  Future<String?> getConfigValue(String key) async {
    try {
      final response = await _supabase
          .from('app_config')
          .select('config_value')
          .eq('config_key', key)
          .single();
      return response['config_value'];
    } catch (e) {
      print('Failed to get config value for $key: $e');
      return null;
    }
  }

  Future<void> updateConfigValue(String key, String value) async {
    try {
      await _supabase
          .from('app_config')
          .update({'config_value': value, 'updated_at': DateTime.now().toIso8601String()})
          .eq('config_key', key);
    } catch (e) {
      throw Exception('Failed to update config value: $e');
    }
  }
}
