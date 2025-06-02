class AppConstants {
  // API Configuration - Railway Production (Corrected URL)
  static const String baseUrl = 'https://platform.up.railway.app'; // Railway Production - Correct URL
  static const String fallbackUrl = 'http://localhost:5000'; // Local development fallback

  static const String apiUrl = '$baseUrl/api';
  static const String fallbackApiUrl = '$fallbackUrl/api';
  
  // API Endpoints
  static const String authEndpoint = '/auth';
  static const String postEndpoint = '/postingan';
  static const String commentEndpoint = '/komentar';
  static const String interactionEndpoint = '/interaksi';
  static const String userEndpoint = '/pengguna';
  static const String categoryEndpoint = '/kategori';
  static const String notificationEndpoint = '/notifikasi';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String draftKey = 'draft_post';
  
  // App Info
  static const String appName = 'AspirasiKu';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Platform Aspirasi Mahasiswa UIN Suska Riau';
  
  // Categories with Emojis
  static const Map<int, Map<String, String>> categories = {
    1: {'name': 'Fasilitas Kampus', 'emoji': '🏫'},
    2: {'name': 'Akademik', 'emoji': '📚'},
    3: {'name': 'Kesejahteraan Mahasiswa', 'emoji': '💝'},
    4: {'name': 'Kegiatan Kemahasiswaan', 'emoji': '🎭'},
    5: {'name': 'Sarana dan Prasarana Digital', 'emoji': '💻'},
    6: {'name': 'Keamanan dan Ketertiban', 'emoji': '🛡️'},
    7: {'name': 'Lingkungan dan Kebersihan', 'emoji': '🌱'},
    8: {'name': 'Transportasi dan Akses', 'emoji': '🚌'},
    9: {'name': 'Kebijakan dan Administrasi', 'emoji': '📋'},
    10: {'name': 'Saran dan Inovasi', 'emoji': '💡'},
  };
  
  // Get category name by ID
  static String getCategoryName(int categoryId) {
    return categories[categoryId]?['name'] ?? 'Kategori Tidak Diketahui';
  }
  
  // Get category emoji by ID
  static String getCategoryEmoji(int categoryId) {
    return categories[categoryId]?['emoji'] ?? '📝';
  }
  
  // Get full category display
  static String getCategoryDisplay(int categoryId) {
    final emoji = getCategoryEmoji(categoryId);
    final name = getCategoryName(categoryId);
    return '$emoji $name';
  }
  
  // User Roles
  static const String roleUser = 'pengguna';
  static const String roleReviewer = 'peninjau';

  // Secret Codes
  static const String reviewerSecretCode = 'peninjauaspirasiku';
  
  // Post Sort Options
  static const Map<String, String> sortOptions = {
    'terbaru': 'Terbaru',
    'populer': 'Populer',
    'terlama': 'Terlama',
  };
  
  // Interaction Types
  static const String upvote = 'upvote';
  static const String downvote = 'downvote';
  static const String report = 'lapor';
  
  // Report Status
  static const String statusActive = 'aktif';
  static const String statusIgnored = 'diabaikan';
  static const String statusResolved = 'diselesaikan';
  
  // Post Status
  static const String postActive = 'aktif';
  static const String postArchived = 'terarsip';
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxTitleLength = 100;
  static const int maxContentLength = 1000;
  static const int maxCommentLength = 500;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Network Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Pagination
  static const int postsPerPage = 10;
  static const int commentsPerPage = 20;
}
