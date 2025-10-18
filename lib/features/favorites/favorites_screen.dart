import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nashmi_tf/services/favorites_service.dart';
import 'package:nashmi_tf/features/home/presentation/widgets/movie_list_horizontal.dart';
import 'package:nashmi_tf/models/movie_model.dart';
import 'package:nashmi_tf/services/ad_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  final FavoritesService _favoritesService = FavoritesService.instance;
  final AdService _adService = AdService();
  late TabController _tabController;

  String _selectedFilter = 'all'; // all, movies, series
  String _selectedCategory = 'all'; // all, action, comedy, etc.
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _adService.initialize();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Movie> _getFilteredFavorites() {
    var favorites = _favoritesService.favorites;
    
    // فلتر حسب النوع
    if (_selectedFilter != 'all') {
      favorites = favorites.where((movie) => movie.type == _selectedFilter).toList();
    }
    
    // فلتر حسب الفئة
    if (_selectedCategory != 'all') {
      favorites = favorites.where((movie) => movie.category == _selectedCategory).toList();
    }
    
    return favorites;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'المفضلة',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Obx(() => _favoritesService.favorites.isNotEmpty
              ? PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  color: Colors.grey[800],
                  onSelected: (value) async {
                    if (value == 'clear_all') {
                      final result = await Get.dialog<bool>(
                        AlertDialog(
                          backgroundColor: Colors.grey[800],
                          title: const Text(
                            'حذف جميع المفضلة',
                            style: TextStyle(color: Colors.white),
                          ),
                          content: const Text(
                            'هل أنت متأكد من حذف جميع العناصر من المفضلة؟',
                            style: TextStyle(color: Colors.white70),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(result: false),
                              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
                            ),
                            ElevatedButton(
                              onPressed: () => Get.back(result: true),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              child: const Text('حذف الكل'),
                            ),
                          ],
                        ),
                      );
                      
                      if (result == true) {
                        await _favoritesService.clearAllFavorites();
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem<String>(
                      value: 'clear_all',
                      child: Row(
                        children: [
                          Icon(Icons.clear_all, color: Colors.red),
                          SizedBox(width: 8),
                          Text('حذف الكل', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                )
              : const SizedBox()),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.red,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.red,
          tabs: const [
            Tab(text: 'الكل', icon: Icon(Icons.favorite)),
            Tab(text: 'أفلام', icon: Icon(Icons.movie)),
            Tab(text: 'مسلسلات', icon: Icon(Icons.tv)),
            Tab(text: 'الأعلى تقييماً', icon: Icon(Icons.star)),
          ],
        ),
      ),
      body: Obx(() {
        if (_favoritesService.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'جاري تحميل المفضلة...',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          );
        }
        
        if (_favoritesService.favorites.isEmpty) {
          return _buildEmptyState();
        }
        
        return TabBarView(
          controller: _tabController,
          children: [
            _buildFavoritesList(_favoritesService.favorites),
            _buildFavoritesList(_favoritesService.getFavoritesByType('movie')),
            _buildFavoritesList(_favoritesService.getFavoritesByType('series')),
            _buildFavoritesList(_favoritesService.getTopRatedFavorites()),
          ],
        );
      }),

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
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.withValues(alpha: 0.2), Colors.red.withValues(alpha: 0.1)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_border,
              size: 80,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'لا توجد أفلام في المفضلة',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابحث عن الأفلام والمسلسلات المفضلة لديك\nوأضفها للمفضلة',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.red, Color(0xFFFF6B6B)],
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                // التبديل للصفحة الرئيسية
                final mainNavigation = context.findAncestorStateOfType<State<StatefulWidget>>();
                if (mainNavigation != null) {
                  // إشارة للتبديل للصفحة الرئيسية
                }
              },
              icon: const Icon(Icons.explore, color: Colors.white),
              label: const Text(
                'استكشف الأفلام',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(List<Movie> favorites) {
    if (favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_filter_outlined,
              size: 64,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد عناصر في هذا القسم',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عداد النتائج والفلاتر
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'العناصر: ${favorites.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              // فلاتر سريعة
              Row(
                children: [
                  _buildFilterChip('الكل', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('أكشن', 'action'),
                  const SizedBox(width: 8),
                  _buildFilterChip('كوميديا', 'comedy'),
                  const SizedBox(width: 8),
                  _buildFilterChip('دراما', 'drama'),
                ],
              ),
            ],
          ),
        ),
        
        // قائمة المفضلة
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: (favorites.length / 3).ceil(),
            itemBuilder: (context, index) {
              final startIndex = index * 3;
              final endIndex = (startIndex + 3 > favorites.length)
                  ? favorites.length
                  : startIndex + 3;
              final moviesInRow = favorites.sublist(startIndex, endIndex);
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _buildFavoritesRow(moviesInRow),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedCategory == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(colors: [Colors.red, Color(0xFFFF6B6B)])
              : null,
          color: isSelected ? null : Colors.grey[800],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.red : Colors.grey[600]!,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[400],
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritesRow(List<Movie> movies) {
    return SizedBox(
      height: 200,
      child: Row(
        children: movies.map((movie) => Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildFavoriteItem(movie),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildFavoriteItem(Movie movie) {
    return Container(
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
      child: Stack(
        children: [
          // صورة الفيلم
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              movie.imageURL,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[800],
                  child: const Center(
                    child: Icon(Icons.error, color: Colors.white, size: 32),
                  ),
                );
              },
            ),
          ),
          
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
          
          // زر الحذف من المفضلة
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => _favoritesService.toggleFavorite(movie),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
          
          // معلومات الفيلم
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    movie.title,
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
                      const SizedBox(width: 2),
                      Text(
                        '${movie.rating}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: movie.type == 'movie' ? Colors.blue : Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          movie.type == 'movie' ? 'فيلم' : 'مسلسل',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
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
    );
  }
}
