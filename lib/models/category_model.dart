import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String id;
  final String name;
  final String? icon;
  final String? description;
  final String? imageURL;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    this.icon,
    this.description,
    this.imageURL,
    required this.createdAt,
  });

  factory Category.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Category(
      id: doc.id,
      name: data['name'] ?? '',
      icon: data['icon'],
      description: data['description'],
      imageURL: data['imageURL'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
      'description': description,
      'imageURL': imageURL,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
