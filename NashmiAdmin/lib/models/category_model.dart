class CategoryModel {
  final String id;
  final String name;
  final CategoryType type;
  final String? year;
  final String? season;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final int? sortOrder;

  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    this.year,
    this.season,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.sortOrder,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: CategoryType.fromString(json['type'] as String),
      year: json['year'] as String?,
      season: json['season'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: json['sort_order'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toStringValue(),
      'year': year,
      'season': season,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_active': isActive,
      'sort_order': sortOrder,
    };
  }

  String get displayName {
    switch (type) {
      case CategoryType.year:
        return year ?? name;
      case CategoryType.seasonal:
        return '$name ${year ?? DateTime.now().year}';
      case CategoryType.regular:
      default:
        return name;
    }
  }

  String get categoryKey {
    switch (type) {
      case CategoryType.year:
        return 'year_$year';
      case CategoryType.seasonal:
        return 'seasonal_${season}_${year ?? DateTime.now().year}';
      case CategoryType.regular:
      default:
        return 'regular_$name';
    }
  }

  @override
  String toString() => displayName;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum CategoryType {
  regular,
  year,
  seasonal;

  static CategoryType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'year':
        return CategoryType.year;
      case 'seasonal':
        return CategoryType.seasonal;
      case 'regular':
      default:
        return CategoryType.regular;
    }
  }

  String toStringValue() {
    switch (this) {
      case CategoryType.year:
        return 'year';
      case CategoryType.seasonal:
        return 'seasonal';
      case CategoryType.regular:
      default:
        return 'regular';
    }
  }

  String get displayName {
    switch (this) {
      case CategoryType.year:
        return 'سنة';
      case CategoryType.seasonal:
        return 'موسمي';
      case CategoryType.regular:
      default:
        return 'عادي';
    }
  }
}

// Helper class for category statistics
class CategoryStats {
  final CategoryModel category;
  final int contentCount;
  final int viewsCount;
  final double averageRating;

  CategoryStats({
    required this.category,
    required this.contentCount,
    required this.viewsCount,
    required this.averageRating,
  });

  factory CategoryStats.fromJson(Map<String, dynamic> json) {
    return CategoryStats(
      category: CategoryModel.fromJson(json['category']),
      contentCount: json['content_count'] as int? ?? 0,
      viewsCount: json['views_count'] as int? ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
