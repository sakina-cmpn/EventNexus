<div align="center">

<img src="assets/images/logo.png" alt="EventNexus Logo" width="120" height="120" />

# EventNexus

**A production-grade college event management platform built with Flutter & Supabase.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Powered-3FCF8E?logo=supabase&logoColor=white)](https://supabase.com)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

[Features](#-features) · [Tech Stack](#-tech-stack) · [Architecture](#-architecture) · [Database](#-database-design) · [Setup](#-local-installation) · [Roadmap](#-roadmap)

</div>

---

## Overview

EventNexus is a full-featured college event management app that provides role-aware experiences for students and administrators. Students can discover, search, and register for events, while admins get a powerful dashboard with analytics, event CRUD operations, and registration management — all backed by a real-time Supabase Postgres database with Row Level Security.

---

## ✨ Features

### 🎓 Student Experience
| Feature | Description |
|---|---|
| **Event Discovery** | Browse events by category with rich cards and custom animations |
| **Search** | Live, real-time search and filtering across all events |
| **Event Registration** | One-tap registration with auto-generated booking IDs |
| **Bookings** | View, refresh, and inspect all personal bookings |
| **Profile** | Update display name and email from within the app |
| **Navigation** | Smooth `PageView + BottomNavigationBar` for instant tab switching |

### 🛠️ Admin Experience
| Feature | Description |
|---|---|
| **Dashboard** | Analytics cards: event counts, registrations, seat occupancy, upcoming events |
| **Event Management** | Full Create / Update / Delete flow via service layer |
| **Registration Viewer** | Search and inspect registrations per event |
| **Analytics Screen** | Deep insights by category, status, and activity |
| **Unified Navigation** | Admin dashboard integrates student tabs via bottom navigation |

### 🔐 Authentication
- Email/password sign-up and login via Supabase Auth
- Email OTP verification with resend support
- Forgot password flow
- Secure sign-out from all student screens

---

## 🧰 Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter (Dart) |
| **Backend & Database** | Supabase (Postgres + RLS) |
| **Authentication** | Supabase Auth |
| **Image Loading** | `cached_network_image ^3.3.1` |
| **Video** | `video_player ^2.8.5` |
| **Internationalization** | `intl ^0.19.0` |
| **Supabase SDK** | `supabase_flutter ^2.8.4` |

---

## 🏗️ Architecture

EventNexus follows a clean **Screen → Service → Model** layering pattern that keeps Supabase logic centralized and UI code lean and maintainable.

```
┌─────────────────────────────────────┐
│             screens/                │  UI composition, form validation,
│   (student/ and admin/)             │  navigation, user interactions
└────────────────┬────────────────────┘
                 │ calls
┌────────────────▼────────────────────┐
│             services/               │  Supabase read/write, auth wrappers,
│  auth · event · admin               │  payload building, fallback logic
└────────────────┬────────────────────┘
                 │ returns
┌────────────────▼────────────────────┐
│          models/ + config/          │  AppUser model, Supabase config,
│                                     │  admin email allowlist
└─────────────────────────────────────┘
```

### Folder Structure

```
lib/
├── main.dart
├── config/
│   ├── admin_access.dart          # Admin email allowlist
│   └── supabase_config.dart       # Supabase URL + anon key
├── models/
│   └── app_user.dart
├── services/
│   ├── admin_service.dart         # Admin reads/writes
│   ├── auth_service.dart          # Auth wrappers
│   └── event_service.dart         # Event CRUD
├── screens/
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── email_verification_screen.dart
│   ├── forgot_password_screen.dart
│   ├── admin/
│   │   ├── admin_dashboard_screen.dart
│   │   ├── analytics_screen.dart
│   │   ├── create_event_screen.dart
│   │   ├── event_registrations_screen.dart
│   │   └── manage_events_screen.dart
│   └── student/
│       ├── main_screen.dart
│       ├── home_screen.dart
│       ├── search_screen.dart
│       ├── event_detail_sheet.dart
│       ├── bookings_screen.dart
│       └── profile_screen.dart
└── widgets/
    ├── animated_text_field.dart
    ├── eventnexus_logo.dart
    ├── gradient_button.dart
    └── wave_clipper.dart

assets/
├── images/
└── videos/
```

---

## 🗄️ Database Design

### `events`

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | Primary key |
| `title` | `text` | |
| `description` | `text` | |
| `category` | `text` | |
| `date` | `timestamptz` | App sends ISO 8601 |
| `venue` | `text` | |
| `price` | `int4` / `numeric` | |
| `total_seats` | `int4` | |
| `seats_left` | `int4` | |
| `status` | `text` | e.g. `upcoming`, `ongoing`, `past` |
| `image_url` | `text` | Public URL |
| `organizer` | `text` | |
| `created_at` | `timestamptz` | |

### `registrations`

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | Primary key |
| `booking_id` | `text` | Auto-generated |
| `user_id` | `uuid` | From Supabase Auth |
| `event_id` | `uuid` | FK → `events.id` |
| `user_email` | `text` | |
| `user_name` | `text` | |
| `registered_at` | `timestamptz` | |
| `status` | `text` | e.g. `confirmed` |

---

## 🔑 Authentication & Roles

### Role Model

Admin access is currently controlled via an **email allowlist** in `lib/config/admin_access.dart`:

```dart
static const Set<String> _adminEmails = {
  'admin@yourdomain.com',
};
```

### Navigation Behavior

```
Login
 ├── Standard user  →  Student tabs (Home · Search · Bookings · Profile)
 └── Admin user     →  Admin dashboard + student tabs via bottom nav
```

> ⚠️ **Note:** The email allowlist is a temporary approach. The roadmap includes migrating to a proper `roles` table. For production, **never rely solely on client-side role checks** — enforce admin access via Supabase RLS policies using `auth.jwt()`.

---

## ⚙️ Supabase Setup

1. Create a Supabase project at [supabase.com](https://supabase.com).
2. Enable **Email/Password** auth under Authentication → Providers.
3. Enable **Email OTP verification** if required by your environment.
4. Create the `events` and `registrations` tables using the schema above.
5. Add a foreign key: `registrations.event_id` → `events.id`.
6. Enable RLS and apply policies (see [RLS Policy Guidance](#-rls-policy-guidance)).

### Configure Project Keys

Edit `lib/config/supabase_config.dart`:

```dart
class SupabaseConfig {
  static const url = 'YOUR_SUPABASE_URL';
  static const anonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

> `main.dart` checks `SupabaseConfig.isConfigured` at startup. If the values are empty, the app shows a fallback configuration screen rather than crashing.

---

## 💻 Local Installation

### Prerequisites

- Flutter SDK (stable channel)
- Dart SDK (compatible with your Flutter version)
- Android Studio **or** VS Code with Flutter/Dart extensions
- Xcode (required for iOS/macOS builds on macOS)
- JDK 17 (recommended for Android builds)

### Steps

```bash
# 1. Clone the repository
git clone <your-repo-url>
cd EventNexus

# 2. Install Flutter dependencies
flutter pub get

# 3. Configure Supabase credentials
#    Edit lib/config/supabase_config.dart
#    Edit lib/config/admin_access.dart

# 4. Run static analysis
flutter analyze

# 5. Launch the app
flutter run
```

---

## 🚀 Run & Build

```bash
# Run in development
flutter run

# List connected devices
flutter devices

# Run on a specific device
flutter run -d <device_id>

# Build release APK
flutter build apk --release

# Build release App Bundle (recommended for Play Store)
flutter build appbundle --release
```

---

## 🔒 RLS Policy Guidance

If you see:
```
new row violates row-level security policy for table "events"
```

Apply the following RLS policies in your Supabase SQL editor:

```sql
-- Allow all authenticated users to read events
CREATE POLICY "events_select_authenticated"
ON public.events FOR SELECT
TO authenticated
USING (true);

-- Allow admin emails to insert events
CREATE POLICY "events_insert_admin"
ON public.events FOR INSERT
TO authenticated
WITH CHECK (
  auth.jwt() ->> 'email' IN ('admin@yourdomain.com')
);

-- Allow admin emails to update events
CREATE POLICY "events_update_admin"
ON public.events FOR UPDATE
TO authenticated
USING (auth.jwt() ->> 'email' IN ('admin@yourdomain.com'))
WITH CHECK (auth.jwt() ->> 'email' IN ('admin@yourdomain.com'));

-- Allow admin emails to delete events
CREATE POLICY "events_delete_admin"
ON public.events FOR DELETE
TO authenticated
USING (auth.jwt() ->> 'email' IN ('admin@yourdomain.com'));
```

**Best practices:**
- Store policies in a versioned SQL migrations folder for team consistency.
- Never rely solely on client-side admin checks — always enforce access at the database level.
- Rotate your anon key and service role key regularly.

---

## 🛠️ Troubleshooting

| Symptom | Likely Cause | Fix |
|---|---|---|
| **"Supabase not configured" screen on launch** | Empty URL or anon key | Check `lib/config/supabase_config.dart` |
| **OTP verification doesn't proceed** | OTP not enabled in Supabase | Enable Email OTP under Auth → Settings |
| **Event create fails with RLS error** | Missing or misconfigured insert policy | Apply the `events_insert_admin` policy above; confirm email is in allowlist |
| **Bookings not loading** | Missing RLS select policy on `registrations` | Add a select policy for authenticated users; verify `event_id` FK is valid |
| **Images not rendering** | Invalid or non-public `image_url` | Confirm URLs are publicly accessible; check network permissions |

---

## 🗺️ Roadmap

- [ ] Migrate admin role checks from email allowlist to a proper `roles` table
- [ ] Add versioned SQL migrations folder for schema management
- [ ] Wire up delete flow in the Manage Events UI (service support is ready)
- [ ] Add unit and widget test coverage for services and auth/navigation flows
- [ ] Set up CI pipeline (`flutter analyze`, tests, release build smoke checks)
- [ ] Push notifications for event reminders and booking confirmations
- [ ] QR code-based check-in for event entry

---

## 📄 Additional Documentation

Want to go deeper? The following companion documents can be generated on request:

| Document | Contents |
|---|---|
| `SUPABASE_SETUP.md` | Complete SQL for tables, indexes, RLS policies, and RPC functions |
| `CONTRIBUTING.md` | Branching strategy, commit conventions, and review standards |
| `SECURITY.md` | API key handling, secrets management, and RLS best practices |

---
