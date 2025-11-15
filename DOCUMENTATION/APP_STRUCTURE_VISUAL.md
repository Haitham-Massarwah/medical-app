# 🏗️ Medical Appointment System - Visual Architecture

## 📊 System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    Medical Appointment System                    │
│                         (Full Stack)                             │
└─────────────────────────────────────────────────────────────────┘
                                 │
                 ┌───────────────┴───────────────┐
                 │                               │
        ┌────────▼────────┐            ┌────────▼────────┐
        │   FRONTEND      │            │    BACKEND      │
        │   (Flutter)     │◄──────────►│  (Node.js/TS)   │
        │   Dart 3.0+     │    HTTP    │   Express.js    │
        └─────────────────┘   REST API  └─────────────────┘
                 │                               │
                 │                               │
        ┌────────▼────────┐            ┌────────▼────────┐
        │  Local Storage  │            │   PostgreSQL    │
        │   (Hive/Prefs)  │            │   Database      │
        └─────────────────┘            └─────────────────┘
                                                │
                                       ┌────────▼────────┐
                                       │     Redis       │
                                       │    (Cache)      │
                                       └─────────────────┘
```

---

## 🎨 Frontend Architecture (Flutter)

```
lib/
│
├── 📱 main.dart (Entry Point)
│   └── MedicalAppointmentApp
│       └── Material App + Localization + Theme
│
├── 🎨 presentation/ (UI Layer)
│   ├── pages/
│   │   ├── 🚀 splash_page.dart
│   │   │   └── Animated Splash Screen
│   │   │
│   │   ├── 🏠 medical_home_page.dart
│   │   │   ├── Welcome Section
│   │   │   ├── Search Bar
│   │   │   ├── Quick Actions
│   │   │   ├── Medical Specialties Grid
│   │   │   └── Featured Doctors List
│   │   │
│   │   └── 🔐 home_page.dart
│   │       ├── LoginPage
│   │       ├── RegisterPage
│   │       ├── AppointmentsPage
│   │       ├── DoctorsPage
│   │       ├── PatientsPage
│   │       ├── ProfilePage
│   │       └── SettingsPage
│   │
│   └── widgets/
│       └── 🧩 medical_widgets.dart
│           ├── MedicalSpecialtyCard
│           ├── DoctorCard
│           ├── AppointmentCard
│           ├── LoadingWidget
│           ├── ErrorWidget
│           └── EmptyStateWidget
│
├── 🏛️ features/ (Business Logic)
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       └── bloc/
│   │
│   ├── appointments/
│   │   └── [Similar structure]
│   ├── doctors/
│   ├── patients/
│   ├── payments/
│   └── notifications/
│
└── ⚙️ core/ (Shared)
    ├── config/
    │   └── app_config.dart
    ├── di/
    │   └── injection_container.dart
    ├── localization/
    │   └── 🌐 app_localizations.dart
    │       ├── Hebrew (עברית)
    │       ├── Arabic (العربية)
    │       └── English
    ├── network/
    │   ├── api_client.dart
    │   └── interceptors/
    ├── storage/
    │   └── local_storage.dart
    ├── theme/
    │   └── 🎨 app_theme.dart
    │       ├── Light Theme
    │       └── Dark Theme
    └── utils/
        └── 📋 app_constants.dart
```

---

## 🔧 Backend Architecture (Node.js)

```
backend/
│
├── 🚀 src/server.ts (Entry Point)
│
├── 🎯 controllers/ (Request Handlers)
│   ├── auth.controller.ts        → Login, Register, JWT
│   ├── appointment.controller.ts → CRUD Appointments
│   ├── doctor.controller.ts      → Doctor Management
│   ├── patient.controller.ts     → Patient Records
│   ├── payment.controller.ts     → Payment Processing
│   ├── notification.controller.ts→ Send Notifications
│   ├── tenant.controller.ts      → Multi-tenant
│   ├── analytics.controller.ts   → Reports & Stats
│   └── user.controller.ts        → User Management
│
├── 🔧 services/ (Business Logic)
│   ├── appointment.service.ts    → Booking Logic
│   ├── compliance.service.ts     → GDPR, HIPAA
│   ├── email.service.ts          → Send Emails
│   ├── sms.service.ts            → Send SMS
│   ├── whatsapp.service.ts       → WhatsApp API
│   ├── payment.service.ts        → Stripe Integration
│   └── notification.service.ts   → Multi-channel
│
├── 🛡️ middleware/ (Request Processing)
│   ├── auth.middleware.ts        → JWT Verification
│   ├── errorHandler.ts           → Global Error Handler
│   ├── rateLimiter.ts            → Rate Limiting
│   ├── tenantContext.ts          → Tenant Isolation
│   └── validation.middleware.ts  → Input Validation
│
├── 🛣️ routes/ (API Endpoints)
│   ├── auth.routes.ts            → /api/auth/*
│   ├── appointment.routes.ts     → /api/appointments/*
│   ├── doctor.routes.ts          → /api/doctors/*
│   ├── patient.routes.ts         → /api/patients/*
│   ├── payment.routes.ts         → /api/payments/*
│   ├── notification.routes.ts    → /api/notifications/*
│   ├── tenant.routes.ts          → /api/tenants/*
│   ├── analytics.routes.ts       → /api/analytics/*
│   └── user.routes.ts            → /api/users/*
│
├── ⚙️ config/ (Configuration)
│   ├── database.ts               → PostgreSQL Setup
│   ├── redis.ts                  → Redis Caching
│   ├── logger.ts                 → Winston Logger
│   └── cors.ts                   → CORS Policy
│
├── 🗄️ database/
│   └── migrations/
│       └── 001_initial_schema.ts → DB Schema
│
└── 🧪 tests/
    └── appointment.test.ts       → Unit Tests
```

---

## 📊 Database Schema (PostgreSQL)

```
┌─────────────────┐      ┌─────────────────┐      ┌─────────────────┐
│     tenants     │      │      users      │      │    doctors      │
├─────────────────┤      ├─────────────────┤      ├─────────────────┤
│ id (PK)         │◄─────┤ id (PK)         │      │ id (PK)         │
│ name            │      │ tenant_id (FK)  │◄─────┤ user_id (FK)    │
│ domain          │      │ email           │      │ specialty       │
│ settings        │      │ password_hash   │      │ license_number  │
│ created_at      │      │ role            │      │ availability    │
└─────────────────┘      │ created_at      │      │ created_at      │
                         └─────────────────┘      └─────────────────┘
                                  │                         │
                                  │                         │
                         ┌────────▼────────┐      ┌────────▼────────┐
                         │    patients     │      │  appointments   │
                         ├─────────────────┤      ├─────────────────┤
                         │ id (PK)         │      │ id (PK)         │
                         │ user_id (FK)    │◄─────┤ patient_id (FK) │
                         │ medical_history │      │ doctor_id (FK)  │
                         │ allergies       │◄─────┤ date_time       │
                         │ created_at      │      │ duration        │
                         └─────────────────┘      │ status          │
                                                  │ is_telehealth   │
                                                  │ created_at      │
                                                  └─────────────────┘
                                                           │
                                                           │
                                                  ┌────────▼────────┐
                                                  │    payments     │
                                                  ├─────────────────┤
                                                  │ id (PK)         │
                                                  │ appointment_id  │
                                                  │ amount          │
                                                  │ method          │
                                                  │ status          │
                                                  │ stripe_id       │
                                                  │ created_at      │
                                                  └─────────────────┘
```

---

## 🔄 Data Flow Diagram

### **Booking an Appointment:**

```
┌────────┐     1. Search Doctor      ┌──────────┐
│ User   │─────────────────────────►│ Frontend │
│(Patient│                           │ (Flutter)│
└────────┘                           └──────────┘
    ▲                                      │
    │                                      │ 2. GET /api/doctors
    │                                      │    ?specialty=osteopath
    │                                      ▼
    │                               ┌──────────┐
    │                               │ Backend  │
    │                               │ (Node.js)│
    │                               └──────────┘
    │                                      │
    │                                      │ 3. Query DB
    │                                      ▼
    │                               ┌──────────┐
    │                               │PostgreSQL│
    │                               └──────────┘
    │                                      │
    │   5. Display Results                 │ 4. Return doctors
    │◄─────────────────────────────────────┘
    │
    │   6. Select Doctor & Time
    ├────────────────────────────►
    │
    │   7. POST /api/appointments
    ├────────────────────────────►┌──────────┐
    │                              │ Backend  │
    │                              └──────────┘
    │                                    │
    │                                    │ 8. Validate & Save
    │                                    ▼
    │                              ┌──────────┐
    │                              │PostgreSQL│
    │                              └──────────┘
    │                                    │
    │                                    │ 9. Send notification
    │                                    ▼
    │                              ┌──────────┐
    │                              │Email/SMS │
    │                              │ Service  │
    │   10. Confirmation           └──────────┘
    │◄──────────────────────────────────┘
    │
```

---

## 🌐 Multi-Language Flow

```
┌────────────────────────────────────────────────────────────┐
│                    User Opens App                          │
└────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────────┐
│           Check System Language / User Preference          │
│                                                             │
│    ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│    │   Hebrew     │  │    Arabic    │  │   English    │  │
│    │   (עברית)    │  │   (العربية)  │  │              │  │
│    │   RTL ◄──    │  │   RTL ◄──    │  │   LTR ──►    │  │
│    └──────────────┘  └──────────────┘  └──────────────┘  │
└────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────────┐
│              Load Localized Strings                        │
│                                                             │
│  appTitle: "מערכת תורים רפואיים" (Hebrew)                 │
│  appTitle: "نظام المواعيد الطبية" (Arabic)                │
│  appTitle: "Medical Appointment System" (English)          │
└────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────────┐
│          Apply Text Direction & Layout                     │
│                                                             │
│  RTL: Directionality(textDirection: TextDirection.rtl)    │
│  LTR: Directionality(textDirection: TextDirection.ltr)    │
└────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────────┐
│               Display Localized UI                         │
└────────────────────────────────────────────────────────────┘
```

---

## 🎨 UI Component Hierarchy

### **Home Page Component Tree:**

```
MedicalHomePage (StatefulWidget)
│
├── Scaffold
│   ├── AppBar
│   │   ├── Title (Localized)
│   │   ├── Language Switcher (PopupMenu)
│   │   │   ├── Hebrew
│   │   │   ├── Arabic
│   │   │   └── English
│   │   └── User Menu (PopupMenu)
│   │       ├── Profile
│   │       ├── Appointments
│   │       └── Login
│   │
│   └── Body (CustomScrollView)
│       └── Slivers
│           ├── SliverToBoxAdapter (Welcome)
│           │   └── Container (Gradient)
│           │       ├── Title Text (Hebrew)
│           │       └── Subtitle Text
│           │
│           ├── SliverToBoxAdapter (Search)
│           │   └── TextField
│           │       ├── Search Icon
│           │       └── Filter Button
│           │
│           ├── SliverToBoxAdapter (Quick Actions)
│           │   └── Row
│           │       ├── QuickActionCard (Appointments)
│           │       └── QuickActionCard (Profile)
│           │
│           ├── SliverToBoxAdapter (Section Header)
│           │   └── Text ("תחומי רפואה")
│           │
│           ├── SliverGrid (Specialties)
│           │   └── MedicalSpecialtyCard × 10
│           │       ├── Icon (Colored)
│           │       ├── Gradient Background
│           │       └── Specialty Name
│           │
│           ├── SliverToBoxAdapter (Doctors Header)
│           │   └── Row
│           │       ├── Text ("רופאים מומלצים")
│           │       └── TextButton ("הצג הכל")
│           │
│           └── SliverList (Doctors)
│               └── DoctorCard × 3
│                   ├── CircleAvatar
│                   ├── Name & Specialty
│                   ├── Location
│                   ├── Rating
│                   └── Book Button
```

---

## 🔐 Authentication Flow

```
┌────────────┐
│ User Opens │
│    App     │
└─────┬──────┘
      │
      ▼
┌─────────────┐      No      ┌───────────┐
│Check Token? │──────────────►│Login Page │
└─────┬───────┘               └─────┬─────┘
      │                             │
      │Yes                          │ Enter Email/Password
      │                             ▼
      │                      ┌──────────────┐
      │                      │POST /api/auth│
      │                      │   /login     │
      │                      └──────┬───────┘
      │                             │
      │                             ▼
      │                      ┌──────────────┐
      │                      │  Validate    │
      │         ┌────────────┤ Credentials  │
      │         │            └──────┬───────┘
      │         │                   │
      │    ┌────▼─────┐       ┌─────▼──────┐
      │    │  Invalid │       │   Valid    │
      │    │  Error   │       │ Generate   │
      │    └──────────┘       │    JWT     │
      │                       └─────┬──────┘
      │                             │
      │                             │ Store Token
      │                             ▼
      │                       ┌─────────────┐
      └───────────────────────►│  Home Page  │
                              └─────────────┘
```

---

## 📱 Responsive Design Breakpoints

```
┌─────────────────────────────────────────────────────────────┐
│                     Mobile (< 600px)                        │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────┐   │
│  │ 📱 Single Column Layout                             │   │
│  │                                                      │   │
│  │  Stack:                                             │   │
│  │   - Full-width cards                                │   │
│  │   - 1-2 columns for specialty grid                 │   │
│  │   - Bottom navigation                               │   │
│  │                                                      │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    Tablet (600-1200px)                      │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────┐   │
│  │ 📱 Two Column Layout                                │   │
│  │                                                      │   │
│  │  ┌─────────────┐  ┌─────────────┐                  │   │
│  │  │   Content   │  │   Sidebar   │                  │   │
│  │  │             │  │             │                  │   │
│  │  │  - Doctors  │  │  - Filters  │                  │   │
│  │  │  - Appts    │  │  - Quick    │                  │   │
│  │  │             │  │    Actions  │                  │   │
│  │  └─────────────┘  └─────────────┘                  │   │
│  │                                                      │   │
│  │  3-4 columns for specialty grid                     │   │
│  │                                                      │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                   Desktop (> 1200px)                        │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────┐   │
│  │ 🖥️ Three Column Layout                              │   │
│  │                                                      │   │
│  │  ┌──────┐  ┌─────────────────┐  ┌──────┐          │   │
│  │  │ Side │  │   Main Content   │  │ Side │          │   │
│  │  │ Nav  │  │                  │  │ Info │          │   │
│  │  │      │  │   - Doctors      │  │      │          │   │
│  │  │ - H  │  │   - Calendar     │  │ - Ad │          │   │
│  │  │ - D  │  │   - Appts        │  │ - Ti │          │   │
│  │  │ - P  │  │                  │  │ - No │          │   │
│  │  └──────┘  └─────────────────┘  └──────┘          │   │
│  │                                                      │   │
│  │  5+ columns for specialty grid                      │   │
│  │                                                      │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎯 State Management (BLoC Pattern)

```
┌───────────────────────────────────────────────────────────┐
│                     UI Layer (Widget)                     │
└───────────────────────────────────────────────────────────┘
                         │        ▲
                         │        │
                   Event │        │ State
                         │        │
                         ▼        │
┌───────────────────────────────────────────────────────────┐
│                    BLoC (Business Logic)                  │
│                                                            │
│  ┌──────────────┐         ┌──────────────┐              │
│  │   Event      │────────►│    BLoC      │              │
│  │              │         │              │              │
│  │ - BookAppt   │         │  - Process   │              │
│  │ - CancelAppt │         │  - Validate  │              │
│  │ - LoadDoctors│         │  - Transform │              │
│  └──────────────┘         └──────┬───────┘              │
│                                   │                       │
│                                   ▼                       │
│                          ┌──────────────┐                │
│                          │    State     │                │
│                          │              │                │
│                          │ - Loading    │                │
│                          │ - Success    │                │
│                          │ - Error      │                │
│                          └──────────────┘                │
└───────────────────────────────────────────────────────────┘
                         │
                         │
                         ▼
┌───────────────────────────────────────────────────────────┐
│                  Repository Layer                         │
│                                                            │
│  ┌────────────────┐              ┌────────────────┐      │
│  │ Remote Data    │              │  Local Data    │      │
│  │ Source (API)   │              │  Source (Hive) │      │
│  └────────────────┘              └────────────────┘      │
└───────────────────────────────────────────────────────────┘
```

---

## 🚀 Deployment Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Production                           │
└─────────────────────────────────────────────────────────────┘
                           │
          ┌────────────────┼────────────────┐
          │                │                │
┌─────────▼────────┐  ┌────▼──────┐  ┌────▼────────┐
│   Flutter Web    │  │  Android  │  │     iOS     │
│   (Hosted)       │  │   APK     │  │    IPA      │
│                  │  │   (Store) │  │   (Store)   │
│  - Firebase      │  │           │  │             │
│  - Netlify       │  │   Google  │  │    Apple    │
│  - Vercel        │  │    Play   │  │   App Store │
└──────────────────┘  └───────────┘  └─────────────┘
          │                │                │
          └────────────────┼────────────────┘
                           │
                    HTTPS/WSS
                           │
          ┌────────────────▼────────────────┐
          │      Load Balancer / CDN        │
          │         (Cloudflare)            │
          └─────────────────────────────────┘
                           │
          ┌────────────────┼────────────────┐
          │                │                │
┌─────────▼────────┐  ┌────▼──────┐  ┌────▼────────┐
│  Backend API     │  │PostgreSQL │  │   Redis     │
│  (Kubernetes)    │  │  (Primary)│  │   (Cache)   │
│                  │  │           │  │             │
│  - Pod 1         │  │  Master   │  │  - Session  │
│  - Pod 2         │  │  Replica  │  │  - Cache    │
│  - Pod 3         │  │           │  │  - Queue    │
└──────────────────┘  └───────────┘  └─────────────┘
          │
          │
┌─────────▼────────┐
│  External APIs   │
│                  │
│  - Stripe        │
│  - Twilio        │
│  - SendGrid      │
│  - WhatsApp      │
└──────────────────┘
```

---

## 📊 Feature Matrix

```
┌──────────────────────────┬──────┬──────────┬──────────┬─────────┐
│        Feature           │ MVP  │ Planned  │ Priority │ Status  │
├──────────────────────────┼──────┼──────────┼──────────┼─────────┤
│ User Authentication      │  ✅  │    ✅    │   High   │  Done   │
│ Multi-language (3)       │  ✅  │    ✅    │   High   │  Done   │
│ RTL Support              │  ✅  │    ✅    │   High   │  Done   │
│ Doctor Profiles          │  ✅  │    ✅    │   High   │  Done   │
│ Appointment Booking      │  ✅  │    ✅    │   High   │  Done   │
│ Calendar Integration     │  🔄  │    ✅    │  Medium  │ In Prog │
│ Payment Processing       │  ✅  │    ✅    │   High   │  Done   │
│ Email Notifications      │  ✅  │    ✅    │   High   │  Done   │
│ SMS Notifications        │  ✅  │    ✅    │  Medium  │  Done   │
│ WhatsApp Notifications   │  🔄  │    ✅    │  Medium  │ In Prog │
│ Push Notifications       │  🔄  │    ✅    │  Medium  │ Planned │
│ Video Consultations      │  🔄  │    ✅    │   Low    │ Planned │
│ Analytics Dashboard      │  🔄  │    ✅    │  Medium  │ In Prog │
│ Multi-tenant Support     │  ✅  │    ✅    │   High   │  Done   │
│ Dark Mode                │  ✅  │    ✅    │   Low    │  Done   │
│ Offline Mode             │  ❌  │    ✅    │   Low    │ Future  │
│ AI Scheduling            │  ❌  │    ✅    │   Low    │ Future  │
└──────────────────────────┴──────┴──────────┴──────────┴─────────┘

Legend:
  ✅ Implemented
  🔄 In Progress
  ❌ Not Started
```

---

## 🎯 User Journey Map

### **Patient Journey:**

```
1. Discovery
   └─► Opens app/website
       └─► Sees welcoming home page
           └─► Browses specialties

2. Search
   └─► Clicks specialty (e.g., "Osteopath")
       └─► Views list of doctors
           └─► Filters by location/rating

3. Selection
   └─► Clicks on doctor
       └─► Views profile, reviews, availability
           └─► Selects time slot

4. Booking
   └─► Fills patient information
       └─► Chooses payment method
           └─► Confirms booking

5. Confirmation
   └─► Receives confirmation email/SMS
       └─► Adds to calendar
           └─► Gets reminder (24h before)

6. Appointment
   └─► Attends appointment (in-person/video)
       └─► Completes visit
           └─► Receives receipt

7. Post-Visit
   └─► Can leave review
       └─► Books follow-up (if needed)
           └─► Views medical records
```

---

**This comprehensive visual architecture guide shows the complete structure of your Medical Appointment System! 🚀**

---

Generated on: **October 21, 2025**


