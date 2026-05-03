<div align="center">

<img src="assets/images/logo.png" alt="EventNexus Logo" width="120" height="120" />

# EventNexus

**A college event management platform built with Flutter & Supabase.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Powered-3FCF8E?logo=supabase&logoColor=white)](https://supabase.com)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)

</div>

---

> **This document is the complete reference for project presentation, viva, and explanation.**
> Every section is written so any team member can pick it up and speak confidently.

---

## Table of Contents

1. [The Idea — What Problem We Are Solving](#1-the-idea--what-problem-we-are-solving)
2. [What is EventNexus](#2-what-is-eventnexus)
3. [Tech Stack](#3-tech-stack)
4. [Architecture & Design Decisions](#4-architecture--design-decisions)
5. [Database Design](#5-database-design)
6. [How the App Works — Student Flow](#6-how-the-app-works--student-flow)
7. [How the App Works — Admin Flow](#7-how-the-app-works--admin-flow)
8. [Authentication System](#8-authentication-system)
9. [Key Code Concepts](#9-key-code-concepts)
10. [How to Present (Viva Guide)](#10-how-to-present-viva-guide)
11. [Anticipated Viva Questions & Answers](#11-anticipated-viva-questions--answers)
12. [Future Scope](#12-future-scope)
13. [Local Setup](#13-local-setup)

---

## 1. The Idea — What Problem We Are Solving

### The Problem

In most colleges, event management is completely manual and fragmented:
- Events are announced through WhatsApp groups, notice boards, or word of mouth.
- Students miss events because there is no centralized place to see what is happening.
- Registration is done through Google Forms or paper, making it error-prone and hard to track.
- Organizers have no real-time visibility into how many students registered.
- There is no proof of registration — students cannot show anything at the event entrance.
- Admins spend significant time managing spreadsheets, counting seats, and tracking attendance.

### The Solution

**EventNexus** is a mobile application that acts as a single platform for all college events. It connects students and event organizers through a clean, fast, and reliable interface. Students discover events, register in one tap, and carry a digital ticket on their phone. Admins create and manage events, track real-time registrations, and view analytics — all from the same app.

The key insight is: **one app, two roles, zero paperwork.**

---

## 2. What is EventNexus

EventNexus is a **cross-platform mobile application** (Android-first, iOS-capable) built for college campuses. It supports two distinct user roles:

- **Students** — browse, search, register, and manage their event bookings.
- **Admins** — create and manage events, monitor seat occupancy, and view registration analytics.

The app uses a **role-detection system based on email address**. When a user logs in, the app checks their email against a whitelist of admin emails. If they match, they are sent to the Admin Dashboard. Everyone else gets the Student experience.

### Core Values
| Value | How it is implemented |
|---|---|
| **Speed** | All data loads in parallel using `Future.wait`; screens never block on a single slow call |
| **Reliability** | Supabase Postgres is a battle-tested backend; data persists across sessions |
| **Simplicity** | One-tap registration, clean UI, no unnecessary screens |
| **Transparency** | Students always know seat availability; admins see live counts |

---

## 3. Tech Stack

### Frontend
| Technology | Version | Purpose |
|---|---|---|
| **Flutter** | 3.x | Cross-platform UI framework (single codebase for Android & iOS) |
| **Dart** | 3.x | Programming language used by Flutter |
| **Material Design 3** | Built-in | UI component system and theming |

### Backend / Cloud
| Technology | Version | Purpose |
|---|---|---|
| **Supabase** | 2.8.4 (Flutter SDK) | Backend-as-a-service: database, auth, real-time, storage |
| **PostgreSQL** | Managed by Supabase | Relational database storing events and registrations |
| **Supabase Auth** | Built-in | Handles sign-up, login, OTP email verification, password reset |
| **Row Level Security (RLS)** | PostgreSQL feature | Ensures users can only access their own data |

### Key Flutter Packages
| Package | Purpose |
|---|---|
| `supabase_flutter ^2.8.4` | Connects the Flutter app to the Supabase cloud backend |
| `video_player ^2.8.5` | Video playback capability (e.g., event promo videos) |
| `cached_network_image ^3.3.1` | Efficiently loads and caches event poster images from URLs |
| `intl ^0.19.0` | Date/time formatting for event dates and booking timestamps |
| `cupertino_icons ^1.0.2` | iOS-style icons alongside Material icons |

### Why These Technologies?

**Why Flutter?**
- One codebase compiles to both Android and iOS — saves 50% development time.
- Hot reload makes UI development extremely fast.
- Rich widget library means we built custom ticket designs, animations, and complex layouts without any extra libraries.

**Why Supabase?**
- It is an open-source Firebase alternative with a real PostgreSQL database (not a document store).
- We get authentication, database, and Row Level Security out of the box for free.
- The Flutter SDK is first-class and makes querying the database as simple as calling `.select()`, `.insert()`, `.update()`.
- No need to write a separate REST API or backend server — Supabase IS the backend.

**Why PostgreSQL (through Supabase)?**
- Relational data model is perfect for events and registrations (one event has many registrations — a classic one-to-many relationship).
- SQL queries are powerful, predictable, and well-understood.

---

## 4. Architecture & Design Decisions

### App Architecture

EventNexus follows a **layered architecture**:

```
┌─────────────────────────────────────────┐
│              UI Layer (Screens)          │  lib/screens/
│   student/          admin/               │
├─────────────────────────────────────────┤
│           Service Layer                  │  lib/services/
│  AuthService  EventService  AdminService │
├─────────────────────────────────────────┤
│           Model Layer                    │  lib/models/
│              AppUser                     │
├─────────────────────────────────────────┤
│         Config / Constants               │  lib/config/
│    SupabaseConfig   AdminAccess          │
├─────────────────────────────────────────┤
│       Supabase Cloud (PostgreSQL)        │  Remote
└─────────────────────────────────────────┘
```

### Role-Based Navigation

When a user successfully logs in, the app checks their email:

```
Login → AuthService.signIn() → success
       → Check: AdminAccess.isAdminEmail(email)
              YES → Navigate to AdminDashboardScreen
              NO  → Navigate to MainScreen (student)
```

The `AdminAccess` class holds a hardcoded `Set` of admin email addresses. This is a **whitelist approach** — secure and simple for a college-scale application.

### State Management

We use **Flutter's built-in `setState`** for local UI state. This is intentional — the app is straightforward enough that introducing Redux/BLoC/Riverpod would add unnecessary complexity. Each screen manages its own loading state, error state, and data.

### Navigation Pattern

- **Student app**: `MainScreen` uses a `PageView` with a `BottomNavigationBar`. Switching tabs is instant (no page rebuilds) because `PageView` keeps all pages alive.
- **Admin app**: `AdminDashboardScreen` has its own bottom navigation that shares the same tab indices, allowing the admin to jump to the student-facing tabs as well.

### Widget Reuse

Custom widgets in `lib/widgets/`:
- `AnimatedTextField` — animated input field used on login/register screens
- `GradientButton` — consistent CTA button with gradient styling
- `WaveClipper` — custom `CustomClipper` that creates the wave shape on the login screen header
- `EventNexusLogo` — reusable branded logo widget

Custom painters:
- `_DotPatternPainter` — draws a subtle dot texture on the ticket's dark section
- `_DashedLinePainter` — draws the dashed perforation line on the ticket tear strip

---

## 5. Database Design

### Tables

#### `events` table
| Column | Type | Description |
|---|---|---|
| `id` | UUID (PK) | Unique identifier for each event |
| `title` | TEXT | Name of the event |
| `description` | TEXT | Detailed description |
| `category` | TEXT | One of: Workshops, Hackathons, Cultural, Sports, Seminar, Other |
| `date` | TIMESTAMPTZ | Event date and time (stored in UTC) |
| `venue` | TEXT | Physical location |
| `organizer` | TEXT | Name of the organizing club or department |
| `price` | INTEGER | Entry fee in rupees; 0 means the event is free |
| `total_seats` | INTEGER | Maximum capacity |
| `seats_left` | INTEGER | Remaining available seats (decremented on registration) |
| `image_url` | TEXT | URL of the event poster/banner image |
| `status` | TEXT | One of: Upcoming, Ongoing, Completed |
| `created_at` | TIMESTAMPTZ | Record creation timestamp |

#### `registrations` table
| Column | Type | Description |
|---|---|---|
| `id` | UUID (PK) | Unique identifier for this registration record |
| `booking_id` | TEXT | Human-readable ID in format `EN-XXXXXX` (e.g., EN-A3F7K2) |
| `user_id` | UUID (FK → auth.users) | References the Supabase Auth user |
| `event_id` | UUID (FK → events.id) | References which event was registered for |
| `user_email` | TEXT | Email of the student at time of registration |
| `user_name` | TEXT | Name of the student at time of registration |
| `registered_at` | TIMESTAMPTZ | When the registration happened |
| `status` | TEXT | Always `confirmed` for successful registrations |
| `created_at` | TIMESTAMPTZ | Record creation timestamp |

### Relationships

```
events (1) ──────────── (many) registrations
auth.users (1) ────────── (many) registrations
```

One event can have many registrations. One user can have many registrations (for different events). A user **cannot register for the same event twice** — this is enforced in `EventService.registerForEvent()` by checking for an existing record before inserting.

### Booking ID Generation

Booking IDs are generated client-side using a random alphanumeric string:

```
Format: EN-XXXXXX
Example: EN-A3F7K2
```

The `EN` prefix stands for EventNexus. The 6-character suffix is generated from a random selection of uppercase letters and digits using `dart:math`.

### Seat Management

When a student registers:
1. App checks `seats_left > 0` on the event.
2. App inserts a new row into `registrations`.
3. App decrements `seats_left` on the `events` row by 1.

This prevents overbooking. The check and decrement are two separate operations — in a production system this would be a database transaction or an RPC call, which is a noted improvement opportunity.

---

## 6. How the App Works — Student Flow

### Step 1: Splash Screen
When the app opens, the `SplashScreen` plays a sequenced animation:
1. A ripple effect expands outward.
2. The EventNexus logo scales in with an elastic bounce.
3. The tagline slides up and fades in.
4. After ~1.8 seconds, the app navigates to the Login screen.

### Step 2: Authentication
**Register:**
- Student fills in: Name, Email, Password.
- App calls `AuthService.registerWithEmailAndPassword()`.
- Supabase creates a user in `auth.users` and sends a verification email.
- Student is redirected to the `EmailVerificationScreen` which shows an OTP entry field.
- On successful OTP verification, the student is taken to the main app.

**Login:**
- Student enters Email and Password.
- App calls `AuthService.signInWithEmailAndPassword()`.
- On success, the app checks `AdminAccess.isAdminEmail(email)`:
  - If the email is in the admin whitelist → `AdminDashboardScreen`.
  - Otherwise → `MainScreen` (student home).

**Forgot Password:**
- Student enters their email.
- App calls `AuthService.sendPasswordResetEmail()`.
- Supabase sends a reset link to the email.

### Step 3: Home Screen (Event Discovery)

The `HomeScreen` is the first tab of the student app. It loads all events from the `events` table and simultaneously fetches the set of event IDs the logged-in user has already registered for — both calls are made in **parallel** using `Future.wait`.

**Category Tabs:** A horizontally scrollable row at the top shows tabs: All, Workshops, Hackathons, Cultural, Sports, Seminar, Other. Tapping a category filters the event list in real time.

**Event Cards:** Each card shows:
- Event poster image (loaded via `cached_network_image` for performance).
- Title, category badge (color-coded), date, venue.
- Total seats and seats left.
- Price (shows "FREE" for Rs 0 events).
- A "Registered" green badge if the student already signed up.

**Tapping an event card** opens a `ModalBottomSheet` (`EventDetailSheet`) with the full event details and a registration button.

### Step 4: Event Registration

Inside `EventDetailSheet`:
1. The sheet first checks (via `EventService.isUserRegistered`) whether the student is already registered — if yes, the button shows "Already Registered".
2. If seats are available and not already registered, the student taps **Register Now**.
3. `EventService.registerForEvent()` runs:
   - Checks for duplicate registration.
   - Checks `seats_left > 0`.
   - Generates a unique `booking_id` (EN-XXXXXX).
   - Inserts the registration record into Supabase.
   - Decrements `seats_left` on the event.
4. A success dialog is shown. The home screen refreshes to show the "Registered" badge.

### Step 5: Search Screen

The `SearchScreen` (second tab) lets students find events by:
- **Text search**: typing in the search bar filters events by title in real time.
- **Category filter**: the same category row from the home screen.
- Both filters work **together** — you can search for "AI" within "Workshops" only.

### Step 6: Bookings Screen

The `BookingsScreen` (third tab) calls `EventService.getUserRegistrations(userId)` which fetches all `registrations` records for the logged-in user, joined with the related `events` data. Each booking card shows:
- Event title, category, date.
- Venue, organizer.
- Event status badge (Upcoming / Ongoing / Completed).
- Booking ID.

Tapping a booking opens the full **Ticket Screen**.

### Step 7: Ticket Screen

The `TicketScreen` renders a physical-style event ticket with:
- **Top dark section**: EventNexus branding, category badge, event title, date/time, venue, organizer, and entry fee strip.
- **Tear line**: A perforated dashed line with semicircular notches on both sides, mimicking a real paper ticket.
- **Bottom stub**: "BOOKING CONFIRMED" badge, Booking ID in monospace font, registration timestamp, and a QR code placeholder icon.
- The AppBar has a **copy icon** that copies the Booking ID to the clipboard.

### Step 8: Profile Screen

The `ProfileScreen` (fourth tab) shows:
- User's name and email.
- Member since date.
- Total events registered and upcoming events count.
- An **Edit Profile** option to update name/email.
- **Sign Out** button.
- If the logged-in user's email is in the admin whitelist, a special **"Switch to Admin"** button appears that navigates to the Admin Dashboard.

---

## 7. How the App Works — Admin Flow

### Accessing Admin Mode

Admins log in with the same login screen as students. The app detects the admin role via `AdminAccess.isAdminEmail()`. There is no separate admin login URL or password — the role is granted by email address inclusion in the whitelist defined in `lib/config/admin_access.dart`.

### Admin Dashboard Screen

The first thing an admin sees is the `AdminDashboardScreen`. It loads **5 statistics in parallel** using `Future.wait`:
1. Total number of events in the database.
2. Total registrations across all events.
3. Number of Upcoming events.
4. Number of Ongoing events.
5. Seat statistics: total seats across all events vs. filled seats.

These are displayed as **stat cards** with icons and colors:
- Total Events (blue)
- Total Registrations (green)
- Upcoming Events (orange)
- Ongoing Events (purple)
- Seat Occupancy: shows filled/total as a fraction

The dashboard also has **Quick Action buttons** to immediately jump to:
- Create Event
- Manage Events
- View Analytics

### Create Event Screen

The `CreateEventScreen` is a full form with validated inputs:
| Field | Input Type | Validation |
|---|---|---|
| Title | Text field | Required |
| Description | Multi-line text | Required |
| Category | Dropdown | Workshops / Hackathons / Cultural / Sports / Seminar / Other |
| Date & Time | Date picker + Time picker | Required |
| Venue | Text field | Required |
| Organizer | Text field | Required |
| Price | Number field | 0 = Free |
| Total Seats | Number field | Required |
| Image URL | Text field | Optional (event poster) |
| Status | Dropdown | Upcoming / Ongoing / Completed |

The same screen is reused for **editing** — if `eventData` is passed as a constructor argument, all fields are pre-populated. The submit button reads "Update Event" instead of "Create Event".

### Manage Events Screen

The `ManageEventsScreen` lists all events in a tab-based layout with category filtering. For each event, the admin can:
- **Edit**: opens the `CreateEventScreen` pre-filled with the event's data.
- **Delete**: shows a confirmation dialog, then calls `AdminService.deleteEvent(id)` to remove the record.
- **View Registrations**: navigates to `EventRegistrationsScreen` for that specific event.

### Event Registrations Screen

The `EventRegistrationsScreen` shows all students who registered for a specific event. It fetches from the `registrations` table filtered by `event_id`. The admin sees each registrant's:
- Name and email.
- Booking ID.
- Registration timestamp.

There is a **search bar** to find a specific student by name or email.

### Analytics Screen

The `AnalyticsScreen` gives the admin deep insights:
- **Events by Category**: shows how many events exist per category (Workshops, Cultural, etc.).
- **Events by Status**: breakdown of Upcoming vs. Ongoing vs. Completed.
- **Revenue Estimate**: for paid events, calculates `price × (total_seats - seats_left)` for each event and sums them up to estimate total revenue collected.
- **Individual event cards** showing each event's occupancy rate.

---

## 8. Authentication System

### How Supabase Auth Works

Supabase Auth is a JWT-based authentication system backed by PostgreSQL. Here is what happens at each step:

**Sign Up:**
- We call `_client.auth.signUp(email, password, data: {name})`.
- Supabase creates a record in its internal `auth.users` table.
- It sends a confirmation email with an OTP code.
- Until the email is verified, the user's session is considered unconfirmed.

**OTP Verification:**
- User enters the 6-digit code from their email.
- We call `_client.auth.verifyOTP(email, token, type: OtpType.email)`.
- On success, Supabase issues a JWT access token and a refresh token.

**Login:**
- We call `_client.auth.signInWithPassword(email, password)`.
- Supabase validates credentials and returns a session with JWT + refresh token.
- The Flutter SDK stores the session in secure local storage automatically.

**Session Persistence:**
- The Supabase Flutter SDK automatically persists and restores sessions.
- On app restart, if a valid session exists, the user does not need to log in again.
- JWT tokens expire (typically after 1 hour) and are auto-refreshed using the refresh token.

**Password Reset:**
- We call `_client.auth.resetPasswordForEmail(email)`.
- Supabase sends an email with a reset link (handled out-of-app via web browser).

**Sign Out:**
- We call `_client.auth.signOut()`.
- The local session is cleared and the user is navigated back to the Login screen.

### AppUser Model

The app defines its own `AppUser` model:
```dart
class AppUser {
  final String id;       // Supabase UUID
  final String email;
  final String? name;    // From user_metadata
  final DateTime? createdAt;
}
```

`AuthService.currentUser` maps the Supabase `User` object to this internal `AppUser`, keeping the UI layer independent of Supabase-specific types.

---

## 9. Key Code Concepts

### Parallel Data Loading with `Future.wait`

Instead of making sequential async calls (which would be slow), we load multiple data sources simultaneously:

```dart
final futures = await Future.wait([
  EventService.getAllEvents(),
  EventService.getRegisteredEventIds(user.id),
]);
```

Both database calls run at the same time. We only process results after both complete. This roughly halves the loading time compared to awaiting them one after another.

### Custom Painter for Ticket UI

The ticket's perforated tear line is drawn using Flutter's `CustomPainter` — there is no image or SVG involved:
- `_DashedLinePainter` — draws horizontal dashed line using `canvas.drawLine()` in a loop.
- `_DotPatternPainter` — draws a grid of tiny circles as a subtle texture on the dark background.

This demonstrates knowledge of Flutter's low-level drawing API.

### Role Detection Pattern

```dart
// lib/config/admin_access.dart
class AdminAccess {
  static const Set<String> _adminEmails = {
    'fullsd206@gmail.com',
    'rizvisakeena16@gmail.com',
  };

  static bool isAdminEmail(String? email) {
    if (email == null) return false;
    return _adminEmails.contains(email.trim().toLowerCase());
  }
}
```

Using a `Set` for lookup is O(1) — it is the most efficient data structure for membership checks. The `toLowerCase()` call prevents case-sensitivity bugs.

### Booking ID Generation

```dart
// Inside EventService
static String _generateBookingId() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = Random();
  final suffix = String.fromCharCodes(
    Iterable.generate(6, (_) => chars.codeUnitAt(random.nextInt(chars.length)))
  );
  return 'EN-$suffix';
}
```

Generates a human-readable unique ID like `EN-A3F7K2`. The `EN` prefix identifies it as an EventNexus booking at a glance.

### Error Handling in Services

All service methods wrap database calls in try-catch blocks. When an error occurs:
- The error is logged with `debugPrint` (only visible in debug mode, not in production builds).
- The method returns a safe fallback (empty list, `false`, or `0`).
- Error messages are stored in `_lastErrorMessage` static variable so the UI can display them if needed.

---

## 10. How to Present (Viva Guide)

### Opening Statement (30 seconds)

> "We built EventNexus to solve a real problem we face as students every day — missing college events because there is no central place to find them, and dealing with manual Google Form registrations that have no tracking. EventNexus is a mobile app with two sides: students discover and register for events in one tap and carry a digital ticket, while admins create events, manage seats, and see live analytics. Everything is built on Flutter for the cross-platform UI and Supabase for the cloud backend."

### Demonstration Flow

Follow this order when showing the app live:

1. **Splash screen** → mention the animated intro (ripple, logo bounce, text slide).
2. **Register a new student account** → show OTP verification email flow.
3. **Login as student** → walk through Home screen tabs (All, Workshops, etc.).
4. **Tap an event card** → show EventDetailSheet with full details, seats left, price.
5. **Register for an event** → show the success dialog, point out the booking ID format (EN-XXXXXX).
6. **Go to Bookings tab** → show the booking card with event status badge.
7. **Tap the booking** → show the ticket screen — explain the tear-line design, the QR placeholder, the copy button.
8. **Go to Search tab** → demonstrate live text filtering + category combo.
9. **Go to Profile tab** → show stats (total registered, upcoming). Show "Switch to Admin" button.
10. **Switch to Admin Dashboard** → show the 5 stat cards loaded in parallel.
11. **Create a new event** → fill in the form, submit.
12. **Manage Events** → show edit and delete options.
13. **View Registrations for an event** → show the student list.
14. **Analytics screen** → explain revenue estimate, category breakdown.

### What to Emphasize

- **Real backend**: This is not a mock app. Data is stored in a live PostgreSQL database in the cloud.
- **Role-based system**: One app, two completely different experiences based on who logs in.
- **Live seat tracking**: Every registration decrements `seats_left` in real time.
- **Parallel loading**: We used `Future.wait` to load data efficiently.
- **Custom ticket design**: The perforated ticket is drawn entirely in Flutter using CustomPainter — no images used.
- **No extra backend server**: Supabase handles auth, database, and security rules so we focused entirely on the app.

### If Asked "What was the hardest part?"

> "The hardest part was designing the ticket screen — we wanted it to look like a real physical ticket with a perforated tear line. There is no built-in Flutter widget for this, so we used CustomPainter to draw the dashed line and placed semicircular notches on both edges using positioned containers. Getting the alignment right took significant iteration."

### If Asked "How does security work?"

> "We use Supabase Row Level Security (RLS) policies on the database. This means even if someone gets hold of the API key (which is the public anonymous key), they can only read and write data they are authorized to access. The anonymous key only allows operations that RLS permits — for example, a student can only read their own registrations, not others'. The admin whitelist is checked on the client side for navigation, but the real data restriction happens at the database level through RLS."

---

## 11. Anticipated Viva Questions & Answers

### General / Concept

**Q: What is the main purpose of EventNexus?**
A: To centralize college event discovery, registration, and management. Students no longer need to hunt for events across WhatsApp and notice boards. Admins no longer manage spreadsheets. Everything is in one app.

**Q: Who are the users of this app?**
A: Two types — Students, who are the primary users, and Admins (event organizers or college staff) who manage the event catalog.

**Q: How do you differentiate between a student and an admin?**
A: When a user logs in, their email is checked against a hardcoded whitelist in `AdminAccess`. If the email matches, they are routed to the Admin Dashboard. Everyone else gets the Student interface. This is a simple, secure, and zero-configuration role system appropriate for a college-scale app.

**Q: What happens if a student tries to access admin screens directly?**
A: Admin screens are only reachable through navigation that is guarded by the admin check. A student account would never be navigated to admin screens because the routing decision is made at login. Additionally, Supabase RLS policies on the database would prevent unauthorized data mutations even if someone tried to call the APIs directly.

---

### Tech Stack

**Q: Why did you choose Flutter over React Native or native Android?**
A: Flutter gives us a single codebase for both Android and iOS with no compromise on performance because it compiles to native ARM code. The widget system is extremely flexible — we built the custom ticket design, custom painters, and animations entirely with Flutter's built-in tools. React Native relies on a JavaScript bridge which can cause performance issues for animations. Native Android would require separate iOS development.

**Q: Why Supabase instead of Firebase?**
A: Supabase uses PostgreSQL — a proper relational database. Firebase uses Firestore which is a NoSQL document database. Our data (events and registrations) has a clear relational structure: one event has many registrations. SQL joins and foreign keys are the natural fit. Supabase also provides Row Level Security which is more granular and explicit than Firebase security rules. Finally, Supabase is open-source.

**Q: What is Supabase?**
A: Supabase is a Backend-as-a-Service that provides a PostgreSQL database, authentication, file storage, and real-time subscriptions. We use it as our complete backend — no separate Express/Node server, no separate auth system. The Supabase Flutter SDK allows us to interact with the database directly from the app using a simple, chainable API.

**Q: What is a Backend-as-a-Service (BaaS)?**
A: It is a cloud service that provides pre-built backend infrastructure — authentication, database, storage, APIs — so developers do not need to build and host a backend server from scratch. We write the frontend app, and Supabase handles everything on the server side.

**Q: What is JWT (JSON Web Token)?**
A: JWT is the token format used by Supabase Auth. After a successful login, Supabase issues a JWT that the Flutter SDK includes in every subsequent API request as a Bearer token. The database uses this token to identify who is making the request and applies Row Level Security policies accordingly.

---

### Flutter / Dart

**Q: What is Flutter's widget tree?**
A: In Flutter, everything is a widget — buttons, text, layouts, padding. Widgets are arranged in a tree structure. Parent widgets contain child widgets. When state changes, Flutter rebuilds only the affected subtree, making it efficient.

**Q: What is `setState` and when do you use it?**
A: `setState` is Flutter's way of telling the framework that some data has changed and the screen should be redrawn. You call it inside a `StatefulWidget` when you update a variable that affects the UI — for example, when data loads from the database, you call `setState` to set `_isLoading = false` and populate the list.

**Q: What is `async/await` in Dart?**
A: Dart is single-threaded. `async/await` allows long-running operations (like network calls) to run without blocking the UI. When you `await` a `Future`, Dart pauses that function and lets other code run, then resumes when the result is ready.

**Q: What is `Future.wait`?**
A: `Future.wait` takes a list of Futures and runs them concurrently, returning when all of them complete. We use it to load multiple database tables simultaneously instead of sequentially, which reduces the total loading time.

**Q: What is `CustomPainter`?**
A: `CustomPainter` is a Flutter class that gives you a `Canvas` object to draw arbitrary shapes — lines, circles, arcs, paths. We used it to draw the dashed perforation line and the dot texture pattern on the ticket screen.

**Q: What is `PageView` and why did you use it for navigation?**
A: `PageView` is a scrollable list of full-screen pages. Unlike `Navigator.push`, switching between `PageView` pages is instant — all pages are kept in memory. Combined with `BottomNavigationBar`, it creates the standard mobile app navigation pattern where tab switching feels immediate and smooth.

**Q: Explain `StatefulWidget` vs `StatelessWidget`.**
A: `StatelessWidget` is immutable — its UI is fixed based on the properties passed to it. `StatefulWidget` has a `State` object that can change over time, causing the widget to rebuild. We use `StatelessWidget` for purely presentational pieces (like the ticket info rows) and `StatefulWidget` for screens that load data or respond to user interaction.

---

### Database / Backend

**Q: What is Row Level Security (RLS)?**
A: RLS is a PostgreSQL feature that lets you define policies controlling which rows a database user can read, insert, update, or delete. For example: a policy can say "a user can only SELECT rows from `registrations` where `user_id` equals their own JWT user ID." This means the database itself enforces data privacy, not just the application code.

**Q: What is a foreign key?**
A: A foreign key is a database constraint that links a column in one table to the primary key of another table. In our `registrations` table, `event_id` is a foreign key referencing `events.id`. This enforces referential integrity — you cannot have a registration pointing to an event that does not exist.

**Q: How do you prevent a student from registering for the same event twice?**
A: Before inserting a new registration, `EventService.registerForEvent()` queries the `registrations` table for an existing record where both `user_id` AND `event_id` match the current request. If a row is found, the registration is rejected with the message "Already registered for this event."

**Q: How is seat availability tracked?**
A: Each event has two columns: `total_seats` (set when the event is created) and `seats_left` (decremented by 1 each time a student registers). The `seats_left` value is checked before registering — if it is 0 or less, registration is rejected.

**Q: How is the booking ID generated? Is it guaranteed to be unique?**
A: It is a client-side random 6-character alphanumeric string prefixed with "EN-". The character set has 36 characters (26 letters + 10 digits), giving 36^6 = ~2.17 billion combinations. For a college-scale app with a few thousand registrations, collisions are extremely unlikely. In a production system, a database UNIQUE constraint on `booking_id` with a retry mechanism would guarantee uniqueness.

---

### Design & UX

**Q: Why does the ticket have that perforated design?**
A: We wanted the ticket to feel like a real physical event ticket that you would receive at a concert or conference. The dashed tear line and semicircular notches on the sides are standard visual language for a ticket. It makes the digital ticket feel tangible and memorable for the student.

**Q: How did you make the category filtering work without a database call?**
A: When the Home or Search screen loads, it fetches ALL events once. The category tabs then filter this local list in memory using Dart's `List.where()`. This is instant because no network call is made on each tab tap — the data is already in the widget's state.

**Q: Why do you cache network images?**
A: Event poster images can be several hundred KB. If we loaded them fresh from the URL every time a card appears on screen, it would cause visible loading delays and use mobile data unnecessarily. `cached_network_image` stores downloaded images in the device's local cache, so the second time an image is shown it loads instantly.

---

## 12. Future Scope

These are genuine improvements that could be made with more time or in a next version:

### High Priority

| Feature | Description |
|---|---|
| **Real QR Code** | Replace the QR icon placeholder with an actual scannable QR code generated from the booking ID, using a package like `qr_flutter`. Admins can scan it at the entrance to verify attendance. |
| **Push Notifications** | Notify students about upcoming events they registered for, event updates, or new events in their preferred categories. Can be implemented using Supabase Edge Functions + FCM. |
| **Payment Gateway Integration** | For paid events, integrate a payment gateway (Razorpay or Stripe) so the full registration and payment flow happens in-app. Currently, paid events are listed but payment is assumed to happen offline. |
| **Attendance Marking** | Allow admins to mark attendance by scanning QR codes at the event. This updates a new `attended` boolean column on the registration record. |

### Medium Priority

| Feature | Description |
|---|---|
| **Real-time Updates** | Use Supabase's real-time subscriptions (`supabase.from('events').stream()`) so seat counts update live on all devices without needing to pull-to-refresh. |
| **Event Cancellation** | Allow admins to cancel an event, which automatically notifies all registered students and optionally processes refunds. |
| **Waitlist System** | When an event is full, students can join a waitlist. If a registered student cancels, the next person on the waitlist is auto-registered and notified. |
| **Student Cancellation** | Allow students to cancel their own registration before a deadline, which returns the seat to the pool. |
| **Image Upload** | Instead of requiring an image URL, allow admins to upload event poster images directly from their phone to Supabase Storage. |

### Long-term / Advanced

| Feature | Description |
|---|---|
| **Google Sign-In / SSO** | Allow students to log in with their college Google account (the package is already partially included in the `pubspec.yaml`). |
| **Event Feedback & Ratings** | After an event completes, send students a feedback form. Admins can see average ratings per event. |
| **Certificate Generation** | Auto-generate a PDF participation certificate after event completion, sent via email or downloadable from the app. |
| **Multi-College Support** | Add a `college_id` to all tables, allowing the app to serve multiple colleges simultaneously with completely isolated data. |
| **Advanced Analytics** | Charts and graphs for registration trends over time, peak registration hours, category popularity over semesters. |
| **Admin Role Levels** | Instead of a binary admin/student, introduce roles like Super Admin, Event Organizer, and Club Head with different permissions. |
| **Offline Support** | Cache the last-loaded event list locally using `sqflite` (already a dependency) so students can browse events even without internet. |
| **Dark Mode** | The app currently uses a light theme for student screens. A full dark mode toggle would improve usability in low-light environments. |

---

## 13. Local Setup

### Prerequisites
- Flutter SDK 3.x installed ([flutter.dev](https://flutter.dev/docs/get-started/install))
- Android Studio or VS Code with Flutter extension
- A device or emulator running Android 5.0+ (API 21+)

### Steps

```bash
# 1. Clone the repository
git clone <your-repo-url>
cd EventNexusNew

# 2. Install dependencies
flutter pub get

# 3. Run the app (debug mode)
flutter run

# 4. Build a release APK
flutter build apk --release
```

The Supabase URL and anonymous key are already configured in `lib/config/supabase_config.dart`. The app will connect to the live database immediately.

### Admin Access
To log in as admin, use one of the whitelisted emails defined in `lib/config/admin_access.dart`. Regular sign-up with any other email gives student access.

---

<div align="center">
  Built with Flutter & Supabase &nbsp;|&nbsp; EventNexus Team
</div>
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
