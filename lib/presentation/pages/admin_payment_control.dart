import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// ADMIN PAYMENT CONTROL - Track payments from doctors to admin
class AdminPaymentControl extends StatefulWidget {
  const AdminPaymentControl({Key? key}) : super(key: key);

  @override
  State<AdminPaymentControl> createState() => _AdminPaymentControlState();
}

class _AdminPaymentControlState extends State<AdminPaymentControl> {
  // Sample data - would come from backend
  final List<Map<String, dynamic>> _doctorPayments = [
    {
      'doctorName': 'ד"ר אברהם כהן',
      'totalEarnings': 15000,
      'adminCommission': 3000, // 20% commission
      'pendingPayment': 3000,
      'lastPayment': '2024-01-01',
      'status': 'pending',
    },
    {
      'doctorName': 'ד"ר שרה לוי',
      'totalEarnings': 22000,
      'adminCommission': 4400,
      'pendingPayment': 0,
      'lastPayment': '2024-01-05',
      'status': 'paid',
    },
    {
      'doctorName': 'ד"ר דוד ישראלי',
      'totalEarnings': 18500,
      'adminCommission': 3700,
      'pendingPayment': 3700,
      'lastPayment': '2023-12-28',
      'status': 'pending',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final totalPending = _doctorPayments
        .where((d) => d['status'] == 'pending')
        .fold(0.0, (sum, d) => sum + d['pendingPayment']);
    
    final totalReceived = _doctorPayments
        .where((d) => d['status'] == 'paid')
        .fold(0.0, (sum, d) => sum + d['adminCommission']);

    return Scaffold(
      appBar: AppBar(
        title: const Text('בקרת תשלומים מרופאים'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportReport,
            tooltip: 'הורד דוח',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'רענן',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'סה"כ ממתין',
                      '₪${totalPending.toStringAsFixed(0)}',
                      Icons.pending,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      'סה"כ התקבל',
                      '₪${totalReceived.toStringAsFixed(0)}',
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Doctors Payment List
              const Text(
                'תשלומים מרופאים',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              ..._doctorPayments.map((doctor) => _buildDoctorPaymentCard(doctor)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _sendPaymentReminders,
        icon: const Icon(Icons.send),
        label: const Text('שלח תזכורות'),
        backgroundColor: Colors.purple,
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 36),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorPaymentCard(Map<String, dynamic> doctor) {
    final isPending = doctor['status'] == 'pending';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: isPending ? Colors.orange.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                      child: Icon(
                        Icons.person,
                        color: isPending ? Colors.orange : Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor['doctorName'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'תשלום אחרון: ${doctor['lastPayment']}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isPending ? Colors.orange : Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isPending ? 'ממתין' : 'שולם',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoItem('הכנסות כוללות', '₪${doctor['totalEarnings']}'),
                const SizedBox(width: 24),
                _buildInfoItem('עמלה למערכת (20%)', '₪${doctor['adminCommission']}'),
                const SizedBox(width: 24),
                _buildInfoItem('יתרה לתשלום', '₪${doctor['pendingPayment']}'),
              ],
            ),
            if (isPending) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _markAsPaid(doctor),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('סמן כשולם'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => _sendReminder(doctor),
                    icon: const Icon(Icons.mail, size: 18),
                    label: const Text('שלח תזכורת'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _markAsPaid(Map<String, dynamic> doctor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('סמן כשולם'),
        content: Text('האם לסמן את התשלום מ${doctor['doctorName']} כשולם?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                doctor['status'] = 'paid';
                doctor['pendingPayment'] = 0;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('התשלום סומן כשולם!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('אישור'),
          ),
        ],
      ),
    );
  }

  void _sendReminder(Map<String, dynamic> doctor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('נשלחה תזכורת ל${doctor['doctorName']}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _sendPaymentReminders() {
    final pendingDoctors = _doctorPayments.where((d) => d['status'] == 'pending').length;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('נשלחו תזכורות ל$pendingDoctors רופאים'),
        backgroundColor: Colors.purple,
      ),
    );
  }

  void _refreshData() {
    setState(() {
      // Refresh from backend
    });
  }

  void _exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('מייצא דוח תשלומים...'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

