import 'package:flutter/material.dart';
import '../../models/treatment_models_simple.dart';

class TreatmentCompletionPage extends StatefulWidget {
  final String appointmentId;
  final String patientId;
  final String patientName;
  final String treatmentTypeId;
  final String treatmentTypeName;
  final double amount;

  const TreatmentCompletionPage({
    super.key,
    required this.appointmentId,
    required this.patientId,
    required this.patientName,
    required this.treatmentTypeId,
    required this.treatmentTypeName,
    required this.amount,
  });

  @override
  State<TreatmentCompletionPage> createState() => _TreatmentCompletionPageState();
}

class _TreatmentCompletionPageState extends State<TreatmentCompletionPage> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  bool _isLoading = false;
  bool _isCompleting = false;
  bool _isRequestingPayment = false;
  
  TreatmentSessionStatus _sessionStatus = TreatmentSessionStatus.inProgress;
  Map<String, dynamic> _treatmentData = {};

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('סיום טיפול'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient and Treatment Info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'פרטי הטיפול',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('מטופל', widget.patientName),
                      _buildInfoRow('סוג טיפול', widget.treatmentTypeName),
                      _buildInfoRow('סכום', '₪${widget.amount.toStringAsFixed(2)}'),
                      _buildInfoRow('סטטוס', _getStatusText(_sessionStatus)),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Treatment Notes
              const Text(
                'הערות טיפול',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'הוסף הערות על הטיפול...',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'נא להזין הערות על הטיפול';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Treatment Data
              const Text(
                'נתוני טיפול',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildTreatmentDataSection(),
              
              const SizedBox(height: 24),
              
              // Session Status
              const Text(
                'סטטוס הטיפול',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      RadioListTile<TreatmentSessionStatus>(
                        title: const Text('בטיפול'),
                        subtitle: const Text('הטיפול עדיין מתבצע'),
                        value: TreatmentSessionStatus.inProgress,
                        groupValue: _sessionStatus,
                        onChanged: (value) {
                          setState(() {
                            _sessionStatus = value!;
                          });
                        },
                      ),
                      RadioListTile<TreatmentSessionStatus>(
                        title: const Text('הושלם'),
                        subtitle: const Text('הטיפול הושלם בהצלחה'),
                        value: TreatmentSessionStatus.completed,
                        groupValue: _sessionStatus,
                        onChanged: (value) {
                          setState(() {
                            _sessionStatus = value!;
                          });
                        },
                      ),
                      RadioListTile<TreatmentSessionStatus>(
                        title: const Text('בוטל'),
                        subtitle: const Text('הטיפול בוטל'),
                        value: TreatmentSessionStatus.cancelled,
                        groupValue: _sessionStatus,
                        onChanged: (value) {
                          setState(() {
                            _sessionStatus = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Action Buttons
              if (_sessionStatus == TreatmentSessionStatus.completed) ...[
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isCompleting ? null : _completeTreatment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isCompleting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'אשר סיום הטיפול',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isRequestingPayment ? null : _requestPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isRequestingPayment
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'בקש תשלום מהמטופל',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ] else if (_sessionStatus == TreatmentSessionStatus.cancelled) ...[
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isCompleting ? null : _cancelTreatment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isCompleting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'אשר ביטול הטיפול',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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

  Widget _buildTreatmentDataSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Blood Pressure
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'לחץ דם (סיסטולי)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _treatmentData['bloodPressureSystolic'] = value;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'לחץ דם (דיאסטולי)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _treatmentData['bloodPressureDiastolic'] = value;
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Heart Rate
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'דופק (BPM)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _treatmentData['heartRate'] = value;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Temperature
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'חום גוף (°C)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _treatmentData['temperature'] = value;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Additional Notes
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'הערות נוספות',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              onChanged: (value) {
                _treatmentData['additionalNotes'] = value;
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(TreatmentSessionStatus status) {
    switch (status) {
      case TreatmentSessionStatus.scheduled:
        return 'מתוכנן';
      case TreatmentSessionStatus.inProgress:
        return 'בטיפול';
      case TreatmentSessionStatus.completed:
        return 'הושלם';
      case TreatmentSessionStatus.cancelled:
        return 'בוטל';
    }
  }

  Future<void> _completeTreatment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isCompleting = true;
    });

    try {
      // Complete treatment session
      final request = CompleteTreatmentSessionRequest(
        sessionId: widget.appointmentId,
        notes: _notesController.text,
        treatmentData: _treatmentData,
      );

      // Call API to complete treatment
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      _showSuccess('הטיפול הושלם בהצלחה');
      
      // Navigate back to doctor dashboard
      Navigator.of(context).pop();
    } catch (e) {
      _showError('שגיאה בסיום הטיפול: $e');
    } finally {
      setState(() {
        _isCompleting = false;
      });
    }
  }

  Future<void> _requestPayment() async {
    setState(() {
      _isRequestingPayment = true;
    });

    try {
      // Request payment from patient
      final request = RequestPaymentRequest(
        appointmentId: widget.appointmentId,
        sessionId: widget.appointmentId,
        amount: widget.amount,
        currency: 'ILS',
        description: 'הטיפול הושלם. אנא השלם את התשלום.',
      );

      // Call API to request payment
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      _showSuccess('בקשת התשלום נשלחה למטופל');
      
      // Show confirmation dialog
      _showPaymentRequestDialog();
    } catch (e) {
      _showError('שגיאה בשליחת בקשת התשלום: $e');
    } finally {
      setState(() {
        _isRequestingPayment = false;
      });
    }
  }

  Future<void> _cancelTreatment() async {
    setState(() {
      _isCompleting = true;
    });

    try {
      // Cancel treatment session
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      _showSuccess('הטיפול בוטל');
      
      // Navigate back to doctor dashboard
      Navigator.of(context).pop();
    } catch (e) {
      _showError('שגיאה בביטול הטיפול: $e');
    } finally {
      setState(() {
        _isCompleting = false;
      });
    }
  }

  void _showPaymentRequestDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('בקשת תשלום נשלחה'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('המטופל קיבל הודעה לבצע תשלום.'),
            const SizedBox(height: 8),
            Text('סכום: ₪${widget.amount.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            const Text('התשלום יתבצע דרך המערכת.'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('אישור'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}
