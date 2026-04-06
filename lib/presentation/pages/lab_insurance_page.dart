import 'package:flutter/material.dart';
import '../../services/lab_service.dart';
import '../../services/insurance_service.dart';
import '../../services/patient_service.dart';

/// Lab/EHR and Insurance integration page (for doctors).
/// Select a patient to view lab results and insurance info.
class LabInsurancePage extends StatefulWidget {
  const LabInsurancePage({super.key});

  @override
  State<LabInsurancePage> createState() => _LabInsurancePageState();
}

class _LabInsurancePageState extends State<LabInsurancePage> {
  final LabService _labService = LabService();
  final InsuranceService _insuranceService = InsuranceService();
  final PatientService _patientService = PatientService();

  List<Map<String, dynamic>> _patients = [];
  String? _selectedPatientId;
  Map<String, dynamic>? _labData;
  Map<String, dynamic>? _insuranceData;
  bool _loadingPatients = true;
  bool _loadingData = false;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    setState(() => _loadingPatients = true);
    try {
      final list = await _patientService.getPatients();
      setState(() {
        _patients = list;
        _loadingPatients = false;
        if (_patients.isNotEmpty && _selectedPatientId == null) {
          _selectedPatientId = _patients.first['id']?.toString();
          _loadLabAndInsurance();
        }
      });
    } catch (e) {
      setState(() => _loadingPatients = false);
    }
  }

  Future<void> _loadLabAndInsurance() async {
    final pid = _selectedPatientId;
    if (pid == null) return;
    setState(() => _loadingData = true);
    try {
      final lab = await _labService.getPatientResults(pid);
      final insurance = await _insuranceService.getPatientInsurance(pid);
      setState(() {
        _labData = lab;
        _insuranceData = insurance;
        _loadingData = false;
      });
    } catch (e) {
      setState(() => _loadingData = false);
    }
  }

  String _patientName(Map<String, dynamic> p) {
    final first = p['first_name'] ?? p['name'] ?? '';
    final last = p['last_name'] ?? '';
    if (first.toString().isNotEmpty || last.toString().isNotEmpty) {
      return '${p['first_name'] ?? p['name'] ?? ''} ${p['last_name'] ?? ''}'.trim();
    }
    return p['email']?.toString() ?? 'Patient';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('מעבדה וביטוח'),
      ),
      body: _loadingPatients
          ? const Center(child: CircularProgressIndicator())
          : _patients.isEmpty
              ? const Center(child: Text('אין מטופלים. הוסף מטופלים מדף המטופלים.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('בחר מטופל', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedPatientId,
                        items: _patients.map((p) {
                          final id = p['id']?.toString() ?? '';
                          return DropdownMenuItem(value: id, child: Text(_patientName(p)));
                        }).toList(),
                        onChanged: (id) {
                          setState(() {
                            _selectedPatientId = id;
                            _loadLabAndInsurance();
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      if (_loadingData)
                        const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
                      else ...[
                        _section('תוצאות מעבדה', _labData?.containsKey('results') == true
                            ? ((_labData!['results'] as List).isEmpty
                                ? const Text('אין תוצאות מעבדה במערכת.')
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: (_labData!['results'] as List).length,
                                    itemBuilder: (_, i) {
                                      final r = (_labData!['results'] as List)[i] as Map<String, dynamic>;
                                      return Card(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        child: ListTile(
                                          title: Text(r['test_name']?.toString() ?? 'בדיקה'),
                                          subtitle: Text(
                                            '${r['result_value'] ?? ''} ${r['unit'] ?? ''}'
                                            '${r['reference_range'] != null ? ' (${r['reference_range']})' : ''}',
                                          ),
                                        ),
                                      );
                                    },
                                  ))
                            : const Text('המערכת מוכנה. חבר מערכת מעבדה לתוצאות חיים.')),
                        const SizedBox(height: 16),
                        _section('ביטוח', _insuranceData?.containsKey('policies') == true
                            ? ((_insuranceData!['policies'] as List).isEmpty
                                ? const Text('אין פוליסות ביטוח במערכת.')
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: (_insuranceData!['policies'] as List).length,
                                    itemBuilder: (_, i) {
                                      final p = (_insuranceData!['policies'] as List)[i] as Map<String, dynamic>;
                                      return Card(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        child: ListTile(
                                          title: Text(p['provider']?.toString() ?? 'ספק'),
                                          subtitle: Text('חבר: ${p['member_id'] ?? '-'}'),
                                        ),
                                      );
                                    },
                                  ))
                            : const Text('המערכת מוכנה. הוסף פוליסות או בדוק זכאות.')),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _section(String title, Widget child) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
