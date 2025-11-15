import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
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
                    'Medical Appointment System',
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
        _buildNavItem(context, 'Dashboard', Icons.dashboard, '/home'),
        _buildNavItem(context, 'Appointments', Icons.calendar_today, '/appointments'),
        _buildNavItem(context, 'Doctors', Icons.medical_services, '/doctors'),
        _buildNavItem(context, 'Settings', Icons.settings, '/settings'),
      ];
    } else if (role == 'doctor') {
      return [
        _buildNavItem(context, 'Dashboard', Icons.dashboard, '/doctor-dashboard'),
        _buildNavItem(context, 'Appointments', Icons.calendar_today, '/appointments'),
        _buildNavItem(context, 'Patients', Icons.people, '/doctor-patients'),
        _buildNavItem(context, 'Messages', Icons.message, '/messages'),
        _buildNavItem(context, 'Settings', Icons.settings, '/settings'),
      ];
    } else {
      return [
        _buildNavItem(context, 'Dashboard', Icons.dashboard, '/developer-control'),
        _buildNavItem(context, 'Appointments', Icons.calendar_today, '/appointments'),
        _buildNavItem(context, 'Patients', Icons.people, '/manage-users'),
        _buildNavItem(context, 'Settings', Icons.settings, '/settings'),
      ];
    }
  }

  Widget _buildNavItem(BuildContext context, String title, IconData icon, String route) {
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
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
}




