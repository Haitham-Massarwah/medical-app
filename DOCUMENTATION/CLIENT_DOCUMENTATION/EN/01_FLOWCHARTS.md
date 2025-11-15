# Complete System Flowcharts

## Medical Appointment Management System - Process Flow Diagrams

---

## 1. USER REGISTRATION & AUTHENTICATION FLOW

```
┌─────────────────────────────────────────────────────────────┐
│                    APPLICATION START                         │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                    LOGIN SCREEN                             │
│  • Email Input                                              │
│  • Password Input                                           │
│  • Language Selection (HE/EN/AR)                            │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
                    ┌──────────────┐
                    │  VALIDATE    │
                    │  CREDENTIALS │
                    └──────┬───────┘
                           │
        ┌──────────────────┴──────────────────┐
        │                                      │
        ▼                                      ▼
┌───────────────┐                    ┌───────────────┐
│   SUCCESS     │                    │    FAILED     │
│               │                    │               │
│ • Get User    │                    │ • Show Error │
│   Role        │                    │ • Retry      │
│ • Load        │                    └───────────────┘
│   Preferences │
└───────┬───────┘
        │
        ▼
┌─────────────────────────────────────────────────────────────┐
│              ROLE SELECTION DIALOG                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ PATIENT  │  │  DOCTOR  │  │  ADMIN   │  │ DEVELOPER│   │
│  │  (Blue)  │  │ (Green)  │  │ (Orange) │  │   (Red)  │   │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘   │
└───────┼─────────────┼─────────────┼─────────────┼──────────┘
        │             │             │             │
        ▼             ▼             ▼             ▼
    ┌──────────────────────────────────────────────────┐
    │         ROLE-BASED DASHBOARD                     │
    │  • Patient: My Appointments, Doctors, Settings  │
    │  • Doctor: Patients, Calendar, Payments         │
    │  • Admin: System Management, Reports             │
    │  • Developer: Full System Control                │
    └──────────────────────────────────────────────────┘
```

---

## 2. APPOINTMENT BOOKING FLOW

```
┌─────────────────────────────────────────────────────────────┐
│              PATIENT DASHBOARD                              │
│  • My Appointments                                          │
│  • Browse Doctors                                          │
│  • Notifications                                            │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              DOCTOR SEARCH & SELECTION                       │
│  • Filter by Specialty                                      │
│  • Search by Name/Location                                   │
│  • View Doctor Profile                                      │
│  • See Availability                                         │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              CALENDAR BOOKING PAGE                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Hebrew Calendar (RTL)                               │   │
│  │  • Month Name (Hebrew)                               │   │
│  │  • Day Names (א׳-ש׳)                                 │   │
│  │  • Green Days = Available                            │   │
│  │  • Grey Days = Unavailable/Past                      │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                              │
│  Quick Buttons:                                              │
│  [Now] [Today] [Tomorrow] [Weekend]                         │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
                    ┌──────────────┐
                    │ SELECT DATE  │
                    └──────┬───────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              TIME SLOT SELECTION                            │
│  • Available Time Slots                                     │
│  • Duration Display                                         │
│  • Price Display                                            │
│  • Location/Online Option                                   │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              APPOINTMENT DETAILS                             │
│  • Patient Information (if new, create profile)            │
│  • Appointment Date & Time                                  │
│  • Service Type                                             │
│  • Notes/Comments                                           │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              PAYMENT PROCESSING                              │
│  Payment Methods:                                           │
│  • Credit/Debit Card (Stripe)                               │
│  • Bank Transfer                                            │
│  • Cash                                                     │
│  • PayPal                                                   │
│                                                              │
│  Deposit Policy:                                            │
│  • Optional Deposit Amount                                  │
│  • Full Payment Option                                      │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              CONFIRMATION                                    │
│  • Appointment Confirmed                                    │
│  • Payment Receipt Generated                                 │
│  • Calendar Event Created (if integrated)                    │
│  • Notifications Sent (Email/SMS/WhatsApp)                   │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. DOCTOR WORKFLOW

```
┌─────────────────────────────────────────────────────────────┐
│              DOCTOR DASHBOARD                                │
│  • My Patients                                               │
│  • Appointments Calendar                                     │
│  • Payments                                                 │
│  • Profile Management                                        │
└──────────────────────────┬──────────────────────────────────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
        ▼                  ▼                  ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│  CREATE      │  │  MANAGE      │  │  VIEW        │
│  PATIENT     │  │  APPOINTMENTS│  │  CALENDAR    │
└──────┬───────┘  └──────┬───────┘  └──────┬───────┘
       │                  │                  │
       ▼                  ▼                  ▼
┌─────────────────────────────────────────────────────────────┐
│              PATIENT CREATION                               │
│  • Personal Information                                     │
│  • Medical History                                          │
│  • Emergency Contacts                                       │
│  • Insurance Information                                     │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              APPOINTMENT MANAGEMENT                          │
│  • View All Appointments                                    │
│  • Approve/Reject Requests                                  │
│  • Reschedule Appointments                                  │
│  • Cancel Appointments                                      │
│  • Mark as Completed                                        │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              AVAILABILITY SETTINGS                          │
│  • Set Working Hours                                        │
│  • Block Unavailable Dates                                  │
│  • Set Holiday Calendar                                     │
│  • Configure Buffer Times                                   │
└─────────────────────────────────────────────────────────────┘
```

---

## 4. PAYMENT PROCESSING FLOW

```
┌─────────────────────────────────────────────────────────────┐
│              PAYMENT INITIATION                             │
│  Triggered by:                                              │
│  • Appointment Booking                                      │
│  • Deposit Requirement                                      │
│  • Full Payment                                             │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              PAYMENT METHOD SELECTION                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ Credit Card  │  │ Bank Transfer│  │     Cash     │     │
│  │  (Stripe)    │  │              │  │              │     │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │
│         │                  │                  │             │
│         ▼                  ▼                  ▼             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ Card Details │  │ Bank Details │  │ Mark as Paid │     │
│  │ 3D Secure    │  │ Instructions │  │              │     │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │
└─────────┼──────────────────┼──────────────────┼───────────┘
          │                  │                  │
          ▼                  ▼                  ▼
┌─────────────────────────────────────────────────────────────┐
│              PAYMENT PROCESSING                             │
│  • Stripe API Call (for cards)                              │
│  • Payment Intent Creation                                  │
│  • SCA (Strong Customer Authentication)                      │
│  • Payment Confirmation                                     │
└──────────────────────────┬──────────────────────────────────┘
                           │
        ┌──────────────────┴──────────────────┐
        │                                      │
        ▼                                      ▼
┌───────────────┐                    ┌───────────────┐
│   SUCCESS     │                    │    FAILED     │
│               │                    │               │
│ • Update DB   │                    │ • Show Error │
│ • Generate    │                    │ • Retry      │
│   Receipt     │                    │ • Cancel     │
│ • Send        │                    └───────────────┘
│   Notification│
└───────┬───────┘
        │
        ▼
┌─────────────────────────────────────────────────────────────┐
│              POST-PAYMENT ACTIONS                           │
│  • Appointment Confirmed                                    │
│  • Receipt/Invoice Generated                                 │
│  • Email Receipt Sent                                        │
│  • Calendar Event Created                                    │
│  • Reminder Scheduled                                        │
└─────────────────────────────────────────────────────────────┘
```

---

## 5. NOTIFICATION SYSTEM FLOW

```
┌─────────────────────────────────────────────────────────────┐
│              NOTIFICATION TRIGGERS                          │
│  • Appointment Booked                                        │
│  • Appointment Reminder (24h before)                        │
│  • Appointment Confirmation Request (2h before)             │
│  • Appointment Cancelled                                    │
│  • Payment Received                                         │
│  • Payment Failed                                           │
│  • Document Uploaded                                        │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              NOTIFICATION CHANNEL SELECTION                   │
│  Based on:                                                   │
│  • User Preferences                                         │
│  • Platform (Web/Mobile)                                    │
│  • Notification Type                                        │
│  • Urgency Level                                            │
└──────────────────────────┬──────────────────────────────────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
        ▼                  ▼                  ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│    EMAIL     │  │     SMS      │  │   WHATSAPP   │
│  (Nodemailer)│  │   (Twilio)   │  │   (Twilio)   │
└──────┬───────┘  └──────┬───────┘  └──────┬───────┘
       │                  │                  │
       └──────────────────┼──────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│              PUSH NOTIFICATION                              │
│  (Firebase Cloud Messaging)                                 │
│  • Real-time Delivery                                       │
│  • Badge Counts                                             │
│  • Action Buttons                                           │
│  • Deep Linking                                             │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              NOTIFICATION DELIVERY                           │
│  • Multi-language Templates                                 │
│  • Delivery Tracking                                        │
│  • Read Receipts                                            │
│  • Retry Logic                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 6. ADMINISTRATOR WORKFLOW

```
┌─────────────────────────────────────────────────────────────┐
│              ADMIN DASHBOARD                                │
│  • System Overview                                          │
│  • User Management                                          │
│  • Doctor Management                                        │
│  • Reports & Analytics                                      │
│  • System Settings                                          │
└──────────────────────────┬──────────────────────────────────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
        ▼                  ▼                  ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│   USER       │  │   DOCTOR     │  │   REPORTS    │
│ MANAGEMENT   │  │ MANAGEMENT   │  │ & ANALYTICS  │
└──────┬───────┘  └──────┬───────┘  └──────┬───────┘
       │                  │                  │
       ▼                  ▼                  ▼
┌─────────────────────────────────────────────────────────────┐
│              USER MANAGEMENT                                │
│  • Create Users                                             │
│  • Edit User Profiles                                       │
│  • Assign Roles                                             │
│  • Enable/Disable Accounts                                 │
│  • View User Activity                                       │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              DOCTOR MANAGEMENT                              │
│  • Add Doctors                                              │
│  • Verify Licenses                                          │
│  • Manage Specialties                                       │
│  • Set Permissions                                          │
│  • View Doctor Statistics                                   │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              REPORTS & ANALYTICS                            │
│  • Appointment Statistics                                   │
│  • Revenue Reports                                          │
│  • User Activity Reports                                    │
│  • System Performance                                       │
│  • Export Data                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 7. DEVELOPER WORKFLOW

```
┌─────────────────────────────────────────────────────────────┐
│              DEVELOPER DASHBOARD                            │
│  • Complete System Control                                  │
│  • Database Management                                      │
│  • System Configuration                                     │
│  • Security Monitoring                                      │
│  • Specialty Management                                     │
└──────────────────────────┬──────────────────────────────────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
        ▼                  ▼                  ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│  DATABASE    │  │   SECURITY   │  │  SPECIALTY   │
│ MANAGEMENT   │  │   DASHBOARD  │  │ MANAGEMENT   │
└──────┬───────┘  └──────┬───────┘  └──────┬───────┘
       │                  │                  │
       ▼                  ▼                  ▼
┌─────────────────────────────────────────────────────────────┐
│              DATABASE OPERATIONS                            │
│  • Upload Backup                                            │
│  • Download Backup                                          │
│  • Restore Database                                         │
│  • Optimize Database                                        │
│  • View Statistics                                          │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              SECURITY MONITORING                            │
│  • Real-time Threat Detection                               │
│  • Security Reports                                         │
│  • Access Control Monitoring                                │
│  • Audit Trail Review                                       │
│  • Incident Management                                      │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              SPECIALTY MANAGEMENT                           │
│  • Enable/Disable Specialties                               │
│  • Organize by Categories                                   │
│  • Set Display Order                                        │
│  • Configure Icons                                          │
└─────────────────────────────────────────────────────────────┘
```

---

## 8. CALENDAR INTEGRATION FLOW

```
┌─────────────────────────────────────────────────────────────┐
│              CALENDAR SETUP                                 │
│  Doctor/Admin selects calendar provider:                     │
│  • Google Calendar                                          │
│  • Outlook Calendar                                         │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              OAUTH AUTHENTICATION                           │
│  • Redirect to Provider (Google/Microsoft)                  │
│  • User Grants Permissions                                  │
│  • Receive Authorization Code                               │
│  • Exchange for Access Token                                │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              CALENDAR SYNC                                  │
│  • Store Access Token                                       │
│  • Create Calendar Events                                   │
│  • Sync Existing Appointments                                │
│  • Set Up Two-Way Sync                                      │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              AUTOMATIC SYNC                                  │
│  When Appointment Created:                                 │
│  • Create Calendar Event                                    │
│  • Set Reminders                                            │
│  • Include Patient Details                                  │
│                                                              │
│  When Appointment Updated:                                  │
│  • Update Calendar Event                                    │
│                                                              │
│  When Appointment Cancelled:                                │
│  • Delete Calendar Event                                    │
└─────────────────────────────────────────────────────────────┘
```

---

## 9. CANCELLATION & REFUND FLOW

```
┌─────────────────────────────────────────────────────────────┐
│              CANCELLATION REQUEST                           │
│  Patient/Doctor requests cancellation                       │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              CHECK CANCELLATION POLICY                      │
│  • Time Until Appointment                                   │
│  • Policy Rules                                             │
│  • Refund Eligibility                                       │
└──────────────────────────┬──────────────────────────────────┘
                           │
        ┌──────────────────┴──────────────────┐
        │                                      │
        ▼                                      ▼
┌───────────────┐                    ┌───────────────┐
│  WITHIN       │                    │  OUTSIDE      │
│  POLICY       │                    │  POLICY       │
│               │                    │               │
│ • Full Refund │                    │ • Partial     │
│ • Process     │                    │   Refund      │
│   Refund      │                    │ • No Refund   │
└───────┬───────┘                    └───────┬───────┘
        │                                      │
        └──────────────┬───────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│              REFUND PROCESSING                              │
│  • Calculate Refund Amount                                  │
│  • Process Stripe Refund (if card payment)                  │
│  • Update Payment Status                                    │
│  • Generate Refund Receipt                                  │
│  • Send Notification                                        │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              APPOINTMENT CANCELLATION                       │
│  • Update Appointment Status                                │
│  • Free Up Time Slot                                        │
│  • Delete Calendar Event                                    │
│  • Send Cancellation Notifications                          │
│  • Update Statistics                                        │
└─────────────────────────────────────────────────────────────┘
```

---

## 10. MULTI-TENANT ARCHITECTURE FLOW

```
┌─────────────────────────────────────────────────────────────┐
│              TENANT CREATION                                │
│  Developer/Admin creates new clinic/tenant                  │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              TENANT CONFIGURATION                           │
│  • Clinic Information                                       │
│  • Branding (Logo, Colors)                                  │
│  • Regional Settings                                        │
│  • Payment Configuration                                    │
│  • Notification Settings                                    │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              USER ASSIGNMENT                                │
│  • Assign Users to Tenant                                   │
│  • Set Tenant Admin                                         │
│  • Configure Permissions                                    │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              DATA ISOLATION                                 │
│  All Data Queries Include Tenant ID:                        │
│  • Appointments                                             │
│  • Patients                                                 │
│  • Doctors                                                  │
│  • Payments                                                 │
│  • Reports                                                  │
└─────────────────────────────────────────────────────────────┘
```

---

## 11. COMPLETE SYSTEM ARCHITECTURE

```
┌─────────────────────────────────────────────────────────────┐
│                    CLIENT LAYER                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │   Web    │  │  Mobile  │  │  Tablet  │  │ Desktop  │   │
│  │ (Flutter)│  │ (Flutter)│  │(Flutter) │  │(Flutter) │   │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘   │
└───────┼─────────────┼─────────────┼─────────────┼──────────┘
        │             │             │             │
        └─────────────┴─────────────┴─────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                    API LAYER                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │         REST API (Express.js/TypeScript)            │   │
│  │  • Authentication Endpoints                         │   │
│  │  • Appointment Endpoints                            │   │
│  │  • Payment Endpoints                                │   │
│  │  • User Management Endpoints                         │   │
│  │  • Notification Endpoints                            │   │
│  │  • Calendar Integration Endpoints                    │   │
│  └─────────────────────────────────────────────────────┘   │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                    SERVICE LAYER                            │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │Appointment│  │ Payment  │  │Notification│ │ Calendar │   │
│  │ Service  │  │ Service  │  │  Service  │  │ Service  │   │
│  └────┬─────┘  └────┬─────┘  └────┬──────┘  └────┬─────┘   │
└───────┼─────────────┼─────────────┼─────────────┼──────────┘
        │             │             │             │
        └─────────────┴─────────────┴─────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                    DATABASE LAYER                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │         PostgreSQL Database                          │   │
│  │  • Users Table                                       │   │
│  │  • Doctors Table                                     │   │
│  │  • Appointments Table                               │   │
│  │  • Payments Table                                   │   │
│  │  • Notifications Table                              │   │
│  │  • Audit Logs Table                                 │   │
│  └─────────────────────────────────────────────────────┘   │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                    EXTERNAL SERVICES                        │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │  Stripe  │  │  Twilio  │  │  Google  │  │ Outlook  │   │
│  │ Payments│  │   SMS/    │  │ Calendar │  │ Calendar │   │
│  │          │  │ WhatsApp │  │          │  │          │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

**Document Version:** 1.0  
**Last Updated:** November 15, 2025  
**System Version:** Medical Appointment Management System v1.0

