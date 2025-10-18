
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nashmi_admin_v2/services/supabase_service.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsView extends StatefulWidget {
  const ReportsView({super.key});

  @override
  State<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView> {
  final SupabaseService supabaseService = Get.find<SupabaseService>();
  final ScrollController _scrollController = ScrollController();

  Map<String, dynamic> stats = {};
  bool isLoading = true;

  // Advanced stats
  String selectedPeriod = 'daily';
  List<Map<String, dynamic>> viewsOverTime = [];
  Map<String, int> categoryDistribution = {};
  List<Map<String, dynamic>> adPerformance = [];
  Map<String, dynamic> growthStats = {};
  List<Map<String, dynamic>> usersOverTime = [];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    try {
      setState(() => isLoading = true);

      // Basic Supabase stats
      final supabaseMoviesCount = await supabaseService.getMoviesCount();
      final supabaseSeriesCount = await supabaseService.getSeriesCount();
      final supabaseAdsCount = await supabaseService.getActiveAdsCount();

      // Advanced stats
      final viewsData = await supabaseService.getMoviesViewsOverTime(selectedPeriod);
      final categoryData = await supabaseService.getCategoryDistribution();
      final adData = await supabaseService.getAdPerformance();
      final growthData = await supabaseService.getContentGrowthStats();
      final usersData = await supabaseService.getUsersStatsOverTime(selectedPeriod);

      setState(() {
        stats = {
          'supabase_movies': supabaseMoviesCount,
          'supabase_series': supabaseSeriesCount,
          'supabase_ads': supabaseAdsCount,
        };
        viewsOverTime = viewsData;
        categoryDistribution = categoryData;
        adPerformance = adData;
        growthStats = growthData;
        usersOverTime = usersData;
        isLoading = false;
      });
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تحميل الإحصائيات: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير والإحصائيات'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadStats,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              thickness: 8,
              radius: const Radius.circular(8),
              trackVisibility: true,
              interactive: true,
              scrollbarOrientation: ScrollbarOrientation.right,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'إحصائيات عامة',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Supabase Stats
                    _buildStatsSection('إحصائيات Supabase', [
                      _buildStatItem('الأفلام', stats['supabase_movies'] ?? 0),
                      _buildStatItem('المسلسلات', stats['supabase_series'] ?? 0),
                      _buildStatItem('الإعلانات النشطة', stats['supabase_ads'] ?? 0),
                    ]),

                    const SizedBox(height: 32),

                    // System Health
                    const Text(
                      'حالة النظام',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSystemHealth(),

                    const SizedBox(height: 32),

                    // Time Filter
                    _buildTimeFilter(),

                    const SizedBox(height: 32),

                    // Advanced Charts
                    const Text(
                      'الرسوم البيانية المتقدمة',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Views Chart
                    _buildViewsChart(),

                    const SizedBox(height: 16),

                    // Category Distribution
                    _buildCategoryChart(),

                    const SizedBox(height: 16),

                    // Growth Stats
                    _buildGrowthStats(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatsSection(String title, List<Widget> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 16),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return const Text('تم إزالة نشاط Firebase');
  }

  Widget _buildSystemHealth() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.cloud_done, color: Colors.green),
                const SizedBox(width: 12),
                const Text('حالة قاعدة البيانات'),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'متصل',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.storage, color: Colors.blue),
                const SizedBox(width: 12),
                const Text('مساحة التخزين'),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'متاح',
                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getEventIcon(String? type) {
    switch (type) {
      case 'movie_added':
      case 'series_added':
        return Icons.add_circle;
      case 'movie_updated':
      case 'series_updated':
        return Icons.edit;
      case 'user_registered':
        return Icons.person_add;
      case 'user_login':
        return Icons.login;
      default:
        return Icons.info;
    }
  }

  Color _getEventColor(String? type) {
    switch (type) {
      case 'movie_added':
      case 'series_added':
        return Colors.green;
      case 'movie_updated':
      case 'series_updated':
        return Colors.orange;
      case 'user_registered':
        return Colors.teal;
      case 'user_login':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildTimeFilter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('الفترة: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: selectedPeriod,
          items: const [
            DropdownMenuItem(value: 'daily', child: Text('يومي')),
            DropdownMenuItem(value: 'weekly', child: Text('أسبوعي')),
            DropdownMenuItem(value: 'monthly', child: Text('شهري')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => selectedPeriod = value);
              loadStats();
            }
          },
        ),
      ],
    );
  }

  Widget _buildViewsChart() {
    if (viewsOverTime.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('لا توجد بيانات مشاهدات متاحة'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إحصائيات المشاهدات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: viewsOverTime.asMap().entries.map((entry) {
                        final views = entry.value['views'] ?? 0;
                        return FlSpot(entry.key.toDouble(), views.toDouble());
                      }).toList(),
                      isCurved: true,
                      color: Colors.teal,
                      barWidth: 3,
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChart() {
    if (categoryDistribution.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('لا توجد بيانات فئات متاحة'),
        ),
      );
    }

    final total = categoryDistribution.values.reduce((a, b) => a + b);
    final sections = categoryDistribution.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      return PieChartSectionData(
        value: percentage,
        title: '${entry.key}\n${percentage.toStringAsFixed(1)}%',
        color: _getCategoryColor(entry.key),
        radius: 60,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'توزيع الفئات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إحصائيات النمو',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildGrowthItem(
                    'أفلام هذا الشهر',
                    growthStats['movies_this_month'] ?? 0,
                    Icons.movie,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildGrowthItem(
                    'أفلام الأسبوع الماضي',
                    growthStats['movies_last_week'] ?? 0,
                    Icons.movie_filter,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildGrowthItem(
                    'مسلسلات هذا الشهر',
                    growthStats['series_this_month'] ?? 0,
                    Icons.tv,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildGrowthItem(
                    'مسلسلات الأسبوع الماضي',
                    growthStats['series_last_week'] ?? 0,
                    Icons.tv_off,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthItem(String label, int value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors[category.hashCode % colors.length];
  }
}
