import 'package:flutter/material.dart';
import '../../models/treatment_models_simple.dart';

class DoctorTreatmentSettingsPage extends StatefulWidget {
  const DoctorTreatmentSettingsPage({super.key});

  @override
  State<DoctorTreatmentSettingsPage> createState() => _DoctorTreatmentSettingsPageState();
}

class _DoctorTreatmentSettingsPageState extends State<DoctorTreatmentSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSaving = false;

  // Treatment settings
  List<String> _selectedTreatmentTypes = [];
  Map<String, Duration> _treatmentDurations = {};
  Map<String, double> _treatmentPrices = {};
  List<BreakPeriodModel> _breakPeriods = [];
  BookingApprovalType _approvalType = BookingApprovalType.immediate;
  PaymentTiming _paymentTiming = PaymentTiming.atBooking;

  // Available treatment types (would typically come from API)
  final List<TreatmentTypeModel> _availableTreatmentTypes = [
    const TreatmentTypeModel(
      id: '1',
      name: 'ייעוץ כללי',
      description: 'ייעוץ רפואי כללי',
      duration: Duration(minutes: 30),
      price: 200.0,
      isActive: true,
    ),
    const TreatmentTypeModel(
      id: '2',
      name: 'בדיקה גופנית',
      description: 'בדיקה גופנית מקיפה',
      duration: Duration(minutes: 45),
      price: 300.0,
      isActive: true,
    ),
    const TreatmentTypeModel(
      id: '3',
      name: 'ייעוץ מומחה',
      description: 'ייעוץ עם מומחה',
      duration: Duration(minutes: 60),
      price: 400.0,
      isActive: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadDoctorSettings();
  }

  Future<void> _loadDoctorSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load doctor's current settings from API
      // For now, use mock data
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _selectedTreatmentTypes = ['1', '2']; // Mock selected types
        _treatmentDurations = {
          '1': const Duration(minutes: 30),
          '2': const Duration(minutes: 45),
        };
        _treatmentPrices = {
          '1': 200.0,
          '2': 300.0,
        };
        _approvalType = BookingApprovalType.immediate;
        _paymentTiming = PaymentTiming.atBooking;
      });
    } catch (e) {
      _showError('שגיאה בטעינת ההגדרות: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('הגדרות טיפולים'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('הגדרות טיפולים'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveSettings,
            tooltip: 'שמור הגדרות',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Treatment Types Selection
              _buildSectionTitle('סוגי טיפולים'),
              _buildTreatmentTypesSection(),
              
              const SizedBox(height: 24),
              
              // Treatment Durations and Prices
              _buildSectionTitle('מחירים וזמנים'),
              _buildTreatmentDetailsSection(),
              
              const SizedBox(height: 24),
              
              // Break Periods
              _buildSectionTitle('זמני הפסקה'),
              _buildBreakPeriodsSection(),
              
              const SizedBox(height: 24),
              
              // Booking Settings
              _buildSectionTitle('הגדרות הזמנה'),
              _buildBookingSettingsSection(),
              
              const SizedBox(height: 24),
              
              // Payment Settings
              _buildSectionTitle('הגדרות תשלום'),
              _buildPaymentSettingsSection(),
              
              const SizedBox(height: 32),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'שמור הגדרות',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
    );
  }

  Widget _buildTreatmentTypesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'בחר את סוגי הטיפולים שאתה מציע:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            ..._availableTreatmentTypes.map((treatmentType) {
              final isSelected = _selectedTreatmentTypes.contains(treatmentType.id);
              return CheckboxListTile(
                title: Text(treatmentType.name),
                subtitle: Text(treatmentType.description),
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedTreatmentTypes.add(treatmentType.id);
                      _treatmentDurations[treatmentType.id] = treatmentType.duration;
                      _treatmentPrices[treatmentType.id] = treatmentType.price;
                    } else {
                      _selectedTreatmentTypes.remove(treatmentType.id);
                      _treatmentDurations.remove(treatmentType.id);
                      _treatmentPrices.remove(treatmentType.id);
                    }
                  });
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTreatmentDetailsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: _selectedTreatmentTypes.map((treatmentId) {
            final treatmentType = _availableTreatmentTypes.firstWhere(
              (t) => t.id == treatmentId,
            );
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    treatmentType.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: _treatmentDurations[treatmentId]?.inMinutes.toString() ?? '',
                          decoration: const InputDecoration(
                            labelText: 'משך הטיפול (דקות)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final minutes = int.tryParse(value);
                            if (minutes != null) {
                              _treatmentDurations[treatmentId] = Duration(minutes: minutes);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          initialValue: _treatmentPrices[treatmentId]?.toString() ?? '',
                          decoration: const InputDecoration(
                            labelText: 'מחיר (₪)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final price = double.tryParse(value);
                            if (price != null) {
                              _treatmentPrices[treatmentId] = price;
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBreakPeriodsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'זמני הפסקה',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addBreakPeriod,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_breakPeriods.isEmpty)
              const Text(
                'אין זמני הפסקה מוגדרים',
                style: TextStyle(color: Colors.grey),
              )
            else
              ..._breakPeriods.asMap().entries.map((entry) {
                final index = entry.key;
                final breakPeriod = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text('${_formatTime(breakPeriod.startTime)} - ${_formatTime(breakPeriod.endTime)}'),
                    subtitle: Text(breakPeriod.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _breakPeriods.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingSettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'אישור הזמנות',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            RadioListTile<BookingApprovalType>(
              title: const Text('אישור מיידי'),
              subtitle: const Text('הזמנות מאושרות אוטומטית'),
              value: BookingApprovalType.immediate,
              groupValue: _approvalType,
              onChanged: (value) {
                setState(() {
                  _approvalType = value!;
                });
              },
            ),
            RadioListTile<BookingApprovalType>(
              title: const Text('אישור ידני'),
              subtitle: const Text('הזמנות דורשות אישור ידני'),
              value: BookingApprovalType.manual,
              groupValue: _approvalType,
              onChanged: (value) {
                setState(() {
                  _approvalType = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'זמן תשלום',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            RadioListTile<PaymentTiming>(
              title: const Text('תשלום בזמן ההזמנה'),
              subtitle: const Text('המטופל משלם בעת קביעת התור'),
              value: PaymentTiming.atBooking,
              groupValue: _paymentTiming,
              onChanged: (value) {
                setState(() {
                  _paymentTiming = value!;
                });
              },
            ),
            RadioListTile<PaymentTiming>(
              title: const Text('תשלום לאחר הטיפול'),
              subtitle: const Text('המטופל משלם לאחר סיום הטיפול'),
              value: PaymentTiming.afterTreatment,
              groupValue: _paymentTiming,
              onChanged: (value) {
                setState(() {
                  _paymentTiming = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addBreakPeriod() {
    showDialog(
      context: context,
      builder: (context) => _BreakPeriodDialog(
        onSave: (breakPeriod) {
          setState(() {
            _breakPeriods.add(breakPeriod);
          });
        },
      ),
    );
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Save settings to API
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      _showSuccess('הגדרות נשמרו בהצלחה');
    } catch (e) {
      _showError('שגיאה בשמירת ההגדרות: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
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

class _BreakPeriodDialog extends StatefulWidget {
  final Function(BreakPeriodModel) onSave;

  const _BreakPeriodDialog({required this.onSave});

  @override
  State<_BreakPeriodDialog> createState() => _BreakPeriodDialogState();
}

class _BreakPeriodDialogState extends State<_BreakPeriodDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('הוסף זמן הפסקה'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('שעת התחלה'),
              subtitle: Text(_startTime.format(context)),
              onTap: _selectStartTime,
            ),
            ListTile(
              title: const Text('שעת סיום'),
              subtitle: Text(_endTime.format(context)),
              onTap: _selectEndTime,
            ),
            TextFormField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'סיבת ההפסקה',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'נא להזין סיבת ההפסקה';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('ביטול'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('שמור'),
        ),
      ],
    );
  }

  Future<void> _selectStartTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (time != null) {
      setState(() {
        _startTime = time;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (time != null) {
      setState(() {
        _endTime = time;
      });
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final now = DateTime.now();
    final startDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _startTime.hour,
      _startTime.minute,
    );
    final endDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _endTime.hour,
      _endTime.minute,
    );

    final breakPeriod = BreakPeriodModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _reasonController.text,
      startTime: startDateTime,
      endTime: endDateTime,
      daysOfWeek: const [0, 1, 2, 3, 4, 5, 6],
      isRecurring: true,
    );

    widget.onSave(breakPeriod);
    Navigator.of(context).pop();
  }
}
