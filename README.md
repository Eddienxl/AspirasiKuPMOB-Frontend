# 📱 AspirasiKu Flutter

Platform Aspirasi Mahasiswa UIN Suska Riau - Mobile Application

## 📋 Overview

**AspirasiKu Flutter** adalah aplikasi mobile yang dirancang khusus untuk mahasiswa UIN Suska Riau untuk menyampaikan aspirasi, pertanyaan, dan feedback kepada pihak universitas. Aplikasi ini menyediakan ruang yang aman dan terstruktur bagi mahasiswa untuk berpartisipasi aktif dalam pengembangan kampus melalui sistem yang transparan dan responsif.

### 🎯 Tujuan Aplikasi
- Memfasilitasi komunikasi dua arah antara mahasiswa dan pihak universitas
- Menyediakan sistem kategorisasi yang terorganisir untuk berbagai jenis aspirasi
- Memberikan tools moderasi untuk menjaga kualitas konten
- Menciptakan lingkungan yang mendukung partisipasi aktif mahasiswa

## ✨ Features & Functionality

### 🔐 **Authentication System**
- **Login/Register**: Sistem autentikasi dengan JWT token
- **Role-based Access**: Mahasiswa dan Peninjau dengan hak akses berbeda
- **Profile Management**: Upload foto profil, edit informasi personal
- **Password Management**: Ubah kata sandi dengan validasi

### 📝 **Post Management**
- **Create Posts**: Buat aspirasi dengan kategori dan opsi anonim
- **View Posts**: Lihat semua aspirasi dengan filtering dan sorting
- **Interaction System**: Upvote, downvote, dan komentar
- **Report System**: Laporkan konten yang tidak pantas

### 🏷️ **Category System**
- **10 Kategori Utama**:
  - 🏫 Fasilitas Kampus
  - 📚 Akademik
  - 💝 Kesejahteraan Mahasiswa
  - 🎭 Kegiatan Kemahasiswaan
  - 💻 Sarana dan Prasarana Digital
  - 🛡️ Keamanan dan Ketertiban
  - 🌱 Lingkungan dan Kebersihan
  - 🚌 Transportasi dan Akses
  - 📋 Kebijakan dan Administrasi
  - 💡 Saran dan Inovasi

### 👥 **User Roles**
- **Mahasiswa**: Dapat membuat, melihat, dan berinteraksi dengan aspirasi
- **Peninjau**: Memiliki akses admin untuk moderasi konten dan laporan

### 📱 **Mobile Features**
- **Responsive Design**: Optimized untuk semua ukuran layar mobile
- **Bottom Navigation**: Navigasi yang mudah diakses
- **Pull to Refresh**: Refresh konten dengan gesture
- **Offline Support**: Cache data untuk akses offline (coming soon)

## 🏗️ Architecture

### **Frontend (Flutter)**
```
lib/
├── main.dart                 # Entry point aplikasi
├── models/                   # Data models
│   ├── user_model.dart
│   ├── post_model.dart
│   └── category_model.dart
├── providers/                # State management (Provider)
│   ├── auth_provider.dart
│   ├── post_provider.dart
│   └── category_provider.dart
├── screens/                  # UI Screens
│   ├── splash_screen.dart
│   ├── home_screen.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── dashboard_screen.dart
│   ├── add_post_screen.dart
│   ├── post_detail_screen.dart
│   ├── profile_screen.dart
│   └── admin_panel_screen.dart
├── widgets/                  # Reusable UI components
│   ├── post_card.dart
│   ├── custom_text_field.dart
│   ├── loading_button.dart
│   ├── category_filter.dart
│   └── sort_dropdown.dart
├── services/                 # API services
│   ├── api_service.dart
│   └── auth_service.dart
└── utils/                    # Utilities
    ├── app_colors.dart
    └── constants.dart
```

### **Backend Integration**
- **API Base URL**: `http://localhost:5000/api` (Development)
- **Production URL**: `https://platform.up.railway.app/api`
- **Authentication**: JWT Bearer Token
- **HTTP Client**: Dart `http` package with custom API service

## 🚀 Getting Started

### **Prerequisites**
- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / VS Code
- Android device or emulator

### **Installation**

1. **Clone the repository**
```bash
git clone <repository-url>
cd AspirasiKuFlutter
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure API endpoint**
```dart
// lib/utils/constants.dart
static const String baseUrl = 'http://localhost:5000'; // Development
// static const String baseUrl = 'https://backend-platform.up.railway.app'; // Production
```

4. **Run the application**
```bash
flutter run
```

### **Build for Release**

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle:**
```bash
flutter build appbundle --release
```

## 🎨 UI/UX Design

### **Design System**
- **Color Scheme**: Green gradient theme (#22C55E to #10B981)
- **Typography**: Poppins font family
- **Components**: Material Design 3 with custom styling
- **Icons**: Material Icons with custom category emojis

### **User Experience**
- **Navigation Flow**: Splash → Home/Login → Dashboard → Detail screens
- **Interaction Patterns**: Tap, swipe, pull-to-refresh
- **Loading States**: Skeleton screens and progress indicators
- **Error Handling**: User-friendly error messages and retry options

## 📱 Screenshots

*Screenshots will be added here once the app is fully implemented*

## 🔧 Configuration

### **Environment Variables**
```dart
// lib/utils/constants.dart
class AppConstants {
  static const String baseUrl = 'http://localhost:5000';
  static const String apiUrl = '$baseUrl/api';
  // ... other constants
}
```

### **Dependencies**
- **State Management**: Provider
- **HTTP Client**: http, dio
- **UI Components**: Material Design
- **Image Handling**: image_picker, cached_network_image
- **Storage**: shared_preferences
- **Fonts**: google_fonts

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Run with coverage
flutter test --coverage
```

## 📦 Deployment

### **Android**
1. Build release APK/AAB
2. Upload to Google Play Console
3. Configure app signing and metadata

### **Backend Connection**
- Development: localhost:5000
- Production: Railway deployment auto-updates

## 👥 Contributors

- **Ahmad Fadli Pratama** - Project Manager/Frontend/UI-UX
- **Wahyu Hidayat** - Backend/Database
- **Syukri Ihsan** - Backend/Database  
- **Wan Muhammad Faaruq** - UI/UX Designer

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📞 Support

For support and questions:
- Email: support@aspirasiku.com
- GitHub Issues: [Create an issue](https://github.com/your-repo/issues)

---

**AspirasiKu Flutter - Empowering Student Voices at UIN Suska Riau** 🎓
