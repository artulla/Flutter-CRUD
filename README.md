# CustomerPro — Flutter App Setup Guide
> Full-stack Flutter Customer Management App | Android Studio

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/        ← AppColors, AppStrings, AppSizes
│   ├── theme/            ← AppTheme (Material 3, Poppins font)
│   ├── network/          ← DioClient + 3 interceptors
│   ├── router/           ← go_router + auth guards
│   ├── di/               ← ALL Riverpod providers
│   └── utils/            ← Validators, Logger
├── features/
│   ├── auth/             ← Login (data/domain/presentation)
│   ├── customer/         ← CRUD (data/domain/presentation)
│   └── dashboard/        ← Dashboard screen
└── main.dart
```

---

## 🚀 STEP-BY-STEP ANDROID STUDIO SETUP

### STEP 1: Create New Flutter Project
```
File → New → New Flutter Project
  ✅ Flutter SDK path: (your SDK path)
  ✅ Project name: customer_app
  ✅ Organization: com.yourcompany
  ✅ Platforms: Android only
```

### STEP 2: Replace Files
Copy all files from this project into the Flutter project root, replacing:
- `pubspec.yaml`
- Entire `lib/` directory

### STEP 3: Install Dependencies
Open **Terminal** in Android Studio (View → Tool Windows → Terminal):

```bash
flutter pub get
```

### STEP 4: Run Code Generation (IMPORTANT!)
Drift and json_serializable require code generation:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This generates:
- `customer_database.g.dart` (Drift ORM code)
- `login_response_model.g.dart` (JSON serialization)

> 💡 Run this every time you change a `@DriftDatabase`, `@JsonSerializable`, or `@freezed` class.

### STEP 5: Configure API Base URL
Edit `lib/core/network/dio_client.dart`:

```dart
const String kBaseUrl = 'https://YOUR-API-URL.com/api/v1';
```

### STEP 6: Android Permissions
In `android/app/src/main/AndroidManifest.xml`, add:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

### STEP 7: Flutter Secure Storage — Android Config
In `android/app/build.gradle`, ensure `minSdkVersion` is **18+**:

```gradle
defaultConfig {
    minSdkVersion 18
    targetSdkVersion 34
    ...
}
```

### STEP 8: Run the App
```bash
flutter run
```
Or press the **▶ Run** button in Android Studio.

---

## 🔑 API Contract Expected

### POST /auth/login
Request:
```json
{ "email": "user@email.com", "password": "pass123" }
```
Response:
```json
{ "token": "eyJhbGci...", "message": "Login successful" }
```

### GET /customers
Response: `[{ "id": 1, "name": "John", "email": "j@j.com", "phone": "9876543210", "address": "...", "is_active": true }]`

### POST /customers — Create
### PUT /customers/:id — Update  
### DELETE /customers/:id — Delete

---

## 🎨 Theme Colors

| Role         | Hex       | Usage                     |
|--------------|-----------|---------------------------|
| Primary      | `#02724C` | AppBar, Buttons, FAB      |
| Secondary    | `#CC8C02` | Dashboard cards, badges   |
| Background   | `#FFFFFF` | Scaffold background       |
| Text/Primary | `#FFFFFF` | Text on primary color     |

---

## 🏗️ Architecture

```
UI (Screen)
    ↓ watches/reads
ViewModel (StateNotifier)
    ↓ calls
UseCase (domain logic)
    ↓ calls
Repository interface (domain)
    ↑ implemented by
RepositoryImpl (data)
    ↓ calls
RemoteDataSource (Dio) + LocalDataSource (Drift)
```

---

## 📦 Commands Reference

```bash
# Get packages
flutter pub get

# Generate code (Drift + JSON)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-generate on save)
flutter pub run build_runner watch --delete-conflicting-outputs

# Run app
flutter run

# Build APK
flutter build apk --release

# Check for issues
flutter analyze
```

---

## ⚠️ Troubleshooting

| Problem | Fix |
|---|---|
| `part of` error in .g.dart | Run build_runner again |
| `minSdkVersion` error | Set to 18 in android/app/build.gradle |
| Network error on Android | Add INTERNET permission in AndroidManifest.xml |
| Storage read returns null | App first launch — go to login screen |
| `drift` table not found | Delete app data and reinstall |
