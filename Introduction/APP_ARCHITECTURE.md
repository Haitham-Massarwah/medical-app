# Medical Appointment System - Architecture Overview

**Version:** 1.0.0  
**Date:** November 1, 2025

---

## 🏗️ **System Architecture**

### **High-Level Architecture**

```
┌─────────────────────────────────────────────────────────────────┐
│                     CLIENT APPLICATIONS                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│   │   Windows    │  │   Android    │  │     iOS      │       │
│   │  Desktop App │  │     App      │  │     App      │       │
│   └──────┬───────┘  └──────┬───────┘  └──────┬───────┘       │
│          │                  │                  │                │
│          └──────────────────┼──────────────────┘                │
│                             │                                   │
└─────────────────────────────┼───────────────────────────────────┘
                              │
                              │ HTTPS/REST API
                              │
┌─────────────────────────────▼───────────────────────────────────┐
│                      BACKEND SERVER                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   ┌─────────────────────────────────────────────────────┐     │
│   │              Node.js + Express.js                    │     │
│   │              TypeScript Backend                      │     │
│   └─────────────────────────────────────────────────────┘     │
│                                                                 │
│   ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│   │  Auth API    │  │  Booking API │  │  Payment API │       │
│   └──────────────┘  └──────────────┘  └──────────────┘       │
│                                                                 │
│   ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│   │  Doctor API  │  │ Patient API  │  │ Treatment API│       │
│   └──────────────┘  └──────────────┘  └──────────────┘       │
│                                                                 │
└─────────────────────────────┬───────────────────────────────────┘
                              │
                              │ SQL Queries
                              │
┌─────────────────────────────▼───────────────────────────────────┐
│                      DATABASE LAYER                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   ┌─────────────────────────────────────────────────────┐     │
│   │              PostgreSQL Database                     │     │
│   └─────────────────────────────────────────────────────┘     │
│                                                                 │
│   ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│   │    Users     │  │ Appointments │  │   Payments   │       │
│   └──────────────┘  └──────────────┘  └──────────────┘       │
│                                                                 │
│   ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│   │   Doctors    │  │   Patients   │  │  Treatments  │       │
│   └──────────────┘  └──────────────┘  └──────────────┘       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📱 **Frontend Architecture (Flutter)**

### **Technology Stack:**
- **Framework:** Flutter 3.16.9
- **Language:** Dart 3.9.2
- **State Management:** Flutter Bloc + Provider
- **UI Components:** Material Design 3
- **Platform:** Windows Desktop (Android/iOS ready)

### **Application Layers:**

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                       │
├─────────────────────────────────────────────────────────────┤
│  • Login Page              • Doctor Dashboard               │
│  • Patient Dashboard       • Appointment Booking            │
│  • Payment Processing      • Treatment Management           │
│  • Calendar View           • Profile Management             │
└─────────────────────────────┬───────────────────────────────┘
                              │
┌─────────────────────────────▼───────────────────────────────┐
│                     BUSINESS LOGIC LAYER                    │
├─────────────────────────────────────────────────────────────┤
│  • Authentication Service  • Appointment Service            │
│  • Payment Service         • Doctor Service                 │
│  • Patient Service         • Treatment Service              │
│  • Notification Service    • Calendar Service               │
└─────────────────────────────┬───────────────────────────────┘
                              │
┌─────────────────────────────▼───────────────────────────────┐
│                      DATA LAYER                             │
├─────────────────────────────────────────────────────────────┤
│  • API Service             • Local Storage (Hive)           │
│  • Authentication Manager  • Cache Manager                  │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔧 **Backend Architecture (Node.js)**

### **Technology Stack:**
- **Runtime:** Node.js 18+
- **Framework:** Express.js
- **Language:** TypeScript
- **Database:** PostgreSQL 15+
- **ORM:** Sequelize / TypeORM
- **Authentication:** JWT + bcrypt

### **Backend Structure:**

```
backend/
├── src/
│   ├── controllers/         # Request handlers
│   │   ├── auth.controller.ts
│   │   ├── appointment.controller.ts
│   │   ├── payment.controller.ts
│   │   ├── doctor.controller.ts
│   │   └── patient.controller.ts
│   │
│   ├── services/            # Business logic
│   │   ├── auth.service.ts
│   │   ├── email.service.ts
│   │   ├── payment.service.ts
│   │   └── notification.service.ts
│   │
│   ├── routes/              # API endpoints
│   │   ├── auth.routes.ts
│   │   ├── appointment.routes.ts
│   │   ├── payment.routes.ts
│   │   └── doctor.routes.ts
│   │
│   ├── models/              # Database models
│   │   ├── User.ts
│   │   ├── Doctor.ts
│   │   ├── Patient.ts
│   │   ├── Appointment.ts
│   │   └── Payment.ts
│   │
│   ├── middleware/          # Custom middleware
│   │   ├── auth.middleware.ts
│   │   ├── validation.middleware.ts
│   │   └── error.middleware.ts
│   │
│   └── config/              # Configuration
│       ├── database.ts
│       ├── email.ts
│       └── payment.ts
│
└── server.ts                # Entry point
```

---

## 💾 **Database Schema**

### **Main Tables:**

```sql
-- Users Table (Base authentication)
users {
  id: UUID PRIMARY KEY
  email: VARCHAR UNIQUE
  password_hash: VARCHAR
  role: ENUM('patient', 'doctor', 'admin')
  created_at: TIMESTAMP
  updated_at: TIMESTAMP
}

-- Doctors Table
doctors {
  id: UUID PRIMARY KEY
  user_id: UUID FOREIGN KEY -> users(id)
  name: VARCHAR
  specialty: VARCHAR
  phone: VARCHAR
  clinic_address: TEXT
  bank_account: VARCHAR (encrypted)
  is_active: BOOLEAN
  created_at: TIMESTAMP
}

-- Patients Table
patients {
  id: UUID PRIMARY KEY
  user_id: UUID FOREIGN KEY -> users(id)
  name: VARCHAR
  phone: VARCHAR
  date_of_birth: DATE
  medical_history: TEXT
  created_at: TIMESTAMP
}

-- Appointments Table
appointments {
  id: UUID PRIMARY KEY
  doctor_id: UUID FOREIGN KEY -> doctors(id)
  patient_id: UUID FOREIGN KEY -> patients(id)
  treatment_type_id: UUID FOREIGN KEY -> treatments(id)
  appointment_date: DATE
  appointment_time: TIME
  duration: INTEGER
  status: ENUM('pending', 'confirmed', 'completed', 'cancelled')
  notes: TEXT
  created_at: TIMESTAMP
}

-- Treatments Table
treatments {
  id: UUID PRIMARY KEY
  doctor_id: UUID FOREIGN KEY -> doctors(id)
  name: VARCHAR
  description: TEXT
  price: DECIMAL
  duration: INTEGER
  is_active: BOOLEAN
  created_at: TIMESTAMP
}

-- Payments Table
payments {
  id: UUID PRIMARY KEY
  appointment_id: UUID FOREIGN KEY -> appointments(id)
  amount: DECIMAL
  payment_method: ENUM('cash', 'card', 'bank_transfer')
  status: ENUM('pending', 'completed', 'failed', 'refunded')
  transaction_id: VARCHAR
  paid_at: TIMESTAMP
  created_at: TIMESTAMP
}
```

---

## 🔐 **Security Architecture**

### **Authentication Flow:**

```
1. User Login
   ↓
2. Validate Credentials (bcrypt hash comparison)
   ↓
3. Generate JWT Token (expires in 24h)
   ↓
4. Return Token to Client
   ↓
5. Client stores Token (Secure Storage)
   ↓
6. Client sends Token with each request (Authorization header)
   ↓
7. Server validates Token (JWT verification)
   ↓
8. Process Request
```

### **Security Features:**
- ✅ Password hashing (bcrypt)
- ✅ JWT authentication
- ✅ HTTPS encryption (production)
- ✅ Input validation
- ✅ SQL injection prevention
- ✅ XSS protection
- ✅ CORS configuration
- ✅ Rate limiting
- ✅ Audit logging

---

## 🔄 **Data Flow**

### **Appointment Booking Flow:**

```
Patient Action → Frontend → Backend → Database
     ↓              ↓          ↓         ↓
1. Select Doctor
2. Choose Date/Time
3. Select Treatment
4. Confirm Booking
     ↓
   API Call
     ↓
   Validate Data
     ↓
   Check Availability
     ↓
   Create Appointment
     ↓
   Send Notification
     ↓
   Return Confirmation
```

### **Payment Processing Flow:**

```
1. Treatment Completed
   ↓
2. Generate Payment Request
   ↓
3. Patient Selects Payment Method
   ↓
4. Process Payment (Cash/Card/Bank)
   ↓
5. Record Transaction
   ↓
6. Update Appointment Status
   ↓
7. Send Receipt
```

---

## 🌐 **API Architecture**

### **RESTful API Endpoints:**

```
Authentication:
POST   /api/auth/login           - User login
POST   /api/auth/register        - Patient registration
POST   /api/auth/logout          - User logout
POST   /api/auth/refresh-token   - Refresh JWT token

Appointments:
GET    /api/appointments          - Get all appointments
POST   /api/appointments          - Create appointment
PUT    /api/appointments/:id      - Update appointment
DELETE /api/appointments/:id      - Cancel appointment
GET    /api/appointments/:id      - Get appointment details

Doctors:
GET    /api/doctors               - List all doctors
GET    /api/doctors/:id           - Get doctor profile
GET    /api/doctors/:id/slots     - Get available time slots
POST   /api/doctors               - Create doctor (admin)
PUT    /api/doctors/:id           - Update doctor profile

Patients:
GET    /api/patients              - List patients (doctor)
GET    /api/patients/:id          - Get patient details
POST   /api/patients              - Create patient
PUT    /api/patients/:id          - Update patient

Treatments:
GET    /api/treatments            - List treatments
POST   /api/treatments            - Create treatment (doctor)
PUT    /api/treatments/:id        - Update treatment
DELETE /api/treatments/:id        - Delete treatment

Payments:
GET    /api/payments              - List payments
POST   /api/payments              - Record payment
GET    /api/payments/:id          - Payment details
```

---

## 📊 **System Requirements**

### **Client Side:**
- **OS:** Windows 10/11 (64-bit)
- **RAM:** 4 GB minimum (8 GB recommended)
- **Storage:** 500 MB free space
- **Display:** 1280x720 minimum resolution
- **Internet:** Stable connection required

### **Server Side:**
- **OS:** Windows Server 2019+ / Linux Ubuntu 20.04+
- **CPU:** 2 cores minimum
- **RAM:** 4 GB minimum (8 GB recommended)
- **Storage:** 10 GB free space
- **Database:** PostgreSQL 15+
- **Node.js:** Version 18+

---

## 🔌 **Integration Points**

### **External Services:**
- **Email Service:** SMTP (Gmail/SendGrid)
- **SMS Service:** Twilio (optional)
- **Payment Gateway:** Stripe/PayPal (configurable)
- **Maps Service:** Google Maps API (location search)
- **Video Calls:** Agora RTC (telehealth)

---

## 📈 **Scalability**

### **Horizontal Scaling:**
- Load balancer for multiple backend instances
- Database read replicas for performance
- Redis caching for session management
- CDN for static assets

### **Vertical Scaling:**
- Increase server resources as needed
- Database optimization (indexes, queries)
- Connection pooling
- Caching strategies

---

## 🛠️ **Development Tools**

### **Frontend:**
- Flutter SDK 3.16.9
- Visual Studio Code / Android Studio
- Flutter DevTools
- Dart Analyzer

### **Backend:**
- Node.js 18+
- TypeScript 5.0+
- Visual Studio Code
- Postman (API testing)
- PostgreSQL Admin Tools

---

## 📝 **Version Control**

- **Git** for source control
- **Branch Strategy:** GitFlow
  - `main` - Production
  - `develop` - Development
  - `feature/*` - New features
  - `bugfix/*` - Bug fixes
  - `release/*` - Release preparation

---

**For detailed implementation guides, see the respective documentation in each component's directory.**




