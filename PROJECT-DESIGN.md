# Pet Table — Project Design Document

**Version:** 1.0  
**Date:** May 26, 2026  
**Platform:** Flutter (iOS + Android)  
**Tracking:** Beads (bd) — see `.beads/` for all 50 tasks across 10 epics

---

## 1. Product Vision

Build **Pet Table** (working name; subject to trademark clearance) — an all-in-one pet wellness companion app that fills the market gap between fragmented pet tracking apps and expensive vet services.

### Target Audience

- **Primary:** Pet owners with 1+ dogs/cats who want comprehensive health tracking
- **Secondary:** Multi-pet households (60% of dog owners have 2+ pets)
- **Tertiary:** Families sharing pet care responsibilities, pet sitters

### Market Opportunity

- Pet care apps market: $2.8B (2025) → $4.7B (2034), CAGR 5.9%
- Pet wellness apps sub-market: $1.42B (2024), growing at 14.7% CAGR
- 79% of Americans would use apps for pet health monitoring
- No dominant comprehensive wellness app exists

### Monetization Model

| Tier | Price | Features |
|------|-------|----------|
| Free | $0 | 1 pet, basic tracking, 7-day calendar, reminders |
| Monthly | $6.99/mo | Unlimited pets, AI insights, exports, analytics |
| Annual | $49.99/yr | All monthly features + 40% discount |
| Family | $9.99/mo or $79.99/yr | Unlimited family members, shared profiles |

---

## 2. Architecture

### Tech Stack

| Layer | Technology | Rationale |
|-------|-----------|-----------|
| **UI Framework** | Flutter 3.x | Single codebase, native performance, rich widget library |
| **State Management** | Riverpod 2.x | Type-safe, testable, scalable for multi-pet/family data |
| **Local Storage** | Hive (NoSQL) + SQLite (relational) | Hive for settings/preferences; SQLite for structured tracking data |
| **Cloud Sync** | Firebase (Firestore, Auth, Cloud Messaging) | Real-time family sync, push notifications, auth |
| **Subscriptions** | RevenueCat SDK | Abstraction over StoreKit/Play Billing, analytics, webhooks |
| **Navigation** | go_router | Declarative, deep linking, web support |
| **Charts** | fl_chart | Rich data visualization for weight trends, health scores |
| **PDF Generation** | pdf + pdf_widget | Vet-ready reports, CSV exports |
| **Crash Reporting** | Sentry | Production error monitoring |
| **Animations** | flutter_animate | Confetti, badge reveals, smooth transitions |

### Architecture Pattern: Clean Architecture

```
lib/
├── main.dart
├── app.dart                    # App shell, routing config
├── di/                         # Dependency injection (Riverpod providers)
│   └── providers.dart
│
├── core/                       # Shared infrastructure
│   ├── theme/                  # Design tokens, light/dark themes
│   │   ├── colors.dart         # Warm pastels, cream backgrounds
│   │   ├── typography.dart     # Rounded sans-serif fonts
│   │   └── themes.dart         # LightTheme, DarkTheme
│   ├── navigation/             # go_router setup
│   │   ├── routes.dart
│   │   └── deep_links.dart
│   ├── storage/                # Hive adapters, SQLite helper
│   │   ├── hive_storage.dart
│   │   └── sqflite_helper.dart
│   ├── firebase/               # Firebase config, auth
│   │   ├── auth_manager.dart
│   │   └── firestore_manager.dart
│   ├── billing/                # RevenueCat integration
│   │   └── billing_service.dart
│   ├── utils/                  # Formatters, validators, date helpers
│   ├── network/                # HTTP client, API services
│   └── errors/                 # Error handling, exceptions
│
├── features/                   # Feature modules (vertical slices)
│   ├── onboarding/
│   │   ├── presentation/
│   │   │   ├── widgets/
│   │   │   └── screens/
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   └── data/
│   │       └── datasources/
│   │
│   ├── home/
│   ├── pets/
│   ├── health/
│   ├── calendar/
│   ├── family/
│   ├── premium/
│   ├── gamification/
│   └── ai/
│
└── shared/                     # Shared widgets (reusable across features)
    ├── widgets/
    │   ├── pet_card.dart
    │   ├── quick_log_button.dart
    │   ├── celebration_animation.dart
    │   └── swipe_action_tile.dart
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

---

## 3. Design System

### Color Palette (Warm Pastels)

```dart
// Light Theme
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
6. **Dark mode** — Deep navy backgrounds, warm accent colors preserved

### Key Screens

1. **Onboarding** — Pet type → breed → name → free trial start
2. **Home** — Pet cards, quick-log (feed, med, weight, behavior), health at a glance
3. **Track** — Detailed logging forms (feeding, vaccination, medication, weight, behavior)
4. **Calendar** — Monthly/weekly view of health events, quick-add
5. **Family** — Family members, shared pets, activity feed, invite
6. **Profile/Settings** — Account, notifications, privacy, subscription
7. **Premium Paywall** — Feature comparison, pricing tiers, upgrade CTA

---

## 4. Feature Specification

### Free Tier (No Paywall)

| Feature | Limit |
|---------|-------|
| Pet profiles | 1 |
| Health logs | Unlimited |
| Calendar history | 7 days rolling |
| Reminders | Up to 3 active |
| Family sharing | 2 members |
| Data export | CSV |
| Health score | Basic |
| Analytics | Last 7 days |

### Premium Tier ($6.99/mo or $49.99/yr)

| Feature | Detail |
|---------|--------|
| Pet profiles | Unlimited |
| Calendar history | Unlimited |
| Reminders | Unlimited |
| AI health insights | Weight trends, anomaly detection, recommendations |
| Data export | CSV + vet-ready PDF |
| Health score | Advanced (composite wellness metric) |
| Analytics | Full historical trends, interactive charts |
| Family sharing | Up to 5 members |
| Pet-sitter access | Temporary credentials |
| Dark mode | Full support |
| Ad-free | Yes |

### Family Tier ($9.99/mo or $79.99/yr)

| Feature | Detail |
|---------|--------|
| All Premium features | Yes |
| Family members | Unlimited |
| Shared pet profiles | Multi-user editing |
| Role-based access | Owner, editor, viewer, pet-sitter |
| Priority support | Yes |

---

## 5. Task Tracking — Beads Structure

All 50 tasks are tracked in beads (`.beads/`). The plan is organized into **10 epics**:

| Epic | ID | Tasks | Priority | Dependencies |
|------|----|-------|----------|-------------|
| **Foundation & Architecture** | d0e | 12 | P0 | None — starts first |
| **Core App Shell & Navigation** | g61 | 7 | P0 | Foundation |
| **Pet Profiles & Management** | 5xa | 7 | P1 | Foundation + Core Shell |
| **Health Tracking Engine** | 75v | 9 | P1 | Pet Profiles |
| **Calendar & Reminders** | a1x | 6 | P1 | Health Tracking + Core Shell |
| **Family Collaboration** | 8og | 7 | P2 | Health Tracking + Calendar + Core Shell |
| **Monetization & Premium** | rm1 | 7 | P2 | Pet Profiles + Health + Family |
| **Gamification & Engagement** | d8b | 6 | P2 | Health Tracking + Calendar |
| **AI Insights & Advanced** | afx | 6 | P3 | Health Tracking + Monetization + Gamification |
| **Polish, Testing & Launch** | ced | 9 | P3 | All epics above |

### Execution Order (Critical Path)

```
Foundation → Core Shell → Pet Profiles → Health Tracking → Calendar → Family → Monetization → Gamification → AI → Polish & Launch
```

### Key Milestones

1. **M1 — Working App Shell:** Foundation + Core Shell complete (builds, runs, navigates)
2. **M2 — Pet Profiles + Tracking:** Pet Profiles + Health Tracking complete (core value)
3. **M3 — Calendar + Reminders:** Calendar + Reminders + Gamification (habit formation)
4. **M4 — Family + Monetization:** Family + Monetization (revenue generation)
5. **M5 — AI Insights:** AI features (differentiation)
6. **M6 — Launch Ready:** Testing, polish, app store (production release)

---

## 6. Key Technical Decisions

### Offline-First Architecture

- **Why:** Pet owners need app access at the vet, during walks, in areas with poor connectivity
- **How:** SQLite for all tracking data → syncs to Firestore when online
- **Conflict Resolution:** Last-write-wins for health logs; manual resolution for family edits

### RevenueCat Over Direct Store Integration

- **Why:** Single SDK handles iOS + Android subscription logic, receipt validation, webhooks
- **Benefit:** Saves ~200 hours of billing code; built-in A/B testing for paywalls
- **Integration:** `RevenueCat` package → abstract `BillingService` interface

### Riverpod Over Bloc/Provider

- **Why:** Type-safe providers, compile-time error detection, easier testing
- **Pattern:** `AsyncNotifierProvider` for data fetching, `NotifierProvider` for local state

### Clean Architecture Over MVC

- **Why:** Feature modules are independently testable, swap data sources, clear ownership
- **Structure:** Each feature has presentation/domain/data sub-folders

---

## 7. Risk Mitigation

| Risk | Mitigation |
|------|-----------|
| **"PawTable" trademark conflict** | Backup names prepared (PetlyTable, PawSpace, TailTable); legal review before launch |
| **Low freemium conversion** | A/B test paywall placement, trial length, pricing; target 5-7% |
| **Family sync conflicts** | Firestore conflict resolution; clear UI for merge decisions |
| **App store rejection** | GDPR compliance from day one; clear privacy policy; no hidden data collection |
| **Battery drain from FCM** | Batch notifications; use WorkManager for periodic sync |
| **Flutter rendering performance** | Profile early; use `const` constructors; limit rebuild scope |

---

## 8. Success Metrics

| Metric | Target (Month 6) | Target (Month 12) |
|--------|-----------------|-------------------|
| Downloads | 25,000 | 75,000 |
| MAU | 8,000 | 25,000 |
| Freemium conversion | 5% | 7% |
| Annual plan share | 70% | 75% |
| Day 30 retention (paid) | 65% | 75% |
| App Store rating | 4.5+ | 4.7+ |
| Crash-free users | 98% | 99.5% |

---

*Design document v1.0. All tasks tracked in beads — see `bd list` or `.beads/` for full task breakdown.*
