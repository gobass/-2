import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:nashmi_tf/models/movie_model.dart';
import 'package:nashmi_tf/models/episode_model.dart';
import 'package:nashmi_tf/services/supabase_service.dart';
import 'package:nashmi_tf/services/auth_service.dart';
import 'package:nashmi_tf/services/mock_data_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  SupabaseService? _supabaseService;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _videoUrlController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _episodeCountController = TextEditingController();

  // File upload variables
  PlatformFile? _selectedImageFile;
  PlatformFile? _selectedVideoFile;
  String? _uploadedImageUrl;
  String? _uploadedVideoUrl;

  // Episode variables
  final TextEditingController _episodeTitleController = TextEditingController();
  final TextEditingController _episodeNumberController = TextEditingController();
  PlatformFile? _selectedEpisodeVideoFile;
  String? _uploadedEpisodeVideoUrl;
  List<Map<String, dynamic>> _episodes = [];
  String? _selectedSeriesId;

  // Ads variables
  final TextEditingController _adTitleController = TextEditingController();
  final TextEditingController _adDescriptionController = TextEditingController();
  final TextEditingController _adUrlController = TextEditingController();
  PlatformFile? _selectedAdImageFile;
  String? _uploadedAdImageUrl;
  DateTime _adStartDate = DateTime.now();
  DateTime _adEndDate = DateTime.now().add(const Duration(days: 30));
  List<Map<String, dynamic>> _ads = [];

  String _selectedType = 'movie';
  String _selectedCategory = 'action';
  double _rating = 4.0;

  bool _isLoading = false;
  List<Movie> _movies = [];
  List<Movie> _series = [];

  @override
  void initState() {
    super.initState();
    // Try to get SupabaseService, but don't fail if it's not available (e.g., web)
    try {
      _supabaseService = Get.find<SupabaseService>();
    } catch (e) {
      _supabaseService = null;
      print('SupabaseService not available, using mock data for admin screen');
    }
    _loadMovies();
    _loadSeries();
    _loadAds();
  }

  void _loadMovies() async {
    setState(() => _isLoading = true);

    try {
      if (_supabaseService != null) {
        final moviesData = await _supabaseService!.getMovies(limit: 50);
        final movies = moviesData.map((data) => Movie(
          id: data['id']?.toString() ?? '',
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          imageURL: data['posterUrl'] ?? '',
          videoURL: data['videoUrl'] ?? '',
          category: (data['categories'] as List?)?.first ?? '',
          type: (data['isSeries'] ?? false) ? 'series' : 'movie',
          viewCount: data['views'] ?? 0,
          rating: (data['rating'] ?? 0).toDouble(),
          year: data['year'] ?? '',
          duration: data['duration'] ?? '',
          episodeCount: data['episodeCount'],
          createdAt: data['createdAt'] != null
            ? DateTime.parse(data['createdAt'])
            : DateTime.now(),
        )).where((m) => m.type == 'movie').toList();

        setState(() {
          _movies = movies;
          _isLoading = false;
        });
      } else {
        // Fallback to mock data for web
        final mockMovies = MockDataService.getMockMovies().where((m) => m.type == 'movie').toList();
        setState(() {
          _movies = mockMovies;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _movies = [];
        _isLoading = false;
      });
    }
  }

  void _loadSeries() async {
    try {
      if (_supabaseService != null) {
        final seriesData = await _supabaseService!.getSeries(limit: 50);
        final series = seriesData.map((data) => Movie(
          id: data['id']?.toString() ?? '',
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          imageURL: data['posterUrl'] ?? '',
          videoURL: data['videoUrl'] ?? '',
          category: (data['categories'] as List?)?.first ?? '',
          type: 'series',
          viewCount: data['views'] ?? 0,
          rating: (data['rating'] ?? 0).toDouble(),
          year: data['year'] ?? '',
          duration: data['duration'] ?? '',
          episodeCount: data['episodeCount'],
          createdAt: data['createdAt'] != null
            ? DateTime.parse(data['createdAt'])
            : DateTime.now(),
        )).toList();

        setState(() {
          _series = series;
        });
      } else {
        // Fallback to mock data for web
        final mockSeries = MockDataService.getMockMovies().where((m) => m.type == 'series').toList();
        setState(() {
          _series = mockSeries;
        });
      }
    } catch (e) {
      setState(() {
        _series = [];
      });
    }
  }

  void _loadAds() async {
    try {
      if (_supabaseService != null) {
        final ads = await _supabaseService!.getAllAds();
        setState(() {
          _ads = ads;
        });
      } else {
        // Fallback to empty list for web
        setState(() {
          _ads = [];
        });
      }
    } catch (e) {
      setState(() {
        _ads = [];
      });
    }
  }

  void _addMovie() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if files are selected but not uploaded
    if ((_selectedImageFile != null && _uploadedImageUrl == null) ||
        (_selectedVideoFile != null && _uploadedVideoUrl == null)) {
      Get.snackbar(
        'تحذير',
        'يرجى رفع الملفات المختارة أولاً',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_supabaseService != null) {
        final movie = Movie(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text,
          description: _descriptionController.text,
          imageURL: _uploadedImageUrl ?? _imageUrlController.text,
          videoURL: _uploadedVideoUrl ?? _videoUrlController.text,
          category: _selectedCategory,
          type: _selectedType,
          viewCount: 0,
          rating: _rating,
          year: _yearController.text,
          duration: _durationController.text,
          episodeCount: _selectedType == 'series' ? int.tryParse(_episodeCountController.text) : null,
          createdAt: DateTime.now(),
        );

        await _supabaseService!.addMovie(movie.toMap());

        _clearForm();
        _loadMovies();

        Get.snackbar(
          'نجح',
          'تم إضافة ${_selectedType == 'movie' ? 'الفيلم' : 'المسلسل'} بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        // For web, just show success message without actually saving
        Get.snackbar(
          'نجح',
          'تم إضافة ${_selectedType == 'movie' ? 'الفيلم' : 'المسلسل'} بنجاح (محاكاة للويب)',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        _clearForm();
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في إضافة المحتوى: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

    setState(() => _isLoading = false);
  }

  void _deleteMovie(String movieId) async {
    try {
      if (_supabaseService != null) {
        await _supabaseService!.deleteMovie(movieId);
        _loadMovies();

        Get.snackbar(
          'تم الحذف',
          'تم حذف العنصر بنجاح',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        // For web, just show success message
        Get.snackbar(
          'تم الحذف',
          'تم حذف العنصر بنجاح (محاكاة للويب)',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في الحذف: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _imageUrlController.clear();
    _videoUrlController.clear();
    _yearController.clear();
    _durationController.clear();
    _episodeCountController.clear();
    setState(() {
      _selectedType = 'movie';
      _selectedCategory = 'action';
      _rating = 4.0;
      _selectedImageFile = null;
      _selectedVideoFile = null;
      _uploadedImageUrl = null;
      _uploadedVideoUrl = null;
    });
  }

  // File picking methods
  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        _selectedImageFile = result.files.first;
      });
    }
  }

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        _selectedVideoFile = result.files.first;
      });
    }
  }

  Future<void> _uploadFiles() async {
    if (_supabaseService == null) {
      Get.snackbar('خطأ', 'رفع الملفات غير متاح في الوضع الحالي', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (_selectedImageFile != null && _selectedImageFile!.bytes != null) {
      try {
        final path = 'images/${DateTime.now().millisecondsSinceEpoch}_${_selectedImageFile!.name}';
        _uploadedImageUrl = await _supabaseService!.uploadImage(path, _selectedImageFile!.bytes!);
        _imageUrlController.text = _uploadedImageUrl!;
      } catch (e) {
        Get.snackbar('خطأ', 'فشل في رفع الصورة: $e', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } else if (_selectedImageFile != null) {
      Get.snackbar('خطأ', 'فشل في قراءة ملف الصورة', backgroundColor: Colors.red, colorText: Colors.white);
    }

    if (_selectedVideoFile != null && _selectedVideoFile!.bytes != null) {
      try {
        final path = 'videos/${DateTime.now().millisecondsSinceEpoch}_${_selectedVideoFile!.name}';
        _uploadedVideoUrl = await _supabaseService!.uploadVideo(path, _selectedVideoFile!.bytes!);
        _videoUrlController.text = _uploadedVideoUrl!;
      } catch (e) {
        Get.snackbar('خطأ', 'فشل في رفع الفيديو: $e', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } else if (_selectedVideoFile != null) {
      Get.snackbar('خطأ', 'فشل في قراءة ملف الفيديو', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // Episode methods
  void _addEpisode() async {
    if (_selectedSeriesId == null || _episodeTitleController.text.isEmpty || _episodeNumberController.text.isEmpty) {
      Get.snackbar('خطأ', 'يرجى ملء جميع الحقول', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_supabaseService != null) {
        if (_selectedEpisodeVideoFile != null) {
          final path = 'episodes/${DateTime.now().millisecondsSinceEpoch}_${_selectedEpisodeVideoFile!.name}';
          _uploadedEpisodeVideoUrl = await _supabaseService!.uploadVideo(path, _selectedEpisodeVideoFile!.bytes!);
        }

        final episodeData = {
          'title': _episodeTitleController.text,
          'videoURL': _uploadedEpisodeVideoUrl ?? '',
          'episodeNumber': int.parse(_episodeNumberController.text),
          'seriesId': _selectedSeriesId!,
          'createdAt': DateTime.now(),
        };

        await _supabaseService!.addEpisode(episodeData);

        _clearEpisodeForm();
        Get.snackbar('نجح', 'تم إضافة الحلقة بنجاح', backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        // For web, just show success message
        _clearEpisodeForm();
        Get.snackbar('نجح', 'تم إضافة الحلقة بنجاح (محاكاة للويب)', backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في إضافة الحلقة: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }

    setState(() => _isLoading = false);
  }

  void _clearEpisodeForm() {
    _episodeTitleController.clear();
    _episodeNumberController.clear();
    setState(() {
      _selectedEpisodeVideoFile = null;
      _uploadedEpisodeVideoUrl = null;
    });
  }

  Future<void> _pickEpisodeVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        _selectedEpisodeVideoFile = result.files.first;
      });
    }
  }

  // Ads methods
  void _addAd() async {
    if (_adTitleController.text.isEmpty || _adDescriptionController.text.isEmpty) {
      Get.snackbar('خطأ', 'يرجى ملء العنوان والوصف', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_supabaseService != null) {
        if (_selectedAdImageFile != null) {
          final path = 'ads/${DateTime.now().millisecondsSinceEpoch}_${_selectedAdImageFile!.name}';
          _uploadedAdImageUrl = await _supabaseService!.uploadImage(path, _selectedAdImageFile!.bytes!);
        }

        final adData = {
          'title': _adTitleController.text,
          'description': _adDescriptionController.text,
          'imageURL': _uploadedAdImageUrl ?? '',
          'url': _adUrlController.text,
          'startAt': _adStartDate,
          'endAt': _adEndDate,
          'isActive': true,
          'createdAt': DateTime.now(),
        };

        await _supabaseService!.addAd(adData);

        _clearAdForm();
        _loadAds();
        Get.snackbar('نجح', 'تم إضافة الإعلان بنجاح', backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        // For web, just show success message
        _clearAdForm();
        Get.snackbar('نجح', 'تم إضافة الإعلان بنجاح (محاكاة للويب)', backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في إضافة الإعلان: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }

    setState(() => _isLoading = false);
  }

  void _clearAdForm() {
    _adTitleController.clear();
    _adDescriptionController.clear();
    _adUrlController.clear();
    setState(() {
      _selectedAdImageFile = null;
      _uploadedAdImageUrl = null;
      _adStartDate = DateTime.now();
      _adEndDate = DateTime.now().add(const Duration(days: 30));
    });
  }

  Future<void> _pickAdImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        _selectedAdImageFile = result.files.first;
      });
    }
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
          'لوحة التحكم',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadMovies,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () async {
              final result = await Get.dialog<bool>(
                AlertDialog(
                  backgroundColor: Colors.grey[800],
                  title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.white)),
                  content: const Text(
                    'هل أنت متأكد من تسجيل الخروج؟',
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
                      child: const Text('تسجيل الخروج'),
                    ),
                  ],
                ),
              );

              if (result == true) {
                await Get.find<AuthService>().logout();
                Get.back(); // العودة للصفحة الرئيسية
                Get.snackbar(
                  'تم تسجيل الخروج',
                  'تم تسجيل خروجك بنجاح',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
              }
            },
          ),
        ],
      ),
      body: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            Container(
              color: Colors.grey[900],
              child: const TabBar(
                labelColor: Colors.red,
                unselectedLabelColor: Colors.white,
                indicatorColor: Colors.red,
                tabs: [
                  Tab(
                    icon: Icon(Icons.add),
                    text: 'إضافة محتوى',
                  ),
                  Tab(
                    icon: Icon(Icons.list),
                    text: 'إدارة المحتوى',
                  ),
                  Tab(
                    icon: Icon(Icons.tv),
                    text: 'الحلقات',
                  ),
                  Tab(
                    icon: Icon(Icons.ad_units),
                    text: 'الإعلانات',
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildAddContentTab(),
                  _buildManageContentTab(),
                  _buildEpisodesTab(),
                  _buildAdsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddContentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // نوع المحتوى
            const Text(
              'نوع المحتوى',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedType,
                  dropdownColor: Colors.grey[800],
                  style: const TextStyle(color: Colors.white),
                  items: const [
                    DropdownMenuItem(value: 'movie', child: Text('فيلم')),
                    DropdownMenuItem(value: 'series', child: Text('مسلسل')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedType = value!);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // العنوان
            _buildTextField(_titleController, 'العنوان', isRequired: true),
            const SizedBox(height: 16),

            // الوصف
            _buildTextField(_descriptionController, 'الوصف', maxLines: 3, isRequired: true),
            const SizedBox(height: 16),

            // رفع الصورة
            const Text(
              'صورة المحتوى',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image, color: Colors.white),
              label: Text(
                _selectedImageFile != null ? _selectedImageFile!.name : 'اختر صورة',
                style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
            const SizedBox(height: 16),

            // رفع الفيديو
            const Text(
              'فيديو المحتوى',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _pickVideo,
              icon: const Icon(Icons.video_file, color: Colors.white),
              label: Text(
                _selectedVideoFile != null ? _selectedVideoFile!.name : 'اختر فيديو',
                style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
            const SizedBox(height: 16),

            // زر رفع الملفات
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_selectedImageFile != null || _selectedVideoFile != null) ? _uploadFiles : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'رفع الملفات المختارة',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // الفئة
            const Text(
              'الفئة',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  dropdownColor: Colors.grey[800],
                  style: const TextStyle(color: Colors.white),
                  items: const [
                    DropdownMenuItem(value: 'action', child: Text('أكشن')),
                    DropdownMenuItem(value: 'comedy', child: Text('كوميديا')),
                    DropdownMenuItem(value: 'drama', child: Text('دراما')),
                    DropdownMenuItem(value: 'horror', child: Text('رعب')),
                    DropdownMenuItem(value: 'romance', child: Text('رومانسية')),
                    DropdownMenuItem(value: 'scifi', child: Text('خيال علمي')),
                    DropdownMenuItem(value: 'thriller', child: Text('إثارة')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedCategory = value!);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // السنة والمدة في صف واحد
            Row(
              children: [
                Expanded(child: _buildTextField(_yearController, 'السنة', isRequired: true)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField(_durationController, 'المدة', isRequired: true)),
              ],
            ),
            const SizedBox(height: 16),

            // عدد الحلقات للمسلسلات فقط
            if (_selectedType == 'series') ...[
              _buildTextField(_episodeCountController, 'عدد الحلقات', keyboardType: TextInputType.number),
              const SizedBox(height: 16),
            ],

            // التقييم
            const Text(
              'التقييم',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _rating,
              min: 1.0,
              max: 5.0,
              divisions: 40,
              label: _rating.toStringAsFixed(1),
              activeColor: Colors.red,
              onChanged: (value) {
                setState(() => _rating = value);
              },
            ),
            Text(
              'التقييم: ${_rating.toStringAsFixed(1)}/5',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),

            // زر الإضافة
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addMovie,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'إضافة ${_selectedType == 'movie' ? 'الفيلم' : 'المسلسل'}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManageContentTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.red),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _movies.length,
      itemBuilder: (context, index) {
        final movie = _movies[index];
        return Card(
          color: Colors.grey[900],
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                movie.imageURL,
                width: 60,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 80,
                    color: Colors.grey[700],
                    child: const Icon(Icons.error, color: Colors.white),
                  );
                },
              ),
            ),
            title: Text(
              movie.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'نوع: ${movie.type == 'movie' ? 'فيلم' : 'مسلسل'} | فئة: ${movie.category}',
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  'تقييم: ${movie.rating}/5 | مشاهدات: ${movie.viewCount}',
                  style: const TextStyle(color: Colors.grey),
                ),
                if (movie.type == 'series' && movie.episodeCount != null)
                  Text(
                    'الحلقات: ${movie.episodeCount}',
                    style: const TextStyle(color: Colors.grey),
                  ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.grey[800],
                    title: const Text('تأكيد الحذف', style: TextStyle(color: Colors.white)),
                    content: Text(
                      'هل أنت متأكد من حذف "${movie.title}"؟',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Get.back();
                          _deleteMovie(movie.id);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('حذف'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label + (isRequired ? ' *' : ''),
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'أدخل $label',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.grey[800],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
          validator: isRequired
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'هذا الحقل مطلوب';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildEpisodesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إدارة حلقات المسلسلات',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // اختيار المسلسل
          const Text(
            'اختر المسلسل',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedSeriesId,
                dropdownColor: Colors.grey[800],
                style: const TextStyle(color: Colors.white),
                hint: const Text('اختر مسلسل', style: TextStyle(color: Colors.grey)),
                items: _series.map((series) {
                  return DropdownMenuItem<String>(
                    value: series.id,
                    child: Text(series.title),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedSeriesId = value);
                  if (value != null) {
                    _loadEpisodes(value);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // إضافة حلقة جديدة
          const Text(
            'إضافة حلقة جديدة',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildTextField(_episodeTitleController, 'عنوان الحلقة', isRequired: true),
          const SizedBox(height: 16),

          _buildTextField(_episodeNumberController, 'رقم الحلقة', keyboardType: TextInputType.number, isRequired: true),
          const SizedBox(height: 16),

          // رفع فيديو الحلقة
          const Text(
            'فيديو الحلقة',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _pickEpisodeVideo,
            icon: const Icon(Icons.video_file, color: Colors.white),
            label: Text(
              _selectedEpisodeVideoFile != null ? _selectedEpisodeVideoFile!.name : 'اختر فيديو',
              style: const TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800],
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _addEpisode,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'إضافة الحلقة',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
          const SizedBox(height: 24),

          // قائمة الحلقات
          const Text(
            'الحلقات',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          if (_episodes.isEmpty)
            const Center(
              child: Text(
                'لا توجد حلقات لهذا المسلسل',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _episodes.length,
              itemBuilder: (context, index) {
                final episode = _episodes[index];
                return Card(
                  color: Colors.grey[900],
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(
                      'الحلقة ${episode['episodeNumber']}: ${episode['title']}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      'المشاهدات: ${episode['viewCount'] ?? 0}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Colors.grey[800],
                            title: const Text('تأكيد الحذف', style: TextStyle(color: Colors.white)),
                            content: Text(
                              'هل أنت متأكد من حذف "${episode['title']}"؟',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Get.back();
                                  _deleteEpisode(episode['id']);
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                child: const Text('حذف'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAdsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إدارة الإعلانات',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // إضافة إعلان جديد
          const Text(
            'إضافة إعلان جديد',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildTextField(_adTitleController, 'عنوان الإعلان', isRequired: true),
          const SizedBox(height: 16),

          _buildTextField(_adDescriptionController, 'وصف الإعلان', maxLines: 2, isRequired: true),
          const SizedBox(height: 16),

          _buildTextField(_adUrlController, 'رابط الإعلان (اختياري)'),
          const SizedBox(height: 16),

          // رفع صورة الإعلان
          const Text(
            'صورة الإعلان',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _pickAdImage,
            icon: const Icon(Icons.image, color: Colors.white),
            label: Text(
              _selectedAdImageFile != null ? _selectedAdImageFile!.name : 'اختر صورة',
              style: const TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800],
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          ),
          const SizedBox(height: 16),

          // تواريخ البداية والنهاية
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'تاريخ البداية',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _adStartDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() => _adStartDate = date);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        '${_adStartDate.day}/${_adStartDate.month}/${_adStartDate.year}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'تاريخ النهاية',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _adEndDate,
                          firstDate: _adStartDate,
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() => _adEndDate = date);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        '${_adEndDate.day}/${_adEndDate.month}/${_adEndDate.year}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _addAd,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'إضافة الإعلان',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
          const SizedBox(height: 24),

          // قائمة الإعلانات
          const Text(
            'الإعلانات',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          if (_ads.isEmpty)
            const Center(
              child: Text(
                'لا توجد إعلانات',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _ads.length,
              itemBuilder: (context, index) {
                final ad = _ads[index];
                return Card(
                  color: Colors.grey[900],
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: ad['imageURL'] != null && ad['imageURL'].isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              ad['imageURL'],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey[700],
                                  child: const Icon(Icons.error, color: Colors.white),
                                );
                              },
                            ),
                          )
                        : Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey[700],
                            child: const Icon(Icons.ad_units, color: Colors.white),
                          ),
                    title: Text(
                      ad['title'] ?? '',
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ad['description'] ?? '',
                          style: const TextStyle(color: Colors.grey),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'من ${ad['startAt']?.toDate()?.day ?? ''}/${ad['startAt']?.toDate()?.month ?? ''} إلى ${ad['endAt']?.toDate()?.day ?? ''}/${ad['endAt']?.toDate()?.month ?? ''}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Colors.grey[800],
                            title: const Text('تأكيد الحذف', style: TextStyle(color: Colors.white)),
                            content: Text(
                              'هل أنت متأكد من حذف "${ad['title']}"؟',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Get.back();
                                  _deleteAd(ad['id']);
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                child: const Text('حذف'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void _loadEpisodes(String seriesId) async {
    try {
      if (_supabaseService != null) {
        final episodes = await _supabaseService!.getEpisodesBySeries(seriesId);
        setState(() {
          _episodes = episodes;
        });
      } else {
        // Fallback to empty list for web
        setState(() {
          _episodes = [];
        });
      }
    } catch (e) {
      setState(() {
        _episodes = [];
      });
    }
  }

  void _deleteEpisode(String episodeId) async {
    try {
      if (_supabaseService != null) {
        await _supabaseService!.deleteEpisode(episodeId);
        if (_selectedSeriesId != null) {
          _loadEpisodes(_selectedSeriesId!);
        }
        Get.snackbar('تم الحذف', 'تم حذف الحلقة بنجاح', backgroundColor: Colors.orange, colorText: Colors.white);
      } else {
        // For web, just show success message
        Get.snackbar('تم الحذف', 'تم حذف الحلقة بنجاح (محاكاة للويب)', backgroundColor: Colors.orange, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في حذف الحلقة: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _deleteAd(String adId) async {
    try {
      if (_supabaseService != null) {
        await _supabaseService!.deleteAd(adId);
        _loadAds();
        Get.snackbar('تم الحذف', 'تم حذف الإعلان بنجاح', backgroundColor: Colors.orange, colorText: Colors.white);
      } else {
        // For web, just show success message
        Get.snackbar('تم الحذف', 'تم حذف الإعلان بنجاح (محاكاة للويب)', backgroundColor: Colors.orange, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في حذف الإعلان: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _videoUrlController.dispose();
    _yearController.dispose();
    _durationController.dispose();
    _episodeCountController.dispose();
    _episodeTitleController.dispose();
    _episodeNumberController.dispose();
    _adTitleController.dispose();
    _adDescriptionController.dispose();
    _adUrlController.dispose();
    super.dispose();
  }
}
