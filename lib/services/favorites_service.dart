import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:nashmi_tf/models/movie_model.dart';

class FavoritesService extends GetxController {
  static FavoritesService get instance => Get.find();
  
  final RxList<Movie> _favorites = <Movie>[].obs;
  final RxBool _isLoading = false.obs;
  
  List<Movie> get favorites => _favorites;
  bool get isLoading => _isLoading.value;
  
  @override
  void onInit() {
    super.onInit();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      _isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList('favorites') ?? [];
      
      _favorites.value = favoritesJson
          .map((json) => Movie.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      print('Error loading favorites: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = _favorites
          .map((movie) => jsonEncode(movie.toJson()))
          .toList();
      
      await prefs.setStringList('favorites', favoritesJson);
    } catch (e) {
      print('Error saving favorites: $e');
    }
  }

  bool isFavorite(String movieId) {
    return _favorites.any((movie) => movie.id == movieId);
  }

  Future<void> toggleFavorite(Movie movie) async {
    try {
      final index = _favorites.indexWhere((m) => m.id == movie.id);
      
      if (index >= 0) {
        // إزالة من المفضلة
        _favorites.removeAt(index);
        Get.snackbar(
          'تمت الإزالة',
          'تم إزالة "${movie.title}" من المفضلة',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          icon: const Icon(Icons.heart_broken, color: Colors.white),
          duration: const Duration(seconds: 2),
        );
      } else {
        // إضافة للمفضلة
        _favorites.add(movie);
        Get.snackbar(
          'تمت الإضافة',
          'تم إضافة "${movie.title}" للمفضلة',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.favorite, color: Colors.white),
          duration: const Duration(seconds: 2),
        );
      }
      
      await _saveFavorites();
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  Future<void> removeFavorite(String movieId) async {
    try {
      final index = _favorites.indexWhere((movie) => movie.id == movieId);
      if (index >= 0) {
        final movie = _favorites[index];
        _favorites.removeAt(index);
        await _saveFavorites();
        
        Get.snackbar(
          'تمت الإزالة',
          'تم إزالة "${movie.title}" من المفضلة',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error removing favorite: $e');
    }
  }

  Future<void> clearAllFavorites() async {
    try {
      _favorites.clear();
      await _saveFavorites();
      
      Get.snackbar(
        'تم الحذف',
        'تم حذف جميع العناصر من المفضلة',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error clearing favorites: $e');
    }
  }

  List<Movie> getFavoritesByCategory(String category) {
    if (category == 'all') return _favorites;
    return _favorites.where((movie) => movie.category == category).toList();
  }

  List<Movie> getFavoritesByType(String type) {
    if (type == 'all') return _favorites;
    return _favorites.where((movie) => movie.type == type).toList();
  }

  List<Movie> getTopRatedFavorites() {
    final sorted = List<Movie>.from(_favorites);
    sorted.sort((a, b) => b.rating!.compareTo(a.rating!));
    return sorted;
  }
}
