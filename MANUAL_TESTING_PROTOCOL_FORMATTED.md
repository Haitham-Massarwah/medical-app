# Manual Testing Protocol
## Medical Appointment System

**Document Version:** 1.0  
**Date:** October 31, 2025  
**Purpose:** Comprehensive manual testing guide for all system functionalities  
**Target Audience:** QA Testers, Developers, Product Managers

---

## Test Procedures

This section describes the detailed test procedures for each test.

**Note:** Each test will be executed on both Windows Desktop and Web platforms where applicable.

---

## End-to-End

This section describes the detailed test procedures for all cases of this test.

---

## 🔐 SECTION 1: AUTHENTICATION & SECURITY TESTING

---

### Successful Login as Doctor [TC-AUTH-001]

**Designed by:** QA Team  
**Date of review:** October 31, 2025  
**Reviewed and approved by:** Development Team, Product Owner

---

#### Test Setup:

- Flutter application installed and ready to launch
- Backend server running on `http://localhost:3000`
- Database connected and populated with test data
- Test doctor account created:
  - Email: `doctor@medicalapp.com`
  - Password: `doctor123`
  - Role: doctor
- Network connection stable

---

#### Pre-condition(s):

- PC/Device is powered on and ready
- Flutter application is installed
- Backend server is running and accessible
- Test accounts are created in database
- Network connectivity is established
- Application can be launched

---

#### Steps:

| Step | Procedure Action | Expected Results |
|------|------------------|------------------|
| 1 | Launch the Flutter application | App opens successfully, login screen appears |
| 2 | Verify login screen appears | Login form with email and password fields is visible |
| 3 | Enter doctor email: `doctor@medicalapp.com` | Email field accepts input and displays the entered email |
| 4 | Enter password: `doctor123` | Password field accepts input (password is masked/asterisks) |
| 5 | Tap/Click "התחבר" (Login) button | Button responds to interaction, login process is initiated |
| 6 | Wait for navigation (2-3 seconds) | Loading indicator may appear, system processes authentication |
| 7 | Verify navigation to doctor dashboard | Doctor home screen/dashboard appears, login succeeds without errors |
| 8 | Verify doctor information is displayed | Doctor name/email displayed in header or profile section |
| 9 | Verify doctor-specific menu items are visible | Menu shows doctor-specific features (appointments, treatments, invitations) |

---

### Failed Login - Invalid Credentials [TC-AUTH-002]

**Designed by:** QA Team  
**Date of review:** October 31, 2025  
**Reviewed and approved by:** Development Team, Product Owner

---

#### Test Setup:

- Flutter application installed and ready to launch
- Backend server running on `http://localhost:3000`
- Network connection stable

---

#### Pre-condition(s):

- Application is launched
- Login screen is visible
- User has access to invalid test credentials:
  - Email: `wrong@email.com`
  - Password: `wrongpass`

---

#### Steps:

| Step | Procedure Action | Expected Results |
|------|------------------|------------------|
| 1 | Launch the application | Login screen appears |
| 2 | Enter invalid email: `wrong@email.com` | Email field accepts input |
| 3 | Enter wrong password: `wrongpass` | Password field accepts input |
| 4 | Tap/Click "התחבר" button | Button responds, login attempt is initiated |
| 5 | Wait for response (2-3 seconds) | System processes login attempt and validates credentials |
| 6 | Verify error message appears | Error message displays: "שגיאה בהתחברות" or similar error message |
| 7 | Verify user remains on login screen | User is not navigated away, remains on login page |
| 8 | Verify fields can be cleared/edited | Email and password fields can be cleared and new values entered |
| 9 | Verify user can retry | User can enter correct credentials and attempt login again |

---

### Successful Login as Customer [TC-AUTH-003]

**Designed by:** QA Team  
**Date of review:** October 31, 2025  
**Reviewed and approved by:** Development Team, Product Owner

---

#### Test Setup:

- Flutter application installed and ready to launch
- Backend server running on `http://localhost:3000`
- Database connected and populated with test data
- Test customer account created:
  - Email: `customer@medicalapp.com`
  - Password: `customer123`
  - Role: patient
- Network connection stable

---

#### Pre-condition(s):

- Application is launched
- Login screen is visible
- Test customer account exists in database
- Backend server is accessible

---

#### Steps:

| Step | Procedure Action | Expected Results |
|------|------------------|------------------|
| 1 | Launch application | Login screen appears |
| 2 | Enter customer email: `customer@medicalapp.com` | Email entered successfully in email field |
| 3 | Enter password: `customer123` | Password entered successfully in password field |
| 4 | Tap/Click login button | Login process is initiated |
| 5 | Wait for navigation | Customer dashboard loads after authentication |
| 6 | Verify login succeeds | No error messages, successful authentication |
| 7 | Verify customer dashboard appears | Customer home screen/dashboard is displayed |
| 8 | Verify customer-specific features visible | Features like "Book Appointment", "My Appointments" are visible |

---

### Successful Login as Developer [TC-AUTH-004]

**Designed by:** QA Team  
**Date of review:** October 31, 2025  
**Reviewed and approved by:** Development Team, Product Owner

---

#### Test Setup:

- Flutter application installed and ready to launch
- Backend server running on `http://localhost:3000`
- Database connected and populated with test data
- Test developer account created:
  - Email: `developer@medicalapp.com`
  - Password: `dev123`
  - Role: developer
- Network connection stable

---

#### Pre-condition(s):

- Application is launched
- Login screen is visible
- Test developer account exists in database
- Backend server is accessible

---

#### Steps:

| Step | Procedure Action | Expected Results |
|------|------------------|------------------|
| 1 | Launch application | Login screen appears |
| 2 | Enter developer email: `developer@medicalapp.com` | Email entered successfully |
| 3 | Enter password: `dev123` | Password entered successfully |
| 4 | Tap/Click login button | Login initiated |
| 5 | Wait for navigation | Developer dashboard loads |
| 6 | Verify login succeeds | No errors, successful authentication |
| 7 | Verify developer dashboard appears | Developer home screen is displayed |
| 8 | Verify developer controls visible | Controls for user management, system logs, payments are visible |

---

### Logout Functionality [TC-AUTH-005]

**Designed by:** QA Team  
**Date of review:** October 31, 2025  
**Reviewed and approved by:** Development Team, Product Owner

---

#### Test Setup:

- Flutter application installed and ready to launch
- Backend server running on `http://localhost:3000`
- User is logged in with any valid account (doctor, customer, or developer)
- User session is active

---

#### Pre-condition(s):

- User is successfully logged into the application
- User menu/profile section is accessible
- User session data exists

---

#### Steps:

| Step | Procedure Action | Expected Results |
|------|------------------|------------------|
| 1 | Login with any valid account | User is logged in and dashboard/home screen is displayed |
| 2 | Navigate to user menu/profile | User menu or profile section is accessible and opens |
| 3 | Locate logout button (🚪 icon or "התנתק" text) | Logout button/option is visible in menu |
| 4 | Tap/Click logout button | Logout action is initiated |
| 5 | Confirm logout if prompted | If confirmation dialog appears, confirm the logout action |
| 6 | Verify return to login screen | Application returns to login screen |
| 7 | Verify user is logged out | User cannot access protected features without logging in again |
| 8 | Verify session data is cleared | User must enter credentials again to login |
| 9 | Attempt to access protected page directly | Application redirects to login screen |

---

## 👨‍⚕️ SECTION 2: DOCTOR FUNCTIONALITY TESTING

---

### Doctor Enables Online Payments [TC-DOC-001]

**Designed by:** QA Team  
**Date of review:** October 31, 2025  
**Reviewed and approved by:** Development Team, Product Owner

---

#### Test Setup:

- Flutter application installed and ready to launch
- Backend server running on `http://localhost:3000`
- Doctor account logged in
- Appointment settings page is accessible
- Database supports payment configuration storage

---

#### Pre-condition(s):

- Doctor is successfully logged in
- Doctor dashboard/home screen is displayed
- Navigation to appointment settings is available
- Payment toggle/switch is accessible in settings

---

#### Steps:

| Step | Procedure Action | Expected Results |
|------|------------------|------------------|
| 1 | Login as doctor | Doctor dashboard visible, user is authenticated |
| 2 | Navigate to "הגדרות תורים" (Appointment Settings) or "טיפולים" (Treatments) | Settings page opens, payment configuration section is visible |
| 3 | Locate "תשלום אונליין" (Online Payment) toggle | Toggle/switch is visible, currently in OFF position |
| 4 | Enable the toggle (tap/click) | Toggle switches from OFF to ON position |
| 5 | Verify payment configuration options appear | Price fields and payment settings become visible |
| 6 | Wait 2 seconds for auto-save or manually save | Changes are saved (either automatically or via save button) |
| 7 | Verify changes are saved | Success message appears or no error message is shown |
| 8 | Verify payment toggle remains ON | Toggle state persists in ON position |
| 9 | (Optional) Restart app and verify persistence | Settings remain enabled after app restart |

---

### Doctor Sets Treatment Price [TC-DOC-002]

**Designed by:** QA Team  
**Date of review:** October 31, 2025  
**Reviewed and approved by:** Development Team, Product Owner

---

#### Test Setup:

- Flutter application installed and ready to launch
- Backend server running on `http://localhost:3000`
- Doctor account logged in
- Payment is enabled (from TC-DOC-001)
- Treatment configuration page is accessible

---

#### Pre-condition(s):

- Doctor is logged in
- Online payments are enabled
- Treatment configuration page is accessible
- Price fields are visible (payment must be enabled)

---

#### Steps:

| Step | Procedure Action | Expected Results |
|------|------------------|------------------|
| 1 | Login as doctor | Doctor dashboard appears |
| 2 | Navigate to treatment configuration | Treatment settings page opens |
| 3 | Select a treatment or create new one | Treatment form/editor appears |
| 4 | Enter treatment name: "ייעוץ כללי" | Name field accepts text input |
| 5 | Enter price: `300` in price field | Price field accepts numeric input |
| 6 | Set duration: 30 minutes | Duration selector works, duration is selected |
| 7 | Tap/Click save button | Save action is initiated |
| 8 | Verify treatment appears in list | Treatment is visible in treatments list with price displayed |
| 9 | Verify price format is correct | Price displays as "₪ 300" or "300 ILS" |

---

### Doctor Disables Payments - Price Fields Hidden [TC-DOC-003]

**Designed by:** QA Team  
**Date of review:** October 31, 2025  
**Reviewed and approved by:** Development Team, Product Owner

---

#### Test Setup:

- Flutter application installed and ready to launch
- Backend server running on `http://localhost:3000`
- Doctor account logged in
- Appointment settings page is accessible

---

#### Pre-condition(s):

- Doctor is logged in
- Appointment settings page is accessible
- Payment toggle exists and is accessible

---

#### Steps:

| Step | Procedure Action | Expected Results |
|------|------------------|------------------|
| 1 | Login as doctor | Doctor dashboard visible |
| 2 | Navigate to appointment settings | Settings page opens |
| 3 | Locate "תשלום אונליין" toggle | Toggle is visible (may be ON or OFF) |
| 4 | Disable toggle (ensure it's OFF) | Toggle switches to OFF position |
| 5 | Navigate to treatment settings | Treatment page opens |
| 6 | Verify price fields are hidden or disabled | Price input fields are not visible or are disabled |
| 7 | Verify message appears | Message "תשלום זמין רק בקליניקה" is displayed |
| 8 | Verify previously set prices are hidden | Price values are not displayed in UI |

---

## 📧 SECTION 3: DOCTOR INVITATION TESTING

---

### Doctor Sends Customer Invitation [TC-INV-001]

**Designed by:** QA Team  
**Date of review:** October 31, 2025  
**Reviewed and approved by:** Development Team, Product Owner

---

#### Test Setup:

- Flutter application installed and ready to launch
- Backend server running on `http://localhost:3000`
- Email service configured and operational
- Doctor account logged in
- Invitation feature is accessible
- Test email account available for verification: `newcustomer@example.com`

---

#### Pre-condition(s):

- Doctor is logged in
- Invitation feature is accessible
- Email service is configured and working
- Backend can generate invitation tokens
- Test email account is accessible for verification

---

#### Steps:

| Step | Procedure Action | Expected Results |
|------|------------------|------------------|
| 1 | Login as doctor | Doctor dashboard visible |
| 2 | Navigate to "הזמן לקוח" (Invite Customer) section | Invitation page/form opens |
| 3 | Enter customer email: `newcustomer@example.com` | Email field accepts input |
| 4 | Optionally add customer name | Name field accepts input (if available) |
| 5 | Tap/Click "שלח הזמנה" (Send Invitation) button | Button responds, invitation process is initiated |
| 6 | Wait for response (3-5 seconds) | System processes invitation, generates token |
| 7 | Verify success message appears | Success message: "הזמנה נשלחה בהצלחה" is displayed |
| 8 | Check email inbox (if accessible) | Invitation email is received at specified address |
| 9 | Verify invitation link contains token | Email contains registration link with valid token |
| 10 | Verify invitation appears in sent invitations list | Invitation is listed in doctor's sent invitations |

---

### Doctor Invites with Invalid Email - Error [TC-INV-002]

**Designed by:** QA Team  
**Date of review:** October 31, 2025  
**Reviewed and approved by:** Development Team, Product Owner

---

#### Test Setup:

- Flutter application installed and ready to launch
- Backend server running on `http://localhost:3000`
- Doctor account logged in
- Invitation feature is accessible

---

#### Pre-condition(s):

- Doctor is logged in
- Invitation form is accessible
- Email validation is implemented

---

#### Steps:

| Step | Procedure Action | Expected Results |
|------|------------------|------------------|
| 1 | Login as doctor | Doctor dashboard visible |
| 2 | Navigate to invite customer | Invitation form opens |
| 3 | Enter invalid email: `not-an-email` | Email field accepts input |
| 4 | Attempt to send invitation (tap send button) | System validates email format |
| 5 | Verify validation error appears | Error message: "כתובת אימייל לא תקינה" is displayed |
| 6 | Verify send button is disabled or shows error | "שלח הזמנה" button is disabled or shows error state |
| 7 | Verify user can correct email | User can edit email field and enter valid format |
| 8 | Enter valid email format | Validation passes, user can proceed |

---

## 👤 SECTION 4: CUSTOMER FUNCTIONALITY TESTING

---

### Customer Views Doctor with Prices [TC-BOOK-001]

**Designed by:** QA Team  
**Date of review:** October 31, 2025  
**Reviewed and approved by:** Development Team, Product Owner

---

#### Test Setup:

- Flutter application installed and ready to launch
- Backend server running on `http://localhost:3000`
- Customer account logged in
- At least one doctor has payments enabled with prices set
- Doctor list is accessible

---

#### Pre-condition(s):

- Customer is logged in
- Booking/appointment feature is accessible
- Doctor has payments enabled (from TC-DOC-001)
- Doctor has set treatment prices (from TC-DOC-002)

---

#### Steps:

| Step | Procedure Action | Expected Results |
|------|------------------|------------------|
| 1 | Login as customer | Customer dashboard appears |
| 2 | Navigate to "קבע תור" (Book Appointment) | Booking page opens |
| 3 | Browse available doctors | Doctor list is displayed |
| 4 | Select a doctor who has payments enabled | Doctor profile/details page opens |
| 5 | View doctor profile/treatment options | Treatment list with prices is visible |
| 6 | Verify doctor list displays correctly | Doctor cards show name, specialty, photo |
| 7 | Verify prices are visible | Prices displayed clearly (e.g., "₪ 300 לייעוץ כללי") |
| 8 | Verify different prices for different treatments | Multiple treatments show different prices |

---

### Customer Books Appointment [TC-BOOK-002]

**Designed by:** QA Team  
**Date of review:** October 31, 2025  
**Reviewed and approved by:** Development Team, Product Owner

---

#### Test Setup:

- Flutter application installed and ready to launch
- Backend server running on `http://localhost:3000`
- Customer account logged in
- Doctor has available appointment slots
- Calendar/date picker is functional
- Payment processing (if required) is configured

---

#### Pre-condition(s):

- Customer is logged in
- Booking feature is accessible
- Doctor has available time slots
- Payment method is ready (if payment required)

---

#### Steps:

| Step | Procedure Action | Expected Results |
|------|------------------|------------------|
| 1 | Login as customer | Customer dashboard appears |
| 2 | Navigate to "קבע תור" | Booking page opens |
| 3 | Select a doctor | Doctor profile opens |
| 4 | Choose treatment type | Treatment is selected from available options |
| 5 | Select available date from calendar | Date picker opens, date is selected |
| 6 | Select available time slot | Time slot is selected from available times |
| 7 | If payment required, complete payment flow | Payment form/process appears, payment is processed |
| 8 | Tap/Click confirm booking | Booking confirmation screen appears |
| 9 | Verify booking is saved | Booking is saved in system, confirmation message appears |
| 10 | Verify appointment in "התורים שלי" | Appointment appears in customer's appointment list |
| 11 | Verify doctor sees new appointment | Doctor's calendar shows the new appointment |

---

## 🌐 SECTION 5: WEB REGISTRATION TESTING

---

### Customer Registration via Invitation Link - Valid Token [TC-REG-001]

**Designed by:** QA Team  
**Date of review:** October 31, 2025  
**Reviewed and approved by:** Development Team, Product Owner

---

#### Test Setup:

- Web browser (Chrome, Firefox, Edge)
- Backend server running on `http://localhost:3000`
- Valid invitation email received with registration link
- Registration web page is accessible
- Database is ready to accept new user registrations

---

#### Pre-condition(s):

- Invitation email has been sent (from TC-INV-001)
- Valid invitation token exists and is not expired
- Registration link in email is accessible
- Token is not already used

---

#### Steps:

| Step | Procedure Action | Expected Results |
|------|------------------|------------------|
| 1 | Open invitation email | Email is readable, registration link is visible |
| 2 | Click registration link | Link opens in browser, registration page loads |
| 3 | Verify registration page loads | Registration form appears, page is mobile-friendly |
| 4 | Fill in name field: "Test Customer" | Name entered successfully |
| 5 | Enter password: `Test1234!` | Password entered (masked/asterisks) |
| 6 | Confirm password: `Test1234!` | Confirmation password entered |
| 7 | Optionally enter phone number | Phone field accepts input (if available) |
| 8 | Submit registration form | Form submission is processed |
| 9 | Verify registration succeeds | Success message appears or redirect to login occurs |
| 10 | Verify user is created in database | User record exists in database |
| 11 | Verify token is marked as "used" | Token status is updated to "used" in database |
| 12 | Attempt to login with new credentials | Login succeeds with new email and password |

---

### Registration Link Validation - Expired Token [TC-REG-002]

**Designed by:** QA Team  
**Date of review:** October 31, 2025  
**Reviewed and approved by:** Development Team, Product Owner

---

#### Test Setup:

- Web browser (Chrome, Firefox, Edge)
- Backend server running on `http://localhost:3000`
- Expired invitation token (manually expired in database or wait 7+ days)
- Registration web page is accessible

---

#### Pre-condition(s):

- Invitation token exists but is expired
- Token expiration time has passed
- Registration link with expired token is available

---

#### Steps:

| Step | Procedure Action | Expected Results |
|------|------------------|------------------|
| 1 | Open registration link with expired token | Link opens in browser |
| 2 | Verify error message appears | Error message: "הזמנה פגה" or "Invitation expired" is displayed |
| 3 | Verify registration form is disabled or not accessible | Form cannot be filled or submitted |
| 4 | Verify option to request new invitation | Option to request new invitation is available (if implemented) |
| 5 | Verify user cannot register | Registration cannot proceed with expired token |

---

## 🛠️ SECTION 6: DEVELOPER FUNCTIONALITY TESTING

---

### Developer Overrides Payment Settings [TC-DEV-004]

**Designed by:** QA Team  
**Date of review:** October 31, 2025  
**Reviewed and approved by:** Development Team, Product Owner

---

#### Test Setup:

- Flutter application installed and ready to launch
- Backend server running on `http://localhost:3000`
- Developer account logged in
- Payment management page is accessible
- At least one doctor exists in system

---

#### Pre-condition(s):

- Developer is logged in
- Payment management page is accessible
- Doctor account exists in system
- Override toggle/control is available

---

#### Steps:

| Step | Procedure Action | Expected Results |
|------|------------------|------------------|
| 1 | Login as developer | Developer dashboard appears |
| 2 | Navigate to "תשלומים" (Payments) or payment management | Payment management page opens |
| 3 | Select a doctor from list | Doctor details/controls are visible |
| 4 | Locate payment override toggle | Override toggle is visible for doctor |
| 5 | Toggle payment override (force enable payments) | Override is activated, toggle switches to ON |
| 6 | Save changes | Changes are saved successfully |
| 7 | Logout and login as customer | Customer dashboard appears |
| 8 | Navigate to booking page and select the doctor | Doctor profile is accessible |
| 9 | Verify prices are visible for that doctor | Prices are displayed for customer even if doctor disabled them |
| 10 | Verify override takes effect immediately | Changes are reflected without delay |

---

## ⚠️ SECTION 7: FAILURE SCENARIOS TESTING

---

### Network Error Handling [TC-FAIL-001]

**Designed by:** QA Team  
**Date of review:** October 31, 2025  
**Reviewed and approved by:** Development Team, Product Owner

---

#### Test Setup:

- Flutter application installed and ready to launch
- Backend server running on `http://localhost:3000`
- User is logged in
- Network connection can be controlled (disable WiFi/network adapter)

---

#### Pre-condition(s):

- Application is running
- User is logged in
- Network connection is active
- User has ability to disable network (for testing)

---

#### Steps:

| Step | Procedure Action | Expected Results |
|------|------------------|------------------|
| 1 | Start app and login | User is logged in, dashboard is visible |
| 2 | Disconnect internet (turn off WiFi/disable network) | Network is disconnected |
| 3 | Attempt to book appointment | Network error handling is triggered |
| 4 | Attempt to send invitation | Error message appears: "אין חיבור לאינטרנט" or "Network error" |
| 5 | Attempt to view appointments | Error is handled gracefully, no crash occurs |
| 6 | Verify app does not crash | Application remains stable, shows error message |
| 7 | Reconnect network | Network is restored |
| 8 | Retry actions | Actions succeed after network is restored |
| 9 | Verify data is not lost | Form data is preserved (if applicable) |
| 10 | Verify app syncs when network restored | Data syncs automatically or on retry |

---

### Form Validation - Empty Fields [TC-FAIL-004]

**Designed by:** QA Team  
**Date of review:** October 31, 2025  
**Reviewed and approved by:** Development Team, Product Owner

---

#### Test Setup:

- Flutter application installed and ready to launch
- Backend server running on `http://localhost:3000`
- Application is launched
- Forms are accessible (login, registration, booking, invitation)

---

#### Pre-condition(s):

- Application is launched
- Forms are accessible
- Validation is implemented for required fields

---

#### Steps:

| Step | Procedure Action | Expected Results |
|------|------------------|------------------|
| 1 | Attempt to submit login form without email/password | Required field indicators appear |
| 2 | Attempt to submit registration without name | Error message: "שדה זה חובה" is displayed |
| 3 | Attempt to book appointment without date selection | Validation prevents submission |
| 4 | Attempt to send invitation without email | Error message appears for empty email field |
| 5 | Verify submit button is disabled or shows error | Submit button is disabled or shows error state |
| 6 | Verify clear error messages | Error messages are clear and indicate which fields are required |
| 7 | Fill required fields | Validation passes, user can proceed |

---

## 📊 TEST EXECUTION SUMMARY

### Overall Test Results

| Section | Total Tests | Passed | Failed | Blocked | Skipped | Pass Rate |
|---------|-------------|--------|--------|---------|---------|-----------|
| Authentication & Security | 5 | | | | | % |
| Doctor Functionality | 5 | | | | | % |
| Doctor Invitation | 3 | | | | | % |
| Customer Functionality | 5 | | | | | % |
| Web Registration | 4 | | | | | % |
| Developer Functionality | 5 | | | | | % |
| Failure Scenarios | 5 | | | | | % |
| **TOTAL** | **32** | | | | | **%** |

### Test Session Information

| Field | Value |
|-------|-------|
| **Tester Name** | |
| **Date** | |
| **App Version** | |
| **Platform** | Windows Desktop / Web / Mobile |
| **Browser (if web)** | |

---

## ✅ Sign-off

| Role | Name | Signature | Date |
|------|------|-----------|------|
| QA Lead | | | |
| Developer | | | |
| Product Owner | | | |

---

**End of Manual Testing Protocol**

**Last Updated:** October 31, 2025



