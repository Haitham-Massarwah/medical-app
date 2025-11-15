import 'package:flutter/material.dart';

class SystemLogsPage extends StatefulWidget {
  const SystemLogsPage({super.key});

  @override
  State<SystemLogsPage> createState() => _SystemLogsPageState();
}

class _SystemLogsPageState extends State<SystemLogsPage> {
  final List<Map<String, dynamic>> _logs = [
    {
      'id': '1',
      'timestamp': '2024-01-15 11:30:45',
      'level': 'INFO',
      'category': 'Authentication',
      'message': 'User login successful',
      'user': 'developer@medicalapp.com',
      'ip': '192.168.1.100',
    },
    {
      'id': '2',
      'timestamp': '2024-01-15 11:25:12',
      'level': 'WARNING',
      'category': 'Security',
      'message': 'Failed login attempt detected',
      'user': 'unknown@email.com',
      'ip': '192.168.1.200',
    },
    {
      'id': '3',
      'timestamp': '2024-01-15 11:20:33',
      'level': 'ERROR',
      'category': 'Database',
      'message': 'Connection timeout to database',
      'user': 'system',
      'ip': 'localhost',
    },
    {
      'id': '4',
      'timestamp': '2024-01-15 11:15:21',
      'level': 'INFO',
      'category': 'Payment',
      'message': 'Payment processed successfully',
      'user': 'customer@medicalapp.com',
      'ip': '192.168.1.150',
    },
    {
      'id': '5',
      'timestamp': '2024-01-15 11:10:08',
      'level': 'DEBUG',
      'category': 'API',
      'message': 'API request processed',
      'user': 'doctor@medicalapp.com',
      'ip': '192.168.1.120',
    },
  ];

  String _selectedFilter = 'כל הלוגים';
  String _selectedLevel = 'כל הרמות';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('יומני מערכת'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshLogs(),
            tooltip: 'רענן לוגים',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _exportLogs(),
            tooltip: 'ייצא לוגים',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Section
            _buildFilterSection(),
            
            const SizedBox(height: 24),
            
            // Logs List
            _buildLogsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'סינון לוגים',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedFilter,
                    decoration: const InputDecoration(
                      labelText: 'קטגוריה',
                      border: OutlineInputBorder(),
                    ),
                    items: ['כל הלוגים', 'Authentication', 'Security', 'Database', 'Payment', 'API']
                        .map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedFilter = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedLevel,
                    decoration: const InputDecoration(
                      labelText: 'רמה',
                      border: OutlineInputBorder(),
                    ),
                    items: ['כל הרמות', 'DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL']
                        .map((level) => DropdownMenuItem(
                              value: level,
                              child: Text(level),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLevel = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogsList() {
    final filteredLogs = _getFilteredLogs();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'יומני מערכת (${filteredLogs.length})',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...filteredLogs.map((log) => _buildLogCard(log)).toList(),
      ],
    );
  }

  List<Map<String, dynamic>> _getFilteredLogs() {
    return _logs.where((log) {
      final categoryMatch = _selectedFilter == 'כל הלוגים' || log['category'] == _selectedFilter;
      final levelMatch = _selectedLevel == 'כל הרמות' || log['level'] == _selectedLevel;
      return categoryMatch && levelMatch;
    }).toList();
  }

  Widget _buildLogCard(Map<String, dynamic> log) {
    Color levelColor = _getLevelColor(log['level']);
    IconData levelIcon = _getLevelIcon(log['level']);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log['message'],
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        log['timestamp'],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: levelColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(levelIcon, size: 16, color: levelColor),
                          const SizedBox(width: 4),
                          Text(
                            log['level'],
                            style: TextStyle(
                              color: levelColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        log['category'],
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text('משתמש: ${log['user']}'),
                const SizedBox(width: 16),
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text('IP: ${log['ip']}'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _viewLogDetails(log),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('פרטים'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _copyLog(log),
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('העתק'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _deleteLog(log),
                    icon: const Icon(Icons.delete, size: 16),
                    label: const Text('מחק'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'DEBUG': return Colors.grey;
      case 'INFO': return Colors.blue;
      case 'WARNING': return Colors.orange;
      case 'ERROR': return Colors.red;
      case 'CRITICAL': return Colors.purple;
      default: return Colors.grey;
    }
  }

  IconData _getLevelIcon(String level) {
    switch (level) {
      case 'DEBUG': return Icons.bug_report;
      case 'INFO': return Icons.info;
      case 'WARNING': return Icons.warning;
      case 'ERROR': return Icons.error;
      case 'CRITICAL': return Icons.dangerous;
      default: return Icons.info;
    }
  }

  void _refreshLogs() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('הלוגים עודכנו בהצלחה!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _exportLogs() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ייצוא לוגים'),
        content: const Text('מייצא את הלוגים לקובץ...\n\n• פורמט: CSV/JSON\n• תאריך: 7 ימים אחרונים\n• קטגוריות: כל הלוגים'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showExportSuccess();
            },
            child: const Text('ייצא'),
          ),
        ],
      ),
    );
  }

  void _showExportSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('הלוגים יוצאו בהצלחה!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _viewLogDetails(Map<String, dynamic> log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('פרטי לוג'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('הודעה: ${log['message']}'),
            Text('זמן: ${log['timestamp']}'),
            Text('רמה: ${log['level']}'),
            Text('קטגוריה: ${log['category']}'),
            Text('משתמש: ${log['user']}'),
            Text('IP: ${log['ip']}'),
            const SizedBox(height: 16),
            const Text('פרטים נוספים:'),
            Text('• מזהה לוג: ${log['id']}'),
            const Text('• זמן עיבוד: 15ms'),
            const Text('• גודל הודעה: 256 bytes'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('סגור'),
          ),
        ],
      ),
    );
  }

  void _copyLog(Map<String, dynamic> log) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('הלוג הועתק ללוח!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deleteLog(Map<String, dynamic> log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('מחק לוג'),
        content: const Text('האם אתה בטוח שברצונך למחוק את הלוג הזה?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _logs.removeWhere((l) => l['id'] == log['id']);
              });
              Navigator.pop(context);
              _showLogDeleted();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('מחק'),
          ),
        ],
      ),
    );
  }

  void _showLogDeleted() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('הלוג נמחק בהצלחה!'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
