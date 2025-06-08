# 🚀 Railway Deployment Guide

## 📋 Langkah-langkah Deploy Backend ke Railway

### **Step 1: Persiapan File**

1. **Copy file yang sudah diperbaiki:**
   ```bash
   # Copy package.json yang Railway-compatible
   cp package-railway.json package.json
   
   # Copy server.js yang Railway-compatible  
   cp server-railway.js server.js
   ```

2. **Update Express.js version:**
   ```bash
   npm install express@4.19.2
   ```

### **Step 2: Environment Variables di Railway**

Set environment variables berikut di Railway dashboard:

```env
# Database (sudah ada)
DATABASE_URL=postgresql://postgres:OoRXHtpVwwfSFdGtCwqigJpPCEMcwyxf@mainline.proxy.rlwy.net:37764/railway

# JWT Secret
JWT_SECRET=your_super_secret_jwt_key_here_make_it_long_and_random

# Node Environment
NODE_ENV=production

# Port (Railway akan set otomatis)
PORT=5000
```

### **Step 3: Deploy ke Railway**

1. **Push ke GitHub:**
   ```bash
   git add .
   git commit -m "Fix Railway deployment - downgrade Express.js"
   git push origin main
   ```

2. **Deploy di Railway:**
   - Buka Railway dashboard
   - Redeploy service
   - Monitor logs untuk memastikan tidak ada error

### **Step 4: Test Deployment**

1. **Test health endpoint:**
   ```bash
   curl https://aspirasiku-backend-production.up.railway.app/health
   ```

2. **Test API endpoints:**
   ```bash
   # Test get posts
   curl https://aspirasiku-backend-production.up.railway.app/api/postingan
   
   # Test get categories
   curl https://aspirasiku-backend-production.up.railway.app/api/kategori
   ```

### **Step 5: Update Flutter App**

Flutter app sudah dikonfigurasi untuk menggunakan Railway URL:
- **Primary**: `https://aspirasiku-backend-production.up.railway.app`
- **Fallback**: `http://localhost:5000`

## 🔧 Troubleshooting

### **Jika masih ada error path-to-regexp:**

1. **Downgrade Express.js lebih jauh:**
   ```bash
   npm install express@4.18.2
   ```

2. **Clear npm cache:**
   ```bash
   npm cache clean --force
   ```

3. **Rebuild dependencies:**
   ```bash
   rm -rf node_modules package-lock.json
   npm install
   ```

### **Jika CORS error:**

Server sudah dikonfigurasi untuk allow semua origins di production.

### **Jika database connection error:**

Pastikan DATABASE_URL sudah benar di Railway environment variables.

## ✅ Expected Results

Setelah deploy berhasil:

1. **Backend**: `https://aspirasiku-backend-production.up.railway.app`
2. **Database**: Railway PostgreSQL (sudah connected)
3. **Flutter**: Otomatis connect ke Railway backend

## 🎯 Connection Flow Setelah Deploy

```
Flutter App (Mobile/Web)
    ↓
Railway Backend (Cloud)
    ↓  
Railway Database (Cloud)
```

**Semua akan berjalan di cloud!** 🌟
