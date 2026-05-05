# 📋 Survey Produk

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Version](https://img.shields.io/badge/version-1.0.0+1-green?style=for-the-badge)

**Aplikasi Surveyor Distribusi Produk** — Dibangun menggunakan **Flutter**.

---

## ✅ Prasyarat

Pastikan perangkat pengembangan Anda telah terinstal:

| Tools | Versi Minimum |
|-------|--------------|
| [Flutter SDK](https://docs.flutter.dev/get-started/install) | >= 3.0.0 |
| [Dart SDK](https://dart.dev/get-dart) | >= 3.0.0 |
| [Android Studio](https://developer.android.com/studio) / [VS Code](https://code.visualstudio.com/) | Terbaru |
| [Git](https://git-scm.com/) | Terbaru |

Verifikasi instalasi Flutter:

```bash
flutter doctor
```

Pastikan semua komponen menampilkan tanda ✅ sebelum melanjutkan.

---

## 📦 Instalasi & Menjalankan Project

### 1. Clone Repository

```bash
git clone https://github.com/ghendraw/survey_app.git
cd survey_app
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Persiapkan Folder Assets

Pastikan folder berikut tersedia di root project:

```bash
mkdir -p assets/images
```

### 4. Jalankan Aplikasi

```bash
# Cek perangkat yang tersedia
flutter devices

# Jalankan aplikasi
flutter run
```

Untuk menjalankan di platform tertentu:

```bash
# Android
flutter run -d android

# iOS (hanya di macOS)
flutter run -d ios
```

---

## 🔧 Build Aplikasi

### Build APK (Android)

```bash
# Debug
flutter build apk --debug

# Release
flutter build apk --release
```

File APK tersimpan di:
```
build/app/outputs/flutter-apk/app-release.apk
```

### Build App Bundle (Android — untuk Google Play)

```bash
flutter build appbundle --release
```

### Build IPA (iOS — hanya di macOS)

```bash
flutter build ios --release
```

---

## 📁 Struktur Project

```
survey_app/
├── android/                  # Konfigurasi native Android
├── ios/                      # Konfigurasi native iOS
├── lib/
│   ├── main.dart             # Entry point aplikasi
│   ├──core/
│        ├──constants/        # Constant variable
│        ├──theme/            # Tema warna
│        ├──utils/            # Utility
│   ├── data/                 
│        ├──database/         # Database
│        ├──models/           # Model
│        ├──repositories/     # Repositories CRUD
│   ├── features/             # Halaman / UI
│   ├── widgets/              # Widget reusable
├── pubspec.yaml              # Konfigurasi dependencies
└── README.md
```

---

## 📚 Dependencies

### 🗄️ Database & Persistence

| Package | Versi | Kegunaan |
|---------|-------|----------|
| [`sqflite`](https://pub.dev/packages/sqflite) | ^2.3.0 | Database SQLite lokal |
| [`shared_preferences`](https://pub.dev/packages/shared_preferences) | ^2.2.2 | Penyimpanan data key-value sederhana |
| [`path_provider`](https://pub.dev/packages/path_provider) | ^2.1.2 | Akses direktori sistem file |
| [`path`](https://pub.dev/packages/path) | ^1.9.0 | Manipulasi path file |

### 📍 GPS & Navigasi Lokasi

| Package | Versi | Kegunaan |
|---------|-------|----------|
| [`geolocator`](https://pub.dev/packages/geolocator) | ^11.0.0 | Akses GPS & lokasi perangkat |
| [`url_launcher`](https://pub.dev/packages/url_launcher) | ^6.3.0 | Membuka URL, maps, atau aplikasi eksternal |

### 🔒 Security

| Package | Versi | Kegunaan |
|---------|-------|----------|
| [`flutter_secure_storage`](https://pub.dev/packages/flutter_secure_storage) | ^9.0.0 | Penyimpanan data sensitif (token, password) |
| [`crypto`](https://pub.dev/packages/crypto) | ^3.0.3 | Enkripsi & hashing data |

### 📷 Sensor Kamera

| Package | Versi | Kegunaan |
|---------|-------|----------|
| [`image_picker`](https://pub.dev/packages/image_picker) | ^1.0.7 | Ambil foto dari kamera atau galeri |

### 🌐 Network

| Package | Versi | Kegunaan |
|---------|-------|----------|
| [`connectivity_plus`](https://pub.dev/packages/connectivity_plus) | ^5.0.2 | Deteksi status koneksi jaringan |

### ℹ️ Info Platform

| Package | Versi | Kegunaan |
|---------|-------|----------|
| [`package_info_plus`](https://pub.dev/packages/package_info_plus) | ^7.0.0 | Info versi & nama aplikasi |
| [`device_info_plus`](https://pub.dev/packages/device_info_plus) | ^10.0.0 | Info perangkat (OS, model, dll.) |

### 🎨 UI & Utilities

| Package | Versi | Kegunaan |
|---------|-------|----------|
| [`intl`](https://pub.dev/packages/intl) | ^0.19.0 | Format tanggal, angka & lokalisasi |
| [`permission_handler`](https://pub.dev/packages/permission_handler) | ^11.3.0 | Manajemen izin runtime (kamera, lokasi, dll.) |
| [`cupertino_icons`](https://pub.dev/packages/cupertino_icons) | ^1.0.8 | Ikon bergaya iOS |

---

## 🔑 Konfigurasi Izin (Permissions)

### Android

Tambahkan izin berikut pada `android/app/src/main/AndroidManifest.xml`:

```xml
<!-- Lokasi -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

<!-- Kamera & Penyimpanan -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />

<!-- Internet -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### iOS

Tambahkan key berikut pada `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Aplikasi membutuhkan akses lokasi untuk fitur surveyor.</string>

<key>NSCameraUsageDescription</key>
<string>Aplikasi membutuhkan akses kamera untuk mengambil foto produk.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Aplikasi membutuhkan akses galeri untuk memilih foto produk.</string>
```

---

## 🧪 Menjalankan Tests

```bash
# Jalankan semua test
flutter test

# Dengan coverage
flutter test --coverage
```

---

## 🛠️ Troubleshooting

**`flutter pub get` gagal**
```bash
flutter clean
flutter pub cache repair
flutter pub get
```

**Gradle build error (Android)**
```bash
cd android
./gradlew clean
cd ..
flutter run
```

**Pod install error (iOS)**
```bash
cd ios
pod install --repo-update
cd ..
flutter run
```

**Izin lokasi / kamera tidak muncul**  
Pastikan konfigurasi `AndroidManifest.xml` dan `Info.plist` sudah ditambahkan seperti pada bagian [Konfigurasi Izin](#-konfigurasi-izin-permissions) di atas.

**Flutter SDK versi tidak cocok**
```bash
flutter upgrade
```

---

## Screenshot Aplikasi

### Dashboard
<img src="assets/Dashboard.jpeg" width="250"/>

### History
<img src="assets/History.jpeg" width="250"/>

### SplashScreen
<img src="assets/SplashScreen.jpeg" width="250"/>


## 🤝 Kontribusi

1. Fork repository ini
2. Buat branch fitur baru: `git checkout -b feature/nama-fitur`
3. Commit perubahan: `git commit -m 'feat: menambahkan fitur X'`
4. Push ke branch: `git push origin feature/nama-fitur`
5. Buat Pull Request

---

## 📄 Lisensi

Project ini dilisensikan di bawah [MIT License](LICENSE).

---

## 👤 Author

**ghendraw**  
🔗 GitHub: [@ghendraw](https://github.com/ghendraw)
