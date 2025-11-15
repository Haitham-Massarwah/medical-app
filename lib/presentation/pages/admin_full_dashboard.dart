import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/dashboard_sidebar.dart';

/// COMPLETE ADMIN CONTROL PANEL DASHBOARD
/// Full system management for administrators
class AdminFullDashboard extends StatefulWidget {
  const AdminFullDashboard({Key? key}) : super(key: key);

  @override
  State<AdminFullDashboard> createState() => _AdminFullDashboardState();
}

class _AdminFullDashboardState extends State<AdminFullDashboard> {
  // Statistics
  int _totalUsers = 120;
  int _totalDoctors = 45;
  int _totalAppointments = 567;
  double _totalRevenue = 25430.50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // Sidebar
            const DashboardSidebar(currentRoute: '/developer-control', role: 'developer'),
            
            // Main Content - FULLY SCROLLABLE ADMIN DASHBOARD
            Expanded(
              child: Container(
                color: AppColors.backgroundLight,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Page Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'לוח בקרה מנהל - Admin Control Panel',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.refresh),
                                onPressed: _refreshData,
                                tooltip: 'רענן נתונים',
                              ),
                              IconButton(
                                icon: const Icon(Icons.download),
                                onPressed: _exportData,
                                tooltip: 'הורד דוח',
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      
                      // Statistics Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'סה"כ משתמשים',
                              _totalUsers.toString(),
                              Icons.people,
                              AppColors.accentCyan,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildStatCard(
                              'סה"כ רופאים',
                              _totalDoctors.toString(),
                              Icons.medical_services,
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildStatCard(
                              'סה"כ תורים',
                              _totalAppointments.toString(),
                              Icons.calendar_today,
                              Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildStatCard(
                              'הכנסות',
                              '₪${_totalRevenue.toStringAsFixed(0)}',
                              Icons.attach_money,
                              Colors.purple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      
                      // Quick Actions
                      const Text(
                        'פעולות מהירות',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              'הוסף רופא',
                              Icons.person_add,
                              Colors.green,
                              () => Navigator.pushNamed(context, '/create-doctor'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildActionButton(
                              'הוסף מטופל',
                              Icons.person_add_outlined,
                              Colors.blue,
                              () => Navigator.pushNamed(context, '/create-patient'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildActionButton(
                              'צפה בתשלומים',
                              Icons.payment,
                              Colors.purple,
                              () => Navigator.pushNamed(context, '/admin-payment-control'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      
                      // DOCTORS SECTION (REQUESTED BY USER) - Opens LIST page
                      _buildManagementSection(
                        'כל הרופאים - All Doctors',
                        Icons.medical_services,
                        Colors.green,
                        [
                          'צפה ברשימת כל הרופאים',
                          'חיפוש וסינון רופאים',
                          'צפה בסטטיסטיקות',
                          'ניהול סטטוס (פעיל/לא פעיל)',
                        ],
                        () => Navigator.pushNamed(context, '/doctors-list'), // Goes to LIST page
                      ),
                      const SizedBox(height: 20),
                      
                      // PATIENTS SECTION - Opens LIST page
                      _buildManagementSection(
                        'כל המטופלים - All Patients',
                        Icons.people,
                        Colors.blue,
                        [
                          'צפה ברשימת כל המטופלים',
                          'חיפוש וסינון מטופלים',
                          'צפה בהיסטוריה רפואית',
                        ],
                        () => Navigator.pushNamed(context, '/users-list'), // Goes to LIST page
                      ),
                      const SizedBox(height: 20),
                      
                      // APPOINTMENTS SECTION - Opens LIST page
                      _buildManagementSection(
                        'כל התורים - All Appointments',
                        Icons.calendar_today,
                        Colors.orange,
                        [
                          'צפה בכל התורים במערכת',
                          'סינון לפי רופא / מטופל',
                          'עדכון סטטוס תורים',
                        ],
                        () => Navigator.pushNamed(context, '/appointments'), // Goes to LIST page
                      ),
                      const SizedBox(height: 20),
                      
                      // PAYMENT CONTROL (REQUESTED BY USER)
                      _buildManagementSection(
                        'בקרת תשלומים מהרופאים - Payment Control',
                        Icons.account_balance_wallet,
                        Colors.purple,
                        [
                          'מעקב אחר הכנסות מרופאים',
                          'חישוב עמלות אוטומטי',
                          'דוחות תשלומים',
                          'היסטוריית תשלומים',
                        ],
                        () => Navigator.pushNamed(context, '/admin-payment-control'),
                      ),
                      const SizedBox(height: 20),
                      
                      // TREATMENT METHODS
                      _buildManagementSection(
                        'שיטות טיפול - Treatment Methods',
                        Icons.medical_information,
                        Colors.teal,
                        [
                          'יצירת שיטות טיפול חדשות',
                          'קביעת מחירים',
                          'שיוך לרופאים',
                        ],
                        () => Navigator.pushNamed(context, '/developer-specialty-settings'),
                      ),
                      const SizedBox(height: 20),
                      
                      // PERMISSIONS (REQUESTED BY USER)
                      _buildManagementSection(
                        'הרשאות - Permissions Management',
                        Icons.admin_panel_settings,
                        Colors.red,
                        [
                          'ניהול הרשאות משתמשים',
                          'שיוך תפקידים',
                          'בקרת גישה למערכת',
                        ],
                        () => Navigator.pushNamed(context, '/admin-permissions'),
                      ),
                      const SizedBox(height: 20),
                      
                      // PAYMENT METHODS
                      _buildManagementSection(
                        'אמצעי תשלום - Payment Methods',
                        Icons.credit_card,
                        Colors.indigo,
                        [
                          'הגדרות שערי תשלום',
                          'כרטיסי אשראי',
                          'ניהול החזרים',
                        ],
                        () => Navigator.pushNamed(context, '/payment-settings'),
                      ),
                      const SizedBox(height: 20),
                      
                      // SYSTEM SETTINGS
                      _buildManagementSection(
                        'הגדרות מערכת - System Settings',
                        Icons.settings,
                        Colors.grey,
                        [
                          'הגדרות גלובליות',
                          'ניהול מסד נתונים',
                          'גיבויים',
                        ],
                        () => Navigator.pushNamed(context, '/developer-database'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementSection(
    String title,
    IconData icon,
    Color color,
    List<String> features,
    VoidCallback onTap,
  ) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('פתח'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  feature,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  void _refreshData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('מרענן נתונים...'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
    setState(() {
      // Refresh data from backend
    });
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('מייצא דוח...'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }
}

