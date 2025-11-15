import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/treatment_models_simple.dart';

class DoctorTreatmentSettingsPage extends StatefulWidget {
  const DoctorTreatmentSettingsPage({super.key});

  @override
  State<DoctorTreatmentSettingsPage> createState() => _DoctorTreatmentSettingsPageState();
}

class _DoctorTreatmentSettingsPageState extends State<DoctorTreatmentSettingsPage> {
  bool _isEditingTreatmentTypes = false;
  bool _isEditingBreakPeriods = false;
  
  // Save changes when leaving edit mode
  Future<void> _saveTreatmentTypesChanges() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final treatmentTypesJson = _selectedTreatmentTypes.map((t) => {
        'id': t.id,
        'name': t.name,
        'description': t.description,
        'duration': t.duration.inMinutes,
        'price': t.price,
        'isActive': t.isActive,
      }).toList();
      
      await prefs.setString('selected_treatment_types', jsonEncode(treatmentTypesJson));
      
      print('Saving treatment types: ${_selectedTreatmentTypes.map((t) => t.name).toList()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('סוגי טיפולים נשמרו בהצלחה: ${_selectedTreatmentTypes.length} טיפולים נבחרו'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print('Error saving treatment types: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('שגיאה בשמירת סוגי טיפולים'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _saveBreakPeriodsChanges() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final breakPeriodsJson = _selectedBreakPeriods.map((bp) => {
        'id': bp.id,
        'name': bp.name,
        'startTime': bp.startTime.toIso8601String(),
        'endTime': bp.endTime.toIso8601String(),
        'daysOfWeek': bp.daysOfWeek,
        'isRecurring': bp.isRecurring,
      }).toList();
      
      await prefs.setString('selected_break_periods', jsonEncode(breakPeriodsJson));
      
      print('Saving break periods: ${_selectedBreakPeriods.map((bp) => bp.name).toList()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('הפסקות נשמרו בהצלחה: ${_selectedBreakPeriods.length} הפסקות נבחרו'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print('Error saving break periods: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('שגיאה בשמירת הפסקות'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // Get saved data for calendar integration
  List<TreatmentTypeModel> getSelectedTreatmentTypes() {
    return _selectedTreatmentTypes;
  }
  
  List<BreakPeriodModel> getSelectedBreakPeriods() {
    return _selectedBreakPeriods;
  }
  
  // Load saved data on init
  Future<void> _loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load treatment types
      final treatmentTypesString = prefs.getString('selected_treatment_types');
      if (treatmentTypesString != null) {
        final treatmentTypesData = jsonDecode(treatmentTypesString) as List;
        setState(() {
          _selectedTreatmentTypes = treatmentTypesData.map((data) => TreatmentTypeModel(
            id: data['id'],
            name: data['name'],
            description: data['description'],
            duration: Duration(minutes: data['duration']),
            price: data['price'].toDouble(),
            isActive: data['isActive'],
          )).toList();
        });
      }
      
      // Load break periods
      final breakPeriodsString = prefs.getString('selected_break_periods');
      if (breakPeriodsString != null) {
        final breakPeriodsData = jsonDecode(breakPeriodsString) as List;
        setState(() {
          _selectedBreakPeriods = breakPeriodsData.map((data) => BreakPeriodModel(
            id: data['id'],
            name: data['name'],
            startTime: DateTime.parse(data['startTime']),
            endTime: DateTime.parse(data['endTime']),
            daysOfWeek: List<int>.from(data['daysOfWeek']),
            isRecurring: data['isRecurring'],
          )).toList();
        });
      }
    } catch (e) {
      print('Error loading saved data: $e');
    }
  }
  
  List<TreatmentTypeModel> _availableTreatmentTypes = [
    TreatmentTypeModel(
      id: '1',
      name: 'ייעוץ כללי',
      description: 'ייעוץ רפואי כללי',
      duration: Duration(minutes: 30),
      price: 200.0,
      isActive: true,
    ),
    TreatmentTypeModel(
      id: '2',
      name: 'בדיקה גופנית',
      description: 'בדיקה גופנית מקיפה',
      duration: Duration(minutes: 45),
      price: 300.0,
      isActive: true,
    ),
    TreatmentTypeModel(
      id: '3',
      name: 'ייעוץ מומחה',
      description: 'ייעוץ עם מומחה',
      duration: Duration(minutes: 60),
      price: 400.0,
      isActive: true,
    ),
    TreatmentTypeModel(
      id: '4',
      name: 'טיפול פיזיותרפיה',
      description: 'טיפול פיזיותרפיה שיקומי',
      duration: Duration(minutes: 45),
      price: 250.0,
      isActive: true,
    ),
    TreatmentTypeModel(
      id: '5',
      name: 'ייעוץ תזונה',
      description: 'ייעוץ תזונתי מקצועי',
      duration: Duration(minutes: 30),
      price: 180.0,
      isActive: true,
    ),
  ];

  List<BreakPeriodModel> _breakPeriods = [
    BreakPeriodModel(
      id: '1',
      name: 'הפסקת צהריים',
      startTime: DateTime(2024, 1, 1, 12, 0),
      endTime: DateTime(2024, 1, 1, 13, 0),
      daysOfWeek: [1, 2, 3, 4, 5], // Monday to Friday
      isRecurring: true,
    ),
    BreakPeriodModel(
      id: '2',
      name: 'הפסקת בוקר',
      startTime: DateTime(2024, 1, 1, 10, 30),
      endTime: DateTime(2024, 1, 1, 10, 45),
      daysOfWeek: [1, 2, 3, 4, 5], // Monday to Friday
      isRecurring: true,
    ),
  ];

  List<TreatmentTypeModel> _selectedTreatmentTypes = [];
  List<BreakPeriodModel> _selectedBreakPeriods = [];
  bool _autoApproveAppointments = false;
  PaymentTiming _paymentTiming = PaymentTiming.atBooking;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('הגדרות טיפולים'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addTreatmentType,
            tooltip: 'הוסף סוג טיפול',
          ),
          IconButton(
            icon: const Icon(Icons.schedule),
            onPressed: _addBreakPeriod,
            tooltip: 'הוסף הפסקה',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Treatment Types Section
            _buildSectionTitle('סוגי טיפולים'),
            _buildTreatmentTypesSection(),
            
            const SizedBox(height: 24),
            
            // Break Periods Section
            _buildSectionTitle('הפסקות'),
            _buildBreakPeriodsSection(),
            
            const SizedBox(height: 24),
            
            // Settings Section
            _buildSectionTitle('הגדרות כלליות'),
            _buildSettingsSection(),
            
            const SizedBox(height: 32),
            
            // Save Button
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.green,
      ),
    );
  }

  Widget _buildTreatmentTypesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Text('סוגי טיפולים', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _isEditingTreatmentTypes
                      ? () {
                          setState(() {
                            _isEditingTreatmentTypes = false;
                          });
                          _saveTreatmentTypesChanges();
                        }
                      : () {
                          setState(() {
                            _isEditingTreatmentTypes = true;
                          });
                        },
                  icon: Icon(_isEditingTreatmentTypes ? Icons.save : Icons.edit),
                  label: Text(_isEditingTreatmentTypes ? 'שמור' : 'עריכה'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.blue,
                    elevation: 0,
                  ),
                ),
                const SizedBox(width: 8),
                if (_isEditingTreatmentTypes)
                  ElevatedButton.icon(
                    onPressed: _addTreatmentType,
                    icon: const Icon(Icons.add),
                    label: const Text('הוסף'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.green,
                      elevation: 0,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ..._availableTreatmentTypes.map((treatment) => _buildTreatmentTypeItem(treatment)),
          ],
        ),
      ),
    );
  }

  Widget _buildTreatmentTypeItem(TreatmentTypeModel treatment) {
    final isSelected = _selectedTreatmentTypes.any((t) => t.id == treatment.id);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(treatment.name),
        subtitle: Text('${treatment.description} - ${treatment.duration.inMinutes} דקות - ₪${treatment.price}'),
        leading: Checkbox(
          value: isSelected,
          onChanged: (value) {
            setState(() {
              if (value == true) {
                _selectedTreatmentTypes.add(treatment);
              } else {
                _selectedTreatmentTypes.removeWhere((t) => t.id == treatment.id);
              }
            });
          },
        ),
        trailing: _isEditingTreatmentTypes
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _editTreatmentType(treatment),
                    tooltip: 'עריכה',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteTreatmentType(treatment),
                    tooltip: 'מחיקה',
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildBreakPeriodsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Text('הפסקות', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _isEditingBreakPeriods
                      ? () {
                          setState(() {
                            _isEditingBreakPeriods = false;
                          });
                          _saveBreakPeriodsChanges();
                        }
                      : () {
                          setState(() {
                            _isEditingBreakPeriods = true;
                          });
                        },
                  icon: Icon(_isEditingBreakPeriods ? Icons.save : Icons.edit),
                  label: Text(_isEditingBreakPeriods ? 'שמור' : 'עריכה'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.blue,
                    elevation: 0,
                  ),
                ),
                const SizedBox(width: 8),
                if (_isEditingBreakPeriods)
                  ElevatedButton.icon(
                    onPressed: _addBreakPeriod,
                    icon: const Icon(Icons.add),
                    label: const Text('הוסף'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.green,
                      elevation: 0,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ..._breakPeriods.map((breakPeriod) => _buildBreakPeriodItem(breakPeriod)),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakPeriodItem(BreakPeriodModel breakPeriod) {
    final isSelected = _selectedBreakPeriods.any((bp) => bp.id == breakPeriod.id);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(breakPeriod.name),
        subtitle: Text('${breakPeriod.startTime.hour}:${breakPeriod.startTime.minute.toString().padLeft(2, '0')} - ${breakPeriod.endTime.hour}:${breakPeriod.endTime.minute.toString().padLeft(2, '0')}'),
        leading: Checkbox(
          value: isSelected,
          onChanged: (value) {
            setState(() {
              if (value == true) {
                _selectedBreakPeriods.add(breakPeriod);
              } else {
                _selectedBreakPeriods.removeWhere((bp) => bp.id == breakPeriod.id);
              }
            });
          },
        ),
        trailing: _isEditingBreakPeriods
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _editBreakPeriod(breakPeriod),
                    tooltip: 'עריכה',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteBreakPeriod(breakPeriod),
                    tooltip: 'מחיקה',
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('אישור תורים אוטומטי'),
              subtitle: const Text('תורים יאושרו אוטומטית ללא צורך באישור ידני'),
              value: _autoApproveAppointments,
              onChanged: (value) {
                setState(() {
                  _autoApproveAppointments = value;
                });
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('זמן תשלום'),
              subtitle: Text(_paymentTiming == PaymentTiming.atBooking ? 'בזמן הזמנה' : 'לאחר הטיפול'),
              trailing: DropdownButton<PaymentTiming>(
                value: _paymentTiming,
                onChanged: (value) {
                  setState(() {
                    _paymentTiming = value!;
                  });
                },
                items: PaymentTiming.values.map((timing) {
                  return DropdownMenuItem(
                    value: timing,
                    child: Text(timing == PaymentTiming.atBooking ? 'בזמן הזמנה' : 'לאחר הטיפול'),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveSettings,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          'שמור הגדרות',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  void _saveSettings() {
    // Save settings logic would go here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('הגדרות נשמרו בהצלחה'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Treatment Type Management Functions
  void _addTreatmentType() {
    _showTreatmentTypeDialog();
  }

  void _editTreatmentType(TreatmentTypeModel treatment) {
    _showTreatmentTypeDialog(treatment: treatment);
  }

  void _deleteTreatmentType(TreatmentTypeModel treatment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('מחיקת סוג טיפול'),
        content: Text('האם אתה בטוח שברצונך למחוק את "${treatment.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ביטול'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _availableTreatmentTypes.removeWhere((t) => t.id == treatment.id);
                _selectedTreatmentTypes.removeWhere((t) => t.id == treatment.id);
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${treatment.name} נמחק בהצלחה'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('מחק'),
          ),
        ],
      ),
    );
  }

  void _showTreatmentTypeDialog({TreatmentTypeModel? treatment}) {
    final nameController = TextEditingController(text: treatment?.name ?? '');
    final descriptionController = TextEditingController(text: treatment?.description ?? '');
    final durationController = TextEditingController(text: treatment?.duration.inMinutes.toString() ?? '30');
    final priceController = TextEditingController(text: treatment?.price.toString() ?? '200');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(treatment == null ? 'הוסף סוג טיפול' : 'ערוך סוג טיפול'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'שם הטיפול',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'תיאור',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(
                  labelText: 'משך בדקות',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'מחיר (₪)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
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
            onPressed: () {
              final newTreatment = TreatmentTypeModel(
                id: treatment?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameController.text,
                description: descriptionController.text,
                duration: Duration(minutes: int.tryParse(durationController.text) ?? 30),
                price: double.tryParse(priceController.text) ?? 200.0,
                isActive: true,
              );

              setState(() {
                if (treatment == null) {
                  _availableTreatmentTypes.add(newTreatment);
                } else {
                  final index = _availableTreatmentTypes.indexWhere((t) => t.id == treatment.id);
                  if (index != -1) {
                    _availableTreatmentTypes[index] = newTreatment;
                  }
                }
              });

              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(treatment == null ? 'סוג טיפול נוסף בהצלחה' : 'סוג טיפול עודכן בהצלחה'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text(treatment == null ? 'הוסף' : 'עדכן'),
          ),
        ],
      ),
    );
  }

  // Break Period Management Functions
  void _addBreakPeriod() {
    _showBreakPeriodDialog();
  }

  void _editBreakPeriod(BreakPeriodModel breakPeriod) {
    _showBreakPeriodDialog(breakPeriod: breakPeriod);
  }

  void _deleteBreakPeriod(BreakPeriodModel breakPeriod) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('מחיקת הפסקה'),
        content: Text('האם אתה בטוח שברצונך למחוק את "${breakPeriod.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ביטול'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _breakPeriods.removeWhere((bp) => bp.id == breakPeriod.id);
                _selectedBreakPeriods.removeWhere((bp) => bp.id == breakPeriod.id);
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${breakPeriod.name} נמחק בהצלחה'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('מחק'),
          ),
        ],
      ),
    );
  }

  void _showBreakPeriodDialog({BreakPeriodModel? breakPeriod}) {
    final nameController = TextEditingController(text: breakPeriod?.name ?? '');
    TimeOfDay startTime = breakPeriod?.startTime != null 
        ? TimeOfDay.fromDateTime(breakPeriod!.startTime)
        : const TimeOfDay(hour: 12, minute: 0);
    TimeOfDay endTime = breakPeriod?.endTime != null 
        ? TimeOfDay.fromDateTime(breakPeriod!.endTime)
        : const TimeOfDay(hour: 13, minute: 0);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(breakPeriod == null ? 'הוסף הפסקה' : 'ערוך הפסקה'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'שם ההפסקה',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('שעת התחלה'),
                  subtitle: Text('${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}'),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: startTime,
                    );
                    if (picked != null) {
                      setDialogState(() {
                        startTime = picked;
                      });
                    }
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  title: const Text('שעת סיום'),
                  subtitle: Text('${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}'),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: endTime,
                    );
                    if (picked != null) {
                      setDialogState(() {
                        endTime = picked;
                      });
                    }
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
              onPressed: () {
                final newBreakPeriod = BreakPeriodModel(
                  id: breakPeriod?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  startTime: DateTime(2024, 1, 1, startTime.hour, startTime.minute),
                  endTime: DateTime(2024, 1, 1, endTime.hour, endTime.minute),
                  daysOfWeek: [1, 2, 3, 4, 5], // Monday to Friday
                  isRecurring: true,
                );

                setState(() {
                  if (breakPeriod == null) {
                    _breakPeriods.add(newBreakPeriod);
                  } else {
                    final index = _breakPeriods.indexWhere((bp) => bp.id == breakPeriod.id);
                    if (index != -1) {
                      _breakPeriods[index] = newBreakPeriod;
                    }
                  }
                });

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(breakPeriod == null ? 'הפסקה נוספה בהצלחה' : 'הפסקה עודכנה בהצלחה'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text(breakPeriod == null ? 'הוסף' : 'עדכן'),
            ),
          ],
        ),
      ),
    );
  }
}
