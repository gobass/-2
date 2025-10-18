import 'package:nashmi_tf/models/category_model.dart';
import 'package:nashmi_tf/models/movie_model.dart';

class MockDataService {
  // Static list to store added movies temporarily
  static List<Movie> _addedMovies = [];
  static List<Movie> getMockMovies() {
    final baseMovies = [
      Movie(
        id: '1',
        title: 'الفيلم الأسود',
        description: 'فيلم إثارة وتشويق مليء بالأحداث المشوقة والمثيرة التي تأخذك في رحلة لا تُنسى.',
        imageURL: 'https://picsum.photos/300/400?random=1',
        videoURL: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        category: 'action',
        type: 'movie',
        viewCount: 1250,
        rating: 4.5,
        year: '2023',
        duration: '2ساعة 15د',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Movie(
        id: '2',
        title: 'رحلة إلى المجهول',
        description: 'مغامرة خيال علمي تأخذك إلى عوالم لم تراها من قبل مع قصة مثيرة وشخصيات لا تُنسى.',
        imageURL: 'https://picsum.photos/300/400?random=2',
        videoURL: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        category: 'scifi',
        type: 'movie',
        viewCount: 980,
        rating: 4.8,
        year: '2023',
        duration: '1ساعة 45د',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Movie(
        id: '3',
        title: 'الحب الأبدي',
        description: 'قصة رومانسية تحكي عن حب عظيم يتحدى كل الصعوبات والعقبات في سبيل البقاء.',
        imageURL: 'https://picsum.photos/300/400?random=3',
        videoURL: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        category: 'romance',
        type: 'movie',
        viewCount: 756,
        rating: 4.2,
        year: '2022',
        duration: '1ساعة 30د',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Movie(
        id: '4',
        title: 'الضحكة الذهبية',
        description: 'كوميديا مرحة تملأ قلبك بالفرح والسعادة مع شخصيات مضحكة ومواقف طريفة.',
        imageURL: 'https://picsum.photos/300/400?random=4',
        videoURL: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        category: 'comedy',
        type: 'movie',
        viewCount: 1890,
        rating: 4.6,
        year: '2023',
        duration: '1ساعة 20د',
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      Movie(
        id: '5',
        title: 'أسرار الماضي',
        description: 'دراما تاريخية تحكي أحداث مؤثرة من الماضي وتأثيرها على الحاضر بطريقة مشوقة.',
        imageURL: 'https://picsum.photos/300/400?random=5',
        videoURL: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        category: 'drama',
        type: 'movie',
        viewCount: 1120,
        rating: 4.4,
        year: '2023',
        duration: '2ساعة 30د',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Movie(
        id: '6',
        title: 'الوحش المخيف',
        description: 'فيلم رعب مثير يجعلك تعيش لحظات من التشويق والإثارة التي لن تنساها أبداً.',
        imageURL: 'https://picsum.photos/300/400?random=6',
        videoURL: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        category: 'horror',
        type: 'movie',
        viewCount: 654,
        rating: 3.9,
        year: '2023',
        duration: '1ساعة 40د',
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
      ),
      
      // مسلسلات
      Movie(
        id: '7',
        title: 'مسلسل الملوك',
        description: 'مسلسل تاريخي درامي يحكي قصة الملوك والحروب في العصور القديمة بأسلوب مثير ومشوق.',
        imageURL: 'https://picsum.photos/300/400?random=7',
        videoURL: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        category: 'drama',
        type: 'series',
        episodeCount: 24,
        viewCount: 2100,
        rating: 4.8,
        year: '2023',
        duration: '45د/الحلقة',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Movie(
        id: '8',
        title: 'أسرار المدينة',
        description: 'مسلسل إثارة وتشويق يكشف أسرار مدينة غامضة وأحداث مثيرة لا تتوقعها.',
        imageURL: 'https://picsum.photos/300/400?random=8',
        videoURL: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        category: 'thriller',
        type: 'series',
        episodeCount: 16,
        viewCount: 1890,
        rating: 4.6,
        year: '2023',
        duration: '50د/الحلقة',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Movie(
        id: '9',
        title: 'عائلة السعادة',
        description: 'مسلسل كوميدي عائلي يحكي قصة عائلة مرحة وأحداثها اليومية المليئة بالضحك والمرح.',
        imageURL: 'https://picsum.photos/300/400?random=9',
        videoURL: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        category: 'comedy',
        type: 'series',
        episodeCount: 30,
        viewCount: 1650,
        rating: 4.4,
        year: '2023',
        duration: '30د/الحلقة',
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      
      // المزيد من الأفلام
      Movie(
        id: '10',
        title: 'البطل الشجاع',
        description: 'فيلم أكشن مليء بالمغامرات والقتال والشجاعة في معركة البقاء.',
        imageURL: 'https://picsum.photos/300/400?random=10',
        videoURL: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        category: 'action',
        type: 'movie',
        viewCount: 2800,
        rating: 4.7,
        year: '2024',
        duration: '2ساعة 5د',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Movie(
        id: '11',
        title: 'الحب الأبدي',
        description: 'قصة حب رومانسية جميلة تحكي عن الحب الحقيقي والتضحية من أجل المحبوب.',
        imageURL: 'https://picsum.photos/300/400?random=11',
        videoURL: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        category: 'romance',
        type: 'movie',
        viewCount: 1750,
        rating: 4.3,
        year: '2024',
        duration: '1ساعة 55د',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Movie(
        id: '12',
        title: 'المستقبل المجهول',
        description: 'فيلم خيال علمي يأخذك إلى المستقبل البعيد مع تقنيات متطورة ومغامرات لا تصدق.',
        imageURL: 'https://picsum.photos/300/400?random=12',
        videoURL: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        category: 'scifi',
        type: 'movie',
        viewCount: 2250,
        rating: 4.6,
        year: '2024',
        duration: '2ساعة 20د',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
    return baseMovies;
  }

  static List<Category> getMockCategories() {
    return [
      Category(
        id: 'action',
        name: 'أكشن',
        description: 'أفلام الإثارة والأكشن',
        imageURL: 'https://picsum.photos/200/150?random=10',
        createdAt: DateTime.now(),
      ),
      Category(
        id: 'comedy',
        name: 'كوميديا',
        description: 'أفلام مضحكة ومسلية',
        imageURL: 'https://picsum.photos/200/150?random=11',
        createdAt: DateTime.now(),
      ),
      Category(
        id: 'drama',
        name: 'دراما',
        description: 'أفلام درامية مؤثرة',
        imageURL: 'https://picsum.photos/200/150?random=12',
        createdAt: DateTime.now(),
      ),
      Category(
        id: 'horror',
        name: 'رعب',
        description: 'أفلام الرعب والتشويق',
        imageURL: 'https://picsum.photos/200/150?random=13',
        createdAt: DateTime.now(),
      ),
      Category(
        id: 'romance',
        name: 'رومانسية',
        description: 'أفلام رومانسية',
        imageURL: 'https://picsum.photos/200/150?random=14',
        createdAt: DateTime.now(),
      ),
      Category(
        id: 'scifi',
        name: 'خيال علمي',
        description: 'أفلام الخيال العلمي',
        imageURL: 'https://picsum.photos/200/150?random=15',
        createdAt: DateTime.now(),
      ),
      Category(
        id: 'thriller',
        name: 'إثارة',
        description: 'أفلام الإثارة والتشويق',
        imageURL: 'https://picsum.photos/200/150?random=16',
        createdAt: DateTime.now(),
      ),
    ];
  }

  static List<Movie> getMostViewedMovies() {
    final movies = getMockMovies();
    movies.sort((a, b) => b.viewCount!.compareTo(a.viewCount!));
    return movies.take(4).toList();
  }

  static List<Movie> getLatestMovies() {
    final movies = getMockMovies();
    movies.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return movies.take(5).toList();
  }

  static List<Movie> getMoviesByCategory(String categoryId) {
    return getMockMovies().where((movie) => movie.category == categoryId).toList();
  }

  // الأفلام المميزة
  static List<Movie> getFeaturedMovies() {
    final movies = getMockMovies();
    return movies.where((movie) => movie.rating! >= 4.5).toList();
  }

  // أفلام فقط (بدون مسلسلات)
  static List<Movie> getMoviesOnly() {
    return getMockMovies().where((movie) => movie.type == 'movie').toList();
  }

  // مسلسلات فقط
  static List<Movie> getSeriesOnly() {
    return getMockMovies().where((movie) => movie.type == 'series').toList();
  }

  // الأفلام الأكثر تقييماً
  static List<Movie> getTopRatedMovies() {
    final movies = getMockMovies();
    movies.sort((a, b) => b.rating!.compareTo(a.rating!));
    return movies.take(4).toList();
  }

  // الأفلام الحديثة (آخر شهر)
  static List<Movie> getRecentMovies() {
    final movies = getMockMovies();
    final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
    return movies.where((movie) => movie.createdAt.isAfter(cutoffDate)).toList();
  }

  // أفلام الأكشن المميزة
  static List<Movie> getActionMovies() {
    return getMockMovies().where((movie) => 
      movie.category == 'action' && movie.rating! >= 4.0).toList();
  }

  // المسلسلات الكوميدية
  static List<Movie> getComedySeries() {
    return getMockMovies().where((movie) => 
      movie.type == 'series' && movie.category == 'comedy').toList();
  }

  // أفلام الرعب المثيرة
  static List<Movie> getHorrorMovies() {
    return getMockMovies().where((movie) => 
      movie.category == 'horror' && movie.type == 'movie').toList();
  }

  // الأفلام الرومانسية
  static List<Movie> getRomanceMovies() {
    return getMockMovies().where((movie) => movie.category == 'romance').toList();
  }

  // أفلام الخيال العلمي
  static List<Movie> getSciFiMovies() {
    return getMockMovies().where((movie) => movie.category == 'scifi').toList();
  }

  // المسلسلات الدرامية
  static List<Movie> getDramaSeries() {
    return getMockMovies().where((movie) => 
      movie.type == 'series' && movie.category == 'drama').toList();
  }

  // الأفلام قصيرة المدة (أقل من ساعتين)
  static List<Movie> getShortMovies() {
    return getMockMovies().where((movie) => 
      movie.type == 'movie' && movie.duration != null && 
      (movie.duration!.contains('1ساعة') || movie.duration!.contains('90د'))).toList();
  }

  // أقسام جديدة
  
  // الأفلام الكلاسيكية (2022 وأقدم)
  static List<Movie> getClassicMovies() {
    return getMockMovies().where((movie) => 
      movie.type == 'movie' && movie.year != null && int.parse(movie.year!) <= 2022).toList();
  }

  // الأفلام الحديثة (2023 وأحدث)
  static List<Movie> getNewMovies() {
    return getMockMovies().where((movie) => 
      movie.type == 'movie' && movie.year != null && int.parse(movie.year!) >= 2023).toList();
  }

  // المسلسلات الطويلة (أكثر من 20 حلقة)
  static List<Movie> getLongSeries() {
    return getMockMovies().where((movie) => 
      movie.type == 'series' && movie.episodeCount != null && movie.episodeCount! > 20).toList();
  }

  // المسلسلات القصيرة (أقل من 20 حلقة)
  static List<Movie> getShortSeries() {
    return getMockMovies().where((movie) => 
      movie.type == 'series' && movie.episodeCount != null && movie.episodeCount! <= 20).toList();
  }

  // الأعمال المقترحة (rating أكبر من 4.5)
  static List<Movie> getRecommendedMovies() {
    return getMockMovies().where((movie) => movie.rating! > 4.5).toList();
  }

  // الأفلام المميزة للعائلة (كوميديا ورومانسية)
  static List<Movie> getFamilyFriendlyMovies() {
    return getMockMovies().where((movie) => 
      movie.category == 'comedy' || movie.category == 'romance').toList();
  }

  // أفلام الإثارة والتشويق
  static List<Movie> getThrillerMovies() {
    return getMockMovies().where((movie) => 
      movie.category == 'thriller' || movie.category == 'horror').toList();
  }

  // أفلام ومسلسلات عالية الجودة (rating أكبر من 4.3)
  static List<Movie> getHighQualityContent() {
    return getMockMovies().where((movie) => movie.rating! > 4.3).toList();
  }

  // المحتوى الشائع (viewCount أكبر من 1500)
  static List<Movie> getTrendingContent() {
    return getMockMovies().where((movie) => movie.viewCount! > 1500).toList();
  }

  // الأعمال الحديثة (آخر أسبوع)
  static List<Movie> getThisWeekMovies() {
    final cutoffDate = DateTime.now().subtract(const Duration(days: 7));
    return getMockMovies().where((movie) => movie.createdAt.isAfter(cutoffDate)).toList();
  }
}
