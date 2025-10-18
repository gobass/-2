import 'package:get/get.dart';
import 'package:nashmi_admin_v2/services/supabase_service.dart';

class StatisticsService extends GetxService {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();

  // Observable statistics
  final RxInt totalMovies = 0.obs;
  final RxInt totalSeries = 0.obs;
  final RxInt totalUsers = 0.obs;
  final RxInt activeAds = 0.obs;
  final RxInt totalEpisodes = 0.obs;
  final RxDouble systemHealth = 100.0.obs;
  final RxBool isLoading = true.obs;

  // Recent activities
  final RxList<Map<String, dynamic>> recentActivities = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadStatistics();
    startRealTimeUpdates();
  }

  Future<void> loadStatistics() async {
    try {
      isLoading.value = true;

      // Load basic statistics
      totalMovies.value = await _supabaseService.getMoviesCount();
      totalSeries.value = await _supabaseService.getSeriesCount();
      totalUsers.value = await _supabaseService.getUsersCount();
      activeAds.value = await _supabaseService.getActiveAdsCount();

      // Load episodes count
      final series = await _supabaseService.getSeries(limit: 100);
      int episodeCount = 0;
      for (final serie in series) {
        final episodes = await _supabaseService.getEpisodes(serie['id']);
        episodeCount += episodes.length;
      }
      totalEpisodes.value = episodeCount;

      // Load recent activities
      recentActivities.value = await _supabaseService.getRecentActivities();

      // Calculate system health (mock calculation)
      systemHealth.value = _calculateSystemHealth();

      // Update observable stats
      updateQuickStats();
      updateGrowthIndicators();

      isLoading.value = false;
    } catch (e) {
      print('Error loading statistics: $e');
      isLoading.value = false;
    }
  }

  void startRealTimeUpdates() {
    // Update statistics every 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      loadStatistics();
      startRealTimeUpdates();
    });
  }

  double _calculateSystemHealth() {
    // Mock system health calculation
    // In real implementation, this would check database connectivity,
    // API response times, storage usage, etc.
    return 95.0 + (DateTime.now().millisecond % 10).toDouble();
  }

  // Observable quick stats for dashboard cards
  final RxMap<String, dynamic> quickStats = <String, dynamic>{}.obs;

  // Observable growth indicators
  final RxMap<String, dynamic> growthIndicators = <String, dynamic>{}.obs;

  // Get quick stats for dashboard cards
  Map<String, dynamic> getQuickStats() {
    return {
      'movies': totalMovies.value,
      'series': totalSeries.value,
      'users': totalUsers.value,
      'ads': activeAds.value,
      'episodes': totalEpisodes.value,
      'total_content': totalMovies.value + totalSeries.value,
      'system_health': systemHealth.value,
    };
  }

  // Get growth indicators
  Map<String, dynamic> getGrowthIndicators() {
    // Mock growth data - in real implementation, compare with previous periods
    return {
      'movies_growth': '+12%',
      'series_growth': '+8%',
      'users_growth': '+15%',
      'ads_growth': '+5%',
    };
  }

  // Update observable stats
  void updateQuickStats() {
    quickStats.assignAll(getQuickStats());
  }

  // Update observable growth indicators
  void updateGrowthIndicators() {
    growthIndicators.assignAll(getGrowthIndicators());
  }
}
