# Aesthetica

Premium Flutter fitness application with AI workouts, combat training, smart tracking, and gamification.

## Features

- **Dashboard** — Activity rings, daily progress, weekly charts, body metrics
- **800+ exercises** — Searchable library with categories and difficulty filters
- **Live workout sessions** — Rep counter, rest timer, set tracking, XP rewards
- **AI workout generator** — Personalized plans based on goals, BMI, experience
- **Combat fitness** — Boxing, Muay Thai, MMA with live session player
- **Smart tracker** — Water, mood, energy, recovery, body measurements (persisted)
- **Analytics** — Weekly/monthly/yearly charts
- **Gamification** — XP, levels, streaks, coins, achievements
- **Auth** — Email sign-up/sign-in, guest mode (local); Firebase-ready for cloud sync
- **Notifications** — Local workout and hydration reminders

## Getting Started

### Prerequisites

- Flutter 3.38+ / Dart 3.10+
- Android Studio or Xcode for device builds

### Run

```bash
flutter pub get
flutter run
```

### First launch flow

1. Splash → Onboarding → Login (or Guest)
2. Complete a workout from **Workouts** or **AI Generator**
3. Track metrics in **Tracker** — data saves to Hive locally

## Architecture

```
lib/
├── core/           # Theme, router, widgets, services
├── data/           # Models, repositories, exercise database
├── features/       # Feature screens (dashboard, workouts, auth, etc.)
├── app.dart
└── main.dart
```

- **State:** Riverpod (`StateNotifier` for user/auth)
- **Navigation:** GoRouter with auth + onboarding guards
- **Storage:** Hive (profile, tracker, workout history) + SharedPreferences (flags)
- **Notifications:** flutter_local_notifications

## Firebase (optional)

For cloud auth, Firestore sync, and push notifications:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Then add to `pubspec.yaml`: `firebase_core`, `firebase_auth`, `cloud_firestore`, etc.

## Project structure

| Route | Screen |
|-------|--------|
| `/` | Splash |
| `/onboarding` | Onboarding |
| `/login`, `/signup` | Authentication |
| `/home` | Dashboard |
| `/home/workouts` | Exercise library |
| `/workout/session` | Live workout player |
| `/combat/:id` | Combat session |
| `/ai-generator` | AI plan generator |
| `/profile/edit` | Profile editor |
| `/settings/notifications` | Reminder settings |

## License

Private project — not for publication.
