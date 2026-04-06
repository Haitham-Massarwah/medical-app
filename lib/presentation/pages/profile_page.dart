import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/user_service.dart';
import '../../services/medical_record_service.dart';
import '../../core/config/app_config.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserService _userService = UserService();
  final MedicalRecordService _medicalRecordService = MedicalRecordService();
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic> _user = {};

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final user = await _userService.getCurrentUser();
      if (mounted) {
        setState(() {
          _user = user;
          _errorMessage = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'שגיאה בטעינת פרטי משתמש: $e';
          _isLoading = false;
        });
      }
    }
  }
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
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : SingleChildScrollView(
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
    final firstName = _user['first_name']?.toString() ?? '';
    final lastName = _user['last_name']?.toString() ?? '';
    final fullName = [firstName, lastName].where((part) => part.isNotEmpty).join(' ');
    final email = _user['email']?.toString() ?? '';
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
        Text(
          fullName.isEmpty ? 'משתמש' : fullName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        
        // Email
        Text(
          email.isEmpty ? '-' : email,
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
    final metadata = Map<String, dynamic>.from(_user['metadata'] ?? {});
    final firstName = _user['first_name']?.toString() ?? '';
    final lastName = _user['last_name']?.toString() ?? '';
    final email = _user['email']?.toString() ?? '';
    final phone = _user['phone']?.toString() ?? '';
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
                _buildDetailField('שם פרטי', firstName.isEmpty ? '-' : firstName),
                _buildDetailField('שם משפחה', lastName.isEmpty ? '-' : lastName),
                _buildDetailField('אימייל', email.isEmpty ? '-' : email),
                _buildDetailField('טלפון', phone.isEmpty ? '-' : phone),
                _buildDetailField('תאריך לידה', metadata['date_of_birth']?.toString() ?? '-'),
                _buildDetailField('מין', metadata['gender']?.toString() ?? '-'),
                _buildDetailField('עיר', metadata['city']?.toString() ?? '-'),
                _buildDetailField('כתובת', metadata['address']?.toString() ?? '-'),
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
    final metadata = Map<String, dynamic>.from(_user['metadata'] ?? {});
    final nameController = TextEditingController(text: _user['first_name']?.toString() ?? '');
    final lastNameController = TextEditingController(text: _user['last_name']?.toString() ?? '');
    final emailController = TextEditingController(text: _user['email']?.toString() ?? '');
    final phoneController = TextEditingController(text: _user['phone']?.toString() ?? '');
    final cityController = TextEditingController(text: metadata['city']?.toString() ?? '');
    final addressController = TextEditingController(text: metadata['address']?.toString() ?? '');
    final dobController = TextEditingController(text: metadata['date_of_birth']?.toString() ?? '');
    final genderController = TextEditingController(text: metadata['gender']?.toString() ?? '');

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
                  enabled: false,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'טלפון',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dobController,
                  decoration: const InputDecoration(
                    labelText: 'תאריך לידה (YYYY-MM-DD)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: genderController,
                  decoration: const InputDecoration(
                    labelText: 'מין (male/female/other)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(
                    labelText: 'עיר',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'כתובת',
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
              onPressed: () async {
                final userId = _user['id']?.toString();
                if (userId == null || userId.isEmpty) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('משתמש לא נמצא לעדכון'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                try {
                  final updateData = <String, dynamic>{
                    'first_name': nameController.text.trim(),
                    'last_name': lastNameController.text.trim(),
                    'phone': phoneController.text.trim(),
                  };
                  if (dobController.text.trim().isNotEmpty) {
                    updateData['date_of_birth'] = dobController.text.trim();
                  }
                  if (genderController.text.trim().isNotEmpty) {
                    updateData['gender'] = genderController.text.trim();
                  }
                  if (cityController.text.trim().isNotEmpty) {
                    updateData['city'] = cityController.text.trim();
                  }
                  if (addressController.text.trim().isNotEmpty) {
                    updateData['address'] = addressController.text.trim();
                  }

                  final updatedUser = await _userService.updateUser(
                    userId: userId,
                    data: updateData,
                  );
                  if (!mounted) return;
                  setState(() {
                    _user = updatedUser;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('הפרטים נשמרו בהצלחה'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('שגיאה בעדכון הפרטים: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
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
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _medicalRecordService.getMyRecords(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('שגיאה בטעינת הרשומות'));
                }
                final records = snapshot.data ?? [];
                if (records.isEmpty) {
                  return const Center(child: Text('אין נתונים זמינים'));
                }
                return ListView(
                  children: records.map(_buildHistoryRecord).toList(),
                );
              },
            ),
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

  Widget _buildHistoryRecord(Map<String, dynamic> record) {
    final authorFirst = record['author_first_name']?.toString() ?? '';
    final authorLast = record['author_last_name']?.toString() ?? '';
    final authorName =
        [authorFirst, authorLast].where((part) => part.isNotEmpty).join(' ');
    final dateValue = record['record_date']?.toString() ?? '';
    final description = record['description']?.toString() ?? '';
    final attachments = record['attachments'] is List
        ? List<String>.from(record['attachments'])
        : <String>[];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(authorName.isEmpty ? 'מטפל' : authorName,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            if (dateValue.isNotEmpty)
              Text(dateValue, style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            if (description.isNotEmpty) MarkdownBody(data: description),
            if (attachments.isNotEmpty) ...[
              const Divider(),
              ...attachments.map((item) => ListTile(
                    leading: const Icon(Icons.attach_file),
                    title: Text(item.split('/').last),
                    onTap: () => _openAttachment(item),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openAttachment(String url) async {
    final baseUrl = AppConfig.baseUrl.replaceFirst('/api/v1', '');
    final uri = Uri.parse(url.startsWith('http') ? url : '$baseUrl$url');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('לא ניתן לפתוח את הקובץ'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
            child: const Center(
              child: Text('אין נתונים זמינים'),
            ),
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