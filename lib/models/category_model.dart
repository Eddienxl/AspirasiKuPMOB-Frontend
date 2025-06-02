class CategoryModel {
  final int id;
  final String nama;
  final String? emoji;

  CategoryModel({
    required this.id,
    required this.nama,
    this.emoji,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? '',
      emoji: json['emoji'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'emoji': emoji,
    };
  }

  CategoryModel copyWith({
    int? id,
    String? nama,
    String? emoji,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      emoji: emoji ?? this.emoji,
    );
  }

  String get displayName {
    if (emoji != null && emoji!.isNotEmpty) {
      return '$emoji $nama';
    }
    return nama;
  }

  @override
  String toString() {
    return 'CategoryModel(id: $id, nama: $nama, emoji: $emoji)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
