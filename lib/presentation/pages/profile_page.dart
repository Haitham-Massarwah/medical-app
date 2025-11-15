import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('פרופיל'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // User Avatar and Info
              _buildUserInfo(),
              const SizedBox(height: 32),
              
              // Menu Options
              _buildMenuOptions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      children: [
        // Avatar
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.blue.shade100,
          child: Icon(
            Icons.person,
            size: 80,
            color: Colors.blue.shade300,
          ),
        ),
        const SizedBox(height: 16),
        
        // Name
        const Text(
          'משתמש לדוגמה',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        
        // Email
        Text(
          'user@example.com',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuOptions() {
    return Column(
      children: [
        _buildMenuItem(
          icon: Icons.person,
          title: 'פרטים אישיים',
          onTap: () => _showPersonalDetails(),
        ),
        _buildMenuItem(
          icon: Icons.medical_services,
          title: 'היסטוריה רפואית',
          onTap: () => _showMedicalHistory(),
        ),
        _buildMenuItem(
          icon: Icons.receipt,
          title: 'קבלות ותשלומים',
          onTap: () => _showReceiptsAndPayments(),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.grey.shade700,
          size: 24,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey.shade400,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showPersonalDetails() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('פרטים אישיים'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailField('שם פרטי', 'משתמש'),
                _buildDetailField('שם משפחה', 'לדוגמה'),
                _buildDetailField('אימייל', 'user@example.com'),
                _buildDetailField('טלפון', '050-1234567'),
                _buildDetailField('תאריך לידה', '01/01/1990'),
                _buildDetailField('מין', 'זכר'),
                _buildDetailField('עיר', 'תל אביב'),
                _buildDetailField('כתובת', 'רחוב הרצל 123'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('סגור'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showEditPersonalDetails();
              },
              child: const Text('ערוך'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
      ),
    );
  }

  void _showEditPersonalDetails() {
    final nameController = TextEditingController(text: 'משתמש');
    final lastNameController = TextEditingController(text: 'לדוגמה');
    final emailController = TextEditingController(text: 'user@example.com');
    final phoneController = TextEditingController(text: '050-1234567');

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('ערוך פרטים אישיים'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'שם פרטי',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'שם משפחה',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'אימייל',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'טלפון',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ביטול'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('הפרטים נשמרו בהצלחה'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('שמור'),
            ),
          ],
        ),
      ),
    );
  }

  void _showMedicalHistory() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('היסטוריה רפואית'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: ListView(
              children: [
                _buildMedicalRecord('2024-01-15', 'בדיקה כללית', 'ד"ר כהן', 'כל תקין'),
                _buildMedicalRecord('2023-12-10', 'בדיקת דם', 'ד"ר לוי', 'רמת סוכר תקינה'),
                _buildMedicalRecord('2023-11-05', 'צילום חזה', 'ד"ר ישראלי', 'ריאות תקינות'),
                _buildMedicalRecord('2023-10-20', 'בדיקת עיניים', 'ד"ר גולד', 'ראייה תקינה'),
                _buildMedicalRecord('2023-09-15', 'בדיקת שיניים', 'ד"ר כהן', 'צריך ניקוי'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('סגור'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showAddMedicalRecord();
              },
              child: const Text('הוסף רשומה'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalRecord(String date, String type, String doctor, String notes) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: const Icon(Icons.medical_services, color: Colors.blue),
        ),
        title: Text(type),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('רופא: $doctor'),
            Text('תאריך: $date'),
            Text('הערות: $notes'),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  void _showAddMedicalRecord() {
    final typeController = TextEditingController();
    final doctorController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('הוסף רשומה רפואית'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: typeController,
                  decoration: const InputDecoration(
                    labelText: 'סוג הבדיקה',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: doctorController,
                  decoration: const InputDecoration(
                    labelText: 'שם הרופא',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'הערות',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ביטול'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('הרשומה נוספה בהצלחה'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('הוסף'),
            ),
          ],
        ),
      ),
    );
  }

  void _showReceiptsAndPayments() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('קבלות ותשלומים'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: ListView(
              children: [
                _buildPaymentRecord('2024-01-15', 'בדיקה כללית', '₪200', 'מזומן', 'שולם'),
                _buildPaymentRecord('2023-12-10', 'בדיקת דם', '₪150', 'כרטיס', 'שולם'),
                _buildPaymentRecord('2023-11-05', 'צילום חזה', '₪300', 'העברה', 'שולם'),
                _buildPaymentRecord('2023-10-20', 'בדיקת עיניים', '₪180', 'מזומן', 'שולם'),
                _buildPaymentRecord('2023-09-15', 'בדיקת שיניים', '₪250', 'כרטיס', 'שולם'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('סגור'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showPaymentSummary();
              },
              child: const Text('סיכום תשלומים'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentRecord(String date, String service, String amount, String method, String status) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: status == 'שולם' ? Colors.green.shade100 : Colors.orange.shade100,
          child: Icon(
            status == 'שולם' ? Icons.check : Icons.pending,
            color: status == 'שולם' ? Colors.green : Colors.orange,
          ),
        ),
        title: Text(service),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('תאריך: $date'),
            Text('שיטת תשלום: $method'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amount,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Text(
              status,
              style: TextStyle(
                fontSize: 12,
                color: status == 'שולם' ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentSummary() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('סיכום תשלומים'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSummaryRow('סה"כ תשלומים', '₪1,080'),
              _buildSummaryRow('תשלומים במזומן', '₪380'),
              _buildSummaryRow('תשלומים בכרטיס', '₪400'),
              _buildSummaryRow('תשלומים בהעברה', '₪300'),
              const Divider(),
              _buildSummaryRow('ממוצע לתשלום', '₪216'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('סגור'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}