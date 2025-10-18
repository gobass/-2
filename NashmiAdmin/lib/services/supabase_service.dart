import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io' show File;

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nashmi_admin_v2/models/category_model.dart';

class SupabaseService extends GetxService {
  SupabaseClient get _supabase => Supabase.instance.client;

  // Check if user is authenticated before making requests
  bool get _isAuthenticated {
    final session = _supabase.auth.currentSession;
    return session != null;
  }

  // Ensure user is authenticated
  void _ensureAuthenticated() {
    if (!_isAuthenticated) {
      throw Exception('User must be authenticated to perform this operation');
    }
  }

  // Supabase configuration - unified with main app
  static const String supabaseUrl = 'https://ohhomkhnzsozopwwnmfw.supabase.co';
  static String get supabaseAnonKey => const String.fromEnvironment('SUPABASE_KEY', defaultValue: '');

  Future<void> initialize() async {
    try {
      String anonKey;

      // Try to load from assets first (works for both web and mobile)
      try {
        final configContent = await rootBundle.loadString('assets/supabase_config.json');
        final config = jsonDecode(configContent);
        anonKey = config['supabaseAnonKey'];
        print('🔑 Loaded Supabase key from assets/supabase_config.json');
      } catch (e) {
        print('⚠️ Warning loading supabase_config.json: $e');
        // Fallback to environment variable
        anonKey = supabaseAnonKey;
        print('🔑 Loaded Supabase key from environment variable SUPABASE_KEY');
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
    } catch (e, stackTrace) {
      print('❌ Failed to initialize Supabase: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to initialize Supabase: $e');
    }
  }

  // Movie methods - unified with main app
  Future<void> addMovie(Map<String, dynamic> movieData) async {
    try {
      _ensureAuthenticated();

      // Remove isActive field if present to avoid schema cache error
      final data = Map<String, dynamic>.from(movieData);
      data.remove('isActive');

      await _supabase.from('movies').insert(data);
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

  Future<List<Map<String, dynamic>>> getMovies({int limit = 50}) async {
    try {
      final response = await _supabase
          .from('movies')
          .select()
          .order('createdat', ascending: false)
          .limit(limit);
      return response;
    } catch (e) {
      throw Exception('Failed to get movies: $e');
    }
  }

  // Series methods - unified with main app
  Future<void> addSeries(Map<String, dynamic> seriesData) async {
    try {
      _ensureAuthenticated();

      final data = Map<String, dynamic>.from(seriesData);
      data.remove('isActive');
      // Ensure slug exists before sending to DB
      if (!data.containsKey('slug')) {
        data['slug'] = '';
      }
      // Fix posterUrl key to posterUrl (camelCase) to match DB schema
      if (data.containsKey('poster_url')) {
        data['posterUrl'] = data['poster_url'];
        data.remove('poster_url');
      }
      if (data.containsKey('posterUrl')) {
        // Keep as is if already camelCase
      }
      await _supabase.from('series').insert(data);
    } catch (e) {
      throw Exception('Failed to add series: $e');
    }
  }

  Future<void> updateSeries(String seriesId, Map<String, dynamic> seriesData) async {
    try {
      final data = Map<String, dynamic>.from(seriesData);
      data.remove('isActive');
      // Ensure slug exists before sending to DB
      if (!data.containsKey('slug')) {
        data['slug'] = '';
      }
      // Fix posterUrl key to posterUrl (camelCase) to match DB schema
      if (data.containsKey('poster_url')) {
        data['posterUrl'] = data['poster_url'];
        data.remove('poster_url');
      }
      if (data.containsKey('posterUrl')) {
        // Keep as is if already camelCase
      }
      await _supabase.from('series').update(data).eq('id', seriesId);
    } catch (e) {
      throw Exception('Failed to update series: $e');
    }
  }

  Future<void> deleteSeries(String seriesId) async {
    try {
      await _supabase.from('series').delete().eq('id', seriesId);
    } catch (e) {
      throw Exception('Failed to delete series: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getSeries({int limit = 50}) async {
    try {
      final response = await _supabase
          .from('series')
          .select()
          .order('createdat', ascending: false)
          .limit(limit);
      return response;
    } catch (e) {
      throw Exception('Failed to get series: $e');
    }
  }

  // Ads methods - unified with main app (using app_config table)
  Future<void> addAd(Map<String, dynamic> adData) async {
    try {
      _ensureAuthenticated();

      // Convert ad data to app_config format
      final configEntries = _convertAdDataToConfig(adData);
      for (final entry in configEntries) {
        await _supabase.from('app_config').insert(entry);
      }
    } catch (e) {
      throw Exception('Failed to add ad: $e');
    }
  }

  Future<void> updateAd(String adId, Map<String, dynamic> adData) async {
    try {
      // First delete existing config entries for this ad
      await _supabase.from('app_config').delete().like('config_key', 'ad_$adId%');
      
      // Then add updated config entries
      final configEntries = _convertAdDataToConfig(adData, adId);
      for (final entry in configEntries) {
        await _supabase.from('app_config').insert(entry);
      }
    } catch (e) {
      throw Exception('Failed to update ad: $e');
    }
  }

  Future<void> deleteAd(String adId) async {
    try {
      await _supabase.from('app_config').delete().like('config_key', 'ad_$adId%');
    } catch (e) {
      throw Exception('Failed to delete ad: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getActiveAds() async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await _supabase
          .from('app_config')
          .select()
          .like('config_key', 'ad_%')
          .like('config_key', '%_active')
          .eq('config_value', 'true');
      return _convertConfigToAdData(response);
    } catch (e) {
      throw Exception('Failed to get active ads: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllAds() async {
    try {
      final response = await _supabase
          .from('app_config')
          .select()
          .like('config_key', 'ad_%')
          .order('config_key', ascending: false);
      return _convertConfigToAdData(response);
    } catch (e) {
      throw Exception('Failed to get ads: $e');
    }
  }

  // Helper methods to convert between ad data and app_config format
  List<Map<String, dynamic>> _convertAdDataToConfig(Map<String, dynamic> adData, [String? adId]) {
    final timestamp = DateTime.now().toIso8601String();
    final id = adId ?? DateTime.now().millisecondsSinceEpoch.toString();
    
    return [
      {
        'config_key': 'ad_${id}_title',
        'config_value': adData['title'] ?? '',
        'description': 'Ad title'
      },
      {
        'config_key': 'ad_${id}_provider',
        'config_value': adData['provider'] ?? 'admob',
        'description': 'Ad provider (admob or custom)'
      },
      {
        'config_key': 'ad_${id}_app_id',
        'config_value': adData['appId'] ?? '',
        'description': 'AdMob App ID'
      },
      {
        'config_key': 'ad_${id}_ad_unit_id',
        'config_value': adData['adUnitId'] ?? '',
        'description': 'AdMob Ad Unit ID'
      },
      {
        'config_key': 'ad_${id}_type',
        'config_value': adData['adType'] ?? 'banner',
        'description': 'Ad type (banner, interstitial, rewarded, native)'
      },
      {
        'config_key': 'ad_${id}_position',
        'config_value': adData['position'] ?? 'home_top',
        'description': 'Ad position'
      },
      {
        'config_key': 'ad_${id}_media_url',
        'config_value': adData['mediaUrl'] ?? '',
        'description': 'Media URL for custom ads'
      },
      {
        'config_key': 'ad_${id}_link',
        'config_value': adData['link'] ?? '',
        'description': 'Ad link'
      },
      {
        'config_key': 'ad_${id}_frequency',
        'config_value': (adData['frequency'] ?? 0).toString(),
        'description': 'Ad frequency'
      },
      {
        'config_key': 'ad_${id}_start_at',
        'config_value': adData['startAt'] ?? timestamp,
        'description': 'Ad start date'
      },
      {
        'config_key': 'ad_${id}_end_at',
        'config_value': adData['endAt'] ?? timestamp,
        'description': 'Ad end date'
      },
      {
        'config_key': 'ad_${id}_active',
        'config_value': (adData['isActive'] ?? true).toString(),
        'description': 'Ad active status'
      },
      {
        'config_key': 'ad_${id}_created_at',
        'config_value': adData['createdAt'] ?? timestamp,
        'description': 'Ad creation timestamp'
      },
    ];
  }

  List<Map<String, dynamic>> _convertConfigToAdData(List<Map<String, dynamic>> configData) {
    final adsMap = <String, Map<String, dynamic>>{};
    
    for (final config in configData) {
      final key = config['config_key'];
      final adId = key.split('_')[1]; // Extract ad ID from key like 'ad_123_title'
      
      if (!adsMap.containsKey(adId)) {
        adsMap[adId] = {'id': adId};
      }
      
      final value = config['config_value'];
      final keySuffix = key.split('_').last;
      
      switch (keySuffix) {
        case 'title':
          adsMap[adId]!['title'] = value;
          break;
        case 'provider':
          adsMap[adId]!['provider'] = value;
          break;
        case 'id':
          adsMap[adId]!['appId'] = value;
          break;
        case 'unit':
          adsMap[adId]!['adUnitId'] = value;
          break;
        case 'type':
          adsMap[adId]!['adType'] = value;
          break;
        case 'position':
          adsMap[adId]!['position'] = value;
          break;
        case 'url':
          if (key.contains('media')) {
            adsMap[adId]!['mediaUrl'] = value;
          } else {
            adsMap[adId]!['link'] = value;
          }
          break;
        case 'frequency':
          adsMap[adId]!['frequency'] = int.tryParse(value) ?? 0;
          break;
        case 'at':
          if (key.contains('start')) {
            adsMap[adId]!['startAt'] = value;
          } else if (key.contains('end')) {
            adsMap[adId]!['endAt'] = value;
          } else if (key.contains('created')) {
            adsMap[adId]!['createdAt'] = value;
          }
          break;
        case 'active':
          adsMap[adId]!['isActive'] = value == 'true';
          break;
      }
    }
    
    return adsMap.values.toList();
  }

  // Statistics methods - unified with main app
  Future<int> getMoviesCount() async {
    try {
      final response = await _supabase
          .from('movies')
          .select();
      return response.length;
    } catch (e) {
      throw Exception('Failed to get movies count: $e');
    }
  }

  Future<int> getSeriesCount() async {
    try {
      final response = await _supabase
          .from('series')
          .select();
      return response.length;
    } catch (e) {
      throw Exception('Failed to get series count: $e');
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
      return response.length;
    } catch (e) {
      throw Exception('Failed to get active ads count: $e');
    }
  }

  Future<int> getUsersCount() async {
    try {
      final response = await _supabase
          .from('users')
          .select();
      return response.length;
    } catch (e) {
      throw Exception('Failed to get users count: $e');
    }
  }

  Future<int> getTotalContentCount() async {
    try {
      final moviesCount = await getMoviesCount();
      final seriesCount = await getSeriesCount();
      return moviesCount + seriesCount;
    } catch (e) {
      throw Exception('Failed to get total content count: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getRecentActivities() async {
    try {
      final movies = await getMovies(limit: 3);
      final series = await getSeries(limit: 3);
      final ads = await getAllAds().then((ads) => ads.take(3).toList());

      final all = [
        ...movies.map((m) => {...m, 'type': 'movie'}),
        ...series.map((s) => {...s, 'type': 'series'}),
        ...ads.map((a) => {...a, 'type': 'ad'}),
      ];

      all.sort((a, b) => DateTime.parse(b['createdat']).compareTo(DateTime.parse(a['createdat'])));
      return all.take(5).toList();
    } catch (e) {
      throw Exception('Failed to get recent activities: $e');
    }
  }

  // Real-time subscriptions - unified with main app
  Stream<List<Map<String, dynamic>>> watchMovies() {
    return _supabase
        .from('movies')
        .stream(primaryKey: ['id'])
        .order('createdat', ascending: false);
  }

  Stream<List<Map<String, dynamic>>> watchAds() {
    return _supabase
        .from('app_config')
        .stream(primaryKey: ['config_key'])
        .order('config_key', ascending: false);
  }

  Stream<List<Map<String, dynamic>>> watchSeries() {
    return _supabase
        .from('series')
        .stream(primaryKey: ['id'])
        .order('createdat', ascending: false);
  }

  // Storage methods - unified with main app
  Future<String> uploadFile(String bucket, String path, Uint8List bytes) async {
    try {
      await _supabase.storage.from(bucket).uploadBinary(path, bytes);
      final downloadUrl = _supabase.storage.from(bucket).getPublicUrl(path);
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  // Episodes methods - unified with main app
  Future<void> addEpisode(Map<String, dynamic> episodeData) async {
    try {
      await _supabase.from('episodes').insert(episodeData);
    } catch (e) {
      throw Exception('Failed to add episode: $e');
    }
  }

  Future<void> updateEpisode(String episodeId, Map<String, dynamic> episodeData) async {
    try {
      await _supabase.from('episodes').update(episodeData).eq('id', episodeId);
    } catch (e) {
      throw Exception('Failed to update episode: $e');
    }
  }

  Future<void> deleteEpisode(String episodeId) async {
    try {
      await _supabase.from('episodes').delete().eq('id', episodeId);
    } catch (e) {
      throw Exception('Failed to delete episode: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getEpisodes(String seriesId) async {
    try {
      final response = await _supabase
          .from('episodes')
          .select()
          .eq('series_id', seriesId)
          .order('episode_number', ascending: true);
      return response;
    } catch (e) {
      throw Exception('Failed to get episodes: $e');
    }
  }

  // User methods - to replace FirebaseService methods
  Future<void> addUser(Map<String, dynamic> userData) async {
    try {
      _ensureAuthenticated();

      await _supabase.from('users').insert(userData);
    } catch (e) {
      throw Exception('Failed to add user: $e');
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> userData) async {
    try {
      await _supabase.from('users').update(userData).eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _supabase.from('users').delete().eq('id', userId);
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _supabase
        .from('users')
        .stream(primaryKey: ['id'])
        .order('createdat', ascending: false);
  }

  // Enhanced Categories methods with support for different types
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _supabase
          .from('categories')
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true)
          .order('created_at', ascending: false);

      return response.map<CategoryModel>((item) => CategoryModel.fromJson(item)).toList();
    } catch (e) {
      print('Warning: Could not load categories from database: $e');
      // Return default categories if table doesn't exist
      return _getDefaultCategories();
    }
  }

  Future<List<String>> getCategoryNames() async {
    try {
      final categories = await getCategories();
      return categories.map((c) => c.displayName).toList();
    } catch (e) {
      return _getDefaultCategoryNames();
    }
  }

  Future<void> addCategory(String categoryName, {CategoryType type = CategoryType.regular, String? year, String? season}) async {
    try {
      _ensureAuthenticated();

      final categoryData = {
        'name': categoryName,
        'type': type.toStringValue(),
        'year': year,
        'season': season,
        'created_at': DateTime.now().toIso8601String(),
        'is_active': true,
        'sort_order': await _getNextSortOrder(),
      };

      await _supabase.from('categories').insert(categoryData);
    } catch (e) {
      throw Exception('Failed to add category: $e');
    }
  }

  Future<void> addYearCategory(int year) async {
    try {
      _ensureAuthenticated();

      final categoryData = {
        'name': year.toString(),
        'type': CategoryType.year.toStringValue(),
        'year': year.toString(),
        'created_at': DateTime.now().toIso8601String(),
        'is_active': true,
        'sort_order': await _getNextSortOrder(),
      };

      await _supabase.from('categories').insert(categoryData);
    } catch (e) {
      throw Exception('Failed to add year category: $e');
    }
  }

  Future<void> addSeasonalCategory(String seasonName, int year) async {
    try {
      _ensureAuthenticated();

      final categoryData = {
        'name': seasonName,
        'type': CategoryType.seasonal.toStringValue(),
        'year': year.toString(),
        'season': seasonName.toLowerCase().replaceAll(' ', '_'),
        'created_at': DateTime.now().toIso8601String(),
        'is_active': true,
        'sort_order': await _getNextSortOrder(),
      };

      await _supabase.from('categories').insert(categoryData);
    } catch (e) {
      throw Exception('Failed to add seasonal category: $e');
    }
  }

  Future<void> addRamadanSeriesCategory(int year) async {
    await addSeasonalCategory('مسلسلات رمضان', year);
  }

  Future<void> updateCategory(String categoryId, Map<String, dynamic> updates) async {
    try {
      _ensureAuthenticated();

      updates['updated_at'] = DateTime.now().toIso8601String();

      await _supabase
          .from('categories')
          .update(updates)
          .eq('id', categoryId);
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      _ensureAuthenticated();

      await _supabase
          .from('categories')
          .update({'is_active': false})
          .eq('id', categoryId);
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  Future<void> generateYearCategories(int startYear, int endYear) async {
    try {
      _ensureAuthenticated();

      final existingYears = await getCategories();
      final existingYearValues = existingYears
          .where((c) => c.type == CategoryType.year)
          .map((c) => c.year)
          .toSet();

      final categoriesToAdd = <Map<String, dynamic>>[];

      for (int year = startYear; year <= endYear; year++) {
        if (!existingYearValues.contains(year.toString())) {
          categoriesToAdd.add({
            'name': year.toString(),
            'type': CategoryType.year.toStringValue(),
            'year': year.toString(),
            'created_at': DateTime.now().toIso8601String(),
            'is_active': true,
            'sort_order': await _getNextSortOrder(),
          });
        }
      }

      if (categoriesToAdd.isNotEmpty) {
        await _supabase.from('categories').insert(categoriesToAdd);
      }
    } catch (e) {
      throw Exception('Failed to generate year categories: $e');
    }
  }

  Future<void> generateRamadanSeriesCategories(int startYear, int endYear) async {
    try {
      _ensureAuthenticated();

      final existingCategories = await getCategories();
      final existingRamadanYears = existingCategories
          .where((c) => c.type == CategoryType.seasonal && c.season == 'مسلسلات_رمضان')
          .map((c) => c.year)
          .toSet();

      final categoriesToAdd = <Map<String, dynamic>>[];

      for (int year = startYear; year <= endYear; year++) {
        if (!existingRamadanYears.contains(year.toString())) {
          categoriesToAdd.add({
            'name': 'مسلسلات رمضان',
            'type': CategoryType.seasonal.toStringValue(),
            'year': year.toString(),
            'season': 'مسلسلات_رمضان',
            'created_at': DateTime.now().toIso8601String(),
            'is_active': true,
            'sort_order': await _getNextSortOrder(),
          });
        }
      }

      if (categoriesToAdd.isNotEmpty) {
        await _supabase.from('categories').insert(categoriesToAdd);
      }
    } catch (e) {
      throw Exception('Failed to generate Ramadan series categories: $e');
    }
  }

  Future<List<CategoryModel>> getCategoriesByType(CategoryType type) async {
    try {
      final response = await _supabase
          .from('categories')
          .select()
          .eq('type', type.toStringValue())
          .eq('is_active', true)
          .order('sort_order', ascending: true)
          .order('created_at', ascending: false);

      return response.map<CategoryModel>((item) => CategoryModel.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<CategoryStats> getCategoryStats(String categoryId) async {
    try {
      // Get category details
      final categoryResponse = await _supabase
          .from('categories')
          .select()
          .eq('id', categoryId)
          .single();

      final category = CategoryModel.fromJson(categoryResponse);

      // Get content count for this category
      int contentCount = 0;
      double totalRating = 0.0;
      int ratedContentCount = 0;

      // Count movies in this category
      final moviesResponse = await _supabase
          .from('movies')
          .select('rating')
          .contains('categories', [category.displayName]);

      contentCount += moviesResponse.length;
      for (final movie in moviesResponse) {
        if (movie['rating'] != null) {
          totalRating += movie['rating'];
          ratedContentCount++;
        }
      }

      // Count series in this category
      final seriesResponse = await _supabase
          .from('series')
          .select('rating')
          .contains('categories', [category.displayName]);

      contentCount += seriesResponse.length;
      for (final series in seriesResponse) {
        if (series['rating'] != null) {
          totalRating += series['rating'];
          ratedContentCount++;
        }
      }

      final averageRating = ratedContentCount > 0 ? totalRating / ratedContentCount : 0.0;

      return CategoryStats(
        category: category,
        contentCount: contentCount,
        viewsCount: 0, // TODO: Implement views tracking
        averageRating: averageRating,
      );
    } catch (e) {
      throw Exception('Failed to get category stats: $e');
    }
  }

  Future<int> _getNextSortOrder() async {
    try {
      final response = await _supabase
          .from('categories')
          .select('sort_order')
          .order('sort_order', ascending: false)
          .limit(1);

      if (response.isEmpty) {
        return 1;
      }

      return (response.first['sort_order'] as int? ?? 0) + 1;
    } catch (e) {
      return 1;
    }
  }

  List<CategoryModel> _getDefaultCategories() {
    return [
      CategoryModel(
        id: 'default_action',
        name: 'أكشن',
        type: CategoryType.regular,
        createdAt: DateTime.now(),
        isActive: true,
      ),
      CategoryModel(
        id: 'default_comedy',
        name: 'كوميديا',
        type: CategoryType.regular,
        createdAt: DateTime.now(),
        isActive: true,
      ),
      CategoryModel(
        id: 'default_drama',
        name: 'دراما',
        type: CategoryType.regular,
        createdAt: DateTime.now(),
        isActive: true,
      ),
      CategoryModel(
        id: 'default_horror',
        name: 'رعب',
        type: CategoryType.regular,
        createdAt: DateTime.now(),
        isActive: true,
      ),
      CategoryModel(
        id: 'default_romance',
        name: 'رومانس',
        type: CategoryType.regular,
        createdAt: DateTime.now(),
        isActive: true,
      ),
    ];
  }

  List<String> _getDefaultCategoryNames() {
    return ['أكشن', 'كوميديا', 'دراما', 'رعب', 'رومانس'];
  }

  // Advanced Statistics methods for reports
  Future<List<Map<String, dynamic>>> getMoviesViewsOverTime(String period) async {
    try {
      final now = DateTime.now();
      DateTime startDate;

      switch (period) {
        case 'daily':
          startDate = now.subtract(const Duration(days: 30));
          break;
        case 'weekly':
          startDate = now.subtract(const Duration(days: 90));
          break;
        case 'monthly':
          startDate = now.subtract(const Duration(days: 365));
          break;
        default:
          startDate = now.subtract(const Duration(days: 30));
      }

      final response = await _supabase
          .from('movies')
          .select('createdat, views')
          .gte('createdat', startDate.toIso8601String())
          .order('createdat', ascending: true);

      return response;
    } catch (e) {
      throw Exception('Failed to get movies views over time: $e');
    }
  }

  Future<Map<String, int>> getCategoryDistribution() async {
    try {
      final movies = await getMovies(limit: 1000);
      final series = await getSeries(limit: 1000);

      final categoryCount = <String, int>{};

      for (final movie in movies) {
        final categories = movie['categories'] as List<dynamic>? ?? [];
        for (final category in categories) {
          categoryCount[category] = (categoryCount[category] ?? 0) + 1;
        }
      }

      for (final serie in series) {
        final categories = serie['categories'] as List<dynamic>? ?? [];
        for (final category in categories) {
          categoryCount[category] = (categoryCount[category] ?? 0) + 1;
        }
      }

      return categoryCount;
    } catch (e) {
      throw Exception('Failed to get category distribution: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAdPerformance() async {
    try {
      final response = await _supabase
          .from('ads')
          .select('title, frequency, weight, is_active, start_at, end_at')
          .order('createdat', ascending: false)
          .limit(20);

      return response;
    } catch (e) {
      throw Exception('Failed to get ad performance: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUsersStatsOverTime(String period) async {
    try {
      final now = DateTime.now();
      DateTime startDate;

      switch (period) {
        case 'daily':
          startDate = now.subtract(const Duration(days: 30));
          break;
        case 'weekly':
          startDate = now.subtract(const Duration(days: 90));
          break;
        case 'monthly':
          startDate = now.subtract(const Duration(days: 365));
          break;
        default:
          startDate = now.subtract(const Duration(days: 30));
      }

      final response = await _supabase
          .from('users')
          .select('createdat')
          .gte('createdat', startDate.toIso8601String())
          .order('createdat', ascending: true);

      return response;
    } catch (e) {
      throw Exception('Failed to get users stats over time: $e');
    }
  }

  Future<Map<String, dynamic>> getContentGrowthStats() async {
    try {
      final now = DateTime.now();
      final lastMonth = now.subtract(const Duration(days: 30));
      final lastWeek = now.subtract(const Duration(days: 7));

      final moviesThisMonth = await _supabase
          .from('movies')
          .select()
          .gte('createdat', lastMonth.toIso8601String());

      final moviesLastWeek = await _supabase
          .from('movies')
          .select()
          .gte('createdat', lastWeek.toIso8601String());

      final seriesThisMonth = await _supabase
          .from('series')
          .select()
          .gte('createdat', lastMonth.toIso8601String());

      final seriesLastWeek = await _supabase
          .from('series')
          .select()
          .gte('createdat', lastWeek.toIso8601String());

      return {
        'movies_this_month': moviesThisMonth.length,
        'movies_last_week': moviesLastWeek.length,
        'series_this_month': seriesThisMonth.length,
        'series_last_week': seriesLastWeek.length,
      };
    } catch (e) {
      throw Exception('Failed to get content growth stats: $e');
    }
  }

  // AdMob Configuration methods
  Future<Map<String, String>> getAppConfig() async {
    try {
      final response = await _supabase
          .from('app_config')
          .select('config_key, config_value');

      final config = <String, String>{};
      for (final item in response) {
        config[item['config_key']] = item['config_value'];
      }

      return config;
    } catch (e) {
      print('Warning: Could not load app_config: $e');
      // Return empty config if table doesn't exist
      return {};
    }
  }

  Future<void> updateConfigValue(String configKey, String configValue) async {
    try {
      _ensureAuthenticated();

      await _supabase
          .from('app_config')
          .upsert({
            'config_key': configKey,
            'config_value': configValue,
            'updated_at': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      throw Exception('Failed to update config value: $e');
    }
  }

  Future<void> initializeAppConfig() async {
    try {
      _ensureAuthenticated();

      // Check if app_config table exists and has data
      final config = await getAppConfig();

      if (config.isEmpty) {
        // Initialize with default AdMob configuration
        final defaultConfig = {
          'admob_app_id_android': '',
          'admob_app_id_ios': '',
          'admob_banner_android': '',
          'admob_banner_ios': '',
          'admob_interstitial_android': '',
          'admob_interstitial_ios': '',
          'admob_rewarded_android': '',
          'admob_rewarded_ios': '',
        };

        for (final entry in defaultConfig.entries) {
          await updateConfigValue(entry.key, entry.value);
        }
      }
    } catch (e) {
      print('Warning: Could not initialize app config: $e');
    }
  }
}
