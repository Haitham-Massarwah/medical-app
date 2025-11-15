import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/dashboard_sidebar.dart';
import '../widgets/metric_card.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // Sidebar
            const DashboardSidebar(currentRoute: '/developer-control', role: 'developer'),
            
            // Main Content - FULLY SCROLLABLE
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
                    const Text(
                      'Admin Dashboard',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Metrics Row
                    Row(
                      children: [
                        Expanded(
                          child: MetricCard(
                            value: '120',
                            label: 'Total Users',
                            color: AppColors.accentCyan,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: MetricCard(
                            value: '85',
                            label: 'Appointments Scheduled',
                            color: AppColors.accentCyan,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: MetricCard(
                            value: '5',
                            label: 'New Messages',
                            color: AppColors.accentPurple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    
                    // Two-column layout
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User List
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(25),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'User List',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _buildUserItem('Sarah Brown', 'sarah.brown@example.com', 'Patient'),
                                const Divider(),
                                _buildUserItem('John Doe', 'john.doe@example.com', 'Doctor'),
                                const Divider(),
                                _buildUserItem('Jane Smith', 'jane.smith@example.com', 'Doctor'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 25),
                        
                        // Recent Appointments
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(25),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Recent Appointments',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {},
                                      child: const Text('View All', style: TextStyle(color: AppColors.accentTeal)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                _buildAppointmentItem('Emily Wilson', 'Dr. Jane Smith', 'Apr 17, 2024'),
                                const Divider(),
                                _buildAppointmentItem('Laura Parker', 'Dr. John Doe', 'Apr 16, 2024'),
                                const Divider(),
                                _buildAppointmentItem('Daniel Scott', 'Dr. Michael', 'Apr 15, 2024'),
                              ],
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildUserItem(String name, String email, String role) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.accentCyan.withOpacity(0.2),
            child: Text(name[0], style: const TextStyle(color: AppColors.accentCyan, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(email, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: role == 'Doctor' ? AppColors.accentCyan.withOpacity(0.2) : AppColors.accentPurple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              role,
              style: TextStyle(
                color: role == 'Doctor' ? AppColors.accentCyan : AppColors.accentPurple,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentItem(String patient, String doctor, String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(patient, style: const TextStyle(fontSize: 15))),
          Expanded(flex: 2, child: Text(doctor, style: const TextStyle(fontSize: 15))),
          Expanded(flex: 1, child: Text(date, style: TextStyle(fontSize: 14, color: Colors.grey.shade700))),
        ],
      ),
    );
  }
}


