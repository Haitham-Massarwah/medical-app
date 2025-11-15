# Complete User Guide
## Medical Appointment Management System

---

## Table of Contents

1. [Getting Started](#getting-started)
2. [Patient Guide](#patient-guide)
3. [Doctor Guide](#doctor-guide)
4. [Administrator Guide](#administrator-guide)
5. [Developer Guide](#developer-guide)
6. [Common Tasks](#common-tasks)
7. [Troubleshooting](#troubleshooting)
8. [FAQs](#faqs)

---

## Getting Started

### System Requirements

**For Web Access:**
- Modern web browser (Chrome, Firefox, Safari, Edge)
- Internet connection
- JavaScript enabled

**For Mobile Access:**
- iOS 12+ or Android 8+
- Internet connection
- App installed (when available)

### First-Time Login

1. **Open the Application**
   - Navigate to the application URL
   - Or launch the mobile/desktop app

2. **Login Screen**
   - Enter your email address
   - Enter your password
   - Select your preferred language (Hebrew/English/Arabic)
   - Click "Login" or "התחבר"

3. **Role Selection**
   - After successful login, select your role:
     - **Patient** (מטופל) - Blue
     - **Doctor** (רופא) - Green
     - **Admin** (מנהל) - Orange
     - **Developer** (מפתח) - Red

4. **Dashboard**
   - You will be taken to your role-specific dashboard
   - Explore the available features

---

## Patient Guide

### Overview

As a patient, you can book appointments, manage your profile, view appointment history, and make payments through the system.

### Main Features

#### 1. **Viewing Your Appointments**

**Access:** Click "My Appointments" (התורים שלי) from the dashboard

**Features:**
- View all your upcoming appointments
- See appointment details (date, time, doctor, service)
- View appointment status (confirmed, pending, cancelled)
- Filter by date range
- Search appointments

**Actions Available:**
- **Reschedule:** Click "Reschedule" to change date/time
- **Cancel:** Click "Cancel" to cancel an appointment
- **View Details:** Click on an appointment to see full details

---

#### 2. **Searching for Doctors**

**Access:** Click "Doctors" (רופאים) from the dashboard

**Search Options:**
- **By Specialty:** Use the dropdown to filter by medical specialty
- **By Name:** Type doctor's name in the search box
- **By Location:** Filter by city or area
- **By Availability:** Filter by available time slots

**Doctor Profile Information:**
- Name and credentials
- Specialty
- Languages spoken
- Location
- Rating and reviews
- Available time slots
- Pricing information

**Booking an Appointment:**
1. Click "Book Appointment" (קבע תור) on a doctor's profile
2. You will be taken to the calendar booking page

---

#### 3. **Booking an Appointment**

**Step 1: Select Date**
- View the Hebrew calendar
- Green days = Available
- Grey days = Unavailable/Past dates
- Click on a green day to proceed

**Quick Options:**
- **Now:** Book for immediate availability
- **Today:** Book for today
- **Tomorrow:** Book for tomorrow
- **Weekend:** Book for weekend slots

**Step 2: Select Time**
- Available time slots will appear below the calendar
- Each slot shows:
  - Time
  - Duration
  - Price
  - Location (clinic or online)
- Click on your preferred time slot

**Step 3: Confirm Details**
- Review appointment details:
  - Date and time
  - Doctor name
  - Service type
  - Duration
  - Price
- Add notes or special requests (optional)
- Click "Continue to Payment" (המשך לתשלום)

**Step 4: Payment**
- Select payment method:
  - **Credit/Debit Card:** Enter card details (Stripe secure)
  - **Bank Transfer:** Receive bank details
  - **Cash:** Mark as cash payment
  - **PayPal:** Use PayPal account
- Complete payment
- Receive confirmation

**Step 5: Confirmation**
- Appointment confirmed message
- Receipt generated automatically
- Email/SMS confirmation sent
- Calendar event created (if integrated)

---

#### 4. **Managing Your Profile**

**Access:** Click your profile icon (top right) → "Profile" (פרופיל)

**Profile Information:**
- Personal details (name, email, phone)
- Medical information
- Emergency contacts
- Insurance information
- Preferences (language, notifications)

**Editing Profile:**
1. Click "Edit" (ערוך)
2. Update information
3. Click "Save" (שמור)

**Uploading Documents:**
1. Go to "Documents" section
2. Click "Upload" (העלה)
3. Select file(s)
4. Add description (optional)
5. Click "Upload"

---

#### 5. **Viewing Notifications**

**Access:** Click "Notifications" (התראות) from the dashboard

**Notification Types:**
- Appointment confirmations
- Appointment reminders (24h before)
- Payment confirmations
- Cancellation alerts
- Document uploads
- System announcements

**Managing Notifications:**
- Mark as read/unread
- Delete notifications
- Filter by type
- Configure notification preferences

---

#### 6. **Making Payments**

**Payment Methods Available:**
- **Credit/Debit Card:** Secure Stripe processing
- **Bank Transfer:** Direct bank transfer
- **Cash:** Mark payment as received
- **PayPal:** PayPal account payment

**Payment Process:**
1. Select payment method
2. Enter payment details
3. Confirm amount
4. Complete payment
5. Receive receipt

**Viewing Payment History:**
- Access "Payments" from profile
- View all past payments
- Download receipts
- View invoices

---

#### 7. **Rescheduling Appointments**

**Steps:**
1. Go to "My Appointments"
2. Find the appointment to reschedule
3. Click "Reschedule" (דחה תור)
4. Select new date from calendar
5. Select new time slot
6. Confirm reschedule
7. Receive confirmation

**Note:** Rescheduling may be subject to cancellation policy.

---

#### 8. **Cancelling Appointments**

**Steps:**
1. Go to "My Appointments"
2. Find the appointment to cancel
3. Click "Cancel" (בטל תור)
4. Confirm cancellation
5. Review refund policy (if applicable)
6. Receive cancellation confirmation

**Refund Policy:**
- Refunds depend on cancellation policy
- Full refund if cancelled within policy timeframe
- Partial refund if outside policy
- No refund if too close to appointment

---

## Doctor Guide

### Overview

As a doctor, you can manage patients, view your calendar, handle appointments, set availability, and manage payments.

### Main Features

#### 1. **Managing Patients**

**Access:** Click "My Patients" (המטופלים שלי) from the dashboard

**Patient List:**
- View all your patients
- Search by name, phone, or email
- Filter by status
- Sort by various criteria

**Creating a New Patient:**
1. Click "Create Patient" (יצירת מטופל)
2. Enter patient information:
   - Personal details (name, email, phone)
   - Medical history
   - Emergency contacts
   - Insurance information
3. Click "Save" (שמור)

**Viewing Patient Profile:**
- Click on a patient's name
- View complete profile:
  - Personal information
  - Medical history
  - Appointment history
  - Documents
  - Payment history

**Editing Patient Information:**
1. Open patient profile
2. Click "Edit" (ערוך)
3. Update information
4. Click "Save" (שמור)

---

#### 2. **Managing Appointments**

**Access:** Click "Appointments" (לוח תורים) from the dashboard

**Appointment Calendar:**
- View appointments by day/week/month
- Color-coded by status:
  - Green = Confirmed
  - Yellow = Pending
  - Red = Cancelled
  - Blue = Completed

**Appointment Actions:**
- **View Details:** Click on appointment
- **Approve/Reject:** For pending appointments
- **Reschedule:** Change date/time
- **Cancel:** Cancel appointment
- **Mark Complete:** After treatment
- **Add Notes:** Clinical notes

**Filtering Appointments:**
- By date range
- By status
- By patient
- By service type

---

#### 3. **Setting Availability**

**Access:** Click "Settings" (הגדרות) → "Availability" (זמינות)

**Working Hours:**
1. Select day of week
2. Set start time
3. Set end time
4. Add break times (optional)
5. Save settings

**Blocking Dates:**
1. Go to "Holidays" (חגים) section
2. Click "Add Holiday" (הוסף חג)
3. Select date(s)
4. Add reason
5. Save

**Special Availability:**
- Add extra availability for specific dates
- Override regular hours
- Set buffer times between appointments

---

#### 4. **Treatment Settings**

**Access:** Click "Settings" (הגדרות) → "Treatments" (טיפולים)

**Managing Treatment Types:**
1. Click "Add Treatment" (הוסף טיפול)
2. Enter treatment details:
   - Name
   - Description
   - Duration
   - Price
   - Category
3. Save

**Editing Treatments:**
- Click on treatment name
- Edit details
- Update pricing
- Save changes

---

#### 5. **Managing Payments**

**Access:** Click "Payments" (תשלומים) from the dashboard

**Payment Overview:**
- Total revenue
- Payments by method
- Pending payments
- Refunds

**Viewing Payment Details:**
- Click on a payment
- View payment information:
  - Patient name
  - Amount
  - Payment method
  - Date
  - Receipt

**Processing Refunds:**
1. Find the payment
2. Click "Refund" (החזר)
3. Enter refund amount
4. Select reason
5. Process refund
6. Patient receives notification

---

#### 6. **Calendar Integration**

**Setting Up Calendar Sync:**
1. Go to "Settings" → "Calendar"
2. Choose calendar provider:
   - Google Calendar
   - Outlook Calendar
3. Click "Connect" (חבר)
4. Authorize access
5. Calendar synced

**How It Works:**
- Appointments automatically create calendar events
- Calendar events sync to appointment system
- Reminders set automatically
- Two-way synchronization

---

## Administrator Guide

### Overview

As an administrator, you have full control over the clinic's operations, user management, reports, and system settings.

### Main Features

#### 1. **User Management**

**Access:** Click "User Management" (ניהול משתמשים) from the dashboard

**Creating Users:**
1. Click "Add User" (הוסף משתמש)
2. Enter user details:
   - Name
   - Email
   - Password
   - Role (Patient, Doctor, Admin)
   - Phone (optional)
3. Click "Create" (צור)

**Managing Users:**
- **Edit:** Update user information
- **Disable:** Temporarily disable account
- **Delete:** Permanently remove user
- **Reset Password:** Send password reset email
- **Change Role:** Assign different role

**User List Features:**
- Search by name, email, or role
- Filter by role
- Sort by various criteria
- Export user list

---

#### 2. **Doctor Management**

**Access:** Click "Doctor Management" (ניהול רופאים) from the dashboard

**Adding Doctors:**
1. Click "Add Doctor" (הוסף רופא)
2. Enter doctor information:
   - Personal details
   - Specialty
   - License number
   - Education
   - Languages
   - Bio
3. Set availability
4. Configure treatments
5. Save

**Managing Doctors:**
- **Verify License:** Verify doctor's license
- **Set Permissions:** Configure doctor permissions
- **Manage Specialties:** Assign specialties
- **View Statistics:** See doctor performance
- **Enable/Disable:** Activate or deactivate doctor

---

#### 3. **Reports & Analytics**

**Access:** Click "Reports" (דוחות) from the dashboard

**Available Reports:**
- **Appointment Reports:**
  - Total appointments
  - By status
  - By doctor
  - By specialty
  - By date range
- **Revenue Reports:**
  - Total revenue
  - By payment method
  - By doctor
  - By time period
- **Patient Reports:**
  - Patient demographics
  - Appointment frequency
  - No-show rates
- **Doctor Performance:**
  - Appointments per doctor
  - Revenue per doctor
  - Patient satisfaction

**Generating Reports:**
1. Select report type
2. Set date range
3. Apply filters
4. Click "Generate" (צור דוח)
5. View or export report

**Export Options:**
- CSV format
- PDF format
- Excel format

---

#### 4. **System Settings**

**Access:** Click "System Settings" (הגדרות מערכת) from the dashboard

**General Settings:**
- Clinic information
- Contact details
- Business hours
- Timezone
- Language preferences

**Payment Settings:**
- Payment methods enabled
- Stripe configuration
- Deposit policies
- Refund policies

**Notification Settings:**
- Email configuration
- SMS configuration
- WhatsApp configuration
- Push notification settings
- Notification templates

**Calendar Settings:**
- Default calendar provider
- Sync settings
- Reminder settings

---

## Developer Guide

### Overview

As a developer, you have complete system control, including database management, security monitoring, and system configuration.

### Main Features

#### 1. **Database Management**

**Access:** Click "Database" (מסד נתונים) from the dashboard

**Backup Operations:**
- **Download Backup:**
  1. Click "Download Backup" (הורד גיבוי)
  2. Select backup type
  3. Click "Generate" (צור)
  4. Download SQL file

- **Upload Backup:**
  1. Click "Upload Backup" (העלה גיבוי)
  2. Select SQL file
  3. Review backup details
  4. Click "Restore" (שחזר)
  5. Confirm restoration

- **Restore Database:**
  1. Select backup file
  2. Review restore options
  3. Click "Restore" (שחזר)
  4. Confirm action
  5. Wait for completion

**Database Optimization:**
- Click "Optimize Database" (אופטימיזציה מסד נתונים)
- System will optimize tables
- View optimization results

**Database Statistics:**
- View table sizes
- Record counts
- Database performance metrics

---

#### 2. **Security Dashboard**

**Access:** Click "Security" (אבטחה) from the dashboard

**Security Monitoring:**
- Real-time threat detection
- Security alerts
- Failed login attempts
- Suspicious activity

**Security Reports:**
- Generate security reports
- View audit logs
- Analyze security events
- Export security data

**Access Control:**
- Monitor user access
- View permission changes
- Track role assignments
- Review access patterns

---

#### 3. **Specialty Management**

**Access:** Click "Specialties" (התמחויות) from the dashboard

**Managing Specialties:**
- **Enable/Disable:** Turn specialties on/off
- **Organize:** Group by categories
- **Order:** Set display order
- **Icons:** Assign icons to specialties

**Specialty Categories:**
- Dental
- Physical Therapy
- Aesthetic
- Mental Health
- Nutrition
- And more...

---

#### 4. **System Logs**

**Access:** Click "System Logs" (יומני מערכת) from the dashboard

**Viewing Logs:**
- Filter by category (Security, User, System)
- Filter by severity (Error, Warning, Info)
- Search logs
- Export logs

**Log Categories:**
- **Security:** Authentication, authorization, security events
- **User:** User actions, profile changes
- **System:** System events, errors, performance
- **Payment:** Payment transactions, refunds
- **Appointment:** Booking, cancellation, rescheduling

---

## Common Tasks

### For Patients

#### How to Book Your First Appointment
1. Login to the system
2. Select "Patient" role
3. Click "Doctors" (רופאים)
4. Search or filter doctors
5. Click "Book Appointment" (קבע תור)
6. Select date and time
7. Complete payment
8. Receive confirmation

#### How to Reschedule an Appointment
1. Go to "My Appointments" (התורים שלי)
2. Find the appointment
3. Click "Reschedule" (דחה תור)
4. Select new date/time
5. Confirm

#### How to Cancel an Appointment
1. Go to "My Appointments" (התורים שלי)
2. Find the appointment
3. Click "Cancel" (בטל תור)
4. Confirm cancellation
5. Check refund status

---

### For Doctors

#### How to Create a New Patient
1. Login as Doctor
2. Click "My Patients" (המטופלים שלי)
3. Click "Create Patient" (יצירת מטופל)
4. Fill in patient information
5. Save

#### How to Set Your Availability
1. Go to "Settings" (הגדרות)
2. Click "Availability" (זמינות)
3. Set working hours for each day
4. Add holidays/unavailable dates
5. Save

#### How to View Your Calendar
1. Click "Appointments" (לוח תורים)
2. View calendar view
3. See all appointments
4. Click on appointment for details

---

### For Administrators

#### How to Add a New Doctor
1. Login as Admin
2. Go to "Doctor Management" (ניהול רופאים)
3. Click "Add Doctor" (הוסף רופא)
4. Enter doctor details
5. Set permissions
6. Save

#### How to Generate a Report
1. Go to "Reports" (דוחות)
2. Select report type
3. Set date range
4. Apply filters
5. Click "Generate" (צור דוח)
6. Export if needed

---

## Troubleshooting

### Common Issues

#### Login Problems

**Issue:** Cannot login
**Solutions:**
- Check email and password
- Try password reset
- Contact administrator
- Clear browser cache

**Issue:** Role selection not appearing
**Solutions:**
- Refresh the page
- Clear browser cache
- Try different browser
- Contact support

---

#### Appointment Booking Issues

**Issue:** Cannot see available time slots
**Solutions:**
- Check date selection
- Try different date
- Contact doctor/clinic
- Refresh page

**Issue:** Payment failed
**Solutions:**
- Check payment method
- Verify card details
- Try different payment method
- Contact support

---

#### Calendar Sync Issues

**Issue:** Calendar not syncing
**Solutions:**
- Reconnect calendar
- Check calendar permissions
- Verify calendar provider
- Contact support

---

### Getting Help

**Support Channels:**
- **Email:** support@medical-app.com
- **Phone:** [Phone number]
- **In-App:** Help section
- **Documentation:** User guides

**Support Hours:**
- Monday-Friday: 9:00 AM - 6:00 PM
- Emergency support: 24/7 for critical issues

---

## FAQs

### General Questions

**Q: Can I use the system on my phone?**
A: Yes, the system works on mobile browsers and native apps (when available).

**Q: What languages are supported?**
A: Hebrew, English, and Arabic with full RTL support.

**Q: Is my data secure?**
A: Yes, all data is encrypted and the system follows security best practices.

**Q: Can I cancel an appointment?**
A: Yes, you can cancel appointments. Refund depends on cancellation policy.

---

### Patient Questions

**Q: How do I book an appointment?**
A: Search for a doctor, select date/time, and complete payment.

**Q: Can I reschedule my appointment?**
A: Yes, go to "My Appointments" and click "Reschedule".

**Q: What payment methods are accepted?**
A: Credit/Debit cards, Bank transfer, Cash, and PayPal.

**Q: Will I receive reminders?**
A: Yes, you'll receive reminders via email, SMS, or WhatsApp 24 hours before.

---

### Doctor Questions

**Q: How do I set my availability?**
A: Go to Settings → Availability and set your working hours.

**Q: Can I create patients?**
A: Yes, doctors can create patient profiles.

**Q: How do I sync with my calendar?**
A: Go to Settings → Calendar and connect your Google or Outlook calendar.

**Q: Can I see my payment history?**
A: Yes, go to Payments section to view all payments.

---

### Administrator Questions

**Q: How do I add a new doctor?**
A: Go to Doctor Management → Add Doctor and fill in details.

**Q: Can I generate reports?**
A: Yes, go to Reports section and select report type.

**Q: How do I manage user permissions?**
A: Go to User Management and edit user roles/permissions.

---

## Additional Resources

### Documentation
- API Documentation
- Technical Documentation
- Deployment Guide
- Security Guide

### Training
- Video Tutorials
- Webinars
- Training Sessions
- Quick Start Guides

### Support
- Help Center
- Knowledge Base
- Community Forum
- Contact Support

---

**Document Version:** 1.0  
**Last Updated:** November 15, 2025  
**System Version:** Medical Appointment Management System v1.0

