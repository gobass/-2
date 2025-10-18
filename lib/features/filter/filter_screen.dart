import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nashmi_tf/models/movie_model.dart';
import 'package:nashmi_tf/services/mock_data_service.dart';
import 'package:nashmi_tf/features/home/presentation/widgets/movie_list_horizontal.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  String _selectedType = 'all'; // all, movie, series
  String _selectedCategory = 'all'; // all, action, comedy, etc.
  String _selectedYear = 'all'; // all, 2024, 2023, 2022
  String _selectedRating = 'all'; // all, high (>4.5), medium (3-4.5), low (<3)
  String _sortBy = 'latest'; // latest, rating, views, name
  
  List<Movie> _allMovies = [];
  List<Movie> _filteredMovies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  void _loadMovies() {
    setState(() => _isLoading = true);
    
    // تحميل جميع الأفلام
    _allMovies = MockDataService.getMockMovies();
    _applyFilters();
    
    setState(() => _isLoading = false);
  }

  void _applyFilters() {
    List<Movie> filtered = List.from(_allMovies);

    // فلتر نوع المحتوى
    if (_selectedType != 'all') {
      filtered = filtered.where((movie) => movie.type == _selectedType).toList();
    }

    // فلتر الفئة
    if (_selectedCategory != 'all') {
      filtered = filtered.where((movie) => movie.category == _selectedCategory).toList();
    }

    // فلتر السنة
    if (_selectedYear != 'all') {
      filtered = filtered.where((movie) => movie.year == _selectedYear).toList();
    }

    // فلتر التقييم
    if (_selectedRating != 'all') {
      if (_selectedRating == 'high') {
        filtered = filtered.where((movie) => movie.rating! > 4.5).toList();
      } else if (_selectedRating == 'medium') {
        filtered = filtered.where((movie) => movie.rating! >= 3.0 && movie.rating! <= 4.5).toList();
      } else if (_selectedRating == 'low') {
        filtered = filtered.where((movie) => movie.rating! < 3.0).toList();
      }
    }

    // ترتيب النتائج
    switch (_sortBy) {
      case 'latest':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'rating':
        filtered.sort((a, b) => b.rating!.compareTo(a.rating!));
        break;
      case 'views':
        filtered.sort((a, b) => b.viewCount!.compareTo(a.viewCount!));
        break;
      case 'name':
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
    }

    setState(() {
      _filteredMovies = filtered;
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedType = 'all';
      _selectedCategory = 'all';
      _selectedYear = 'all';
      _selectedRating = 'all';
      _sortBy = 'latest';
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'فرز وتصفية',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all, color: Colors.red),
            onPressed: _clearFilters,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.red),
            )
          : Column(
              children: [
                // قسم الفلاتر
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // نوع المحتوى
                      _buildFilterSection(
                        'نوع المحتوى',
                        _selectedType,
                        [
                          {'key': 'all', 'value': 'الكل'},
                          {'key': 'movie', 'value': 'أفلام'},
                          {'key': 'series', 'value': 'مسلسلات'},
                        ],
                        (value) {
                          setState(() => _selectedType = value);
                          _applyFilters();
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // الفئة
                      _buildFilterSection(
                        'الفئة',
                        _selectedCategory,
                        [
                          {'key': 'all', 'value': 'جميع الفئات'},
                          {'key': 'action', 'value': 'أكشن'},
                          {'key': 'comedy', 'value': 'كوميديا'},
                          {'key': 'drama', 'value': 'دراما'},
                          {'key': 'horror', 'value': 'رعب'},
                          {'key': 'romance', 'value': 'رومانسية'},
                          {'key': 'scifi', 'value': 'خيال علمي'},
                          {'key': 'thriller', 'value': 'إثارة'},
                        ],
                        (value) {
                          setState(() => _selectedCategory = value);
                          _applyFilters();
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // السنة والتقييم والترتيب في صف واحد
                      Row(
                        children: [
                          // السنة
                          Expanded(
                            child: _buildFilterSection(
                              'السنة',
                              _selectedYear,
                              [
                                {'key': 'all', 'value': 'الكل'},
                                {'key': '2024', 'value': '2024'},
                                {'key': '2023', 'value': '2023'},
                                {'key': '2022', 'value': '2022'},
                              ],
                              (value) {
                                setState(() => _selectedYear = value);
                                _applyFilters();
                              },
                              isCompact: true,
                            ),
                          ),
                          
                          const SizedBox(width: 8),
                          
                          // التقييم
                          Expanded(
                            child: _buildFilterSection(
                              'التقييم',
                              _selectedRating,
                              [
                                {'key': 'all', 'value': 'الكل'},
                                {'key': 'high', 'value': 'عالي'},
                                {'key': 'medium', 'value': 'متوسط'},
                                {'key': 'low', 'value': 'منخفض'},
                              ],
                              (value) {
                                setState(() => _selectedRating = value);
                                _applyFilters();
                              },
                              isCompact: true,
                            ),
                          ),
                          
                          const SizedBox(width: 8),
                          
                          // الترتيب
                          Expanded(
                            child: _buildFilterSection(
                              'ترتيب',
                              _sortBy,
                              [
                                {'key': 'latest', 'value': 'الأحدث'},
                                {'key': 'rating', 'value': 'التقييم'},
                                {'key': 'views', 'value': 'المشاهدات'},
                                {'key': 'name', 'value': 'الاسم'},
                              ],
                              (value) {
                                setState(() => _sortBy = value);
                                _applyFilters();
                              },
                              isCompact: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // عداد النتائج
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'النتائج: ${_filteredMovies.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_filteredMovies.isEmpty)
                        const Text(
                          'لا توجد نتائج',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
                
                const Divider(color: Colors.grey, thickness: 0.5),
                
                // قائمة النتائج
                Expanded(
                  child: _filteredMovies.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                color: Colors.grey,
                                size: 64,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'لا توجد نتائج تطابق معايير البحث',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'جرب تغيير الفلاتر',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: (_filteredMovies.length / 4).ceil(),
                          itemBuilder: (context, index) {
                            final startIndex = index * 4;
                            final endIndex = (startIndex + 4 > _filteredMovies.length)
                                ? _filteredMovies.length
                                : startIndex + 4;
                            final moviesInRow = _filteredMovies.sublist(startIndex, endIndex);
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: MovieListHorizontal(movies: moviesInRow),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterSection(
    String title,
    String selectedValue,
    List<Map<String, String>> options,
    Function(String) onChanged, {
    bool isCompact = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: isCompact ? 14 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: isCompact ? 4 : 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey[800]!, Colors.grey[900]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[700]!, width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue,
              dropdownColor: Colors.grey[800],
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
              isExpanded: true,
              style: TextStyle(
                color: Colors.white,
                fontSize: isCompact ? 12 : 14,
              ),
              items: options.map((option) {
                return DropdownMenuItem<String>(
                  value: option['key']!,
                  child: Text(option['value']!),
                );
              }).toList(),
              onChanged: (value) => onChanged(value!),
            ),
          ),
        ),
      ],
    );
  }
}
