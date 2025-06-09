import '../utils/time_utils.dart';

class Comment {
  final int id;
  final int idPostingan;
  final int idUser;
  final String konten;
  final DateTime dibuatPada;
  final DateTime diperbaruiPada;
  final String authorName;
  final bool isAuthor; // True if comment author is the post author
  final String? authorRole; // Role of the comment author
  final String? profilePictureUrl; // Profile picture URL of the comment author

  Comment({
    required this.id,
    required this.idPostingan,
    required this.idUser,
    required this.konten,
    required this.dibuatPada,
    required this.diperbaruiPada,
    required this.authorName,
    this.isAuthor = false,
    this.authorRole,
    this.profilePictureUrl,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    // Handle nested penulis object from backend
    String authorName = 'Anonymous';
    String? authorRole;
    String? profilePictureUrl;

    if (json['penulis'] != null && json['penulis']['nama'] != null) {
      authorName = json['penulis']['nama'];
      authorRole = json['penulis']['peran']; // Get role from penulis object
      profilePictureUrl = json['penulis']['profile_picture']; // Get profile picture from penulis object
    } else if (json['author_name'] != null) {
      authorName = json['author_name'];
      authorRole = json['author_role']; // Get role from direct field
      profilePictureUrl = json['author_profile_picture']; // Get profile picture from direct field
    }

    return Comment(
      id: json['id'] ?? 0,
      idPostingan: json['id_postingan'] ?? 0,
      idUser: json['id_penulis'] ?? json['id_user'] ?? 0,
      konten: json['konten'] ?? '',
      dibuatPada: DateTime.tryParse(json['dibuat_pada'] ?? '') ?? DateTime.now(),
      diperbaruiPada: DateTime.tryParse(json['diperbarui_pada'] ?? json['dibuat_pada'] ?? '') ?? DateTime.now(),
      authorName: authorName,
      isAuthor: json['is_author'] ?? false,
      authorRole: authorRole,
      profilePictureUrl: profilePictureUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_postingan': idPostingan,
      'id_user': idUser,
      'konten': konten,
      'dibuat_pada': dibuatPada.toIso8601String(),
      'diperbarui_pada': diperbaruiPada.toIso8601String(),
      'author_name': authorName,
      'is_author': isAuthor,
    };
  }

  Comment copyWith({
    int? id,
    int? idPostingan,
    int? idUser,
    String? konten,
    DateTime? dibuatPada,
    DateTime? diperbaruiPada,
    String? authorName,
    bool? isAuthor,
    String? authorRole,
    String? profilePictureUrl,
  }) {
    return Comment(
      id: id ?? this.id,
      idPostingan: idPostingan ?? this.idPostingan,
      idUser: idUser ?? this.idUser,
      konten: konten ?? this.konten,
      dibuatPada: dibuatPada ?? this.dibuatPada,
      diperbaruiPada: diperbaruiPada ?? this.diperbaruiPada,
      authorName: authorName ?? this.authorName,
      isAuthor: isAuthor ?? this.isAuthor,
      authorRole: authorRole ?? this.authorRole,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
    );
  }

  String get timeAgo => TimeUtils.timeAgo(dibuatPada);

  @override
  String toString() {
    return 'Comment(id: $id, idPostingan: $idPostingan, konten: $konten, authorName: $authorName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Comment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
