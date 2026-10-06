import 'package:equatable/equatable.dart';

/// Application-level entity representing a photo asset on device.
/// Completely decouples the presentation layer from platform-specific types (AssetEntity).
class PhotoModel extends Equatable {
  final String id;
  final String? title;
  final int width;
  final int height;
  final DateTime createDateTime;
  final bool isFavorite;
  final String? mimeType;
  final int orientation;

  const PhotoModel({
    required this.id,
    this.title,
    required this.width,
    required this.height,
    required this.createDateTime,
    this.isFavorite = false,
    this.mimeType,
    this.orientation = 0,
  });

  PhotoModel copyWith({
    String? id,
    String? title,
    int? width,
    int? height,
    DateTime? createDateTime,
    bool? isFavorite,
    String? mimeType,
    int? orientation,
  }) {
    return PhotoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      width: width ?? this.width,
      height: height ?? this.height,
      createDateTime: createDateTime ?? this.createDateTime,
      isFavorite: isFavorite ?? this.isFavorite,
      mimeType: mimeType ?? this.mimeType,
      orientation: orientation ?? this.orientation,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    width,
    height,
    createDateTime,
    isFavorite,
    mimeType,
    orientation,
  ];
}
