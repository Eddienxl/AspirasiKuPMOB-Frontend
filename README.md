# 🎓 AspirasiKu - Platform Aspirasi Mahasiswa UIN Suska Riau

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-3.24.0-blue?style=for-the-badge&logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.5.0-blue?style=for-the-badge&logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/Node.js-18.x-green?style=for-the-badge&logo=node.js" alt="Node.js">
  <img src="https://img.shields.io/badge/PostgreSQL-15.x-blue?style=for-the-badge&logo=postgresql" alt="PostgreSQL">
  <img src="https://img.shields.io/badge/Material_Design-3.0-purple?style=for-the-badge&logo=material-design" alt="Material Design">
</div>

## 📋 **Project Overview**

**AspirasiKu** adalah platform digital yang dirancang khusus untuk mahasiswa UIN Suska Riau untuk menyampaikan aspirasi, pertanyaan, dan feedback kepada pihak universitas. Platform ini menyediakan ruang yang aman dan terstruktur bagi mahasiswa untuk berpartisipasi aktif dalam pengembangan kampus melalui sistem yang transparan dan responsif.

### 🎯 **Tujuan Platform**
- Memfasilitasi komunikasi dua arah antara mahasiswa dan pihak universitas
- Menyediakan sistem kategorisasi yang terorganisir untuk berbagai jenis aspirasi
- Memberikan tools moderasi untuk menjaga kualitas konten
- Menciptakan lingkungan yang mendukung partisipasi aktif mahasiswa

---

## ✨ **Features & Functionality**

### 🔐 **Authentication & User Management**
- **User Registration**: Sistem registrasi dengan validasi email dan data mahasiswa
- **Role-based Authentication**: Dua tipe user (Mahasiswa & Admin)
- **JWT Token Security**: Secure authentication dengan JSON Web Tokens
- **Profile Management**: Edit profil dengan upload avatar dan ubah password
- **Session Management**: Auto-logout dan session expiry handling

### 📝 **Content Management**
- **Post Creation**: Buat aspirasi dengan judul, konten, dan kategori
- **10 Kategori Terstruktur**:
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

### 💬 **Interactive Features**
- **Comment System**: Komentar dengan real-time updates
- **Voting System**: Upvote/downvote untuk postingan dengan toggle functionality
- **Report System**: Laporkan konten dengan kategori predefined
- **Category Filtering**: Filter postingan berdasarkan kategori
- **Sorting Options**: Urutkan berdasarkan terbaru atau popularitas
- **Real-time Notifications**: Notifikasi untuk upvote, downvote, dan komentar

### 🎛️ **Admin Panel (Admin Only)**
- **Content Moderation**: Arsipkan/aktifkan postingan
- **Report Management**: Review dan tindak lanjuti laporan dengan username reporter
- **User Analytics**: Statistik penggunaan platform
- **Post Management**: Kelola semua postingan dengan status indicators

### 🎨 **UI/UX Features**
- **Responsive Design**: Optimal di desktop, tablet, dan mobile
- **Modern Interface**: Material Design 3 dengan custom theme
- **Campus Background**: Background kampus UIN Suska dengan overlay
- **Smooth Animations**: Micro-interactions dan hover effects
- **Loading States**: Loading indicators dan error handling
- **Custom Color Scheme**: Green gradient theme sesuai identitas kampus

---

## 🛠️ **Technology Stack**

### **Frontend (Flutter Web)**
```
Flutter 3.24.0            - UI Framework
Dart 3.5.0               - Programming Language
Provider 6.x             - State Management
HTTP 1.x                 - HTTP Client
Google Fonts 6.x         - Typography
Material Design 3        - Design System
Timeago 3.x              - Time formatting
```

### **Backend**
```
Node.js 18.x              - Runtime Environment
Express.js 4.x            - Web Framework
Sequelize ORM 6.x         - Database ORM
JWT                       - Authentication
bcrypt                    - Password Hashing
PostgreSQL 15.x           - Database
```

### **Development Tools**
```
VS Code                   - IDE
Flutter DevTools          - Debugging
Chrome DevTools           - Web debugging
Git & GitHub              - Version Control
```

---

## 👥 **User Roles & Permissions**

### **👤 Mahasiswa (Regular User)**
```
✅ Create and edit own posts
✅ Comment on posts
✅ Vote on posts (upvote/downvote)
✅ Report inappropriate content
✅ Manage personal profile with avatar
✅ View real-time notifications
✅ Filter posts by category
✅ Navigate to post detail for commenting
❌ Access admin panel
❌ Moderate other users' content
```

### **👨‍💼 Admin (Administrator)**
```
✅ All regular user capabilities
✅ Access admin panel
✅ Moderate posts (archive/activate)
✅ Review and manage reports
✅ View reporter usernames
✅ Toggle post status with indicators
✅ Sort reports by newest first
✅ Monitor platform activities
```

---

## 🔌 **API Integration**

### **Authentication Endpoints**
```
POST /api/auth/register     - User registration
POST /api/auth/login        - User login
GET  /api/auth/profile      - Get current user profile
PUT  /api/auth/profile      - Update user profile
```

### **Post Management**
```
GET    /api/postingan       - Get all posts (with filtering)
POST   /api/postingan       - Create new post
GET    /api/postingan/:id   - Get specific post
PUT    /api/postingan/:id   - Update post
DELETE /api/postingan/:id   - Delete post
```

### **Interaction System**
```
POST /api/posts/:id/upvote    - Upvote post
POST /api/posts/:id/downvote  - Downvote post
POST /api/posts/:id/report    - Report post
GET  /api/posts/:id/comments  - Get post comments
POST /api/posts/:id/comments  - Add comment
```

### **Notification System**
```
GET /api/notifications        - Get user notifications
PUT /api/notifications/:id/read - Mark notification as read
PUT /api/notifications/read-all - Mark all as read
```

---

## 👨‍💻 **Contributors**

This project exists thanks to all the people who contributed:

<table>
  <tr>
    <td align="center">
      <strong>Ahmad Fadli Pratama</strong><br>
      <sub>Project Manager, Flutter Developer, UI/UX Designer</sub><br>
      <sub>Project management, mobile development, responsive design</sub>
    </td>
    <td align="center">
      <strong>Fadlan Amar Ma'ruf</strong><br>
      <sub>UI/UX Designer</sub><br>
      <sub>User interface design, user experience optimization</sub>
    </td>
    <td align="center">
      <strong>Wahyu Hidayat</strong><br>
      <sub>Backend Developer, Database Architect</sub><br>
      <sub>API development, database design</sub>
    </td>
  </tr>
</table>

---

<div align="center">
  <p><strong>Made with ❤️ for UIN Suska Riau Students</strong></p>
  <p>© 2024 AspirasiKu Platform. All rights reserved.</p>
  <p><em>Developed with Flutter for cross-platform excellence</em></p>
</div>
