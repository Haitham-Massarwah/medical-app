import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/print_service.dart';

class IntegrationsOperationsPage extends StatefulWidget {
  const IntegrationsOperationsPage({super.key});

  @override
  State<IntegrationsOperationsPage> createState() => _IntegrationsOperationsPageState();
}

class _IntegrationsOperationsPageState extends State<IntegrationsOperationsPage> {
  final ApiService _api = ApiService();
  final AuthService _auth = AuthService();
  bool _loading = true;
  String _role = 'patient';
  List<Map<String, dynamic>> _connections = [];
  List<Map<String, dynamic>> _events = [];

  bool get _canView => const ['admin', 'developer', 'receptionist', 'doctor', 'paramedical'].contains(_role);
  bool get _canManage => const ['admin', 'developer'].contains(_role);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final me = await _auth.getCurrentUser();
      _role = me['data']?['user']?['role']?.toString() ?? 'patient';
      if (!_canView) {
        setState(() {
          _connections = [];
          _events = [];
        });
        return;
      }
      final c = await _api.get('/integrations/connections');
      final e = await _api.get('/integrations/events');
      setState(() {
        _connections = ((c['data']?['connections'] ?? []) as List).map((x) => Map<String, dynamic>.from(x as Map)).toList();
        _events = ((e['data']?['events'] ?? []) as List).map((x) => Map<String, dynamic>.from(x as Map)).toList();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _upsertConnection() async {
    final provider = TextEditingController(text: 'lab');
    String status = 'connected';
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('עדכון חיבור אינטגרציה'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: provider, decoration: const InputDecoration(labelText: 'provider')),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: status,
                items: const [
                  DropdownMenuItem(value: 'connected', child: Text('connected')),
                  DropdownMenuItem(value: 'disconnected', child: Text('disconnected')),
                  DropdownMenuItem(value: 'error', child: Text('error')),
                ],
                onChanged: (v) => setDialogState(() => status = v ?? 'connected'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ביטול')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('שמירה')),
          ],
        ),
      ),
    );
    if (ok != true || provider.text.trim().isEmpty) return;
    final res = await _api.put('/integrations/connections', {
      'provider': provider.text.trim(),
      'scope': 'tenant',
      'status': status,
      if (status == 'connected') 'last_sync_at': DateTime.now().toIso8601String(),
    });
    if (res['success'] == true) _load();
  }

  Future<void> _addEvent() async {
    final provider = TextEditingController(text: 'insurance');
    final type = TextEditingController(text: 'sync');
    final message = TextEditingController(text: 'Manual health event');
    String severity = 'info';
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('הוספת אירוע אינטגרציה'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: provider, decoration: const InputDecoration(labelText: 'provider')),
              TextField(controller: type, decoration: const InputDecoration(labelText: 'event type')),
              TextField(controller: message, decoration: const InputDecoration(labelText: 'message')),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: severity,
                items: const [
                  DropdownMenuItem(value: 'info', child: Text('info')),
                  DropdownMenuItem(value: 'warn', child: Text('warn')),
                  DropdownMenuItem(value: 'error', child: Text('error')),
                ],
                onChanged: (v) => setDialogState(() => severity = v ?? 'info'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ביטול')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('שמירה')),
          ],
        ),
      ),
    );
    if (ok != true) return;
    final res = await _api.post('/integrations/events', {
      'provider': provider.text.trim(),
      'event_type': type.text.trim(),
      'message': message.text.trim(),
      'severity': severity,
      'status': severity == 'error' ? 'failed' : 'ok',
      'payload': {'source': 'manual-ui'},
    });
    if (res['success'] == true) _load();
  }

  Future<void> _printSummary() async {
    final lines = <String>[
      'Connections: ${_connections.length}',
      'Events: ${_events.length}',
      '',
      ..._connections.map((c) => '- ${c['provider']}: ${c['status']}'),
      '',
      ..._events.take(15).map((e) => '- ${e['provider']} ${e['event_type']}: ${e['message']}'),
    ];
    await PrintService.printDocument(title: 'Integrations report', lines: lines);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Integrations Operations'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
          if (_canView)
            IconButton(
              onPressed: _printSummary,
              icon: const Icon(Icons.print_outlined),
              tooltip: 'Print',
            ),
          if (_canManage) IconButton(onPressed: _upsertConnection, icon: const Icon(Icons.link)),
          if (_canManage) IconButton(onPressed: _addEvent, icon: const Icon(Icons.add_alert)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : !_canView
              ? const Center(child: Text('אין הרשאה לצפייה'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text('Connections', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (_connections.isEmpty)
                      const Card(child: ListTile(title: Text('No connections')))
                    else
                      ..._connections.map((c) => Card(
                            child: ListTile(
                              title: Text('${c['provider']} (${c['scope']})'),
                              subtitle: Text('status: ${c['status']} | last sync: ${c['last_sync_at'] ?? '-'}'),
                            ),
                          )),
                    const SizedBox(height: 20),
                    const Text('Events', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (_events.isEmpty)
                      const Card(child: ListTile(title: Text('No events')))
                    else
                      ..._events.map((e) => Card(
                            child: ListTile(
                              title: Text('${e['provider']} | ${e['event_type']}'),
                              subtitle: Text('[${e['severity']}] ${e['message']}'),
                              trailing: Text(e['status']?.toString() ?? ''),
                            ),
                          )),
                  ],
                ),
    );
  }
}

