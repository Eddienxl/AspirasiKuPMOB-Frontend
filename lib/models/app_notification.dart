class AppNotification {
  final int id;
  final int idPenerima;
  final int? idPengirim;
  final int? idPostingan;
  final int? idKomentar;
  final String tipe;
  final String judul;
  final String pesan;
  final bool dibaca;
  final DateTime dibuatPada;
  final NotificationSender? pengirim;
  final NotificationPost? postingan;
  final NotificationComment? komentar;

  AppNotification({
    required this.id,
    required this.idPenerima,
    this.idPengirim,
    this.idPostingan,
    this.idKomentar,
    required this.tipe,
    required this.judul,
    required this.pesan,
    required this.dibaca,
    required this.dibuatPada,
    this.pengirim,
    this.postingan,
    this.komentar,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? 0,
      idPenerima: json['id_penerima'] ?? 0,
      idPengirim: json['id_pengirim'],
      idPostingan: json['id_postingan'],
      idKomentar: json['id_komentar'],
      tipe: json['tipe'] ?? '',
      judul: json['judul'] ?? '',
      pesan: json['pesan'] ?? '',
      dibaca: json['dibaca'] ?? false,
      dibuatPada: DateTime.parse(json['dibuat_pada'] ?? DateTime.now().toIso8601String()),
      pengirim: json['pengirim'] != null 
          ? NotificationSender.fromJson(json['pengirim'])
          : null,
      postingan: json['postingan'] != null 
          ? NotificationPost.fromJson(json['postingan'])
          : null,
      komentar: json['komentar'] != null 
          ? NotificationComment.fromJson(json['komentar'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_penerima': idPenerima,
      'id_pengirim': idPengirim,
      'id_postingan': idPostingan,
      'id_komentar': idKomentar,
      'tipe': tipe,
      'judul': judul,
      'pesan': pesan,
      'dibaca': dibaca,
      'dibuat_pada': dibuatPada.toIso8601String(),
      'pengirim': pengirim?.toJson(),
      'postingan': postingan?.toJson(),
      'komentar': komentar?.toJson(),
    };
  }

  // Helper methods
  bool get isUnread => !dibaca;
  
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(dibuatPada);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }

  String get typeDisplayName {
    switch (tipe) {
      case 'like':
        return 'Suka';
      case 'comment':
        return 'Komentar';
      case 'reply':
        return 'Balasan';
      case 'mention':
        return 'Sebutan';
      case 'system':
        return 'Sistem';
      default:
        return 'Notifikasi';
    }
  }
}

class NotificationSender {
  final int id;
  final String nama;
  final String email;

  NotificationSender({
    required this.id,
    required this.nama,
    required this.email,
  });

  factory NotificationSender.fromJson(Map<String, dynamic> json) {
    return NotificationSender(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
    };
  }
}

class NotificationPost {
  final int id;
  final String judul;

  NotificationPost({
    required this.id,
    required this.judul,
  });

  factory NotificationPost.fromJson(Map<String, dynamic> json) {
    return NotificationPost(
      id: json['id'] ?? 0,
      judul: json['judul'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
    };
  }
}

class NotificationComment {
  final int id;
  final String konten;

  NotificationComment({
    required this.id,
    required this.konten,
  });

  factory NotificationComment.fromJson(Map<String, dynamic> json) {
    return NotificationComment(
      id: json['id'] ?? 0,
      konten: json['konten'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'konten': konten,
    };
  }
}
