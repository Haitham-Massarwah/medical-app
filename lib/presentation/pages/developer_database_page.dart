import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../services/database_service.dart';

class DeveloperDatabasePage extends StatefulWidget {
  const DeveloperDatabasePage({super.key});

  @override
  State<DeveloperDatabasePage> createState() => _DeveloperDatabasePageState();
}

class _DeveloperDatabasePageState extends State<DeveloperDatabasePage> {
  final DatabaseService _databaseService = DatabaseService();
  Map<String, dynamic> _databaseStatus = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDatabaseStatus();
  }

  Future<void> _loadDatabaseStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final status = await DatabaseService.getDatabaseStatus();
      setState(() {
        _databaseStatus = status;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('ניהול מסד נתונים'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Database Status Card
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'סטטוס מסד נתונים',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildStatusRow('סטטוס', _databaseStatus['status'] ?? 'לא ידוע'),
                            _buildStatusRow('גודל', _databaseStatus['size'] ?? 'לא ידוע'),
                            _buildStatusRow('תאריך גיבוי אחרון', _databaseStatus['lastBackup'] ?? 'לא ידוע'),
                            _buildStatusRow('מספר רשומות', _databaseStatus['records'] ?? 'לא ידוע'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Database Operations
                    const Text(
                      'פעולות מסד נתונים:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Upload Database
                    _buildActionCard(
                      'העלה גיבוי מסד נתונים',
                      'העלה קובץ גיבוי SQL',
                      Icons.upload_file,
                      Colors.blue,
                      _uploadDatabase,
                    ),

                    // Download Database
                    _buildActionCard(
                      'הורד גיבוי מסד נתונים',
                      'צור גיבוי של מסד הנתונים הנוכחי',
                      Icons.download,
                      Colors.green,
                      _downloadDatabase,
                    ),

                    // Restore Database
                    _buildActionCard(
                      'שחזר מסד נתונים',
                      'שחזר מסד נתונים מגיבוי',
                      Icons.restore,
                      Colors.orange,
                      _restoreDatabase,
                    ),

                    // Optimize Database
                    _buildActionCard(
                      'אופטימיזציה למסד נתונים',
                      'שפר ביצועי מסד הנתונים',
                      Icons.speed,
                      Colors.purple,
                      _optimizeDatabase,
                    ),

                    const SizedBox(height: 20),

                    // Database Statistics
                    const Text(
                      'סטטיסטיקות:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.people, color: Colors.blue),
                              title: const Text('משתמשים'),
                              trailing: Text(_databaseStatus['users']?.toString() ?? '0'),
                            ),
                            ListTile(
                              leading: const Icon(Icons.medical_services, color: Colors.green),
                              title: const Text('רופאים'),
                              trailing: Text(_databaseStatus['doctors']?.toString() ?? '0'),
                            ),
                            ListTile(
                              leading: const Icon(Icons.calendar_today, color: Colors.orange),
                              title: const Text('תורים'),
                              trailing: Text(_databaseStatus['appointments']?.toString() ?? '0'),
                            ),
                            ListTile(
                              leading: const Icon(Icons.payment, color: Colors.purple),
                              title: const Text('תשלומים'),
                              trailing: Text(_databaseStatus['payments']?.toString() ?? '0'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Future<void> _uploadDatabase() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('תכונה זו זמינה כשהשרת רץ. אנא הפעל את השרת והתחבר מחדש.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
    }
    return;
    // Original code commented out due to FilePicker dependency
    /*
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['sql'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final success = await DatabaseService.uploadDatabaseBackup(file);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? 'הגיבוי הועלה בהצלחה' : 'שגיאה בהעלאת הגיבוי'),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );

          if (success) {
            _loadDatabaseStatus();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    */
  }

  Future<void> _downloadDatabase() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await DatabaseService.downloadDatabaseBackup();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('הגיבוי הורד בהצלחה'),
              backgroundColor: Colors.green,
            ),
          );
          // Reload status after successful download
          _loadDatabaseStatus();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('שגיאה בהורדת הגיבוי - נסה שוב מאוחר יותר או בדוק שהשרת רץ'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה: $e - ודא שהשרת רץ על פורט 3000'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _restoreDatabase() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('תכונה זו זמינה כשהשרת רץ. אנא הפעל את השרת והתחבר מחדש.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
    }
    return;
    // Original code commented out due to FilePicker dependency
    /*
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['sql'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final success = await DatabaseService.restoreDatabase(file);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? 'מסד הנתונים שוחזר בהצלחה' : 'שגיאה בשחזור מסד הנתונים'),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );

          if (success) {
            _loadDatabaseStatus();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    */
  }

  Future<void> _optimizeDatabase() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await DatabaseService.optimizeDatabase();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('מסד הנתונים אופטמז בהצלחה'),
              backgroundColor: Colors.green,
            ),
          );
          _loadDatabaseStatus();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('שגיאה באופטימיזציה - נסה שוב מאוחר יותר או בדוק שהשרת רץ'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה: $e - ודא שהשרת רץ על פורט 3000'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}
