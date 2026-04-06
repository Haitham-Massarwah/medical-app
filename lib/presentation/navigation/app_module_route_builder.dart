import 'package:flutter/material.dart';

import '../pages/admin_health_page.dart';
import '../pages/admin_permissions.dart';
import '../pages/admin_payment_control.dart';
import '../pages/admin_all_appointments.dart';
import '../pages/appointments_page.dart';
import '../pages/booking_management_page.dart';
import '../pages/calendar_connection_page.dart';
import '../pages/create_doctor_page.dart';
import '../pages/create_patient_page.dart';
import '../pages/crm_communication_page.dart';
import '../pages/developer_database_page.dart';
import '../pages/developer_specialty_settings.dart';
import '../pages/doctor_booking_page.dart';
import '../pages/doctor_calendar_page.dart';
import '../pages/doctors_page.dart';
import '../pages/doctors_list_page.dart';
import '../pages/finance_operations_page.dart';
import '../pages/forms_documents_page.dart';
import '../pages/integrations_operations_page.dart';
import '../pages/notifications_page.dart';
import '../pages/patient_management_page.dart';
import '../pages/payment_settings_page.dart';
import '../pages/settings_page.dart';
import '../pages/users_list_page.dart';

/// Builds full-screen module pages for [Navigator.push] (stacked routes with back).
Widget? buildModuleWidget(String route, {Object? arguments}) {
  final Map<String, dynamic>? args =
      arguments is Map<String, dynamic> ? arguments : null;

  switch (route) {
    case '/forms-documents':
      return const FormsDocumentsPage();
    case '/crm-communication':
      return const CrmCommunicationPage();
    case '/finance-operations':
      return const FinanceOperationsPage();
    case '/integrations-operations':
      return const IntegrationsOperationsPage();
    case '/admin-health':
      return const AdminHealthPage();
    case '/booking-management':
      return const BookingManagementPage();
    case '/create-patient':
      return const CreatePatientPage();
    case '/create-doctor':
      return const CreateDoctorPage(isAdmin: true);
    case '/doctor-calendar':
      return const DoctorCalendarPage();
    case '/doctor-patients':
      return const PatientManagementPage();
    case '/doctor-booking':
      return const DoctorBookingPage();
    case '/calendar-connection':
      return const CalendarConnectionPage();
    case '/doctors':
      return const DoctorsPage();
    case '/my-appointments':
      return const AppointmentsPage();
    case '/settings':
      return const SettingsPage();
    case '/messages':
    case '/notifications':
      return const NotificationsPage();
    case '/users-list':
      return const UsersListPage();
    case '/doctors-list':
      return const DoctorsListPage();
    case '/appointments':
      return const AdminAllAppointments();
    case '/admin-payment-control':
      return const AdminPaymentControl();
    case '/admin-permissions':
      return const AdminPermissions();
    case '/developer-specialty-settings':
      return const DeveloperSpecialtySettings();
    case '/payment-settings':
      return const PaymentSettingsPage();
    case '/developer-database':
      final readOnly = args != null && args['readOnly'] == true;
      return DeveloperDatabasePage(isReadOnly: readOnly);
    default:
      return null;
  }
}

/// Opens a module on a new route (stack). Dashboard routes should use [openDashboardRoot] instead.
void openModuleRoute(BuildContext context, String route, {Object? arguments}) {
  final w = buildModuleWidget(route, arguments: arguments);
  if (w != null) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        settings: RouteSettings(name: route, arguments: arguments),
        builder: (_) => w,
      ),
    );
    return;
  }
  Navigator.pushNamed(context, route, arguments: arguments);
}

/// Pops back to the root dashboard (first route after login).
void popToDashboardRoot(BuildContext context) {
  Navigator.popUntil(context, (r) => r.isFirst);
}

bool _isDashboardHomeRoute(String route, String role) {
  if (route == '/home' && (role == 'patient' || role == 'customer')) return true;
  if (route == '/doctor-dashboard' && role == 'doctor') return true;
  if (route == '/receptionist-dashboard' && role == 'receptionist') return true;
  if (route == '/developer-control' && (role == 'admin' || role == 'developer')) return true;
  return false;
}

/// Sidebar / drawer: dashboard home pops stack; everything else opens a new pushed screen when possible.
void navigateFromSidebar(
  BuildContext context,
  String route, {
  required String role,
  Object? arguments,
}) {
  if (_isDashboardHomeRoute(route, role)) {
    popToDashboardRoot(context);
    return;
  }
  openModuleRoute(context, route, arguments: arguments);
}
