import 'package:flutter/material.dart';
import '../../services/visa_mastercard_payment_service.dart';
import '../../features/payments/data/models/payment_models.dart';
import '../../services/api_service.dart';

class PaymentPage extends StatefulWidget {
  final String appointmentId;
  final String doctorName;
  final String specialty;
  final DateTime appointmentDate;
  final String timeSlot;
  final int amount;

  const PaymentPage({
    super.key,
    required this.appointmentId,
    required this.doctorName,
    required this.specialty,
    required this.appointmentDate,
    required this.timeSlot,
    required this.amount,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  PaymentMethod _selectedCardType = PaymentMethod.visa;
  bool _isProcessing = false;
  bool _saveCard = false;
  double _currentAmount = 0;
  final ApiService _apiService = ApiService();
  
  final _cardNumberController = TextEditingController();
  final _expiryMonthController = TextEditingController();
  final _expiryYearController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentAmount = widget.amount.toDouble();
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryMonthController.dispose();
    _expiryYearController.dispose();
    _cvvController.dispose();
    _cardNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('תשלום'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appointment Summary
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'סיכום התור',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryRow('רופא', widget.doctorName),
                    _buildSummaryRow('התמחות', widget.specialty),
                    _buildSummaryRow('תאריך', _formatDate(widget.appointmentDate)),
                    _buildSummaryRow('שעה', widget.timeSlot),
                    const Divider(),
                    _buildSummaryRow(
                      'סכום לתשלום',
                      '₪${_currentAmount.toStringAsFixed(2)}',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Card Type Selection
            const Text(
              'בחר סוג כרטיס',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Card Types
            Row(
              children: [
                Expanded(
                  child: _buildCardTypeOption(
                    PaymentMethod.visa,
                    'Visa',
                    Icons.credit_card,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCardTypeOption(
                    PaymentMethod.mastercard,
                    'Mastercard',
                    Icons.credit_card,
                    Colors.red,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Payment Form (always shown since only card payments are supported)
            ...[
              const Text(
                'פרטי כרטיס אשראי',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Card Number
              TextFormField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'מספר כרטיס',
                  hintText: '1234 5678 9012 3456',
                  prefixIcon: const Icon(Icons.credit_card),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'נא להזין מספר כרטיס';
                  }
                  if (value.replaceAll(' ', '').length < 16) {
                    return 'מספר כרטיס לא תקין';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Card Holder Name
              TextFormField(
                controller: _cardNameController,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  labelText: 'שם על הכרטיס',
                  hintText: 'John Doe',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'נא להזין שם על הכרטיס';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Expiry Month, Year and CVV
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryMonthController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'חודש',
                        hintText: 'MM',
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'נא להזין חודש';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _expiryYearController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'שנה',
                        hintText: 'YY',
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'נא להזין שנה';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        hintText: '123',
                        prefixIcon: const Icon(Icons.security),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'נא להזין CVV';
                        }
                        if (value.length < 3) {
                          return 'CVV לא תקין';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Save Card Option
              Row(
                children: [
                  Checkbox(
                    value: _saveCard,
                    onChanged: (value) {
                      setState(() {
                        _saveCard = value ?? false;
                      });
                    },
                  ),
                  const Text('שמור כרטיס לתשלומים עתידיים'),
                ],
              ),
            ],
            
            // Amount Update Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'הסכום יתעדכן אוטומטית אם ישנה שינוי',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _updateAmount,
                    child: const Text('עדכן סכום'),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Payment Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'שלם ₪${_currentAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Security Notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.security, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'התשלום מאובטח ומצפין לפי תקן PCI DSS',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.green : Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: FontWeight.bold,
              color: isTotal ? Colors.green : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardTypeOption(PaymentMethod cardType, String title, IconData icon, Color color) {
    final isSelected = _selectedCardType == cardType;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCardType = cardType;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.black87,
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  void _updateAmount() async {
    // This would typically fetch the latest amount from the server
    // For now, we'll simulate a small change
    setState(() {
      _currentAmount = widget.amount.toDouble() + 10.0; // Simulate price change
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('הסכום עודכן בהצלחה'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildBankDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'ינואר', 'פברואר', 'מרץ', 'אפריל', 'מאי', 'יוני',
      'יולי', 'אוגוסט', 'ספטמבר', 'אוקטובר', 'נובמבר', 'דצמבר'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _processPayment() async {
    // Validate card details
    if (!_validateCardDetails()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Create payment request with real backend API
      final paymentRequest = {
        'appointment_id': widget.appointmentId,
        'amount': _currentAmount,
        'currency': 'ILS',
        'payment_method': _selectedCardType == PaymentMethod.visa ? 'visa' : 'mastercard',
        'card_number': _cardNumberController.text.replaceAll(' ', ''),
        'expiry_month': _expiryMonthController.text,
        'expiry_year': _expiryYearController.text,
        'cvv': _cvvController.text,
        'cardholder_name': _cardNameController.text,
        'save_card': _saveCard,
      };

      // Process payment through real backend API
      final result = await _apiService.post('/payments', paymentRequest);

      if (result['success'] == true) {
        final data = result['data'];
        final dataMap = data is Map<String, dynamic> ? data : null;
        final transactionId =
            dataMap?['transaction_id'] ?? dataMap?['id'] ?? 'Unknown';
        final receiptNumber = dataMap?['receipt_number'] ?? '';
        _showSuccessDialog(transactionId.toString(), receiptNumber.toString());
      } else {
        final errorMessage = result['message'] ?? 'שגיאה לא ידועה';
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      _showErrorDialog('שגיאה בעיבוד התשלום: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  bool _validateCardDetails() {
    // Validate card number and determine card type
    String cardNumber = _cardNumberController.text.replaceAll(' ', '');
    if (cardNumber.isEmpty) {
      _showError('נא להזין מספר כרטיס');
      return false;
    }
    
    final cardType = VisaMastercardPaymentService.validateCardNumber(cardNumber);
    if (cardType == null) {
      _showError('מספר כרטיס לא תקין - רק Visa ו-Mastercard נתמכים');
      return false;
    }

    // Update selected card type if it was auto-detected
    if (_selectedCardType != cardType) {
      setState(() {
        _selectedCardType = cardType;
      });
    }

    // Validate expiry date
    String month = _expiryMonthController.text;
    String year = _expiryYearController.text;
    if (month.isEmpty || year.isEmpty) {
      _showError('נא להזין תאריך תפוגה');
      return false;
    }
    
    if (!VisaMastercardPaymentService.validateExpiryDate(month, year)) {
      _showError('תאריך תפוגה לא תקין');
      return false;
    }

    // Validate CVV
    String cvv = _cvvController.text;
    if (cvv.isEmpty) {
      _showError('נא להזין קוד אבטחה');
      return false;
    }
    
    if (!VisaMastercardPaymentService.validateCVV(cvv, cardType)) {
      _showError('קוד אבטחה לא תקין');
      return false;
    }

    // Validate cardholder name
    if (_cardNameController.text.isEmpty) {
      _showError('נא להזין שם בעל הכרטיס');
      return false;
    }

    return true;
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
        title: const Text('תשלום הושלם בהצלחה!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('מספר עסקה: $transactionId'),
            if (receiptNumber.isNotEmpty) Text('מספר קבלה: $receiptNumber'),
            const SizedBox(height: 16),
            const Text('קבלת תשלום נשלחה למייל שלך'),
            const Text('התור נקבע בהצלחה!'),
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
}
