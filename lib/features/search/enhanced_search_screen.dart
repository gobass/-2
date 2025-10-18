import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nashmi_tf/models/movie_model.dart';
import 'package:nashmi_tf/services/supabase_service.dart';
import 'package:nashmi_tf/features/home/presentation/widgets/movie_list_horizontal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnhancedSearchScreen extends StatefulWidget {
  const EnhancedSearchScreen({super.key});

  @override
  State<EnhancedSearchScreen> createState() => _EnhancedSearchScreenState();
}

class _EnhancedSearchScreenState extends State<EnhancedSearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  List<Movie> _allMovies = [];
  List<Movie> _searchResults = [];
  List<String> _searchSuggestions = [];
  List<String> _recentSearches = [];
  List<String> _popularSearches = [
    'أكشن',
    'كوميديا',
    'رومانسية',
    'رعب',
    'خيال علمي',
    'دراما',
    'إثارة',
    '2024',
    '2023',
  ];

  bool _isSearching = false;
  bool _isLoading = false;
  bool _isLoadingMovies = true;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRecentSearches();
    _loadAllMovies();
    _searchController.addListener(_onSearchTextChanged);
  }

  Future<void> _loadAllMovies() async {
    setState(() {
      _isLoadingMovies = true;
    });

    try {
      final supabaseService = Get.find<SupabaseService>();
      final moviesData = await supabaseService.getMovies();
      final seriesData = await supabaseService.getSeries();

      final movies = moviesData.map((data) => Movie.fromJson(data)).toList();
      final series = seriesData.map((data) => Movie(
        id: data['id']?.toString() ?? '',
        title: data['title'] ?? '',
        description: data['description'] ?? '',
        imageURL: data['posterUrl'] ?? '',
        videoURL: data['video_url'] ?? '',
        category: (data['categories'] as List?)?.first ?? '',
        type: 'series',
        viewCount: data['views'] ?? 0,
        rating: (data['rating'] ?? 0).toDouble(),
        year: data['year']?.toString(),
        duration: data['duration']?.toString(),
        episodeCount: data['total_episodes'],
        createdAt: data['createdat'] != null
          ? DateTime.parse(data['createdat'])
          : DateTime.now(),
      )).toList();

      _allMovies = [...movies, ...series];

      // Remove duplicates by id
      final Set<String> seenIds = <String>{};
      _allMovies = _allMovies.where((movie) => seenIds.add(movie.id)).toList();
    } catch (e) {
      print('Error loading all movies: $e');
    } finally {
      setState(() {
        _isLoadingMovies = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchTextChanged() {
    final query = _searchController.text;
    if (query.isNotEmpty) {
      setState(() {
        _currentQuery = query;
        _isSearching = true;
      });
      _generateSuggestions(query);
    } else {
      setState(() {
        _isSearching = false;
        _searchSuggestions.clear();
        _searchResults.clear();
      });
    }
  }

  void _generateSuggestions(String query) {
    if (_allMovies.isEmpty) return;

    final suggestions = <String>{};

    for (final movie in _allMovies) {
      if (movie.title.toLowerCase().contains(query.toLowerCase())) {
        suggestions.add(movie.title);
      }

      if (movie.category.toLowerCase().contains(query.toLowerCase())) {
        suggestions.add(_getCategoryName(movie.category));
      }

      if (movie.year != null && movie.year!.contains(query)) {
        suggestions.add(movie.year!);
      }
    }

    for (final popular in _popularSearches) {
      if (popular.toLowerCase().contains(query.toLowerCase())) {
        suggestions.add(popular);
      }
    }

    setState(() {
      _searchSuggestions = suggestions.take(6).toList();
    });
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'action': return 'أكشن';
      case 'comedy': return 'كوميديا';
      case 'drama': return 'دراما';
      case 'horror': return 'رعب';
      case 'romance': return 'رومانسية';
      case 'scifi': return 'خيال علمي';
      case 'thriller': return 'إثارة';
      default: return category;
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // حفظ البحث في التاريخ
      await _saveSearchToHistory(query);

      // البحث في الأفلام المحملة مسبقاً
      final results = _allMovies.where((movie) {
        final searchLower = query.toLowerCase();
        return movie.title.toLowerCase().contains(searchLower) ||
               movie.description.toLowerCase().contains(searchLower) ||
               movie.category.toLowerCase().contains(searchLower) ||
               _getCategoryName(movie.category).toLowerCase().contains(searchLower) ||
               (movie.year != null && movie.year!.contains(query));
      }).toList();

      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _searchResults = results;
        _isLoading = false;
        _isSearching = false;
      });
    } catch (e) {
      print('Error performing search: $e');
      setState(() {
        _isLoading = false;
        _isSearching = false;
      });
    }
  }

  Future<void> _loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recent = prefs.getStringList('recent_searches') ?? [];
      setState(() {
        _recentSearches = recent.take(10).toList();
      });
    } catch (e) {
      print('Error loading recent searches: $e');
    }
  }

  Future<void> _saveSearchToHistory(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recent = prefs.getStringList('recent_searches') ?? [];
      
      // إزالة البحث إذا كان موجود مسبقاً
      recent.remove(query);
      // إضافة البحث في المقدمة
      recent.insert(0, query);
      // الاحتفاظ بآخر 10 بحثات فقط
      final limitedRecent = recent.take(10).toList();
      
      await prefs.setStringList('recent_searches', limitedRecent);
      
      setState(() {
        _recentSearches = limitedRecent;
      });
    } catch (e) {
      print('Error saving search to history: $e');
    }
  }

  Future<void> _clearSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('recent_searches');
      setState(() {
        _recentSearches.clear();
      });
    } catch (e) {
      print('Error clearing search history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.grey[700]!),
          ),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'ابحث عن الأفلام والمسلسلات...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchResults.clear();
                          _isSearching = false;
                          _searchSuggestions.clear();
                        });
                      },
                    )
                  : null,
            ),
            onSubmitted: _performSearch,
            textInputAction: TextInputAction.search,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.red),
            SizedBox(height: 16),
            Text(
              'جاري البحث...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    if (_isSearching && _searchSuggestions.isNotEmpty) {
      return _buildSuggestions();
    }

    if (_searchResults.isNotEmpty) {
      return _buildSearchResults();
    }

    if (_currentQuery.isNotEmpty && _searchResults.isEmpty) {
      return _buildNoResults();
    }

    return _buildEmptyState();
  }

  Widget _buildSuggestions() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'اقتراحات البحث',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            itemCount: _searchSuggestions.length,
            itemBuilder: (context, index) {
              final suggestion = _searchSuggestions[index];
              return ListTile(
                leading: const Icon(Icons.search, color: Colors.grey),
                title: Text(
                  suggestion,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  _searchController.text = suggestion;
                  _performSearch(suggestion);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Column(
      children: [
        // عدد النتائج
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'النتائج: ${_searchResults.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'البحث عن: "$_currentQuery"',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        
        // تبويبات التصفية
        TabBar(
          controller: _tabController,
          labelColor: Colors.red,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.red,
          tabs: const [
            Tab(text: 'الكل'),
            Tab(text: 'أفلام'),
            Tab(text: 'مسلسلات'),
          ],
        ),
        
        // قائمة النتائج
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildResultsList(_searchResults),
              _buildResultsList(_searchResults.where((m) => m.type == 'movie').toList()),
              _buildResultsList(_searchResults.where((m) => m.type == 'series').toList()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultsList(List<Movie> movies) {
    if (movies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد نتائج في هذا القسم',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: (movies.length / 3).ceil(),
      itemBuilder: (context, index) {
        final startIndex = index * 3;
        final endIndex = (startIndex + 3 > movies.length)
            ? movies.length
            : startIndex + 3;
        final moviesInRow = movies.sublist(startIndex, endIndex);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: MovieListHorizontal(movies: moviesInRow),
        );
      },
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد نتائج',
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'لم نجد أي نتائج لـ "$_currentQuery"',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchResults.clear();
                _currentQuery = '';
              });
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text('بحث جديد', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // البحثات الأخيرة
          if (_recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'البحثات الأخيرة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final result = await Get.dialog<bool>(
                      AlertDialog(
                        backgroundColor: Colors.grey[800],
                        title: const Text('مسح التاريخ', style: TextStyle(color: Colors.white)),
                        content: const Text(
                          'هل تريد مسح جميع البحثات السابقة؟',
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
                            child: const Text('مسح'),
                          ),
                        ],
                      ),
                    );
                    
                    if (result == true) {
                      await _clearSearchHistory();
                    }
                  },
                  child: const Text('مسح الكل', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentSearches.map((search) => _buildSearchChip(search, true)).toList(),
            ),
            const SizedBox(height: 32),
          ],

          // البحثات الشائعة
          const Text(
            'البحثات الشائعة',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularSearches.map((search) => _buildSearchChip(search, false)).toList(),
          ),
          const SizedBox(height: 32),

          // نصائح البحث
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'نصائح البحث',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '• ابحث باسم الفيلم أو المسلسل\n'
                  '• ابحث بالفئة (أكشن، كوميديا، رعب)\n'
                  '• ابحث بسنة الإنتاج (2023، 2024)\n'
                  '• استخدم الكلمات المفتاحية المختلفة',
                  style: TextStyle(
                    color: Colors.blue[300],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchChip(String text, bool isRecent) {
    return GestureDetector(
      onTap: () {
        _searchController.text = text;
        _performSearch(text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isRecent
              ? LinearGradient(
                  colors: [Colors.grey[800]!, Colors.grey[900]!],
                )
              : const LinearGradient(
                  colors: [Colors.red, Color(0xFFFF6B6B)],
                ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isRecent ? Colors.grey[600]! : Colors.red,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isRecent ? Icons.history : Icons.trending_up,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
