# EventNexus 🎫
### College Event Management System
**Shree LR Tiwari College of Engineering**

---

## 👥 Team

| Name | Role |
|------|------|
| Monish Sharma | Team Lead & Flutter Developer |
| Sakina Rizvi | Flutter Developer (Auth & UI) |
| Akshat Sabnis | Flutter Developer |
| Shashank Sharma | Flutter Developer |

---

## 📱 About the Project

EventNexus is a mobile application built for college students and administrators to manage, discover, and register for college events. It solves problems like scattered announcements, missed updates, and manual registrations by providing a centralized platform.

---

## 🧱 Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile App | Flutter (Dart) |
| Backend / Database | Supabase |
| Authentication | Supabase Auth (Email + OTP verification) |
| Admin Panel | React + Vite + Tailwind CSS (coming soon) |

---

## ✅ What Has Been Built So Far

### Splash Screen
- [x] Animated logo splash with ripple effect
- [x] Smooth fade transition to Login screen
- [x] Professional dark navy + blue gradient background

### Login Screen
- [x] Animated wave header
- [x] Email and password fields with validation
- [x] Show/hide password toggle
- [x] Forgot password link
- [x] Verify email link
- [x] Navigate to Register screen
- [x] Error handling with SnackBar

### Register Screen
- [x] Full name, email, password, confirm password fields
- [x] Password strength indicator
- [x] Terms and Conditions checkbox
- [x] Saves user to Supabase Auth on register
- [x] Routes to Email Verification if email confirmation enabled

### Email Verification Screen
- [x] OTP input field
- [x] Verify email with Supabase OTP
- [x] Resend OTP option
- [x] Routes to Home on success

### Forgot Password Screen
- [x] Email input field
- [x] Sends password reset link via Supabase
- [x] Success state with confirmation message

### Home Screen (Student)
- [x] Top bar with logo, notification bell, user dropdown
- [x] User dropdown with My Profile and Sign Out
- [x] Sign Out working and routes back to Login
- [x] Category tabs (All, Workshops, Hackathons, Cultural, Sports)
- [x] Category filter working
- [x] Banner with Unsplash event image
- [x] Event cards with title, category badge, status dot, date, venue
- [x] Free events show Details + Register button
- [x] Paid events show Details button only
- [x] Bottom navigation (Home, Search, Bookings, Profile)

### Navigation
- [x] Bottom navigation bar with 4 tabs
- [x] PageView for instant tab switching
- [x] Placeholder screens for Search, Bookings, Profile

---

## 🗂️ Folder Structure

```
lib/
├── main.dart
├── config/
│   └── supabase_config.dart
├── models/
│   └── app_user.dart
├── services/
│   └── auth_service.dart
├── screens/
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── email_verification_screen.dart
│   ├── forgot_password_screen.dart
│   └── student/
│       ├── main_screen.dart
│       ├── home_screen.dart
│       ├── search_screen.dart
│       ├── bookings_screen.dart
│       └── profile_screen.dart
└── widgets/
    ├── animated_text_field.dart
    ├── eventnexus_logo.dart
    ├── gradient_button.dart
    └── wave_clipper.dart
```

---

## 🗄️ Supabase Setup

### Authentication
- Email and Password auth enabled
- Email OTP verification enabled
- Password reset via email enabled

### Database Collections (Coming Soon)
```
events
  id          — uuid
  title       — string
  description — string
  category    — string
  date        — timestamp
  venue       — string
  price       — number
  totalSeats  — number
  seatsLeft   — number
  status      — string (Upcoming / Ongoing / Completed)
  imageUrl    — string
  createdAt   — timestamp

registrations
  id           — uuid
  userId       — uuid
  eventId      — uuid
  bookingId    — string
  registeredAt — timestamp
  status       — string
```

---

## 🚀 How to Run This Project

### Step 1 — Prerequisites
Make sure you have these installed:
- Flutter SDK (latest stable)
- Android Studio
- VS Code with Flutter and Dart extensions
- Java JDK 17

### Step 2 — Clone the Repository
```bash
git clone https://github.com/sakina-cmpn/EventNexus.git
cd EventNexus
```

### Step 3 — Install Dependencies
```bash
flutter pub get
```

### Step 4 — Android Setup
Make sure these files exist in your project (copy from a working Flutter project if missing):
- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/main/java/com/example/eventnexus/MainActivity.kt`
- `android/gradle.properties`

### Step 5 — Run the App
Connect an Android device or start an emulator, then:
```bash
flutter run
```

---

## 🗺️ What's Coming Next

### Student App
- [ ] Event Detail bottom sheet (floating panel)
- [ ] Booking / Registration system
- [ ] Search screen with filters
- [ ] Bookings screen (My tickets with Booking ID)
- [ ] Profile screen
- [ ] Real events fetched from Supabase

### Admin Panel (React Web App)
- [ ] Admin login
- [ ] Create / Edit / Delete events
- [ ] View registrations per event
- [ ] Track attendance
- [ ] Analytics dashboard

### Advanced Features
- [ ] Push notifications
- [ ] Payment simulation
- [ ] Event reminders
- [ ] AI feedback analysis

---

## ⚠️ Important Rules for Team

1. Always create your own branch — never push directly to main
2. Ask Monish before making changes to:
   - `main.dart`
   - `auth_service.dart`
   - `supabase_config.dart`
   - `pubspec.yaml`
3. Always run `flutter pub get` after pulling new changes
4. Always test on your device before saying something is done
5. Commit after every working feature with a clear message

## 📝 Git Commit Message Format
```
feat: add event detail bottom sheet
fix: resolve sign out navigation bug
ui: update home screen banner design
refactor: clean up auth service
```

---

## 📞 Contact

For Supabase access or any issues contact:
**Monish Sharma** — 9372962545
GitHub: [@MonishSharma01](https://github.com/MonishSharma01)

**Sakina Rizvi** — Auth & UI
GitHub: [@sakina-cmpn](https://github.com/sakina-cmpn)