import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nashmi_tf/models/movie_model.dart';
import 'package:nashmi_tf/services/mock_data_service.dart';
import 'package:nashmi_tf/services/supabase_service.dart';
import 'package:nashmi_tf/features/home/presentation/widgets/movie_list_horizontal.dart';
import 'package:nashmi_tf/services/ad_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Movie> _allMovies = [];
  List<Movie> _filteredMovies = [];
  List<String> _searchHistory = [];
  bool _isLoading = true;
  bool _isSearching = false;
  late final AdService _adService;

  @override
  void initState() {
    super.initState();
    _adService = Get.find<AdService>();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    setState(() => _isLoading = true);

    try {
      final supabaseService = Get.find<SupabaseService>();

      final moviesData = await supabaseService.getMovies();
      final seriesData = await supabaseService.getSeries();
      // final adsData = await supabaseService.getAllAds();

      final movies = moviesData.map((data) => Movie.fromJson(data)).toList();
      final series = seriesData
          .map(
            (data) => Movie(
              id: data['id']?.toString() ?? '',
              title: data['title'] ?? '',
              description: data['description'] ?? '',
              imageURL: data['posterUrl'] ?? '',
              videoURL: data['video_url'] ?? '', // Fixed field name for series
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
            ),
          )
          .toList();

      _allMovies = [...movies, ...series];
      // Removed ads from search results as per user request

      // Remove duplicates by id
      final Set<String> seenIds = <String>{};
      _allMovies = _allMovies.where((movie) => seenIds.add(movie.id)).toList();
    } catch (e) {
      print('Error loading movies from Supabase: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _searchMovies(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _filteredMovies = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    final filteredList = _allMovies.where((movie) {
      return movie.title.toLowerCase().contains(query.toLowerCase()) ||
          movie.description.toLowerCase().contains(query.toLowerCase()) ||
          movie.category.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredMovies = filteredList;
      _isSearching = false;
    });

    // Add to search history if not empty
    if (query.trim().isNotEmpty && !_searchHistory.contains(query)) {
      setState(() {
        _searchHistory.insert(0, query);
        if (_searchHistory.length > 10) {
          _searchHistory = _searchHistory.take(10).toList();
        }
      });
    }
  }

  void _clearSearchHistory() {
    setState(() {
      _searchHistory.clear();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'البحث',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: 'ابحث عن فيلم أو مسلسل...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.red,
                            ),
                          ),
                        ),
                      )
                    : const Icon(Icons.search, color: Colors.red),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _searchMovies('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              onChanged: _searchMovies,
            ),
          ),

          // Results/Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    ),
                  )
                : _searchController.text.isEmpty
                ? _buildSearchHistory()
                : _filteredMovies.isEmpty
                ? _buildNoResults()
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHistory() {
    if (_searchHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, color: Colors.grey[600], size: 64),
            const SizedBox(height: 16),
            Text(
              'ابدأ البحث عن أفلامك المفضلة',
              style: TextStyle(color: Colors.grey[400], fontSize: 18),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'عمليات البحث السابقة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _clearSearchHistory,
                child: const Text(
                  'مسح الكل',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _searchHistory.length,
            itemBuilder: (context, index) {
              final query = _searchHistory[index];
              return ListTile(
                leading: const Icon(Icons.history, color: Colors.grey),
                title: Text(query, style: const TextStyle(color: Colors.white)),
                trailing: IconButton(
                  icon: const Icon(Icons.north_west, color: Colors.grey),
                  onPressed: () {
                    _searchController.text = query;
                    _searchMovies(query);
                  },
                ),
                onTap: () {
                  _searchController.text = query;
                  _searchMovies(query);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.movie_filter_outlined, color: Colors.grey[600], size: 64),
          const SizedBox(height: 16),
          const Text(
            'لا توجد نتائج',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'جرب البحث بكلمات مختلفة',
            style: TextStyle(color: Colors.grey[400], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'نتائج البحث (${_filteredMovies.length})',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Banner Ad
        Container(
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: _adService.getBannerAdWidget(),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: MovieListHorizontal(movies: _filteredMovies),
          ),
        ),
      ],
    );
  }
}
