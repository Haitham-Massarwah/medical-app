import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/dashboard_sidebar.dart';
import '../widgets/metric_card.dart';

class DoctorDashboardPage extends StatelessWidget {
  const DoctorDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // Sidebar
            const DashboardSidebar(currentRoute: '/doctor-dashboard', role: 'doctor'),
            
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
                      'Doctor Dashboard',
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
                            value: '25',
                            label: 'Upcoming Appointments',
                            color: AppColors.accentCyan,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: MetricCard(
                            value: '10',
                            label: 'New Patients This Month',
                            color: AppColors.accentCyan,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: MetricCard(
                            value: '3',
                            label: 'Messages',
                            color: AppColors.accentPurple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    
                    // Upcoming Appointments Table
                    Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Upcoming Appointments',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Table(
                            columnWidths: const {
                              0: FlexColumnWidth(2),
                              1: FlexColumnWidth(2),
                              2: FlexColumnWidth(1.5),
                              3: FlexColumnWidth(1.2),
                            },
                            children: [
                              TableRow(
                                decoration: BoxDecoration(color: Colors.grey.shade100),
                                children: const [
                                  Padding(padding: EdgeInsets.all(12), child: Text('Patient', style: TextStyle(fontWeight: FontWeight.bold))),
                                  Padding(padding: EdgeInsets.all(12), child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                                  Padding(padding: EdgeInsets.all(12), child: Text('Time', style: TextStyle(fontWeight: FontWeight.bold))),
                                  Padding(padding: EdgeInsets.all(12), child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                                ],
                              ),
                              _buildAppointmentRow('John Doe', 'Apr 10, 2024', '10:00 AM', 'Confirmed', true),
                              _buildAppointmentRow('Jane Smith', 'Apr 11, 2024', '11:00 AM', 'Confirmed', true),
                              _buildAppointmentRow('Michael Johnson', 'Apr 12, 2024', '2:00 PM', 'Pending', false),
                              _buildAppointmentRow('Sarah Brown', 'Apr 13, 2024', '3:00 PM', 'Confirmed', true),
                              _buildAppointmentRow('Emily Wilson', 'Apr 14, 2024', '2:00 PM', 'Confirmed', true),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    
                    // Messages Section
                    Container(
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
                                'Messages',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accentCyan,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('View All', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildMessage('Patricia Reed', 'Patient Portal Question', '14m'),
                          const Divider(),
                          _buildMessage('Daniel Scott', 'Appointment Request', '39m'),
                          const Divider(),
                          _buildMessage('Laura Parker', 'Follow-Up Inquiry', '1h'),
                        ],
                      ),
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

  TableRow _buildAppointmentRow(String patient, String date, String time, String status, bool isConfirmed) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(12), child: Text(patient)),
        Padding(padding: const EdgeInsets.all(12), child: Text(date)),
        Padding(padding: const EdgeInsets.all(12), child: Text(time)),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isConfirmed ? AppColors.statusConfirmed : AppColors.statusPending,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessage(String sender, String subject, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sender, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(subject, style: const TextStyle(color: Colors.black87)),
              ],
            ),
          ),
          Text(time, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        ],
      ),
    );
  }
}


