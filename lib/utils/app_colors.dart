import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Green Theme
  static const Color primary = Color(0xFF22C55E); // green-500
  static const Color primaryDark = Color(0xFF16A34A); // green-600
  static const Color primaryLight = Color(0xFF4ADE80); // green-400
  
  // Secondary Colors - Emerald Theme
  static const Color secondary = Color(0xFF10B981); // emerald-500
  static const Color secondaryDark = Color(0xFF059669); // emerald-600
  static const Color secondaryLight = Color(0xFF34D399); // emerald-400
  
  // Background Colors
  static const Color background = Color(0xFFF8FAFC); // slate-50
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF1F5F9); // slate-100
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1E293B); // slate-800
  static const Color textSecondary = Color(0xFF64748B); // slate-500
  static const Color textTertiary = Color(0xFF94A3B8); // slate-400
  
  // Border Colors
  static const Color border = Color(0xFFE2E8F0); // slate-200
  static const Color borderLight = Color(0xFFF1F5F9); // slate-100
  
  // Status Colors
  static const Color success = Color(0xFF22C55E); // green-500
  static const Color warning = Color(0xFFF59E0B); // amber-500
  static const Color error = Color(0xFFEF4444); // red-500
  static const Color info = Color(0xFF3B82F6); // blue-500
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFF0FDF4), Color(0xFFECFDF5)], // green-50 to emerald-50
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Campus Background Overlay
  static const Color campusOverlay = Color(0x1A22C55E); // green with 10% opacity
  
  // Card Colors
  static const Color cardBackground = Colors.white;
  static const Color cardShadow = Color(0x0F000000); // black with 6% opacity
  
  // Interactive Colors
  static const Color hover = Color(0xFFF0FDF4); // green-50
  static const Color pressed = Color(0xFFDCFCE7); // green-100
  static const Color disabled = Color(0xFFF1F5F9); // slate-100
  
  // Category Colors
  static const Map<int, Color> categoryColors = {
    1: Color(0xFF3B82F6), // blue-500 - Fasilitas Kampus
    2: Color(0xFF8B5CF6), // violet-500 - Akademik
    3: Color(0xFFEC4899), // pink-500 - Kesejahteraan Mahasiswa
    4: Color(0xFFF59E0B), // amber-500 - Kegiatan Kemahasiswaan
    5: Color(0xFF06B6D4), // cyan-500 - Sarana dan Prasarana Digital
    6: Color(0xFFEF4444), // red-500 - Keamanan dan Ketertiban
    7: Color(0xFF22C55E), // green-500 - Lingkungan dan Kebersihan
    8: Color(0xFF84CC16), // lime-500 - Transportasi dan Akses
    9: Color(0xFF6366F1), // indigo-500 - Kebijakan dan Administrasi
    10: Color(0xFFF97316), // orange-500 - Saran dan Inovasi
  };
  
  // Get category color by ID
  static Color getCategoryColor(int categoryId) {
    return categoryColors[categoryId] ?? primary;
  }
}
