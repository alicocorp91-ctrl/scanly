import 'package:hive/hive.dart';

part 'document_model.g.dart';

@HiveType(typeId: 1)
class Document extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  final List<String> imagePaths; // Local file paths of scanned pages

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  DateTime updatedAt;

  @HiveField(5)
  String? folderId; // null = root / uncategorized

  @HiveField(6)
  int pageCount;

  @HiveField(7)
  String? thumbnailPath; // Path to first page thumbnail

  Document({
    required this.id,
    required this.name,
    required this.imagePaths,
    required this.createdAt,
    required this.updatedAt,
    this.folderId,
    this.pageCount = 1,
    this.thumbnailPath,
  });

  factory Document.create({
    required String name,
    required List<String> imagePaths,
    String? folderId,
    String? thumbnailPath,
  }) {
    final now = DateTime.now();
    return Document(
      id: DateTime.now().millisecondsSinceEpoch.toString() + '_' + DateTime.now().microsecond.toString(),
      name: name,
      imagePaths: imagePaths,
      createdAt: now,
      updatedAt: now,
      folderId: folderId,
      pageCount: imagePaths.length,
      thumbnailPath: thumbnailPath ?? (imagePaths.isNotEmpty ? imagePaths.first : null),
    );
  }

  Document copyWith({
    String? name,
    List<String>? imagePaths,
    String? folderId,
    int? pageCount,
    String? thumbnailPath,
  }) {
    return Document(
      id: id,
      name: name ?? this.name,
      imagePaths: imagePaths ?? this.imagePaths,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      folderId: folderId ?? this.folderId,
      pageCount: pageCount ?? this.pageCount,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    );
  }
}