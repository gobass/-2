import 'package:cloud_firestore/cloud_firestore.dart';

class Episode {
  final String id;
  final String title;
  final String videoURL;
  final String? imageURL;
  final int episodeNumber;
  final String seriesId;
  final DateTime createdAt;
  final int? viewCount;
  final String? duration;

  Episode({
    required this.id,
    required this.title,
    required this.videoURL,
    this.imageURL,
    required this.episodeNumber,
    required this.seriesId,
    required this.createdAt,
    this.viewCount,
    this.duration,
  });

  factory Episode.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Episode(
      id: doc.id,
      title: data['title'] ?? '',
      videoURL: data['videoURL'] ?? '',
      imageURL: data['imageURL'],
      episodeNumber: data['episodeNumber'] ?? 0,
      seriesId: data['seriesId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      viewCount: data['viewCount'],
      duration: data['duration'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'videoURL': videoURL,
      'imageURL': imageURL,
      'episodeNumber': episodeNumber,
      'seriesId': seriesId,
      'createdAt': Timestamp.fromDate(createdAt),
      'viewCount': viewCount,
      'duration': duration,
    };
  }
}
