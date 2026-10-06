import 'package:equatable/equatable.dart';

/// Supported gallery category types derived strictly from local device metadata/albums.
enum CategoryType { all, favorites, recent, screenshots, camera }

/// Domain entity representing a gallery category or album.
class CategoryModel extends Equatable {
  final String id;
  final String title;
  final CategoryType type;
  final int photoCount;
  final String? coverPhotoId;

  const CategoryModel({
    required this.id,
    required this.title,
    required this.type,
    this.photoCount = 0,
    this.coverPhotoId,
  });

  CategoryModel copyWith({
    String? id,
    String? title,
    CategoryType? type,
    int? photoCount,
    String? coverPhotoId,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      photoCount: photoCount ?? this.photoCount,
      coverPhotoId: coverPhotoId ?? this.coverPhotoId,
    );
  }

  @override
  List<Object?> get props => [id, title, type, photoCount, coverPhotoId];
}
