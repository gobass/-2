import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/supabase_service.dart';

class MoviesView extends StatefulWidget {
  const MoviesView({super.key});

  @override
  State<MoviesView> createState() => _MoviesViewState();
}

class _MoviesViewState extends State<MoviesView> {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();
  final TextEditingController _searchController = TextEditingController();
  
  List<Map<String, dynamic>> _movies = [];
  List<Map<String, dynamic>> _filteredMovies = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final movies = await _supabaseService.getMovies();
      setState(() {
        _movies = movies;
        _filteredMovies = movies;
        _isLoading = false;
      });
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في تحميل الأفلام: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterMovies(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredMovies = _movies;
      } else {
        _filteredMovies = _movies.where((movie) {
          final title = movie['title']?.toString().toLowerCase() ?? '';
          final genre = movie['genre']?.toString().toLowerCase() ?? '';
          return title.contains(query.toLowerCase()) || 
                 genre.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _showAddMovieDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final genreController = TextEditingController();
    final urlController = TextEditingController();
    final durationController = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(Get.context!).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.add_circle_outline,
                      color: Theme.of(Get.context!).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'إضافة فيلم جديد',
                    style: Theme.of(Get.context!).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'عنوان الفيلم',
                  hintText: 'أدخل عنوان الفيلم',
                  prefixIcon: const Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'وصف الفيلم',
                  hintText: 'أدخل وصف الفيلم (اختياري)',
                  prefixIcon: const Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: genreController,
                decoration: InputDecoration(
                  labelText: 'النوع',
                  hintText: 'مثال: أكشن، كوميديا، دراما...',
                  prefixIcon: const Icon(Icons.category),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: urlController,
                decoration: InputDecoration(
                  labelText: 'رابط الفيلم',
                  hintText: 'أدخل رابط الفيلم',
                  prefixIcon: const Icon(Icons.link),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: durationController,
                decoration: InputDecoration(
                  labelText: 'المدة (بالثواني)',
                  hintText: 'أدخل مدة الفيلم بالثواني',
                  prefixIcon: const Icon(Icons.access_time),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('إلغاء'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: () async {
                      if (titleController.text.isEmpty || urlController.text.isEmpty) {
                        Get.snackbar('خطأ', 'العنوان والرابط مطلوبان');
                        return;
                      }

                      try {
                        final movieData = {
                          'title': titleController.text,
                          'description': descriptionController.text,
                          'genre': genreController.text,
                          'url': urlController.text,
                          'duration': int.tryParse(durationController.text),
                          'archived': false,
                        };

                        await _supabaseService.addMovie(movieData);
                        Get.back();
                        Get.snackbar(
                          'نجاح',
                          'تم إضافة الفيلم بنجاح',
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                        _loadMovies();
                      } catch (e) {
                        Get.snackbar(
                          'خطأ',
                          'فشل في إضافة الفيلم: $e',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة الفيلم'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditMovieDialog(Map<String, dynamic> movie) {
    final titleController = TextEditingController(text: movie['title']?.toString());
    final descriptionController = TextEditingController(text: movie['description']?.toString());
    final genreController = TextEditingController(text: movie['genre']?.toString());
    final urlController = TextEditingController(text: movie['url']?.toString());
    final durationController = TextEditingController(text: movie['duration']?.toString());

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(Get.context!).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.edit_outlined,
                      color: Theme.of(Get.context!).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'تعديل الفيلم',
                    style: Theme.of(Get.context!).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'عنوان الفيلم',
                  hintText: 'أدخل عنوان الفيلم',
                  prefixIcon: const Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'وصف الفيلم',
                  hintText: 'أدخل وصف الفيلم (اختياري)',
                  prefixIcon: const Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: genreController,
                decoration: InputDecoration(
                  labelText: 'النوع',
                  hintText: 'مثال: أكشن، كوميديا، دراما...',
                  prefixIcon: const Icon(Icons.category),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: urlController,
                decoration: InputDecoration(
                  labelText: 'رابط الفيلم',
                  hintText: 'أدخل رابط الفيلم',
                  prefixIcon: const Icon(Icons.link),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: durationController,
                decoration: InputDecoration(
                  labelText: 'المدة (بالثواني)',
                  hintText: 'أدخل مدة الفيلم بالثواني',
                  prefixIcon: const Icon(Icons.access_time),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('إلغاء'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: () async {
                      if (titleController.text.isEmpty || urlController.text.isEmpty) {
                        Get.snackbar('خطأ', 'العنوان والرابط مطلوبان');
                        return;
                      }

                      try {
                        final movieData = {
                          'title': titleController.text,
                          'description': descriptionController.text,
                          'genre': genreController.text,
                          'url': urlController.text,
                          'duration': int.tryParse(durationController.text),
                        };

                        await _supabaseService.updateMovie(movie['id'].toString(), movieData);
                        Get.back();
                        Get.snackbar(
                          'نجاح',
                          'تم تعديل الفيلم بنجاح',
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                        _loadMovies();
                      } catch (e) {
                        Get.snackbar(
                          'خطأ',
                          'فشل في تعديل الفيلم: $e',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('حفظ التغييرات'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> movie) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'تأكيد الحذف',
                      style: Theme.of(Get.context!).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'هل أنت متأكد من رغبتك في حذف هذا الفيلم؟',
                style: Theme.of(Get.context!).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(Get.context!).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(Get.context!).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.movie_outlined,
                      size: 20,
                      color: Theme.of(Get.context!).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        movie['title']?.toString() ?? 'بدون عنوان',
                        style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'هذا الإجراء لا يمكن التراجع عنه.',
                style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                  color: Theme.of(Get.context!).colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('إلغاء'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: () async {
                      try {
                        await _supabaseService.deleteMovie(movie['id'].toString());
                        Get.back();
                        Get.snackbar(
                          'نجاح',
                          'تم حذف الفيلم بنجاح',
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                        _loadMovies();
                      } catch (e) {
                        Get.snackbar(
                          'خطأ',
                          'فشل في حذف الفيلم: $e',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    icon: const Icon(Icons.delete),
                    label: const Text('حذف الفيلم'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الأفلام'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: _loadMovies,
            tooltip: 'تحديث القائمة',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'بحث في الأفلام',
                    hintText: 'اكتب عنوان الفيلم أو النوع...',
                    prefixIcon: const Icon(Icons.search_outlined),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterMovies('');
                            },
                          )
                        : null,
                  ),
                  onChanged: _filterMovies,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'عدد الأفلام: ${_filteredMovies.length}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    if (_searchQuery.isNotEmpty)
                      TextButton.icon(
                        onPressed: () {
                          _searchController.clear();
                          _filterMovies('');
                        },
                        icon: const Icon(Icons.clear_all, size: 16),
                        label: const Text('مسح البحث'),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Movies List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('جاري تحميل الأفلام...'),
                      ],
                    ),
                  )
                : _filteredMovies.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchQuery.isEmpty
                                  ? Icons.movie_outlined
                                  : Icons.search_off_outlined,
                              size: 64,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'لا توجد أفلام'
                                  : 'لا توجد نتائج للبحث',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'ابدأ بإضافة أفلام جديدة'
                                  : 'جرب كلمات بحث مختلفة',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredMovies.length,
                        itemBuilder: (context, index) {
                          final movie = _filteredMovies[index];
                          return _buildMovieCard(context, movie);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMovieDialog,
        icon: const Icon(Icons.add),
        label: const Text('إضافة فيلم'),
      ),
    );
  }

  Widget _buildMovieCard(BuildContext context, Map<String, dynamic> movie) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showMovieDetailsDialog(movie),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.movie_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie['title']?.toString() ?? 'بدون عنوان',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.category_outlined,
                              size: 16,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              movie['genre']?.toString() ?? 'بدون نوع',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (movie['duration'] != null) ...[
                              const SizedBox(width: 16),
                              Icon(
                                Icons.access_time_outlined,
                                size: 16,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${movie['duration']} ثانية',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _showEditMovieDialog(movie);
                          break;
                        case 'delete':
                          _showDeleteConfirmation(movie);
                          break;
                        case 'details':
                          _showMovieDetailsDialog(movie);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'details',
                        child: Row(
                          children: [
                            Icon(Icons.info_outline),
                            SizedBox(width: 8),
                            Text('التفاصيل'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined),
                            SizedBox(width: 8),
                            Text('تعديل'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.red),
                            SizedBox(width: 8),
                            Text('حذف', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (movie['description']?.toString().isNotEmpty ?? false) ...[
                const SizedBox(height: 12),
                Text(
                  movie['description']!.toString(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showMovieDetailsDialog(Map<String, dynamic> movie) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(Get.context!).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.movie_outlined,
                      color: Theme.of(Get.context!).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      movie['title']?.toString() ?? 'بدون عنوان',
                      style: Theme.of(Get.context!).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailRow('النوع', movie['genre']?.toString() ?? 'غير محدد'),
              _buildDetailRow('المدة', movie['duration'] != null ? '${movie['duration']} ثانية' : 'غير محدد'),
              _buildDetailRow('الرابط', movie['url']?.toString() ?? 'غير محدد'),
              if (movie['description']?.toString().isNotEmpty ?? false) ...[
                const SizedBox(height: 16),
                Text(
                  'الوصف',
                  style: Theme.of(Get.context!).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  movie['description']!.toString(),
                  style: Theme.of(Get.context!).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('إغلاق'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () {
                      Get.back();
                      _showEditMovieDialog(movie);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('تعديل'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(Get.context!).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: Theme.of(Get.context!).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
