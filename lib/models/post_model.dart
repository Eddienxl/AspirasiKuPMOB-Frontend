import 'user_model.dart';
import 'category_model.dart';
import '../utils/time_utils.dart';

class Post {
  final int id;
  final int idPenulis;
  final int idKategori;
  final String judul;
  final String konten;
  final bool anonim;
  final String status;
  final DateTime dibuatPada;
  final User? penulis;
  final CategoryModel? kategori;
  final int upvoteCount;
  final int downvoteCount;
  final int commentCount;
  final String? userInteraction; // 'upvote', 'downvote', or null

  Post({
    required this.id,
    required this.idPenulis,
    required this.idKategori,
    required this.judul,
    required this.konten,
    required this.anonim,
    required this.status,
    required this.dibuatPada,
    this.penulis,
    this.kategori,
    this.upvoteCount = 0,
    this.downvoteCount = 0,
    this.commentCount = 0,
    this.userInteraction,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? 0,
      idPenulis: json['id_penulis'] ?? 0,
      idKategori: json['id_kategori'] ?? 0,
      judul: json['judul'] ?? '',
      konten: json['konten'] ?? '',
      anonim: json['anonim'] ?? false,
      status: json['status'] ?? 'aktif',
      dibuatPada: DateTime.tryParse(json['dibuat_pada'] ?? '') ?? DateTime.now(),
      penulis: json['penulis'] != null ? User.fromJson(json['penulis']) : null,
      kategori: json['kategori'] != null ? CategoryModel.fromJson(json['kategori']) : null,
      upvoteCount: json['upvote_count'] ?? 0,
      downvoteCount: json['downvote_count'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
      userInteraction: json['user_interaction'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_penulis': idPenulis,
      'id_kategori': idKategori,
      'judul': judul,
      'konten': konten,
      'anonim': anonim,
      'status': status,
      'dibuat_pada': dibuatPada.toIso8601String(),
      'penulis': penulis?.toJson(),
      'kategori': kategori?.toJson(),
      'upvote_count': upvoteCount,
      'downvote_count': downvoteCount,
      'comment_count': commentCount,
      'user_interaction': userInteraction,
    };
  }

  Post copyWith({
    int? id,
    int? idPenulis,
    int? idKategori,
    String? judul,
    String? konten,
    bool? anonim,
    String? status,
    DateTime? dibuatPada,
    User? penulis,
    CategoryModel? kategori,
    int? upvoteCount,
    int? downvoteCount,
    int? commentCount,
    String? userInteraction,
  }) {
    return Post(
      id: id ?? this.id,
      idPenulis: idPenulis ?? this.idPenulis,
      idKategori: idKategori ?? this.idKategori,
      judul: judul ?? this.judul,
      konten: konten ?? this.konten,
      anonim: anonim ?? this.anonim,
      status: status ?? this.status,
      dibuatPada: dibuatPada ?? this.dibuatPada,
      penulis: penulis ?? this.penulis,
      kategori: kategori ?? this.kategori,
      upvoteCount: upvoteCount ?? this.upvoteCount,
      downvoteCount: downvoteCount ?? this.downvoteCount,
      commentCount: commentCount ?? this.commentCount,
      userInteraction: userInteraction ?? this.userInteraction,
    );
  }

  String get authorName {
    if (anonim) return 'Anonim';
    return penulis?.nama ?? 'Unknown';
  }

  String get categoryName {
    return kategori?.nama ?? 'Kategori Tidak Diketahui';
  }

  String get categoryEmoji {
    return kategori?.emoji ?? '📝';
  }

  String get categoryDisplay {
    return kategori?.displayName ?? '📝 Kategori Tidak Diketahui';
  }

  int get totalVotes => upvoteCount - downvoteCount;

  bool get isActive => status == 'aktif';
  bool get isArchived => status == 'terarsip';

  bool get hasUserUpvoted => userInteraction == 'upvote';
  bool get hasUserDownvoted => userInteraction == 'downvote';

  String get timeAgo => TimeUtils.timeAgo(dibuatPada);

  @override
  String toString() {
    return 'Post(id: $id, judul: $judul, penulis: ${penulis?.nama})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Post && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
