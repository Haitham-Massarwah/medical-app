import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DoctorAppointmentConfigPage extends StatefulWidget {
  const DoctorAppointmentConfigPage({super.key});

  @override
  State<DoctorAppointmentConfigPage> createState() => _DoctorAppointmentConfigPageState();
}

class _DoctorAppointmentConfigPageState extends State<DoctorAppointmentConfigPage> {
  bool _allowGroupAppointments = false;
  int _maxCustomersPerSlot = 1;
  final Map<String, TreatmentConfig> _treatmentConfigs = {};
  bool _enableOnlinePayment = false; // locked for doctors by default
  bool _developerCanEditPayment = false; // toggled by developer area
  final TextEditingController _newTreatmentNameController = TextEditingController();
  final TextEditingController _newTreatmentDescController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _allowGroupAppointments = prefs.getBool('allow_group_appointments') ?? false;
      _maxCustomersPerSlot = prefs.getInt('max_customers_per_slot') ?? 1;
      _enableOnlinePayment = prefs.getBool('payments_enabled_doctor_current') ?? false;
      _developerCanEditPayment = prefs.getBool('developer_can_edit_payment') ?? false;
    });
    _loadTreatmentConfigs();
  }

  Future<void> _loadTreatmentConfigs() async {
    final prefs = await SharedPreferences.getInstance();
    final treatments = ['ייעוץ', 'טיפול', 'בדיקה', 'מעקב'];
    final Map<String, TreatmentConfig> configs = {};
    
    for (var treatment in treatments) {
      final json = prefs.getString('treatment_config_$treatment');
      if (json != null) {
        configs[treatment] = TreatmentConfig.fromJson(jsonDecode(json));
      } else {
        configs[treatment] = TreatmentConfig();
      }
    }
    
    setState(() {
      _treatmentConfigs.addAll(configs);
    });
  }

  Future<void> _saveConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('allow_group_appointments', _allowGroupAppointments);
    await prefs.setInt('max_customers_per_slot', _maxCustomersPerSlot);
    await prefs.setBool('payments_enabled_doctor_current', _enableOnlinePayment);
    
    for (var entry in _treatmentConfigs.entries) {
      await prefs.setString('treatment_config_${entry.key}', jsonEncode(entry.value.toJson()));
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('הגדרות נשמרו בהצלחה')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('הגדרות תורים'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveConfig,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'הגדרות כלליות',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('אפשר תורים קבוצתיים'),
                    value: _allowGroupAppointments,
                    onChanged: (value) {
                      setState(() {
                        _allowGroupAppointments = value;
                        if (!value) {
                          _maxCustomersPerSlot = 1;
                        }
                      });
                    },
                  ),
                  if (_allowGroupAppointments) ...[
                    const SizedBox(height: 8),
                    Text('מס\' מקסימלי של מטופלים לכל תור: $_maxCustomersPerSlot'),
                    Slider(
                      value: _maxCustomersPerSlot.toDouble(),
                      min: 1,
                      max: 10,
                      divisions: 9,
                      label: '$_maxCustomersPerSlot מטופלים',
                      onChanged: (value) {
                        setState(() {
                          _maxCustomersPerSlot = value.toInt();
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'תשלומים אונליין',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: _enableOnlinePayment,
                        onChanged: _developerCanEditPayment
                            ? (v) {
                                setState(() {
                                  _enableOnlinePayment = v ?? false;
                                });
                              }
                            : null,
                      ),
                      const SizedBox(width: 8),
                      const Text('אפשר תשלום אונליין'),
                      const SizedBox(width: 12),
                      if (!_enableOnlinePayment)
                        const Text('Soon', style: TextStyle(color: Colors.orange)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (!_enableOnlinePayment)
                    const Text(
                      'התשלום זמין רק בקליניקה (In-house).',
                      style: TextStyle(color: Colors.blueGrey),
                    ),
                  if (!_developerCanEditPayment)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'האפשרות נעולה. רק מפתח יכול לאפשר.',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'סוגי טיפולים',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: _showAddTreatmentDialog,
                icon: const Icon(Icons.add),
                label: const Text('הוסף טיפול'),
              ),
            ],
          ),
          ..._treatmentConfigs.entries.map((entry) => _buildTreatmentCard(entry.key, entry.value)),
        ],
      ),
    );
  }

  Widget _buildTreatmentCard(String treatmentName, TreatmentConfig config) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(treatmentName, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextFormField(
                  initialValue: config.description,
                  decoration: const InputDecoration(labelText: 'תיאור (רשות)'),
                  onChanged: (v) { _treatmentConfigs[treatmentName]!.description = v; },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: config.durationMinutes,
                  decoration: const InputDecoration(labelText: 'משך זמן התור'),
                  items: [15, 30, 45, 60, 90, 120]
                      .map((min) => DropdownMenuItem(
                            value: min,
                            child: Text('$min דקות'),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _treatmentConfigs[treatmentName]!.durationMinutes = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  enabled: _enableOnlinePayment,
                  keyboardType: TextInputType.number,
                  initialValue: config.price?.toString() ?? '',
                  decoration: InputDecoration(
                    labelText: _enableOnlinePayment ? 'מחיר (חובה)' : 'מחיר (מוסתר כאשר תשלום כבוי)',
                  ),
                  onChanged: (v) { _treatmentConfigs[treatmentName]!.price = double.tryParse(v); },
                ),
                if (!_enableOnlinePayment)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('התשלום זמין רק בקליניקה.', style: TextStyle(color: Colors.blueGrey)),
                    ),
                  ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('אפשר מספר מטופלים'),
                  value: config.allowMultiplePatients,
                  onChanged: (value) {
                    setState(() {
                      _treatmentConfigs[treatmentName]!.allowMultiplePatients = value;
                      if (!value) {
                        _treatmentConfigs[treatmentName]!.maxPatientsPerSlot = 1;
                      }
                    });
                  },
                ),
                if (config.allowMultiplePatients) ...[
                  const SizedBox(height: 8),
                  Text('מקסימלי מטופלים: ${config.maxPatientsPerSlot}'),
                  Slider(
                    value: config.maxPatientsPerSlot.toDouble(),
                    min: 1,
                    max: _maxCustomersPerSlot.toDouble(),
                    divisions: (_maxCustomersPerSlot - 1).clamp(1, 9),
                    label: '${config.maxPatientsPerSlot} מטופלים',
                    onChanged: (value) {
                      setState(() {
                        _treatmentConfigs[treatmentName]!.maxPatientsPerSlot = value.toInt();
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTreatmentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('הוסף סוג טיפול'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _newTreatmentNameController,
              decoration: const InputDecoration(labelText: 'שם טיפול'),
            ),
            TextField(
              controller: _newTreatmentDescController,
              decoration: const InputDecoration(labelText: 'תיאור (רשות)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('בטל')),
          ElevatedButton(
            onPressed: () async {
              final name = _newTreatmentNameController.text.trim();
              if (name.isEmpty) return;
              setState(() { _treatmentConfigs[name] = TreatmentConfig(description: _newTreatmentDescController.text.trim()); });
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('treatment_config_$name', jsonEncode(_treatmentConfigs[name]!.toJson()));
              _newTreatmentNameController.clear();
              _newTreatmentDescController.clear();
              if (mounted) Navigator.pop(context);
            },
            child: const Text('שמור'),
          ),
        ],
      ),
    );
  }
}

class TreatmentConfig {
  int durationMinutes;
  bool allowMultiplePatients;
  int maxPatientsPerSlot;
  String? description;
  double? price;

  TreatmentConfig({
    this.durationMinutes = 30,
    this.allowMultiplePatients = false,
    this.maxPatientsPerSlot = 1,
    this.description,
    this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      'durationMinutes': durationMinutes,
      'allowMultiplePatients': allowMultiplePatients,
      'maxPatientsPerSlot': maxPatientsPerSlot,
      'description': description,
      'price': price,
    };
  }

  factory TreatmentConfig.fromJson(Map<String, dynamic> json) {
    return TreatmentConfig(
      durationMinutes: json['durationMinutes'] ?? 30,
      allowMultiplePatients: json['allowMultiplePatients'] ?? false,
      maxPatientsPerSlot: json['maxPatientsPerSlot'] ?? 1,
      description: json['description'] as String?,
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : null,
    );
  }
}
