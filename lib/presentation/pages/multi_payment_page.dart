import 'package:flutter/material.dart';
import '../../services/israeli_payment_gateway.dart';
import '../../models/appointment_cart.dart';
import '../../services/payment_service.dart';
import '../../services/email_service.dart';

class MultiPaymentPage extends StatefulWidget {
  final AppointmentCart cart;

  const MultiPaymentPage({
    super.key,
    required this.cart,
  });

  @override
  State<MultiPaymentPage> createState() => _MultiPaymentPageState();
}

class _MultiPaymentPageState extends State<MultiPaymentPage> {
  String _selectedPaymentMethod = 'card';
  bool _isProcessing = false;
  bool _savePaymentMethod = false;
  
  // Card details
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardNameController = TextEditingController();
  
  // Israeli payment service
  final PaymentService _paymentService = PaymentService();
  final EmailService _emailService = EmailService();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardNameController.dispose();
    super.dispose();
  }

  void _processMultiPayment() async {
    // Only card payments are supported
    if (!_validateIsraeliCardDetails()) {
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Calculate total with VAT
      final subtotal = _getTotalAmount();
      final vat = subtotal * 0.17; // 17% VAT
      final total = subtotal + vat;

      // Process payment through Israeli gateway
      final result = await IsraeliPaymentGateway.processPayment(
        amount: subtotal,
        paymentMethod: 'card',
        cardDetails: _getCardDetails(),
        transactionId: _generateTransactionId(),
        customerEmail: 'customer@example.com',
        customerName: 'שרה לוי',
        customerPhone: '050-1234567',
      );

      if (result['success']) {
        // Generate Israeli-compliant receipt for all appointments
        final receipt = IsraeliPaymentGateway.generateIsraeliReceipt(
          transactionId: result['transactionId'],
          amount: result['amount'],
          vat: result['vat'],
          customerName: 'שרה לוי',
          customerEmail: 'customer@example.com',
          appointments: widget.cart.items.map((item) => {
            'doctorName': item.doctorName,
            'specialty': item.specialty,
            'appointmentDate': item.appointmentDate,
            'timeSlot': item.timeSlot,
            'consultationFee': item.consultationFee,
          }).toList(),
        );

        // Send receipt
        await IsraeliPaymentGateway.sendIsraeliReceipt(
          customerEmail: 'customer@example.com',
          receipt: receipt,
        );

        _showSuccessDialog(result['transactionId'], receipt['receiptNumber']);
      } else {
        _showErrorDialog(result['error'] ?? 'שגיאה לא ידועה');
      }
    } catch (e) {
      _showErrorDialog('שגיאה בעיבוד התשלום: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  bool _validateIsraeliCardDetails() {
    String cardNumber = _cardNumberController.text.replaceAll(' ', '');
    if (cardNumber.isEmpty) {
      _showError('נא להזין מספר כרטיס');
      return false;
    }
    if (!IsraeliPaymentGateway.validateIsraeliCard(cardNumber)) {
      _showError('מספר כרטיס ישראלי לא תקין');
      return false;
    }

    String expiry = _expiryController.text;
    if (expiry.isEmpty) {
      _showError('נא להזין תאריך תפוגה');
      return false;
    }
    if (!_isValidExpiryDate(expiry)) {
      _showError('תאריך תפוגה לא תקין (MM/YY)');
      return false;
    }

    String cvv = _cvvController.text;
    if (cvv.isEmpty) {
      _showError('נא להזין קוד אבטחה');
      return false;
    }
    if (!_isValidCVV(cvv)) {
      _showError('קוד אבטחה לא תקין (3-4 ספרות)');
      return false;
    }

    if (_cardNameController.text.isEmpty) {
      _showError('נא להזין שם בעל הכרטיס');
      return false;
    }
    return true;
  }

  Map<String, dynamic> _getCardDetails() {
    return {
      'number': _cardNumberController.text.replaceAll(' ', ''),
      'expiry': _expiryController.text,
      'cvv': _cvvController.text,
      'name': _cardNameController.text,
    };
  }

  String _generateTransactionId() {
    return 'TXN-${DateTime.now().millisecondsSinceEpoch}';
  }

  double _getTotalAmount() {
    return widget.cart.items.fold(0.0, (sum, item) => sum + item.consultationFee);
  }

  bool _isValidExpiryDate(String expiry) {
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(expiry)) {
      return false;
    }
    
    final parts = expiry.split('/');
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);
    
    if (month == null || year == null) {
      return false;
    }
    
    if (month < 1 || month > 12) {
      return false;
    }
    
    DateTime now = DateTime.now();
    int currentYear = now.year % 100;
    int currentMonth = now.month;
    
    if (year < currentYear || (year == currentYear && month < currentMonth)) {
      return false;
    }
    
    return true;
  }

  bool _isValidCVV(String cvv) {
    return RegExp(r'^\d{3,4}$').hasMatch(cvv);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessDialog(String transactionId, String receiptNumber) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('תשלום מרובה הושלם בהצלחה!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('מספר עסקה: $transactionId'),
            Text('מספר קבלה: $receiptNumber'),
            const SizedBox(height: 16),
            Text('סה"כ תורים: ${widget.cart.items.length}'),
            Text('סה"כ תשלום: ₪${_getTotalAmount().toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            const Text('קבלת תשלום נשלחה למייל שלך'),
            const Text('כל התורים נקבעו בהצלחה!'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/appointments');
            },
            child: const Text('אישור'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('שגיאה בתשלום'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('אישור'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('תשלום מרובה'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'סיכום הזמנה',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ...widget.cart.items.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text('${item.doctorName} - ${item.specialty}'),
                            ),
                            Text('₪${item.consultationFee.toStringAsFixed(0)}'),
                          ],
                        ),
                      )),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('סה"כ:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('₪${_getTotalAmount().toStringAsFixed(0)}', 
                               style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('מע"מ (17%):', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('₪${(_getTotalAmount() * 0.17).toStringAsFixed(0)}', 
                               style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('סה"כ לתשלום:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('₪${(_getTotalAmount() * 1.17).toStringAsFixed(0)}', 
                               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Payment Methods
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'בחר שיטת תשלום',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildPaymentOption(
                        'card',
                        'כרטיס אשראי',
                        'Visa / Mastercard / Isracard',
                        Icons.credit_card,
                        Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Card Details (always shown since only card payments are supported)
              _buildCardDetails(),
              const SizedBox(height: 24),
              
              // Process Payment Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processMultiPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isProcessing
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('מעבד תשלום...'),
                          ],
                        )
                      : const Text(
                          'שלם עכשיו',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String value, String title, String subtitle, IconData icon, Color color) {
    return RadioListTile<String>(
      value: value,
      groupValue: _selectedPaymentMethod,
      onChanged: (value) {
        setState(() {
          _selectedPaymentMethod = value!;
        });
      },
      title: Text(title),
      subtitle: Text(subtitle),
      secondary: Icon(icon, color: color),
      activeColor: color,
    );
  }

  Widget _buildCardDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'פרטי כרטיס אשראי',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cardNumberController,
              decoration: const InputDecoration(
                labelText: 'מספר כרטיס',
                hintText: '1234 5678 9012 3456',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.credit_card),
              ),
              keyboardType: TextInputType.number,
              maxLength: 19,
              onChanged: (value) {
                // Format card number with spaces
                String formatted = value.replaceAll(' ', '');
                if (formatted.length > 4) {
                  formatted = formatted.substring(0, 4) + ' ' + formatted.substring(4);
                }
                if (formatted.length > 9) {
                  formatted = formatted.substring(0, 9) + ' ' + formatted.substring(9);
                }
                if (formatted.length > 14) {
                  formatted = formatted.substring(0, 14) + ' ' + formatted.substring(14);
                }
                if (formatted != value) {
                  _cardNumberController.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(offset: formatted.length),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _expiryController,
                    decoration: const InputDecoration(
                      labelText: 'תאריך תפוגה',
                      hintText: 'MM/YY',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 5,
                    onChanged: (value) {
                      // Format expiry date
                      if (value.length == 2 && !value.contains('/')) {
                        _expiryController.value = TextEditingValue(
                          text: value + '/',
                          selection: TextSelection.collapsed(offset: 3),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _cvvController,
                    decoration: const InputDecoration(
                      labelText: 'קוד אבטחה',
                      hintText: '123',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    obscureText: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cardNameController,
              decoration: const InputDecoration(
                labelText: 'שם בעל הכרטיס',
                hintText: 'שם מלא',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              value: _savePaymentMethod,
              onChanged: (value) {
                setState(() {
                  _savePaymentMethod = value ?? false;
                });
              },
              title: const Text('שמור פרטי כרטיס לתשלומים עתידיים'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        ),
      ),
    );
  }
}