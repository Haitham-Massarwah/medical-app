import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../services/print_service.dart';

class AdminHealthPage extends StatefulWidget {
  const AdminHealthPage({super.key});

  @override
  State<AdminHealthPage> createState() => _AdminHealthPageState();
}

class _AdminHealthPageState extends State<AdminHealthPage> {
  final AdminService _adminService = AdminService();
  bool _loading = true;
  Map<String, dynamic> _summary = {};
  List<Map<String, dynamic>> _integrationEvents = [];
  List<Map<String, dynamic>> _auditEntries = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _adminService.getAdminHealth();
      final summary = Map<String, dynamic>.from((data['summary'] ?? {}) as Map);
      final events = ((data['integration_events'] ?? []) as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      final audit = ((data['audit_entries'] ?? []) as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      setState(() {
        _summary = summary;
        _integrationEvents = events;
        _auditEntries = audit;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _printReport() async {
    final lines = <String>[
      'Connected integrations: ${_summary['connected_integrations'] ?? 0}',
      'Integration errors (24h): ${_summary['integration_errors_24h'] ?? 0}',
      'Recent integration events: ${_summary['recent_integration_events'] ?? 0}',
      'Recent audit entries: ${_summary['recent_audit_entries'] ?? 0}',
      '',
      'Integration events:',
      if (_integrationEvents.isEmpty)
        '  (none)'
      else
        ..._integrationEvents.take(25).map(
              (e) =>
                  '  ${e['provider']} | ${e['event_type']} [${e['severity']}] ${e['message']} (${e['status'] ?? ''})',
            ),
      '',
      'Audit entries:',
      if (_auditEntries.isEmpty)
        '  (none)'
      else
        ..._auditEntries.take(25).map(
              (a) =>
                  '  ${a['action'] ?? '-'} | ${a['entity_type'] ?? '-'} entity=${a['entity_id'] ?? '-'} user=${a['user_id'] ?? '-'}',
            ),
    ];
    await PrintService.printDocument(title: 'Admin Health Report', lines: lines);
  }

  Widget _statCard(String title, Object value, Color color) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(
          value.toString(),
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Health'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: _printReport, icon: const Icon(Icons.print_outlined), tooltip: 'Print'),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                _statCard('Connected integrations', _summary['connected_integrations'] ?? 0, Colors.green),
                _statCard('Integration errors (24h)', _summary['integration_errors_24h'] ?? 0, Colors.red),
                _statCard('Recent integration events', _summary['recent_integration_events'] ?? 0, Colors.blue),
                _statCard('Recent audit entries', _summary['recent_audit_entries'] ?? 0, Colors.orange),
                const SizedBox(height: 16),
                const Text('Integration Events', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if (_integrationEvents.isEmpty)
                  const Card(child: ListTile(title: Text('No integration events')))
                else
                  ..._integrationEvents.map((e) => Card(
                        child: ListTile(
                          title: Text('${e['provider']} | ${e['event_type']}'),
                          subtitle: Text('[${e['severity']}] ${e['message']}'),
                          trailing: Text('${e['status'] ?? ''}'),
                        ),
                      )),
                const SizedBox(height: 16),
                const Text('Audit Entries', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if (_auditEntries.isEmpty)
                  const Card(child: ListTile(title: Text('No audit entries')))
                else
                  ..._auditEntries.map((a) => Card(
                        child: ListTile(
                          title: Text('${a['action'] ?? '-'} | ${a['entity_type'] ?? '-'}'),
                          subtitle: Text('entity: ${a['entity_id'] ?? '-'} | user: ${a['user_id'] ?? '-'}'),
                        ),
                      )),
              ],
            ),
    );
  }
}

