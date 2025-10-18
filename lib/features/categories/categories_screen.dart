import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../services/ad_service.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final AdService _adService = AdService();
  String _selectedSortBy = 'المشاهدة';
  String _selectedCategory = 'الكل';
  bool _isLoading = false;

  // بيانات تجريبية للأقسام
  final List<Map<String, dynamic>> _categories = [
    {'id': 'all', 'name': 'الكل', 'icon': Icons.all_inclusive, 'color': Colors.red},
    {'id': 'action', 'name': 'أكشن', 'icon': Icons.local_fire_department, 'color': Colors.orange},
    {'id': 'comedy', 'name': 'كوميديا', 'icon': Icons.sentiment_very_satisfied, 'color': Colors.yellow},
    {'id': 'drama', 'name': 'دراما', 'icon': Icons.theater_comedy, 'color': Colors.purple},
    {'id': 'horror', 'name': 'رعب', 'icon': Icons.warning_amber, 'color': Colors.redAccent},
    {'id': 'romance', 'name': 'رومانس', 'icon': Icons.favorite, 'color': Colors.pink},
    {'id': 'animation', 'name': 'أنمي', 'icon': Icons.animation, 'color': Colors.blue},
    {'id': 'documentary', 'name': 'وثائقي', 'icon': Icons.article, 'color': Colors.green},
  ];

  // بيانات تجريبية للأفلام
  final List<Map<String, dynamic>> _movies = [
    {
      'id': '1',
      'title': 'فيلم أكشن مثير',
      'poster': 'https://via.placeholder.com/150x200/FF5722/FFFFFF?text=Action',
      'category': 'action',
      'views': 1250,
      'year': 2024,
      'rating': 4.5,
      'duration': '2h 15m'
    },
    {
      'id': '2',
      'title': 'كوميديا رائعة',
      'poster': 'https://via.placeholder.com/150x200/FFC107/000000?text=Comedy',
      'category': 'comedy',
      'views': 890,
      'year': 2023,
      'rating': 4.2,
      'duration': '1h 45m'
    },
    {
      'id': '3',
      'title': 'دراما مؤثرة',
      'poster': 'https://via.placeholder.com/150x200/9C27B0/FFFFFF?text=Drama',
      'category': 'drama',
      'views': 2100,
      'year': 2024,
      'rating': 4.8,
      'duration': '2h 30m'
    },
    {
      'id': '4',
      'title': 'فيلم رعب مخيف',
      'poster': 'https://via.placeholder.com/150x200/F44336/FFFFFF?text=Horror',
      'category': 'horror',
      'views': 750,
      'year': 2023,
      'rating': 4.0,
      'duration': '1h 50m'
    },
    {
      'id': '5',
      'title': 'قصة حب رومانسية',
      'poster': 'https://via.placeholder.com/150x200/E91E63/FFFFFF?text=Romance',
      'category': 'romance',
      'views': 1800,
      'year': 2024,
      'rating': 4.6,
      'duration': '2h 10m'
    },
    {
      'id': '6',
      'title': 'أنمي مذهل',
      'poster': 'https://via.placeholder.com/150x200/2196F3/FFFFFF?text=Anime',
      'category': 'animation',
      'views': 3200,
      'year': 2024,
      'rating': 4.9,
      'duration': '1h 30m'
    },
  ];

  List<Map<String, dynamic>> get _filteredMovies {
    List<Map<String, dynamic>> filtered = _movies;

    // فلترة حسب القسم
    if (_selectedCategory != 'الكل') {
      filtered = filtered.where((movie) => movie['category'] == _selectedCategory).toList();
    }

    // ترتيب حسب المعيار المحدد
    switch (_selectedSortBy) {
      case 'المشاهدة':
        filtered.sort((a, b) => b['views'].compareTo(a['views']));
        break;
      case 'التقييم':
        filtered.sort((a, b) => b['rating'].compareTo(a['rating']));
        break;
      case 'السنة':
        filtered.sort((a, b) => b['year'].compareTo(a['year']));
        break;
      case 'المدة':
        filtered.sort((a, b) => a['duration'].compareTo(b['duration']));
        break;
    }

    return filtered;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    // محاكاة تحميل البيانات
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ترتيب حسب',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ...['المشاهدة', 'التقييم', 'السنة', 'المدة'].map((option) => ListTile(
              title: Text(
                option,
                style: TextStyle(
                  color: _selectedSortBy == option ? Colors.red : Colors.white,
                  fontWeight: _selectedSortBy == option ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: _selectedSortBy == option
                  ? const Icon(Icons.check, color: Colors.red)
                  : null,
              onTap: () {
                setState(() => _selectedSortBy = option);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'الأقسام',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort, color: Colors.white),
            onPressed: _showSortOptions,
            tooltip: 'ترتيب',
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط الأقسام
          Container(
            height: 120,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category['name'];

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedCategory = category['name']);
                    // عرض إعلان عند تغيير القسم (احتمالية 30%)
                    if (DateTime.now().millisecondsSinceEpoch % 10 < 3) {
                      _adService.showInterstitialAd(() {});
                    }
                  },
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.only(left: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? category['color'] : Colors.grey[800],
                      borderRadius: BorderRadius.circular(16),
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 2)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          category['icon'],
                          color: isSelected ? Colors.white : category['color'],
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          category['name'],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[300],
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // معلومات الفلترة
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[900],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'القسم: $_selectedCategory',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'الترتيب: $_selectedSortBy',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${_filteredMovies.length} فيلم',
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // قائمة الأفلام
          Expanded(
            child: _isLoading
              ? _buildLoadingGrid()
              : _filteredMovies.isEmpty
                ? _buildEmptyState()
                : _buildMoviesGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: 12,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[800]!,
        highlightColor: Colors.grey[600]!,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie_filter,
            size: 80,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد أفلام في هذا القسم',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'جاري إضافة المزيد من المحتوى قريباً',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoviesGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: _filteredMovies.length,
      itemBuilder: (context, index) {
        final movie = _filteredMovies[index];
        return GestureDetector(
          onTap: () => _onMovieTap(movie),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  // صورة الفيلم
                  CachedNetworkImage(
                    imageUrl: movie['poster'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[800]!,
                      highlightColor: Colors.grey[600]!,
                      child: Container(color: Colors.grey[800]),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[800],
                      child: const Icon(
                        Icons.error,
                        color: Colors.grey,
                        size: 40,
                      ),
                    ),
                  ),

                  // تدرج لوني للنص
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),

                  // معلومات الفيلم
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            movie['title'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.yellow[600],
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                movie['rating'].toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.visibility,
                                color: Colors.grey[400],
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${movie['views']}',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _onMovieTap(Map<String, dynamic> movie) {
    // عرض إعلان قبل تشغيل الفيلم (احتمالية 40%)
    if (DateTime.now().millisecondsSinceEpoch % 10 < 4) {
      _adService.showInterstitialAd(() {
        _navigateToMovie(movie);
      });
    } else {
      _navigateToMovie(movie);
    }
  }

  void _navigateToMovie(Map<String, dynamic> movie) {
    // الانتقال إلى صفحة الفيلم
    print('Navigating to movie: ${movie['title']}');
    // Get.to(() => MovieDetailsScreen(movieId: movie['id']));
  }
}
