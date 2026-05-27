# 🐾 PawTable — Start From Scratch Prompt

> **Use this document to begin a fresh session building the PawTable project from the ground up.**
> Copy this entire document into your new session as context. It contains all the research, design decisions, architecture, and implementation guidance needed to build the project correctly.

---

## 📋 Session Checklist

Before starting, ensure:

- [ ] Flutter SDK is installed (`flutter --version` ≥ 3.27.0)
- [ ] Android SDK is configured (`flutter doctor --android-licenses`)
- [ ] iOS setup is complete (Xcode for iOS builds)
- [ ] Project directory is clean and ready

---

## 🎯 1. Project Overview

### What is PawTable?

**Pet Table** (working name) is an all-in-one pet wellness companion app for pet owners. It fills the gap between fragmented pet tracking apps and expensive vet services by providing comprehensive health tracking, smart reminders, family collaboration, and AI-powered insights.

### Target Users

1. **Primary:** Pet owners with 1+ dogs/cats wanting comprehensive health tracking
2. **Secondary:** Multi-pet households (60% of dog owners have 2+ pets)
3. **Tertiary:** Families sharing pet care responsibilities, pet sitters

### Market Context

- Pet care apps market: $2.8B (2025) → $4.7B (2034), CAGR 5.9%
- Pet wellness apps: $1.42B (2024), growing at 14.7% CAGR
- 79% of Americans would use apps for pet health monitoring
- **No dominant comprehensive wellness app exists** — this is the opportunity

### Monetization

| Tier | Price | Key Features |
|------|-------|--------------|
| **Free** | $0 | 1 pet, basic tracking, 7-day calendar, 3 reminders |
| **Monthly** | $6.99/mo | Unlimited pets, AI insights, exports, analytics |
| **Annual** | $49.99/yr | All monthly features + 40% discount |
| **Family** | $9.99/mo | Unlimited members, shared profiles, priority support |

---

## 🏗️ 2. Technical Architecture

### Tech Stack

| Layer | Technology | Why |
|-------|-----------|-----|
| **UI Framework** | Flutter 3.27+ | Single codebase, native performance |
| **State Management** | Riverpod 2.6+ | Type-safe, testable, scalable |
| **Local Storage** | Hive + SQLite | Hive for settings; SQLite for structured data |
| **Cloud Sync** | Firebase (Firestore, Auth, FCM) | Real-time sync, push notifications |
| **Subscriptions** | RevenueCat SDK | Abstraction over StoreKit/Play Billing |
| **Navigation** | go_router 16+ | Declarative routing, deep links |
| **Charts** | fl_chart 0.69+ | Rich data visualization |
| **PDF Export** | pdf + pdf_widget | Vet-ready reports |
| **Animations** | flutter_animate 4.5+ | Confetti, badge reveals |

### Architecture: Clean Architecture (Feature Modules)

```
lib/
├── main.dart                           # App entry point
├── app.dart                            # App shell, routing
├── di/                                 # Dependency injection
│   └── app_module.dart
│
├── core/                               # Shared infrastructure
│   ├── theme/                          # Design tokens, themes
│   │   ├── colors.dart
│   │   ├── typography.dart
│   │   └── themes.dart
│   ├── navigation/                     # go_router setup
│   │   ├── routes.dart
│   │   └── deep_links.dart
│   ├── storage/                        # Hive + SQLite
│   │   ├── hive_storage.dart
│   │   └── sqflite_helper.dart
│   ├── firebase/                       # Firebase services
│   │   ├── auth_manager.dart
│   │   ├── firestore_manager.dart
│   │   └── notification_service.dart
│   ├── billing/                        # RevenueCat
│   │   └── billing_service.dart
│   ├── utils/                          # Helpers
│   ├── network/                        # HTTP client
│   └── errors/                         # Exceptions
│
├── features/                           # Feature modules (vertical slices)
│   ├── onboarding/
│   ├── home/
│   ├── pets/
│   ├── health/
│   ├── calendar/
│   ├── family/
│   ├── premium/
│   ├── gamification/
│   └── ai/
│
└── shared/                             # Shared widgets
    ├── widgets/
    └── constants/
```

### Data Flow

```
User Action
    ↓
Presentation Layer (Widgets, Riverpod StateNotifier)
    ↓
Domain Layer (UseCases, Repositories interface)
    ↓
Data Layer (SQLite, Hive, Firestore, RevenueCat, External APIs)
    ↑
State Stream → Rebuilds UI
```

### Key Architectural Decisions

1. **Offline-First:** SQLite for all tracking data → syncs to Firestore when online
2. **RevenueCat Over Direct Billing:** Saves ~200h of billing code, built-in analytics
3. **Riverpod Over Bloc/Provider:** Type-safe providers, compile-time error detection
4. **Clean Architecture Over MVC:** Independently testable feature modules

---

## 🎨 3. Design System

### Color Palette (Warm Pastels)

```dart
class PawTableColors {
  static const cream = Color(0xFFFDF8F0);        // Background
  static const warmWhite = Color(0xFFFFFCF7);     // Card backgrounds
  static const softOrange = Color(0xFFF4A261);    // Primary action
  static const warmCoral = Color(0xFFE76F51);     // Secondary accent
  static const sageGreen = Color(0xFFA8D5BA);     // Success / wellness
  static const softBlue = Color(0xFFB5C9D9);      // Info / calm
  static const lavender = Color(0xFFD4C5E2);      // AI / premium
  static const warmGray = Color(0xFF6B6B6B);      // Text secondary
  static const darkBrown = Color(0xFF3D3D3D);     // Text primary
}
```

### Typography

- **Headings:** Poppins (bold, rounded feel)
- **Body:** Inter (clean, readable at small sizes)
- **Numbers/Data:** SF Pro Rounded / Roboto Mono

### Layout Principles

1. **One-thumb navigation** — All primary actions within thumb reach
2. **Bottom navigation** — 4 tabs: Home, Track, Calendar, Family
3. **Quick-log buttons** — Persistent floating buttons on home screen
4. **Swipe actions** — Edit, delete, share from list items
5. **Celebration animations** — Confetti on logging streaks, milestone badges

---

## 📱 4. Key Screens

1. **Onboarding** — Pet type → breed → name → free trial start
2. **Home** — Pet cards, quick-log (feed, med, weight, behavior), health at a glance
3. **Track** — Detailed logging forms (feeding, vaccination, medication, weight, behavior)
4. **Calendar** — Monthly/weekly view of health events, quick-add
5. **Family** — Family members, shared pets, activity feed, invite
6. **Profile/Settings** — Account, notifications, privacy, subscription
7. **Premium Paywall** — Feature comparison, pricing tiers, upgrade CTA

---

## 🚀 5. Getting Started — Step by Step

### Step 1: Scaffold the Project

```bash
flutter create pawtable \
  --org com.pawtable \
  --project-name pawtable \
  --platforms android,ios
```

### Step 2: Add Dependencies

Add these to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State management & DI
  flutter_riverpod: ^2.6.1
  get_it: ^8.0.3
  injectable: ^2.5.0
  rxdart: ^0.28.0

  # Navigation
  go_router: ^16.2.0

  # Local storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  sqflite: ^2.4.1
  path_provider: ^2.1.5
  path: ^1.9.0

  # Firebase
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
  cloud_firestore: ^5.0.0
  firebase_messaging: ^15.0.0
  flutter_local_notifications: ^18.0.1

  # Billing
  purchases_flutter: ^9.5.0

  # Charts & PDF
  fl_chart: ^0.69.2
  pdf: ^3.11.1
  pdf_widget: ^3.0.0

  # UI utilities
  flutter_animate: ^4.5.0
  intl: ^0.20.2
  uuid: ^4.5.1
  equatable: ^2.0.5

  # Permissions & device
  permission_handler: ^11.3.1
  image_picker: ^1.1.2
  camera: ^0.11.0+1
  connectivity_plus: ^6.1.1

  # Logging
  logger: ^2.5.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  build_runner: ^2.4.0
  hive_generator: ^2.0.1
  freezed: ^2.4.0
  injectable_generator: ^2.0.0
  json_serializable: ^6.7.0
```

### Step 3: Configure Android

**android/app/build.gradle.kts:**

```kotlin
plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.pawtable.pawtable"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "com.pawtable.pawtable"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
```

**android/gradle.properties:**

```properties
org.gradle.jvmargs=-Xmx8G -XX:MaxMetaspaceSize=4G -XX:ReservedCodeCacheSize=512m -XX:+HeapDumpOnOutOfMemoryError
android.useAndroidX=true
android.newDsl=false
android.builtInKotlin=false
kotlin.incremental=false
```

**local.properties:**

```properties
sdk.dir=C:\\Users\\<YOUR_USER>\\AppData\\Local\\Android\\Sdk
flutter.sdk=C:\\Users\\<YOUR_USER>\\scoop\\apps\\flutter\\current
```

### Step 4: Create Core Structure

Create these directories and files:

```
lib/
├── main.dart
├── core/
│   ├── theme/
│   │   ├── colors.dart
│   │   ├── typography.dart
│   │   └── themes.dart
│   ├── navigation/
│   │   └── routes.dart
│   └── firebase/
│       └── firebase_service.dart
├── di/
│   └── app_module.dart
├── features/
└── shared/
```

### Step 5: Implement Core Components

#### 1. Theme

```dart
// lib/core/theme/colors.dart
class PawTableColors {
  static const cream = Color(0xFFFDF8F0);
  static const warmWhite = Color(0xFFFFFCF7);
  static const softOrange = Color(0xFFF4A261);
  static const warmCoral = Color(0xFFE76F51);
  static const sageGreen = Color(0xFFA8D5BA);
  static const softBlue = Color(0xFFB5C9D9);
  static const lavender = Color(0xFFD4C5E2);
  static const warmGray = Color(0xFF6B6B6B);
  static const darkBrown = Color(0xFF3D3D3D);
}
```

#### 2. Navigation

```dart
// lib/core/navigation/routes.dart
final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);
```

#### 3. Dependency Injection

```dart
// lib/di/app_module.dart
final getIt = GetIt.instance;

void configureDependencies() {
  getIt.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());
  getIt.registerLazySingleton<HiveService>(() => HiveService());
  getIt.registerLazySingleton<FirebaseService>(() => FirebaseService());
}
```

#### 4. Main Entry Point

```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  configureDependencies();
  await FirebaseService().initialize();
  
  runApp(
    ProviderScope(
      child: PawTableApp(),
    ),
  );
}

class PawTableApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PawTable',
      debugShowCheckedModeBanner: false,
      theme: PawThemes.lightTheme,
      darkTheme: PawThemes.darkTheme,
      routerConfig: router,
    );
  }
}
```

---

## 📦 6. Feature Implementation Order

Build features in this order (dependencies respected):

1. **Foundation** — Core architecture, DI, theme, navigation
2. **Core App Shell** — Onboarding, home screen, bottom nav
3. **Pet Profiles** — Pet creation, photos, profiles
4. **Health Tracking** — Feeding, vaccinations, medications, weight
5. **Calendar & Reminders** — Event calendar, push notifications
6. **Family Collaboration** — Sharing, permissions, real-time sync
7. **Gamification** — Streaks, achievements, celebrations
8. **Monetization** — RevenueCat integration, paywalls
9. **AI Insights** — Health analysis, recommendations
10. **Polish & Launch** — Testing, app store prep

---

## ⚠️ 7. Common Pitfalls & Solutions

### Pitfall 1: Project Never Scaffolded

**Problem:** Hand-crafted without `flutter create` → missing `local.properties`, corrupted Gradle

**Solution:** Always start with `flutter create` before adding custom code

### Pitfall 2: Kotlin Cache Corruption on Windows

**Problem:** `.tab` file errors in Kotlin compilation

**Solution:** Add `kotlin.incremental=false` to `gradle.properties`

### Pitfall 3: Core Library Desugaring Missing

**Problem:** `flutter_local_notifications` requires Java 8+ desugaring

**Solution:** Add `isCoreLibraryDesugaringEnabled = true` and desugaring dependency

### Pitfall 4: Sentry Plugin Incompatibility

**Problem:** `sentry_flutter` uses Kotlin 1.6, incompatible with Kotlin 2.3.20

**Solution:** Either:
- Remove sentry until plugin updates
- Use stub service (same API, no-op implementation)
- Pin Kotlin version to 1.9.x temporarily

### Pitfall 5: Missing Asset Directories

**Problem:** `pubspec.yaml` references `assets/images/` but directory doesn't exist

**Solution:** Create empty directories with `.gitkeep` files

---

## ✅ 8. Build Verification

After each major step, verify:

```bash
# Clean rebuild
flutter clean
flutter pub get

# Analyze
flutter analyze

# Build APK
flutter build apk --debug

# Run on device/emulator
flutter run
```

**Success Criteria:**
- `flutter analyze` → 0 errors
- `flutter build apk --debug` → ✅ builds successfully
- App runs without crashes

---

## 📚 9. Additional Resources

### Flutter Documentation
- [Flutter Docs](https://docs.flutter.dev/)
- [Riverpod Docs](https://riverpod.dev/)
- [go_router Docs](https://pub.dev/packages/go_router)

### Firebase Setup
- [Firebase Flutter Setup](https://firebase.google.com/docs/flutter/setup)
- Run `flutterfire configure` for Firebase options

### RevenueCat Setup
- [RevenueCat Flutter SDK](https://docs.revenuecat.com/docs/flutter)
- Create project at [revenuecat.com](https://www.revenuecat.com/)

### Design Resources
- Poppins: [fonts.google.com/specimen/Poppins](https://fonts.google.com/specimen/Poppins)
- Inter: [fonts.google.com/specimen/Inter](https://fonts.google.com/specimen/Inter)

---

## 🎯 10. Session Workflow

1. **Start fresh** — Run `flutter create`
2. **Add dependencies** — Update `pubspec.yaml`, run `flutter pub get`
3. **Configure Android/iOS** — Apply gradle fixes, add assets
4. **Build core** — Theme, navigation, DI, Firebase
5. **Implement features** — Follow implementation order above
6. **Test regularly** — `flutter analyze` after each feature
7. **Push to git** — Commit and push after each feature

---

*This document should be used as a starting point for building PawTable from scratch. All decisions, architecture, and implementation details are captured for reference.*
