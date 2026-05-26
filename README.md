# 💎 Jewelry Stone Counter — Flutter App

AI-powered jewelry analyzer that counts gold balls, diamonds, rubies,
emeralds, sapphires, pearls and other gemstones from any photo.

## ✅ Features
- 🪙 Count Gold Balls/Beads
- 💎 Count Diamonds (all cuts)
- 🔴 Count Rubies
- 💚 Count Emeralds
- 🔵 Count Sapphires
- ⚪ Count Pearls
- 💠 Detect other gemstones
- 📊 Composition breakdown chart
- 📋 Copy report to clipboard
- 📷 Camera & Gallery support
- 🆓 Google Gemini Free API (1500 scans/day)

---

## 🚀 Setup in 4 Steps

### Step 1 — Prerequisites
Make sure you have Flutter installed:
```bash
flutter doctor
```
All checks should pass (at minimum Flutter SDK + Android/iOS toolchain).

### Step 2 — Get FREE Gemini API Key
1. Open: https://aistudio.google.com/app/apikey
2. Sign in with your Google account
3. Click **"Create API Key"**
4. Copy the key (starts with "AIza...")

### Step 3 — Add API Key
Open `lib/services/gemini_service.dart` and replace:
```dart
static const String apiKey = 'YOUR_GEMINI_API_KEY';
```
With your actual key:
```dart
static const String apiKey = 'AIzaSyXXXXXXXXXXXXXXXXXXXXX';
```

### Step 4 — Run the App
```bash
# Install dependencies
flutter pub get

# Run on connected device or emulator
flutter run

# Run on specific device
flutter run -d <device_id>
```

---

## 📦 Build Release APK (Android)
```bash
flutter build apk --release
```
APK location: `build/app/outputs/flutter-apk/app-release.apk`

## 📱 Build for iOS (Mac only)
```bash
flutter build ios --release
# Then open ios/Runner.xcworkspace in Xcode to archive
```

---

## 📁 Project Structure
```
lib/
├── main.dart                    ← App entry point
├── models/
│   ├── app_theme.dart           ← Colors, theme, stone types
│   └── jewelry_result.dart      ← Data model for scan results
├── services/
│   └── gemini_service.dart      ← Gemini AI API integration
└── screens/
    ├── home_screen.dart         ← Main screen with camera/gallery
    └── result_screen.dart       ← Results with stone counts
```

---

## 💰 API Pricing (Gemini Free Tier)
| Plan | Requests | Cost |
|------|----------|------|
| Free | 1,500/day, 15/min | $0 |
| Paid | Unlimited | ~$0.0001/image |

---

## ⚠️ Common Issues

### "Permission denied" on Android
Run on Android 13+: grant "Photos and videos" permission manually in Settings.

### "API key not valid"
Make sure you copied the full key from aistudio.google.com

### Image too large / timeout
The app auto-limits images to 1400px. For very large images (>8MB),
add flutter_image_compress to pubspec.yaml.

### iOS build fails
Run: `cd ios && pod install && cd ..`

---

## 🔧 Platform Support
| Platform | Status | Notes |
|----------|--------|-------|
| Android | ✅ Full | API 21+ |
| iOS | ✅ Full | iOS 13+ |
| Web | ⚠️ Partial | No camera on some browsers |
