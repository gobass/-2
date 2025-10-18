import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nashmi_tf/models/category_model.dart';
import 'package:nashmi_tf/models/movie_model.dart';
import 'package:nashmi_tf/services/mock_data_service.dart';

class FirebaseService {
  // Firebase service for real-time data management
  static bool _isFirebaseEnabled = true; // تم تفعيل Firebase

  // Collection references
  static const String moviesCollection = 'movies';
  static const String categoriesCollection = 'categories';
  static const String adsCollection = 'ads';
  static const String seriesCollection = 'series';

  // Firebase instances - lazy initialization
  FirebaseFirestore? _firestore;
  FirebaseStorage? _storage;

  // Initialization flag
  bool _isInitialized = false;

  // Singleton pattern
  static FirebaseService? _instance;
  static FirebaseService get instance {
    _instance ??= FirebaseService._();
    return _instance!;
  }

  FirebaseService._() {
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    if (_isInitialized) return;

    try {
      // Check if Firebase is already initialized
      if (Firebase.apps.isEmpty) {
        print('Firebase not initialized, initializing...');
        await Firebase.initializeApp();
      }

      _firestore = FirebaseFirestore.instance;
      _storage = FirebaseStorage.instance;
      _isInitialized = true;
      print('✅ Firebase initialized successfully in FirebaseService');
    } catch (e) {
      print('❌ Firebase initialization failed in FirebaseService: $e');
      _firestore = null;
      _storage = null;
      _isInitialized = false;
    }
  }

  // Ensure Firebase is initialized before use
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await _initializeFirebase();
    }
  }

  // Safe getters for Firebase instances
  Future<FirebaseFirestore?> get firestore async {
    await _ensureInitialized();
    return _firestore;
  }

  Future<FirebaseStorage?> get storage async {
    await _ensureInitialized();
    return _storage;
  }

  // Check if Firebase is available
  Future<bool> get isFirebaseAvailable async {
    await _ensureInitialized();
    return _firestore != null && _storage != null;
  }

  // Movies Methods
  Future<List<Movie>> getMovies() async {
    final firestore = await this.firestore;
    if (firestore == null) {
      print('Firebase not available, using mock data');
      return MockDataService.getMockMovies();
    }

    try {
      final snapshot = await firestore.collection(moviesCollection)
          .where('isActive', isEqualTo: true)
          .where('archived', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList();
      }
    } catch (e) {
      print('Firebase error, using mock data: $e');
    }

    // Fallback to mock data
    return MockDataService.getMockMovies();
  }

  Future<List<Movie>> getMoviesByCategory(String categoryId) async {
    if (_firestore == null) {
      print('Firebase not available, using mock data');
      return MockDataService.getMoviesByCategory(categoryId);
    }

    try {
      final snapshot = await _firestore!.collection(moviesCollection)
          .where('categories', arrayContains: categoryId)
          .where('isActive', isEqualTo: true)
          .where('archived', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList();
      }
    } catch (e) {
      print('Firebase error, using mock data: $e');
    }

    return MockDataService.getMoviesByCategory(categoryId);
  }

  Future<List<Movie>> getMostViewedMovies() async {
    if (_firestore == null) {
      print('Firebase not available, using mock data');
      return MockDataService.getMostViewedMovies();
    }

    try {
      final snapshot = await _firestore!.collection(moviesCollection)
          .where('isActive', isEqualTo: true)
          .where('archived', isEqualTo: false)
          .orderBy('views', descending: true)
          .limit(10)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList();
      }
    } catch (e) {
      print('Firebase error, using mock data: $e');
    }

    return MockDataService.getMostViewedMovies();
  }

  Future<Movie?> getMovieById(String id) async {
    if (_firestore == null) {
      print('Firebase not available, using mock data');
      final movies = MockDataService.getMockMovies();
      try {
        return movies.firstWhere((movie) => movie.id == id);
      } catch (e) {
        return null;
      }
    }

    try {
      final doc = await _firestore!.collection(moviesCollection).doc(id).get();
      if (doc.exists) {
        return Movie.fromFirestore(doc);
      }
    } catch (e) {
      print('Firebase error getting movie: $e');
    }

    // Fallback to mock data
    final movies = MockDataService.getMockMovies();
    try {
      return movies.firstWhere((movie) => movie.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> incrementMovieViews(String movieId) async {
    if (_firestore == null) {
      print('Firebase not available, skipping view increment');
      return;
    }

    try {
      await _firestore!.collection(moviesCollection).doc(movieId).update({
        'views': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Firebase error incrementing views: $e');
    }
  }

  // Admin Methods
  Future<void> addMovie(Map<String, dynamic> movieData) async {
    if (_firestore == null) {
      print('Firebase not available, adding to mock data');
      // For web, we'll simulate adding to mock data
      // In a real app, this would be handled differently
      return;
    }

    try {
      await _firestore!.collection(moviesCollection).add({
        ...movieData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'views': 0,
        'archived': false,
      });
    } catch (e) {
      throw Exception('Failed to add movie: $e');
    }
  }

  Future<void> updateMovie(String movieId, Map<String, dynamic> movieData) async {
    if (_firestore == null) {
      print('Firebase not available, updating mock data');
      // For web, we'll simulate updating mock data
      return;
    }

    try {
      await _firestore!.collection(moviesCollection).doc(movieId).update({
        ...movieData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update movie: $e');
    }
  }

  Future<void> deleteMovie(String movieId) async {
    if (_firestore == null) {
      print('Firebase not available, deleting from mock data');
      // For web, we'll simulate deleting from mock data
      return;
    }

    try {
      await _firestore!.collection(moviesCollection).doc(movieId).delete();
    } catch (e) {
      throw Exception('Failed to delete movie: $e');
    }
  }

  // Categories Methods
  Future<List<Category>> getCategories() async {
    if (_firestore == null) {
      print('Firebase not available, using mock data');
      return MockDataService.getMockCategories();
    }

    try {
      final snapshot = await _firestore!.collection(categoriesCollection)
          .orderBy('name')
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList();
      }
    } catch (e) {
      print('Firebase error getting categories: $e');
    }

    return MockDataService.getMockCategories();
  }

  // Ads Methods
  Future<List<Map<String, dynamic>>> getActiveAds() async {
    if (_firestore == null) {
      print('Firebase not available, returning empty ads list');
      return [];
    }

    try {
      final now = DateTime.now();
      final snapshot = await _firestore!.collection(adsCollection)
          .where('isActive', isEqualTo: true)
          .where('startAt', isLessThanOrEqualTo: now)
          .where('endAt', isGreaterThanOrEqualTo: now)
          .get();

      return snapshot.docs.map((doc) => {
        ...doc.data(),
        'id': doc.id,
      }).toList();
    } catch (e) {
      print('Firebase error getting ads: $e');
      return [];
    }
  }

  // Series Methods
  Future<List<Map<String, dynamic>>> getSeries() async {
    if (_firestore == null) {
      print('Firebase not available, returning empty series list');
      return [];
    }

    try {
      final snapshot = await _firestore!.collection(seriesCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => {
        ...doc.data(),
        'id': doc.id,
      }).toList();
    } catch (e) {
      print('Firebase error getting series: $e');
      return [];
    }
  }

  // Real-time streams
  Stream<QuerySnapshot> watchMovies() {
    if (_firestore == null) {
      return Stream.empty();
    }

    return _firestore!.collection(moviesCollection)
        .where('isActive', isEqualTo: true)
        .where('archived', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> watchAds() {
    if (_firestore == null) {
      return Stream.empty();
    }

    return _firestore!.collection(adsCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> watchSeries() {
    if (_firestore == null) {
      return Stream.empty();
    }

    return _firestore!.collection(seriesCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Upload methods
  Future<String> uploadImage(String path, List<int> bytes) async {
    if (_storage == null) {
      throw Exception('Firebase storage not available');
    }

    try {
      final storageRef = _storage!.ref().child(path);
      final uploadTask = storageRef.putData(Uint8List.fromList(bytes));
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<String> uploadVideo(String path, List<int> bytes) async {
    if (_storage == null) {
      throw Exception('Firebase storage not available');
    }

    try {
      final storageRef = _storage!.ref().child(path);
      final uploadTask = storageRef.putData(Uint8List.fromList(bytes));
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload video: $e');
    }
  }

  // Episode Methods
  Future<void> addEpisode(Map<String, dynamic> episodeData) async {
    if (_firestore == null) {
      print('Firebase not available, adding episode to mock data');
      return;
    }

    try {
      await _firestore!.collection('episodes').add({
        ...episodeData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'views': 0,
      });
    } catch (e) {
      throw Exception('Failed to add episode: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getEpisodesBySeries(String seriesId) async {
    if (_firestore == null) {
      print('Firebase not available, returning empty episodes list');
      return [];
    }

    try {
      final snapshot = await _firestore!.collection('episodes')
          .where('seriesId', isEqualTo: seriesId)
          .orderBy('episodeNumber')
          .get();

      return snapshot.docs.map((doc) => {
        ...doc.data(),
        'id': doc.id,
      }).toList();
    } catch (e) {
      print('Firebase error getting episodes: $e');
      return [];
    }
  }

  Future<void> deleteEpisode(String episodeId) async {
    if (_firestore == null) {
      print('Firebase not available, deleting episode from mock data');
      return;
    }

    try {
      await _firestore!.collection('episodes').doc(episodeId).delete();
    } catch (e) {
      throw Exception('Failed to delete episode: $e');
    }
  }

  // Ads Management Methods
  Future<void> addAd(Map<String, dynamic> adData) async {
    if (_firestore == null) {
      print('Firebase not available, adding ad to mock data');
      return;
    }

    try {
      await _firestore!.collection(adsCollection).add({
        ...adData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add ad: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllAds() async {
    if (_firestore == null) {
      print('Firebase not available, returning empty ads list');
      return [];
    }

    try {
      final snapshot = await _firestore!.collection(adsCollection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => {
        ...doc.data(),
        'id': doc.id,
      }).toList();
    } catch (e) {
      print('Firebase error getting all ads: $e');
      return [];
    }
  }

  Future<void> updateAd(String adId, Map<String, dynamic> adData) async {
    if (_firestore == null) {
      print('Firebase not available, updating ad in mock data');
      return;
    }

    try {
      await _firestore!.collection(adsCollection).doc(adId).update({
        ...adData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update ad: $e');
    }
  }

  Future<void> deleteAd(String adId) async {
    if (_firestore == null) {
      print('Firebase not available, deleting ad from mock data');
      return;
    }

    try {
      await _firestore!.collection(adsCollection).doc(adId).delete();
    } catch (e) {
      throw Exception('Failed to delete ad: $e');
    }
  }
}
