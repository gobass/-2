import 'package:cloud_firestore/cloud_firestore.dart';

class Movie {
  final String id;
  final String title;
  final String description;
  final String category;
  final String imageURL;
  final String videoURL;
  final DateTime createdAt;
  final double? rating;
  final int? viewCount;
  final String? year;
  final String? duration;
  final String type; // 'movie' or 'series'
  final int? episodeCount; // For series
  final Map<String, String>? subtitles;
  final Map<String, String>? videoQualities;

  Movie({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.imageURL,
    required this.videoURL,
    required this.createdAt,
    this.type = 'movie',
    this.episodeCount,
    this.rating,
    this.viewCount,
    this.year,
    this.duration,
    this.subtitles,
    this.videoQualities,
  });

  factory Movie.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return Movie(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      imageURL: data['imageURL'] ?? '',
      videoURL: data['videoURL'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      type: data['type'] ?? 'movie',
      episodeCount: data['episodeCount'],
      rating: data['rating']?.toDouble(),
      viewCount: data['viewCount'],
      year: data['year'],
      duration: data['duration'],
      subtitles: data['subtitles'] != null ? Map<String, String>.from(data['subtitles']) : null,
      videoQualities: data['videoQualities'] != null 
          ? Map<String, String>.from(data['videoQualities']) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'imageURL': imageURL,
      'videoURL': videoURL,
      'createdAt': Timestamp.fromDate(createdAt),
      'type': type,
      'episodeCount': episodeCount,
      'rating': rating,
      'viewCount': viewCount,
      'year': year,
      'duration': duration,
      'subtitles': subtitles,
      'videoQualities': videoQualities,
    };
  }

  // For JSON serialization (for SharedPreferences)
  factory Movie.fromJson(Map<String, dynamic> json) {
    // Handle different field names from Supabase
    final imageUrl = json['imageURL'] ?? json['posterUrl'] ?? json['poster_url'] ?? '';
    final videoUrl = json['videoURL'] ?? json['videoUrl'] ?? json['video_url'] ?? '';
    final createdAt = json['createdAt'] ?? json['createdat'] ?? json['created_at'];

    return Movie(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? json['categories']?.toString() ?? '',
      imageURL: imageUrl,
      videoURL: videoUrl,
      createdAt: createdAt is String
          ? DateTime.tryParse(createdAt) ?? DateTime.now()
          : createdAt is int
              ? DateTime.fromMillisecondsSinceEpoch(createdAt)
              : DateTime.now(),
      type: json['type'] ?? json['isSeries'] == true ? 'series' : 'movie',
      episodeCount: json['episodeCount'],
      rating: json['rating']?.toDouble(),
      viewCount: json['viewCount'],
      year: json['year'],
      duration: json['duration'],
      subtitles: json['subtitles'] != null ? Map<String, String>.from(json['subtitles']) : null,
      videoQualities: json['videoQualities'] != null ? Map<String, String>.from(json['videoQualities']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'imageURL': imageURL,
      'videoURL': videoURL,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'type': type,
      'episodeCount': episodeCount,
      'rating': rating,
      'viewCount': viewCount,
      'year': year,
      'duration': duration,
      'subtitles': subtitles,
      'videoQualities': videoQualities,
    };
  }
}
