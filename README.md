# 📱 Mobile Application (Flutter)

Mobile application untuk aplikasi Zoom AI menggunakan Flutter dengan integrasi LiveKit untuk video calling dan real-time communication.

## 📋 Table of Contents

- [About](#-about)
- [Features](#-features)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Getting Started](#-getting-started)
- [Project Structure](#-project-structure)
- [Configuration](#-configuration)
- [Development Commands](#-development-commands)
- [Building for Production](#-building-for-production)

---

## 🎯 About

Aplikasi mobile ini adalah bagian dari ekosistem Zoom AI yang memungkinkan pengguna untuk:
- Melakukan video call dengan kualitas tinggi menggunakan LiveKit
- Berkomunikasi secara real-time melalui chat
- Mengelola profil dan autentikasi
- Mengakses fitur-fitur AI-powered dari backend

### Key Highlights

- 🎥 **Video Calling** - Video call berkualitas tinggi dengan LiveKit
- 💬 **Real-time Chat** - Komunikasi real-time melalui WebSocket
- 🔐 **Secure Authentication** - Sistem autentikasi yang aman dengan JWT
- 📱 **Cross-Platform** - Berjalan di Android dan iOS
- 🎨 **Modern UI** - Interface yang modern dan user-friendly

---

## ✨ Features

### 🔐 Authentication
- Login dan Register
- OTP Verification
- Reset Password
- Session Management dengan secure storage

### 🎥 Video Calling
- Create dan join video rooms
- Real-time video communication dengan LiveKit
- Audio/Video controls
- Screen sharing support

### 💬 Real-time Communication
- WebSocket-based chat
- Real-time messaging
- Presence indicators

### 👤 User Profile
- Profile management
- Settings
- Account information

---

## 🚀 Prerequisites

Sebelum menjalankan aplikasi, pastikan Anda telah menginstall:

- **Flutter SDK 3.9.2+** - [Download Flutter](https://flutter.dev/docs/get-started/install)
- **Dart SDK** - Included dengan Flutter
- **Android Studio** atau **VS Code** dengan Flutter extension
- **Android SDK** (untuk Android development)
- **Xcode** (untuk iOS development, hanya macOS)
- **Git** - [Download Git](https://git-scm.com/downloads)

### Platform Requirements

- **Android**: Android SDK 21+ (Android 5.0+)
- **iOS**: iOS 12.0+
- **Web**: Modern browsers (Chrome, Firefox, Safari, Edge)

---

## 📦 Installation

### 1. Clone Repository

```bash
git clone https://github.com/Sanjaee/MOBILE-HACKATHON-ZOOM-AI-KOLOSAL.git
cd mobile
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Setup Environment

Buat file `.env` di root folder `mobile/` (opsional, jika menggunakan flutter_dotenv):

```env
# API Configuration
API_BASE_URL=https://your-backend-api.com
WS_URL=wss://your-backend-api.com/ws

# LiveKit Configuration
LIVEKIT_URL=wss://your-livekit-server.com
LIVEKIT_API_KEY=your_livekit_api_key
LIVEKIT_API_SECRET=your_livekit_api_secret
```

> **⚠️ PENTING:** Jangan commit file `.env` ke repository! Pastikan file `.env` sudah ada di `.gitignore`.

---

## 🚀 Getting Started

### Development Mode

1. **Pastikan device/emulator sudah terhubung:**

```bash
# Cek devices yang tersedia
flutter devices
```

2. **Jalankan aplikasi:**

```bash
flutter run
```

3. **Jalankan dengan hot reload:**

Aplikasi akan otomatis reload ketika Anda mengubah file. Tekan `r` di terminal untuk hot reload, atau `R` untuk hot restart.

### Menjalankan di Platform Spesifik

```bash
# Android
flutter run -d android

# iOS (hanya macOS)
flutter run -d ios

# Web
flutter run -d chrome

# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux
```

---

## 🏗️ Project Structure

```
mobile/
├── lib/
│   ├── main.dart                 # Application entry point
│   ├── app.dart                  # App configuration & routing
│   │
│   ├── core/                     # Core utilities & shared code
│   │   ├── constants/
│   │   │   ├── app_colors.dart   # Color constants
│   │   │   └── text_styles.dart  # Text style constants
│   │   ├── middleware/
│   │   │   └── auth_guard.dart   # Route protection middleware
│   │   ├── utils/
│   │   │   └── validators.dart   # Input validators
│   │   └── widgets/              # Reusable widgets
│   │       ├── primary_button.dart
│   │       └── input_field.dart
│   │
│   ├── data/                     # Data layer
│   │   ├── models/               # Data models
│   │   │   ├── user.dart
│   │   │   ├── room.dart
│   │   │   └── chat.dart
│   │   ├── services/             # API & storage services
│   │   │   ├── api_service.dart
│   │   │   ├── auth_storage_service.dart
│   │   │   ├── websocket_service.dart
│   │   │   └── livekit_service.dart
│   │   └── repository/           # Data repositories
│   │
│   ├── features/                 # Feature modules
│   │   ├── auth/
│   │   │   ├── pages/
│   │   │   │   ├── login_page.dart
│   │   │   │   ├── register_page.dart
│   │   │   │   ├── verify_otp_page.dart
│   │   │   │   └── reset_password_page.dart
│   │   │   ├── controllers/      # State management
│   │   │   └── widgets/           # Feature-specific widgets
│   │   │
│   │   ├── home/
│   │   │   ├── pages/
│   │   │   │   └── home_page.dart
│   │   │   ├── controllers/
│   │   │   └── widgets/
│   │   │
│   │   ├── profile/
│   │   │   ├── pages/
│   │   │   │   └── profile_page.dart
│   │   │   └── controllers/
│   │   │
│   │   └── zoom/
│   │       ├── pages/
│   │       │   ├── rooms_page.dart
│   │       │   └── video_call_page.dart
│   │       ├── controllers/
│   │       └── widgets/
│   │
│   └── routes/
│       └── app_routes.dart       # Route definitions
│
├── android/                      # Android-specific files
├── ios/                          # iOS-specific files
├── web/                          # Web-specific files
├── windows/                      # Windows-specific files
├── macos/                        # macOS-specific files
├── linux/                        # Linux-specific files
├── pubspec.yaml                  # Dependencies & configuration
└── README.md                     # This file
```

### Architecture Pattern

Aplikasi menggunakan **Clean Architecture** dengan struktur yang ringan dan scalable:

- **Core/**: Shared utilities, constants, dan reusable widgets
- **Data/**: API services, models, dan data repositories
- **Features/**: Feature modules yang terpisah (auth, home, zoom, dll)
- **Routes/**: Centralized routing configuration

Setiap feature memiliki struktur sendiri:
- `pages/`: UI screens
- `controllers/`: State management (GetX, Provider, atau BLoC)
- `widgets/`: Feature-specific widgets

---

## ⚙️ Configuration

### Android Configuration

1. **Update `android/app/build.gradle`:**

```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
        // ...
    }
}
```

2. **Update `AndroidManifest.xml` untuk permissions:**

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS"/>
```

### iOS Configuration

1. **Update `ios/Runner/Info.plist` untuk permissions:**

```xml
<key>NSCameraUsageDescription</key>
<string>We need access to your camera for video calls</string>
<key>NSMicrophoneUsageDescription</key>
<string>We need access to your microphone for video calls</string>
```

2. **Update minimum iOS version di `ios/Podfile`:**

```ruby
platform :ios, '12.0'
```

### API Configuration

Update API base URL di service files:

```dart
// lib/data/services/api_service.dart
const String baseUrl = 'https://your-backend-api.com';
```

---

## 🛠️ Development Commands

### Flutter Commands

```bash
# Install dependencies
flutter pub get

# Run app
flutter run

# Run with specific device
flutter run -d <device-id>

# Build APK (Android)
flutter build apk

# Build App Bundle (Android)
flutter build appbundle

# Build IPA (iOS)
flutter build ios

# Build Web
flutter build web

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
flutter format .

# Clean build
flutter clean
```

### Debugging

```bash
# Run in debug mode
flutter run --debug

# Run in profile mode (performance testing)
flutter run --profile

# Run in release mode
flutter run --release
```

### Hot Reload & Hot Restart

- **Hot Reload**: Tekan `r` di terminal (mempertahankan state)
- **Hot Restart**: Tekan `R` di terminal (reset state)
- **Quit**: Tekan `q` di terminal

---

## 📦 Building for Production

### Android

#### Build APK

```bash
flutter build apk --release
```

#### Build App Bundle (untuk Google Play Store)

```bash
flutter build appbundle --release
```

File akan tersedia di: `build/app/outputs/bundle/release/app-release.aab`

### iOS

#### Build IPA

```bash
flutter build ios --release
```

Kemudian buka Xcode dan archive aplikasi:
1. Buka `ios/Runner.xcworkspace` di Xcode
2. Product → Archive
3. Distribute App

### Web

```bash
flutter build web --release
```

File akan tersedia di: `build/web/`

---

## 📝 Dependencies

### Main Dependencies

- **flutter**: SDK framework
- **http**: HTTP client untuk API calls
- **shared_preferences**: Local storage
- **livekit_client**: LiveKit SDK untuk video calling
- **permission_handler**: Handle device permissions
- **web_socket_channel**: WebSocket untuk real-time communication

### Development Dependencies

- **flutter_test**: Testing framework
- **flutter_lints**: Linting rules

Lihat `pubspec.yaml` untuk daftar lengkap dependencies.

---

## 🔧 Troubleshooting

### Common Issues

1. **Dependencies tidak terinstall:**
```bash
flutter clean
flutter pub get
```

2. **Build error di Android:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

3. **Build error di iOS:**
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
```

4. **Permission issues:**
- Pastikan permissions sudah ditambahkan di `AndroidManifest.xml` (Android) atau `Info.plist` (iOS)
- Restart aplikasi setelah menambahkan permissions

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License.

---

## 🔗 Related Links

- [Backend Repository](../backend/README.md)
- [Frontend Repository](../frontend/README.md)
- [Flutter Documentation](https://flutter.dev/docs)
- [LiveKit Documentation](https://docs.livekit.io/)

---

<div align="center">

**Built with ❤️ using Flutter**

[Get Started →](#-getting-started) | [View Demo →](#)

</div>
