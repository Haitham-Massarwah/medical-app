import 'package:flutter/material.dart';
import '../../services/receipt_service.dart';

class ReceiptPage extends StatefulWidget {
  final String receiptId;
  final Map<String, dynamic>? receiptData;

  const ReceiptPage({
    super.key,
    required this.receiptId,
    this.receiptData,
  });

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  final ReceiptService _receiptService = ReceiptService();
  Map<String, dynamic>? _receipt;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.receiptData != null) {
      _receipt = widget.receiptData;
      _isLoading = false;
    } else {
      _loadReceipt();
    }
  }

  Future<void> _loadReceipt() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final receipt = await _receiptService.getReceipt(widget.receiptId);
      setState(() {
        _receipt = receipt;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('קבלה'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadPDF,
          ),
          IconButton(
            icon: const Icon(Icons.email),
            onPressed: _emailReceipt,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareReceipt,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _receipt == null
              ? const Center(child: Text('קבלה לא נמצאה'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Receipt Header
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.receipt_long,
                              size: 64,
                              color: Colors.green,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'קבלה',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '#${_receipt!['id']}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Receipt Details
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildReceiptRow('תאריך', _formatDate(_receipt!['date'])),
                            const Divider(),
                            _buildReceiptRow('רופא', _receipt!['doctor_name'] ?? ''),
                            const Divider(),
                            _buildReceiptRow('שירות', _receipt!['service'] ?? 'בדיקה רפואית'),
                            const Divider(),
                            _buildReceiptRow('סכום', '₪${_receipt!['amount']}'),
                            _buildReceiptRow('מע"מ (17%)', '₪${_receipt!['vat']}'),
                            const Divider(thickness: 2),
                            _buildReceiptRow(
                              'סה"כ',
                              '₪${_receipt!['total']}',
                              isTotal: true,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Actions
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _downloadPDF,
                              icon: const Icon(Icons.download),
                              label: const Text('הורד PDF'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.all(16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _emailReceipt,
                              icon: const Icon(Icons.email),
                              label: const Text('שלח למייל'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.all(16),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Footer
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Column(
                          children: [
                            Text(
                              'תודה שבחרת במערכת התורים הרפואיים שלנו',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'קבלה זו עומדת בתקני מס הכנסה ומשרד הבריאות',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 20 : 16,
              fontWeight: FontWeight.bold,
              color: isTotal ? Colors.green : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  void _downloadPDF() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('מוריד PDF...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _emailReceipt() async {
    final TextEditingController emailController = TextEditingController();
    
    final shouldSend = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('שלח קבלה במייל'),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: 'כתובת אימייל',
            hintText: 'example@email.com',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('שלח'),
          ),
        ],
      ),
    );

    if (shouldSend == true && emailController.text.isNotEmpty) {
      try {
        await _receiptService.emailReceipt(widget.receiptId, emailController.text);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('הקבלה נשלחה למייל בהצלחה'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('שגיאה בשליחה: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _shareReceipt() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('פתיחת אפשרויות שיתוף...')),
    );
  }
}









