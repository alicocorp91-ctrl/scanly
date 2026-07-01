import 'package:hive/hive.dart';

part 'folder_model.g.dart';

@HiveType(typeId: 0)
class Folder extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  String? colorHex; // Optional folder color

  Folder({
    required this.id,
    required this.name,
    required this.createdAt,
    this.colorHex,
  });

  factory Folder.create({
    required String name,
    String? colorHex,
  }) {
    return Folder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      createdAt: DateTime.now(),
      colorHex: colorHex,
    );
  }

  Folder copyWith({
    String? name,
    String? colorHex,
  }) {
    return Folder(
      id: id,
      name: name ?? this.name,
      createdAt: createdAt,
      colorHex: colorHex ?? this.colorHex,
    );
  }
}