# 📁 **PANDUAN PENEMPATAN ASSETS - AspirasiKu Flutter**

## 🎯 **Lokasi Penempatan Assets**

### **📂 Struktur Folder Assets**
```
assets/
├── images/
│   ├── aspirasikulogo.png        # Logo aplikasi AspirasiKu
│   └── background.jpg            # Background kampus
├── icons/
│   └── (custom icons jika ada)
└── fonts/
    └── (custom fonts jika ada)
```

## 🖼️ **Spesifikasi Gambar yang Dibutuhkan**

### **1. Logo AspirasiKu (`aspirasikulogo.png`)**
- **Ukuran**: 512x512px (minimum)
- **Format**: PNG dengan background transparan
- **Penggunaan**: Header aplikasi, login screen, dashboard
- **Lokasi**: `assets/images/aspirasikulogo.png`

### **2. Background Kampus (`background.jpg`)**
- **Ukuran**: 1920x1080px (minimum)
- **Format**: JPG atau PNG
- **Kualitas**: High resolution untuk berbagai ukuran layar
- **Penggunaan**: Background semua screen dengan overlay hijau
- **Lokasi**: `assets/images/background.jpg`

## 🔧 **Cara Menambahkan Assets**

### **Langkah 1: Letakkan File**
1. Buka folder `assets/images/` di project Flutter
2. Copy file gambar ke folder tersebut
3. Pastikan nama file sesuai dengan yang tertera di atas

### **Langkah 2: Verifikasi pubspec.yaml**
File `pubspec.yaml` sudah dikonfigurasi untuk assets:
```yaml
flutter:
  assets:
    - assets/images/
    - assets/icons/
    - assets/images/logo_uin.png
    - assets/images/campus_background.jpg
    - assets/images/aspirasikulogo.png
```

### **Langkah 3: Restart Aplikasi**
Setelah menambahkan assets baru:
```bash
flutter clean
flutter pub get
flutter run
```

## 🎨 **Implementasi dalam Kode**

### **Background Kampus**
```dart
// Menggunakan CampusBackground widget
CampusBackground(
  showOverlay: true,
  overlayOpacity: 0.15,
  child: YourContent(),
)

// Atau menggunakan CampusBackgroundScaffold
CampusBackgroundScaffold(
  body: YourBody(),
  showOverlay: true,
  overlayOpacity: 0.1,
)
```

### **Logo UIN**
```dart
// Menggunakan AppLogo widget
AppLogo(
  size: 40,
  showText: true,
  showShadow: true,
)
```

### **Logo AspirasiKu**
```dart
// Menggunakan AspirasiKuLogo widget
AspirasiKuLogo(
  size: 80,
  showShadow: true,
)
```

## 🔄 **Fallback System**

Jika gambar tidak ditemukan, aplikasi akan menggunakan:
- **Logo**: Icon default dengan gradient hijau
- **Background**: Gradient hijau solid
- **Avatar**: Icon person default

## 📱 **Responsive Design**

Assets akan otomatis menyesuaikan dengan:
- Berbagai ukuran layar (phone, tablet)
- Orientasi portrait dan landscape
- Density pixel yang berbeda

## ⚠️ **Catatan Penting**

1. **Ukuran File**: Pastikan ukuran file tidak terlalu besar (< 2MB per file)
2. **Format**: Gunakan PNG untuk logo, JPG untuk background
3. **Kualitas**: Gunakan gambar berkualitas tinggi untuk hasil terbaik
4. **Nama File**: Jangan ubah nama file yang sudah ditentukan
5. **Restart**: Selalu restart aplikasi setelah menambah assets baru

## 🎯 **Hasil Akhir**

Setelah assets ditambahkan, aplikasi akan memiliki:
- ✅ Background kampus di semua screen
- ✅ Logo UIN di header dan dashboard
- ✅ Logo AspirasiKu di login screen
- ✅ Overlay hijau yang konsisten
- ✅ Glass card effect yang modern
- ✅ Visual yang sama dengan versi web

## 🆘 **Troubleshooting**

### **Gambar Tidak Muncul**
1. Periksa nama file dan lokasi
2. Restart aplikasi dengan `flutter clean`
3. Pastikan format file benar (PNG/JPG)

### **Kualitas Gambar Buruk**
1. Gunakan gambar dengan resolusi tinggi
2. Periksa compression ratio
3. Gunakan format yang tepat

### **Aplikasi Lambat**
1. Kompres gambar jika terlalu besar
2. Gunakan format JPG untuk background
3. Optimasi ukuran file
