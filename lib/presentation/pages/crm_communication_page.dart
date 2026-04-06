import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/print_service.dart';

/// CRM & communication — tabbed layout for faster navigation.
class CrmCommunicationPage extends StatefulWidget {
  const CrmCommunicationPage({super.key});

  @override
  State<CrmCommunicationPage> createState() => _CrmCommunicationPageState();
}

class _CrmCommunicationPageState extends State<CrmCommunicationPage>
    with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  final AuthService _auth = AuthService();
  late TabController _tabController;
  final TextEditingController _search = TextEditingController();

  bool _loading = true;
  String _role = 'patient';
  List<Map<String, dynamic>> _leads = [];
  List<Map<String, dynamic>> _followups = [];
  List<Map<String, dynamic>> _templates = [];

  bool get _isStaff =>
      const ['admin', 'developer', 'doctor', 'receptionist', 'paramedical'].contains(_role);
  bool get _canManageTemplates => const ['admin', 'developer'].contains(_role);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final me = await _auth.getCurrentUser();
      final role = me['data']?['user']?['role']?.toString() ?? 'patient';
      _role = role;
      if (!_isStaff) {
        setState(() {
          _leads = [];
          _followups = [];
          _templates = [];
        });
        return;
      }

      final leadsRes = await _api.get('/crm/leads');
      final followRes = await _api.get('/crm/followups');
      final templRes = await _api.get('/crm/templates');

      setState(() {
        _leads = ((leadsRes['data']?['leads'] ?? []) as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        _followups = ((followRes['data']?['followups'] ?? []) as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        _templates = ((templRes['data']?['templates'] ?? []) as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String get _q => _search.text.trim().toLowerCase();

  List<Map<String, dynamic>> get _filteredLeads {
    if (_q.isEmpty) return _leads;
    return _leads.where((l) {
      final n = '${l['full_name']} ${l['phone']} ${l['email']} ${l['status']}'.toLowerCase();
      return n.contains(_q);
    }).toList();
  }

  List<Map<String, dynamic>> get _filteredFollowups {
    if (_q.isEmpty) return _followups;
    return _followups.where((f) {
      final n = '${f['lead_name']} ${f['message']} ${f['channel']} ${f['status']}'.toLowerCase();
      return n.contains(_q);
    }).toList();
  }

  List<Map<String, dynamic>> get _filteredTemplates {
    if (_q.isEmpty) return _templates;
    return _templates.where((t) {
      final n = '${t['name']} ${t['body']} ${t['channel']}'.toLowerCase();
      return n.contains(_q);
    }).toList();
  }

  Future<void> _printSummary() async {
    final lines = <String>[
      'Leads: ${_leads.length}',
      'Follow-ups: ${_followups.length}',
      'Templates: ${_templates.length}',
      '',
      ..._leads.take(8).map((l) => '- ${l['full_name'] ?? '-'} | ${l['status'] ?? ''}'),
    ];
    await PrintService.printDocument(title: 'CRM summary', lines: lines);
  }

  Future<void> _createLead() async {
    final name = TextEditingController();
    final phone = TextEditingController();
    final email = TextEditingController();
    final notes = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ליד חדש'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: 'שם מלא *')),
              TextField(controller: phone, decoration: const InputDecoration(labelText: 'טלפון')),
              TextField(controller: email, decoration: const InputDecoration(labelText: 'אימייל')),
              TextField(controller: notes, decoration: const InputDecoration(labelText: 'הערות')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ביטול')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('שמירה')),
        ],
      ),
    );
    if (ok != true || name.text.trim().isEmpty) return;

    final res = await _api.post('/crm/leads', {
      'full_name': name.text.trim(),
      'phone': phone.text.trim(),
      'email': email.text.trim().isEmpty ? null : email.text.trim(),
      'notes': notes.text.trim(),
      'source': 'manual',
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res['success'] == true ? 'ליד נוצר' : 'שגיאה ביצירת ליד'),
        backgroundColor: res['success'] == true ? Colors.green : Colors.red,
      ),
    );
    if (res['success'] == true) {
      _tabController.index = 0;
      _load();
    }
  }

  Future<void> _createFollowup(Map<String, dynamic> lead) async {
    final message = TextEditingController();
    String channel = 'sms';
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('משימת מעקב'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ליד: ${lead['full_name'] ?? '-'}', style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: channel,
                decoration: const InputDecoration(labelText: 'ערוץ', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'sms', child: Text('SMS')),
                  DropdownMenuItem(value: 'email', child: Text('Email')),
                  DropdownMenuItem(value: 'whatsapp', child: Text('WhatsApp')),
                  DropdownMenuItem(value: 'call', child: Text('שיחה')),
                ],
                onChanged: (v) => setDialogState(() => channel = v ?? 'sms'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: message,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'הודעה / משימה *',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ביטול')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('יצירה')),
          ],
        ),
      ),
    );
    if (ok != true || message.text.trim().isEmpty) return;

    final res = await _api.post('/crm/followups', {
      'lead_id': lead['id'],
      'channel': channel,
      'message': message.text.trim(),
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res['success'] == true ? 'מעקב נוצר' : 'שגיאה'),
        backgroundColor: res['success'] == true ? Colors.green : Colors.red,
      ),
    );
    if (res['success'] == true) {
      _tabController.index = 1;
      _load();
    }
  }

  Future<void> _completeFollowup(String id) async {
    final res = await _api.put('/crm/followups/$id/complete', {});
    if (!mounted) return;
    if (res['success'] == true) _load();
  }

  Future<void> _createTemplate() async {
    final name = TextEditingController();
    final subject = TextEditingController();
    final body = TextEditingController();
    String channel = 'sms';
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('תבנית תקשורת'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: name, decoration: const InputDecoration(labelText: 'שם תבנית *')),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: channel,
                  decoration: const InputDecoration(labelText: 'ערוץ', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'sms', child: Text('SMS')),
                    DropdownMenuItem(value: 'email', child: Text('Email')),
                    DropdownMenuItem(value: 'whatsapp', child: Text('WhatsApp')),
                  ],
                  onChanged: (v) => setDialogState(() => channel = v ?? 'sms'),
                ),
                const SizedBox(height: 8),
                TextField(controller: subject, decoration: const InputDecoration(labelText: 'נושא (אימייל)')),
                TextField(
                  controller: body,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'תוכן *', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ביטול')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('שמירה')),
          ],
        ),
      ),
    );
    if (ok != true || name.text.trim().isEmpty || body.text.trim().isEmpty) return;
    final res = await _api.post('/crm/templates', {
      'name': name.text.trim(),
      'channel': channel,
      'subject': subject.text.trim().isEmpty ? null : subject.text.trim(),
      'body': body.text.trim(),
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res['success'] == true ? 'תבנית נשמרה' : 'שגיאה'),
        backgroundColor: res['success'] == true ? Colors.green : Colors.red,
      ),
    );
    if (res['success'] == true) {
      _tabController.index = 2;
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRM ותקשורת'),
        bottom: _isStaff
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'לידים', icon: Icon(Icons.person_search, size: 20)),
                  Tab(text: 'מעקב', icon: Icon(Icons.task_alt, size: 20)),
                  Tab(text: 'תבניות', icon: Icon(Icons.mail_outline, size: 20)),
                ],
              )
            : null,
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh), tooltip: 'רענון'),
          if (_isStaff)
            IconButton(
              onPressed: _printSummary,
              icon: const Icon(Icons.print_outlined),
              tooltip: 'הדפסה',
            ),
        ],
      ),
      floatingActionButton: _isStaff
          ? FloatingActionButton.extended(
              onPressed: () {
                if (_tabController.index == 0) {
                  _createLead();
                } else if (_tabController.index == 1) {
                  if (_leads.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('אין לידים — צור ליד בלשונית ראשונה')),
                    );
                    _tabController.index = 0;
                  } else {
                    _pickLeadForFollowup();
                  }
                } else if (_canManageTemplates) {
                  _createTemplate();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('יצירת תבנית: מנהל/מפתח בלבד')),
                  );
                }
              },
              icon: Icon(_tabController.index == 2 ? Icons.add_comment : Icons.add),
              label: Text(_tabController.index == 0
                  ? 'ליד חדש'
                  : _tabController.index == 1
                      ? 'מעקב'
                      : 'תבנית'),
            )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : !_isStaff
              ? const Center(child: Text('גישה זמינה לצוות בלבד'))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: TextField(
                        controller: _search,
                        decoration: InputDecoration(
                          hintText: 'חיפוש בלשונית הפעילה…',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          isDense: true,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildLeadsTab(),
                          _buildFollowupsTab(),
                          _buildTemplatesTab(),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Future<void> _pickLeadForFollowup() async {
    final picked = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => ListView(
        children: _leads
            .map(
              (l) => ListTile(
                title: Text(l['full_name']?.toString() ?? '-'),
                subtitle: Text(l['phone']?.toString() ?? ''),
                onTap: () => Navigator.pop(ctx, l),
              ),
            )
            .toList(),
      ),
    );
    if (picked != null) _createFollowup(picked);
  }

  Widget _buildLeadsTab() {
    final list = _filteredLeads;
    if (list.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'אין לידים להצגה',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'לחץ על ״ליד חדש״ למטה או השתמש בדוגמאות מהרצת seed בשרת.',
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final lead = list[i];
        final status = lead['status']?.toString() ?? 'new';
        return Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        lead['full_name']?.toString() ?? '-',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    Chip(
                      label: Text(status, style: const TextStyle(fontSize: 12)),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('${lead['phone'] ?? ''}  ${lead['email'] ?? ''}'.trim()),
                if ((lead['notes'] ?? '').toString().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(lead['notes'].toString(), style: TextStyle(color: Colors.grey.shade700)),
                ],
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton.icon(
                    onPressed: () => _createFollowup(lead),
                    icon: const Icon(Icons.add_task, size: 18),
                    label: const Text('מעקב'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFollowupsTab() {
    final list = _filteredFollowups;
    if (list.isEmpty) {
      return Center(
        child: Text('אין משימות מעקב', style: TextStyle(color: Colors.grey.shade600)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final f = list[i];
        final done = f['status'] == 'completed';
        return Card(
          child: ListTile(
            title: Text(f['lead_name']?.toString() ?? 'Lead'),
            subtitle: Text('[${f['channel'] ?? 'sms'}]\n${f['message'] ?? ''}'),
            isThreeLine: true,
            trailing: done
                ? const Icon(Icons.check_circle, color: Colors.green)
                : IconButton(
                    icon: const Icon(Icons.check_circle_outline),
                    onPressed: () => _completeFollowup(f['id'].toString()),
                    tooltip: 'סמן כבוצע',
                  ),
          ),
        );
      },
    );
  }

  Widget _buildTemplatesTab() {
    final list = _filteredTemplates;
    if (list.isEmpty) {
      return Center(
        child: Text('אין תבניות', style: TextStyle(color: Colors.grey.shade600)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final t = list[i];
        return Card(
          child: ListTile(
            title: Text(t['name']?.toString() ?? '-'),
            subtitle: Text('[${t['channel'] ?? 'sms'}] ${t['subject'] ?? ''}\n${t['body'] ?? ''}'),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}
