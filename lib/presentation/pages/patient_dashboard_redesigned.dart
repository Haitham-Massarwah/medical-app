import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/dashboard_sidebar.dart';
import '../widgets/metric_card.dart';

class PatientDashboardPage extends StatelessWidget {
  const PatientDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // Sidebar
            const DashboardSidebar(currentRoute: '/home', role: 'patient'),
            
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
                      'Patient Dashboard',
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
                            value: '2',
                            label: 'Upcoming Appointments',
                            color: AppColors.accentCyan,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: MetricCard(
                            value: '1',
                            label: 'New Message',
                            color: AppColors.accentCyan,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: MetricCard(
                            value: '\$250.00',
                            label: 'Amount Due',
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    
                    // Upcoming Appointments Section
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
                                'Upcoming Appointments',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: const Text('View Messages', style: TextStyle(color: AppColors.accentTeal)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Table(
                            columnWidths: const {
                              0: FlexColumnWidth(2),
                              1: FlexColumnWidth(2),
                              2: FlexColumnWidth(1.5),
                              3: FlexColumnWidth(1),
                            },
                            children: [
                              TableRow(
                                decoration: BoxDecoration(color: Colors.grey.shade100),
                                children: const [
                                  Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Text('Doctor', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Text('Time', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                              _buildTableRow('John Doe', 'April 10, 2024', '10:00 AM', 'Confirmed'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    
                    // Billing Section
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
                            'Billing',
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
                              3: FlexColumnWidth(1),
                            },
                            children: [
                              TableRow(
                                decoration: BoxDecoration(color: Colors.grey.shade100),
                                children: const [
                                  Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Text('Service', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Text('Action', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                              _buildBillingRow('April 5, 2024', 'Consultation', '\$250.00'),
                            ],
                          ),
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

  TableRow _buildTableRow(String doctor, String date, String time, String status) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(12), child: Text(doctor)),
        Padding(padding: const EdgeInsets.all(12), child: Text(date)),
        Padding(padding: const EdgeInsets.all(12), child: Text(time)),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.statusConfirmed,
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

  TableRow _buildBillingRow(String date, String service, String amount) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(12), child: Text(date)),
        Padding(padding: const EdgeInsets.all(12), child: Text(service)),
        Padding(padding: const EdgeInsets.all(12), child: Text(amount, style: const TextStyle(fontWeight: FontWeight.bold))),
        Padding(
          padding: const EdgeInsets.all(12),
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentCyan,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Pay Now', style: TextStyle(color: Colors.white, fontSize: 13)),
          ),
        ),
      ],
    );
  }
}


