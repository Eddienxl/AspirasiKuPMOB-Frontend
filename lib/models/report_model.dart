import '../utils/time_utils.dart';
import 'post_model.dart';
import 'user_model.dart';

class Report {
  final int id;
  final int idPengguna;
  final int? idPostingan;
  final int? idKomentar;
  final String tipe;
  final String? alasanLaporan;
  final DateTime dibuatPada;
  final User? pelapor;
  final Post? postingan;

  Report({
    required this.id,
    required this.idPengguna,
    this.idPostingan,
    this.idKomentar,
    required this.tipe,
    this.alasanLaporan,
    required this.dibuatPada,
    this.pelapor,
    this.postingan,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    // Handle both 'pelapor' and 'pengguna' keys for reporter information
    User? reporter;
    if (json['pelapor'] != null) {
      reporter = User.fromJson(json['pelapor']);
    } else if (json['pengguna'] != null) {
      reporter = User.fromJson(json['pengguna']);
    }

    return Report(
      id: json['id'] ?? 0,
      idPengguna: json['id_pengguna'] ?? 0,
      idPostingan: json['id_postingan'],
      idKomentar: json['id_komentar'],
      tipe: json['tipe'] ?? '',
      alasanLaporan: json['alasan_laporan'],
      dibuatPada: TimeUtils.parseDateTime(json['dibuat_pada']) ?? DateTime.now(),
      pelapor: reporter,
      postingan: json['postingan'] != null ? Post.fromJson(json['postingan']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_pengguna': idPengguna,
      'id_postingan': idPostingan,
      'id_komentar': idKomentar,
      'tipe': tipe,
      'alasan_laporan': alasanLaporan,
      'dibuat_pada': dibuatPada.toIso8601String(),
      'pelapor': pelapor?.toJson(),
      'postingan': postingan?.toJson(),
    };
  }

  String get timeAgo => TimeUtils.timeAgo(dibuatPada);

  String get reportTypeDisplay {
    switch (alasanLaporan?.toLowerCase()) {
      case 'konten tidak pantas':
        return 'Konten Tidak Pantas';
      case 'spam':
        return 'Spam';
      case 'informasi palsu':
        return 'Informasi Palsu';
      case 'bahasa ofensif':
        return 'Bahasa Ofensif';
      case 'melanggar aturan komunitas':
        return 'Melanggar Aturan Komunitas';
      case 'lainnya':
        return 'Lainnya';
      default:
        return alasanLaporan ?? 'Tidak Diketahui';
    }
  }

  String get reporterName {
    // Always show actual username for admin panel, never show "Anonim"
    if (pelapor?.nama != null && pelapor!.nama.isNotEmpty) {
      return pelapor!.nama;
    }
    // If no reporter name available, show a more user-friendly message
    return 'Pengguna Tidak Dikenal';
  }
  String get postTitle => postingan?.judul ?? 'Postingan Tidak Ditemukan';

  @override
  String toString() {
    return 'Report(id: $id, tipe: $tipe, alasan: $alasanLaporan)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Report && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
