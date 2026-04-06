import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/print_service.dart';

class FormsDocumentsPage extends StatefulWidget {
  const FormsDocumentsPage({super.key});

  @override
  State<FormsDocumentsPage> createState() => _FormsDocumentsPageState();
}

class _FormsDocumentsPageState extends State<FormsDocumentsPage> {
  final ApiService _api = ApiService();
  final AuthService _auth = AuthService();

  bool _loading = true;
  String _role = 'patient';
  List<Map<String, dynamic>> _templates = [];
  List<Map<String, dynamic>> _submissions = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final me = await _auth.getCurrentUser();
      final role = me['data']?['user']?['role']?.toString() ?? 'patient';
      _role = role;

      final templatesRes = await _api.get('/forms/templates');
      final templates = ((templatesRes['data']?['templates'] ?? []) as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      final endpoint = _isStaff() ? '/forms/submissions' : '/forms/my-submissions';
      final submissionsRes = await _api.get(endpoint);
      final submissions = ((submissionsRes['data']?['submissions'] ?? []) as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      if (mounted) {
        setState(() {
          _templates = templates;
          _submissions = submissions;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _templates = [];
          _submissions = [];
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _isStaff() =>
      _role == 'admin' ||
      _role == 'developer' ||
      _role == 'doctor' ||
      _role == 'receptionist' ||
      _role == 'paramedical';

  Future<void> _submitQuickForm(Map<String, dynamic> template) async {
    final nameCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    bool signed = false;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('מילוי טופס'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(template['title']?.toString() ?? 'טופס'),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'שם מלא להסכמה',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'הערות / תשובות קצרות',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                value: signed,
                onChanged: (v) => setDialogState(() => signed = v == true),
                title: const Text('אני מאשר/ת חתימה דיגיטלית'),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ביטול')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('שליחה')),
          ],
        ),
      ),
    );

    if (ok != true) return;

    final body = <String, dynamic>{
      'template_id': template['id'],
      'answers_json': {
        'notes': notesCtrl.text.trim(),
      },
      if (nameCtrl.text.trim().isNotEmpty) 'consent_name': nameCtrl.text.trim(),
      if (signed) 'signature_data': 'signed:true',
    };

    final res = await _api.post('/forms/submit', body);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res['success'] == true ? 'הטופס נשלח בהצלחה' : 'שגיאה בשליחת טופס'),
        backgroundColor: res['success'] == true ? Colors.green : Colors.red,
      ),
    );
    if (res['success'] == true) {
      _load();
    }
  }

  Future<void> _createTemplate() async {
    final titleCtrl = TextEditingController();
    String type = 'consent';

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('תבנית חדשה'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'שם תבנית',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: type,
                items: const [
                  DropdownMenuItem(value: 'intake', child: Text('Intake')),
                  DropdownMenuItem(value: 'consent', child: Text('Consent')),
                  DropdownMenuItem(value: 'questionnaire', child: Text('Questionnaire')),
                ],
                onChanged: (v) => setDialogState(() => type = v ?? 'consent'),
                decoration: const InputDecoration(
                  labelText: 'סוג',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ביטול')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('יצירה')),
          ],
        ),
      ),
    );

    if (ok != true || titleCtrl.text.trim().isEmpty) return;

    final res = await _api.post('/forms/templates', {
      'title': titleCtrl.text.trim(),
      'form_type': type,
      'schema_json': {
        'fields': [
          {'key': 'notes', 'type': 'textarea', 'label': 'Notes'}
        ]
      }
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res['success'] == true ? 'תבנית נוצרה' : 'שגיאה ביצירת תבנית'),
        backgroundColor: res['success'] == true ? Colors.green : Colors.red,
      ),
    );
    if (res['success'] == true) _load();
  }

  Future<void> _printPageSummary() async {
    final lines = <String>[
      'Templates: ${_templates.length}',
      'Submissions shown: ${_submissions.length}',
      '',
      ..._templates.map((t) => '- ${t['title']} (${t['form_type']})'),
    ];
    await PrintService.printDocument(title: 'Forms & documents', lines: lines);
  }

  @override
  Widget build(BuildContext context) {
    final canCreateTemplate = _role == 'admin' || _role == 'developer';

    return Scaffold(
      appBar: AppBar(
        title: const Text('טפסים ומסמכים'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
          IconButton(
            onPressed: _printPageSummary,
            icon: const Icon(Icons.print_outlined),
            tooltip: 'הדפסה',
          ),
          if (canCreateTemplate)
            IconButton(onPressed: _createTemplate, icon: const Icon(Icons.add)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'תבניות פעילות',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (_templates.isEmpty)
                  const Card(child: ListTile(title: Text('אין תבניות זמינות')))
                else
                  ..._templates.map((t) => Card(
                        child: ListTile(
                          title: Text(t['title']?.toString() ?? '-'),
                          subtitle: Text('Type: ${t['form_type'] ?? 'intake'}'),
                          trailing: ElevatedButton(
                            onPressed: () => _submitQuickForm(t),
                            child: const Text('מילוי'),
                          ),
                        ),
                      )),
                const SizedBox(height: 20),
                Text(
                  _isStaff() ? 'הגשות טפסים (צוות)' : 'ההגשות שלי',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (_submissions.isEmpty)
                  const Card(child: ListTile(title: Text('אין הגשות')))
                else
                  ..._submissions.map((s) => Card(
                        child: ListTile(
                          title: Text(s['template_title']?.toString() ?? 'Submission'),
                          subtitle: Text(
                            'Status: ${s['status'] ?? 'submitted'}'
                            '${s['consent_name'] != null ? ' | ${s['consent_name']}' : ''}',
                          ),
                        ),
                      )),
              ],
            ),
    );
  }
}

