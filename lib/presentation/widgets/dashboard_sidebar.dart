import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../navigation/app_module_route_builder.dart';
import 'app_logo.dart';

class DashboardSidebar extends StatelessWidget {
  final String currentRoute;
  final String role;
  
  const DashboardSidebar({
    Key? key,
    required this.currentRoute,
    required this.role,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primaryDark, AppColors.primaryMedium],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo and title
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const AppLogo(size: 50, showText: false),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'מערכת תורים רפואיים',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 20),
          
          // Navigation items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: _buildNavItems(context),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildNavItems(BuildContext context) {
    if (role == 'patient') {
      return [
        _buildNavItem(context, role, 'ראשי', Icons.dashboard, '/home'),
        _buildNavItem(context, role, 'תורים', Icons.calendar_today, '/my-appointments'),
        _buildNavItem(context, role, 'רופאים', Icons.medical_services, '/doctors'),
        _buildNavItem(context, role, 'טפסים ומסמכים', Icons.description, '/forms-documents'),
        _buildDisabledCartButton(context),
        _buildNavItem(context, role, 'חיבור ללוח שנה', Icons.calendar_month, '/calendar-connection'),
      ];
    } else if (role == 'receptionist') {
      return [
        _buildNavItem(context, role, 'לוח בקרה', Icons.dashboard, '/receptionist-dashboard'),
        _buildNavItem(context, role, 'ניהול תורים', Icons.calendar_today, '/booking-management'),
        _buildNavItem(context, role, 'מטופל חדש', Icons.person_add, '/create-patient'),
        _buildNavItem(context, role, 'טפסים ומסמכים', Icons.description, '/forms-documents'),
        _buildNavItem(context, role, 'CRM ותקשורת', Icons.campaign, '/crm-communication'),
        _buildNavItem(context, role, 'פעולות פיננסיות', Icons.account_balance_wallet, '/finance-operations'),
        _buildNavItem(context, role, 'אינטגרציות', Icons.hub, '/integrations-operations'),
        _buildNavItem(context, role, 'הגדרות', Icons.settings, '/settings'),
      ];
    } else if (role == 'doctor') {
      return [
        _buildNavItem(context, role, 'לוח בקרה', Icons.dashboard, '/doctor-dashboard'),
        _buildNavItem(context, role, 'תורים', Icons.calendar_today, '/booking-management'),
        _buildNavItem(context, role, 'לוח שנה', Icons.calendar_month, '/doctor-calendar'),
        _buildNavItem(context, role, 'מטופלים', Icons.people, '/doctor-patients'),
        _buildNavItem(context, role, 'קביעת תור', Icons.event_available, '/doctor-booking'),
        _buildNavItem(context, role, 'טפסים ומסמכים', Icons.description, '/forms-documents'),
        _buildNavItem(context, role, 'CRM ותקשורת', Icons.campaign, '/crm-communication'),
        _buildNavItem(context, role, 'פעולות פיננסיות', Icons.account_balance_wallet, '/finance-operations'),
        _buildNavItem(context, role, 'אינטגרציות', Icons.hub, '/integrations-operations'),
        _buildNavItem(context, role, 'הודעות', Icons.message, '/messages'),
        _buildNavItem(context, role, 'הגדרות', Icons.settings, '/settings'),
      ];
    } else if (role == 'admin') {
      return [
        _buildNavItem(context, role, 'Dashboard', Icons.dashboard, '/developer-control',
            arguments: {'role': role}),
        _buildNavItem(context, role, 'Users', Icons.people, '/users-list',
            arguments: {'role': role}),
        _buildNavItem(context, role, 'Doctors', Icons.medical_services, '/doctors-list',
            arguments: {'role': role}),
        _buildNavItem(context, role, 'Appointments', Icons.calendar_today, '/appointments',
            arguments: {'role': role}),
        _buildNavItem(context, role, 'Payments', Icons.payment, '/admin-payment-control',
            arguments: {'role': role}),
        _buildNavItem(context, role, 'Permissions', Icons.admin_panel_settings, '/admin-permissions',
            arguments: {'role': role}),
        _buildNavItem(context, role, 'Forms', Icons.description, '/forms-documents',
            arguments: {'role': role}),
        _buildNavItem(context, role, 'CRM', Icons.campaign, '/crm-communication',
            arguments: {'role': role}),
        _buildNavItem(context, role, 'Finance', Icons.account_balance_wallet, '/finance-operations',
            arguments: {'role': role}),
        _buildNavItem(context, role, 'Integrations', Icons.hub, '/integrations-operations',
            arguments: {'role': role}),
        _buildNavItem(context, role, 'Admin Health', Icons.health_and_safety, '/admin-health',
            arguments: {'role': role}),
      ];
    } else {
      // Developer role – keep in English
      return [
        _buildNavItem(context, role, 'Dashboard', Icons.dashboard, '/developer-control',
            arguments: {'role': role}),
        _buildNavItem(context, role, 'Appointments', Icons.calendar_today, '/appointments',
            arguments: {'role': role}),
        _buildNavItem(context, role, 'Users', Icons.people, '/users-list',
            arguments: {'role': role}),
        _buildNavItem(context, role, 'Doctors', Icons.medical_services, '/doctors-list',
            arguments: {'role': role}),
        _buildNavItem(context, role, 'Payments', Icons.payment, '/admin-payment-control',
            arguments: {'role': role}),
        _buildNavItem(context, role, 'Permissions', Icons.admin_panel_settings, '/admin-permissions',
            arguments: {'role': role}),
        _buildNavItem(context, role, 'Forms', Icons.description, '/forms-documents',
            arguments: {'role': role}),
        _buildNavItem(context, role, 'CRM', Icons.campaign, '/crm-communication',
            arguments: {'role': role}),
        _buildNavItem(context, role, 'Finance', Icons.account_balance_wallet, '/finance-operations',
            arguments: {'role': role}),
        _buildNavItem(context, role, 'Integrations', Icons.hub, '/integrations-operations',
            arguments: {'role': role}),
        _buildNavItem(context, role, 'Admin Health', Icons.health_and_safety, '/admin-health',
            arguments: {'role': role}),
        _buildNavItem(context, role, 'Database', Icons.storage, '/developer-database',
            arguments: {'role': role, 'readOnly': false}),
      ];
    }
  }

  Widget _buildNavItem(
    BuildContext context,
    String role,
    String title,
    IconData icon,
    String route, {
    Object? arguments,
  }) {
    final isActive = currentRoute == route;
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryLight : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white, size: 22),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: () => navigateFromSidebar(context, route, role: role, arguments: arguments),
      ),
    );
  }

  // PD-09: Disabled cart button with "SOON" text ON the button
  Widget _buildDisabledCartButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(Icons.shopping_cart, color: Colors.white.withOpacity(0.5), size: 22),
        title: Row(
          children: [
            Expanded(
              child: Text(
                'עגלת תורים',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'בקרוב',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
        onTap: null, // Disabled
      ),
    );
  }
}




