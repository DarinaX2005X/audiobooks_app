import 'package:hive/hive.dart';

part 'category.g.dart'; // Для генерации адаптера

@HiveType(typeId: 1) // Уникальный typeId (0 уже занят Book)
class Category {
  @HiveField(0)
  final String? id; // Делаем id необязательным
  @HiveField(1)
  final String name;

  Category({this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id']?.toString(),
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'name': name,
  };
}