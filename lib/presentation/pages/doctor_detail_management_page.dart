import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class DoctorDetailManagementPage extends StatefulWidget {
  final Map<String, dynamic> doctor;

  const DoctorDetailManagementPage({
    super.key,
    required this.doctor,
  });

  @override
  State<DoctorDetailManagementPage> createState() => _DoctorDetailManagementPageState();
}

class _DoctorDetailManagementPageState extends State<DoctorDetailManagementPage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _isLoadingSMSSettings = false;

  // SMS Settings State
  bool _smsEnabled = false;
  bool _hasDiscount = false;
  double _discountPercentage = 0.0;
  double _smsPrice = 0.0;
  double _priceBeforeDiscount = 0.0;
  String _currency = 'ILS';
  Map<String, dynamic>? _smsSettings;
  Map<String, dynamic>? _usageStats;

  // Doctor Info State
  Map<String, dynamic>? _fullDoctorInfo;

  @override
  void initState() {
    super.initState();
    _loadDoctorDetails();
    _loadSMSSettings();
  }

  Future<void> _loadDoctorDetails() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('/doctors/${widget.doctor['id']}');
      if (response['success'] == true) {
        setState(() {
          _fullDoctorInfo = response['data']?['doctor'] ?? widget.doctor;
          _isLoading = false;
        });
      } else {
        setState(() {
          _fullDoctorInfo = widget.doctor;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _fullDoctorInfo = widget.doctor;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSMSSettings() async {
    setState(() => _isLoadingSMSSettings = true);
    try {
      final response = await _apiService.get('/doctors/${widget.doctor['id']}/sms/settings');
      if (response['success'] == true) {
        final data = response['data'];
        final settings = data['settings'] ?? {};
        final pricing = data['pricing'] ?? {};
        
        setState(() {
          _smsSettings = settings;
          _smsEnabled = settings['sms_enabled'] ?? false;
          _hasDiscount = settings['has_discount'] ?? false;
          _discountPercentage = (settings['discount_percentage'] ?? 0).toDouble();
          _smsPrice = (pricing['priceILS'] ?? settings['sms_cost_per_message'] ?? 0).toDouble();
          _priceBeforeDiscount = pricing['priceBeforeDiscount']?.toDouble() ?? _smsPrice;
          _currency = pricing['currency'] ?? settings['currency'] ?? 'ILS';
          _usageStats = data['usage'];
          _isLoadingSMSSettings = false;
        });
      } else {
        setState(() => _isLoadingSMSSettings = false);
      }
    } catch (e) {
      setState(() => _isLoadingSMSSettings = false);
    }
  }

  Future<void> _updateSMSSettings() async {
    setState(() => _isLoadingSMSSettings = true);
    try {
      final response = await _apiService.put(
        '/doctors/${widget.doctor['id']}/sms/settings',
        {
          'sms_enabled': _smsEnabled,
          'has_discount': _hasDiscount,
          'discount_percentage': _hasDiscount ? _discountPercentage : 0,
        },
      );

      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('הגדרות SMS עודכנו בהצלחה'),
              backgroundColor: Colors.green,
            ),
          );
          _loadSMSSettings();
        }
      } else {
        throw Exception(response['message'] ?? 'Failed to update SMS settings');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה בעדכון הגדרות SMS: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoadingSMSSettings = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('פרטי רופא: ${widget.doctor['name'] ?? 'ללא שם'}'),
          backgroundColor: Colors.green.shade700,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Doctor Basic Information
                    _buildSection(
                      'פרטים אישיים',
                      Icons.person,
                      _buildPersonalInfo(),
                    ),
                    const SizedBox(height: 16),

                    // Professional Information
                    _buildSection(
                      'פרטים מקצועיים',
                      Icons.medical_services,
                      _buildProfessionalInfo(),
                    ),
                    const SizedBox(height: 16),

                    // Contact Information
                    _buildSection(
                      'פרטי התקשרות',
                      Icons.contact_mail,
                      _buildContactInfo(),
                    ),
                    const SizedBox(height: 16),

                    // SMS Service Settings
                    _buildSection(
                      'הגדרות שירות SMS',
                      Icons.sms,
                      _buildSMSSettings(),
                    ),
                    const SizedBox(height: 16),

                    // Usage Statistics
                    if (_usageStats != null)
                      _buildSection(
                        'סטטיסטיקות שימוש',
                        Icons.analytics,
                        _buildUsageStats(),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Widget content) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.green.shade700),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const Divider(),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfo() {
    final doctor = _fullDoctorInfo ?? widget.doctor;
    return Column(
      children: [
        _buildInfoRow('שם מלא', doctor['name'] ?? 'לא צוין'),
        _buildInfoRow('אימייל', doctor['email'] ?? 'לא צוין'),
        _buildInfoRow('טלפון', doctor['phone'] ?? 'לא צוין'),
        _buildInfoRow('מספר תעודת זהות', doctor['id_number'] ?? 'לא צוין'),
        _buildInfoRow('תאריך רישום', doctor['created_at']?.toString().split('T')[0] ?? 'לא צוין'),
        _buildInfoRow('סטטוס', (doctor['is_active'] == true ? 'פעיל' : 'לא פעיל')),
      ],
    );
  }

  Widget _buildProfessionalInfo() {
    final doctor = _fullDoctorInfo ?? widget.doctor;
    return Column(
      children: [
        _buildInfoRow('התמחות', doctor['specialty'] ?? doctor['specialty_name'] ?? 'לא צוין'),
        _buildInfoRow('מספר רישיון', doctor['license_number'] ?? doctor['licenseNumber'] ?? 'לא צוין'),
        _buildInfoRow('שנות ניסיון', doctor['years_experience']?.toString() ?? 'לא צוין'),
        _buildInfoRow('כתובת', doctor['address'] ?? 'לא צוין'),
        _buildInfoRow('עיר', doctor['city'] ?? 'לא צוין'),
      ],
    );
  }

  Widget _buildContactInfo() {
    final doctor = _fullDoctorInfo ?? widget.doctor;
    return Column(
      children: [
        _buildInfoRow('אימייל', doctor['email'] ?? 'לא צוין'),
        _buildInfoRow('טלפון', doctor['phone'] ?? 'לא צוין'),
        if (doctor['website'] != null)
          _buildInfoRow('אתר אינטרנט', doctor['website']),
      ],
    );
  }

  Widget _buildSMSSettings() {
    return _isLoadingSMSSettings
        ? const Center(child: CircularProgressIndicator())
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enable SMS Service
              SwitchListTile(
                title: const Text('הפעל שירות SMS'),
                subtitle: const Text('אפשר לרופא לשלוח הודעות SMS למטופלים'),
                value: _smsEnabled,
                onChanged: (value) {
                  setState(() => _smsEnabled = value);
                },
              ),
              const Divider(),

              if (_smsEnabled) ...[
                // Discount Section
                const SizedBox(height: 8),
                const Text(
                  'הנחה',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // Enable Discount Checkbox
                CheckboxListTile(
                  title: const Text('החל הנחה'),
                  subtitle: const Text('החל הנחה על מחיר ה-SMS'),
                  value: _hasDiscount,
                  onChanged: (value) {
                    setState(() {
                      _hasDiscount = value ?? false;
                      if (!_hasDiscount) {
                        _discountPercentage = 0.0;
                      }
                    });
                  },
                ),

                // Discount Percentage Dropdown
                if (_hasDiscount) ...[
                  const SizedBox(height: 8),
                  DropdownButtonFormField<double>(
                    decoration: const InputDecoration(
                      labelText: 'אחוז הנחה',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.percent),
                    ),
                    value: _discountPercentage,
                    items: const [
                      DropdownMenuItem(value: 0.0, child: Text('ללא הנחה')),
                      DropdownMenuItem(value: 10.0, child: Text('10% הנחה')),
                      DropdownMenuItem(value: 15.0, child: Text('15% הנחה')),
                      DropdownMenuItem(value: 20.0, child: Text('20% הנחה')),
                      DropdownMenuItem(value: 25.0, child: Text('25% הנחה')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _discountPercentage = value ?? 0.0;
                      });
                    },
                  ),
                ],

                const SizedBox(height: 16),

                // Price Display
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_hasDiscount && _priceBeforeDiscount > 0) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('מחיר לפני הנחה:'),
                            Text(
                              '${_priceBeforeDiscount.toStringAsFixed(4)} $_currency',
                              style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'מחיר נוכחי:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${_smsPrice.toStringAsFixed(4)} $_currency',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      if (_hasDiscount && _discountPercentage > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'הנחה: ${_discountPercentage.toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _updateSMSSettings,
                    icon: const Icon(Icons.save),
                    label: const Text('שמור הגדרות SMS'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ] else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'שירות SMS מושבת. הפעל את השירות כדי להגדיר הנחות.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
            ],
          );
  }

  Widget _buildUsageStats() {
    if (_usageStats == null) return const SizedBox.shrink();

    return Column(
      children: [
        _buildStatRow('סה"כ הודעות שנשלחו', _usageStats!['totalSent']?.toString() ?? '0'),
        _buildStatRow('הודעות מוצלחות', _usageStats!['successful']?.toString() ?? '0'),
        _buildStatRow('עלות כוללת', '${_usageStats!['totalCost']?.toStringAsFixed(2) ?? '0.00'} $_currency'),
        _buildStatRow('הודעות ב-30 יום האחרונים', _usageStats!['sentLast30Days']?.toString() ?? '0'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.green.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}


