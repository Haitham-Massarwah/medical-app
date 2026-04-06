import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/print_service.dart';

class FinanceOperationsPage extends StatefulWidget {
  const FinanceOperationsPage({super.key});

  @override
  State<FinanceOperationsPage> createState() => _FinanceOperationsPageState();
}

class _FinanceOperationsPageState extends State<FinanceOperationsPage> {
  final ApiService _api = ApiService();
  final AuthService _auth = AuthService();

  bool _loading = true;
  String _role = 'patient';
  List<Map<String, dynamic>> _deposits = [];
  List<Map<String, dynamic>> _refunds = [];
  List<Map<String, dynamic>> _payouts = [];
  List<Map<String, dynamic>> _rules = [];

  bool get _canView =>
      const ['admin', 'developer', 'receptionist', 'doctor'].contains(_role);
  bool get _canManageAll => const ['admin', 'developer'].contains(_role);
  bool get _canAddDeposit =>
      const ['admin', 'developer', 'receptionist', 'doctor'].contains(_role);

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
          _deposits = [];
          _refunds = [];
          _payouts = [];
          _rules = [];
        });
        return;
      }
      final deposits = await _api.get('/finance/deposits');
      final refunds = await _api.get('/finance/refunds');
      final payouts = await _api.get('/finance/payouts');
      final rules = await _api.get('/finance/commission-rules');
      setState(() {
        _deposits = ((deposits['data']?['deposits'] ?? []) as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        _refunds = ((refunds['data']?['refunds'] ?? []) as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        _payouts = ((payouts['data']?['payouts'] ?? []) as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        _rules = ((rules['data']?['rules'] ?? []) as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addDeposit() async {
    final amount = TextEditingController();
    final notes = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('הוספת מקדמה'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: amount, decoration: const InputDecoration(labelText: 'סכום')),
            TextField(controller: notes, decoration: const InputDecoration(labelText: 'הערות')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ביטול')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('שמירה')),
        ],
      ),
    );
    if (ok != true) return;
    final res = await _api.post('/finance/deposits', {
      'amount': double.tryParse(amount.text) ?? 0,
      'notes': notes.text,
      'currency': 'ILS',
      'method': 'manual',
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res['success'] == true ? 'מקדמה נשמרה' : 'שגיאה בשמירה'),
        backgroundColor: res['success'] == true ? Colors.green : Colors.red,
      ),
    );
    if (res['success'] == true) _load();
  }

  Future<void> _requestRefund(Map<String, dynamic>? deposit) async {
    final amount = TextEditingController(
      text: deposit != null ? (deposit['amount']?.toString() ?? '') : '',
    );
    final reason = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('בקשת החזר'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: amount, decoration: const InputDecoration(labelText: 'סכום')),
            TextField(controller: reason, decoration: const InputDecoration(labelText: 'סיבה')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ביטול')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('שליחה')),
        ],
      ),
    );
    if (ok != true) return;
    final res = await _api.post('/finance/refunds', {
      'deposit_id': deposit?['id'],
      'amount': double.tryParse(amount.text) ?? 0,
      'reason': reason.text.trim(),
      'currency': 'ILS',
    });
    if (res['success'] == true) _load();
  }

  Future<void> _processRefund(String id, String status) async {
    final res = await _api.put('/finance/refunds/$id/process', {'status': status});
    if (res['success'] == true) _load();
  }

  Future<void> _createCommissionRule() async {
    if (!_canManageAll) return;
    final name = TextEditingController();
    final percent = TextEditingController(text: '0');
    final fixed = TextEditingController(text: '0');
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('כלל עמלה חדש'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'שם כלל')),
            TextField(controller: percent, decoration: const InputDecoration(labelText: 'אחוז עמלה')),
            TextField(controller: fixed, decoration: const InputDecoration(labelText: 'סכום קבוע')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ביטול')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('שמירה')),
        ],
      ),
    );
    if (ok != true) return;
    final res = await _api.post('/finance/commission-rules', {
      'name': name.text.trim(),
      'percent': double.tryParse(percent.text) ?? 0,
      'fixed_amount': double.tryParse(fixed.text) ?? 0,
    });
    if (res['success'] == true) _load();
  }

  Future<void> _printDepositReceipt(Map<String, dynamic> d) async {
    await PrintService.printDepositReceipt(
      receiptNo: d['id']?.toString() ?? '-',
      amount: d['amount']?.toString() ?? '0',
      currency: d['currency']?.toString() ?? 'ILS',
      notes: d['notes']?.toString(),
      method: d['method']?.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('פעולות פיננסיות'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
          if (_canView) IconButton(onPressed: _addDeposit, icon: const Icon(Icons.account_balance_wallet)),
          if (_canManageAll) IconButton(onPressed: _createCommissionRule, icon: const Icon(Icons.rule)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : !_canView
              ? const Center(child: Text('גישה מותרת למנהלים, קבלה או רופא בלבד'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text('מקדמות', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (_deposits.isEmpty)
                      const Card(child: ListTile(title: Text('אין מקדמות')))
                    else
                      ..._deposits.map((d) => Card(
                            child: ListTile(
                              title: Text('₪${d['amount'] ?? '-'} (${d['status'] ?? '-'})'),
                              subtitle: Text('${d['notes'] ?? ''}'),
                              trailing: Wrap(
                                spacing: 0,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.receipt_long),
                                    tooltip: 'הדפס קבלה',
                                    onPressed: () => _printDepositReceipt(d),
                                  ),
                                  if (_canAddDeposit)
                                    IconButton(
                                      icon: const Icon(Icons.undo),
                                      tooltip: 'בקשת החזר',
                                      onPressed: () => _requestRefund(d),
                                    ),
                                ],
                              ),
                            ),
                          )),
                    const SizedBox(height: 20),
                    const Text('החזרים', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (_refunds.isEmpty)
                      const Card(child: ListTile(title: Text('אין החזרים')))
                    else
                      ..._refunds.map((r) => Card(
                            child: ListTile(
                              title: Text('₪${r['amount'] ?? '-'} | ${r['status'] ?? '-'}'),
                              subtitle: Text(r['reason']?.toString() ?? ''),
                              trailing: (_canManageAll && r['status'] == 'requested')
                                  ? Wrap(
                                      spacing: 4,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.check, color: Colors.green),
                                          onPressed: () => _processRefund(r['id'].toString(), 'processed'),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close, color: Colors.red),
                                          onPressed: () => _processRefund(r['id'].toString(), 'rejected'),
                                        ),
                                      ],
                                    )
                                  : null,
                            ),
                          )),
                    const SizedBox(height: 20),
                    const Text('תשלומי ספק/רופא', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (_payouts.isEmpty)
                      const Card(child: ListTile(title: Text('אין תשלומים')))
                    else
                      ..._payouts.map((p) => Card(
                            child: ListTile(
                              title: Text('נטו: ₪${p['net_amount'] ?? '-'} | ${p['status'] ?? '-'}'),
                              subtitle: Text('ברוטו: ₪${p['gross_amount'] ?? '-'} | עמלה: ₪${p['commission_amount'] ?? '-'}'),
                            ),
                          )),
                    const SizedBox(height: 20),
                    const Text('כללי עמלה', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (_rules.isEmpty)
                      const Card(child: ListTile(title: Text('אין כללי עמלה')))
                    else
                      ..._rules.map((rule) => Card(
                            child: ListTile(
                              title: Text(rule['name']?.toString() ?? '-'),
                              subtitle: Text('אחוז: ${rule['percent']}% | קבוע: ₪${rule['fixed_amount']}'),
                            ),
                          )),
                  ],
                ),
    );
  }
}

