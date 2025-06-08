class TimeUtils {
  /// Mengkonversi DateTime menjadi string "waktu yang lalu" dalam bahasa Indonesia
  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years tahun yang lalu';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months bulan yang lalu';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inSeconds > 30) {
      return '${difference.inSeconds} detik yang lalu';
    } else {
      return 'Baru saja';
    }
  }

  /// Format tanggal untuk tampilan yang lebih detail
  static String formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays == 0) {
      // Hari ini
      return 'Hari ini ${_formatTime(dateTime)}';
    } else if (difference.inDays == 1) {
      // Kemarin
      return 'Kemarin ${_formatTime(dateTime)}';
    } else if (difference.inDays < 7) {
      // Minggu ini
      return '${_getDayName(dateTime.weekday)} ${_formatTime(dateTime)}';
    } else {
      // Tanggal lengkap
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${_formatTime(dateTime)}';
    }
  }

  static String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Senin';
      case 2:
        return 'Selasa';
      case 3:
        return 'Rabu';
      case 4:
        return 'Kamis';
      case 5:
        return 'Jumat';
      case 6:
        return 'Sabtu';
      case 7:
        return 'Minggu';
      default:
        return '';
    }
  }

  /// Parse string tanggal dengan berbagai format
  static DateTime? parseDateTime(dynamic value) {
    if (value == null) return null;
    
    try {
      if (value is DateTime) return value;
      if (value is String) {
        // Try different date formats
        if (value.contains('T')) {
          // ISO format
          return DateTime.parse(value);
        } else if (value.contains('-')) {
          // YYYY-MM-DD format
          return DateTime.parse(value);
        } else if (value.contains('/')) {
          // DD/MM/YYYY format
          final parts = value.split('/');
          if (parts.length == 3) {
            final day = int.parse(parts[0]);
            final month = int.parse(parts[1]);
            final year = int.parse(parts[2]);
            return DateTime(year, month, day);
          }
        }
      }
    } catch (e) {
      // Return current time if parsing fails
      return DateTime.now();
    }
    
    return DateTime.now();
  }
}
