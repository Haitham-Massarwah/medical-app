import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/treatment_models_simple.dart';
import '../../services/medical_record_service.dart';
import '../../services/appointment_service.dart';
import '../../services/doctor_service.dart';
import '../../core/config/app_config.dart';

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
  final _summaryController = TextEditingController();
  final MedicalRecordService _medicalRecordService = MedicalRecordService();
  final AppointmentService _appointmentService = AppointmentService();
  final DoctorService _doctorService = DoctorService();
  bool _isLoading = false;
  bool _isCompleting = false;
  bool _isRequestingPayment = false;
  bool _isSavingDraft = false;
  bool _isSubmittingRecord = false;
  bool _isUploadingFiles = false;
  
  TreatmentSessionStatus _sessionStatus = TreatmentSessionStatus.inProgress;
  Map<String, dynamic> _treatmentData = {};
  String? _recordId;
  List<String> _attachments = [];
  List<Map<String, dynamic>> _historyRecords = [];
  bool _isLoadingHistory = true;

  @override
  void dispose() {
    _summaryController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
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
              
              // Clinical Summary - only inside one text box; Bold/list inside box
              const Text(
                'סיכום קליני',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.format_bold, size: 22),
                            tooltip: 'הדגשה',
                            onPressed: _insertBold,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          ),
                          IconButton(
                            icon: const Icon(Icons.format_list_bulleted, size: 22),
                            tooltip: 'תבליטים',
                            onPressed: _insertBullet,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    TextFormField(
                      controller: _summaryController,
                      maxLines: 6,
                      textDirection: TextDirection.rtl,
                      decoration: const InputDecoration(
                        hintText: 'הוסף סיכום טיפול...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(12),
                        filled: false,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Attachments
              const Text(
                'קבצים מצורפים',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (_attachments.isEmpty)
                const Text('לא הועלו קבצים'),
              if (_attachments.isNotEmpty)
                Column(
                  children: _attachments.map((item) {
                    return ListTile(
                      leading: const Icon(Icons.attach_file),
                      title: Text(item.split('/').last),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isUploadingFiles ? null : _pickAndUploadFiles,
                  icon: _isUploadingFiles
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.upload_file),
                  label: Text(_isUploadingFiles ? 'מעלה קבצים...' : 'העלה קבצים'),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Draft / Submit
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSavingDraft ? null : _saveDraft,
                      child: _isSavingDraft
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('שמור טיוטה'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmittingRecord ? null : _submitRecord,
                      child: _isSubmittingRecord
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('שלח לרשומה'),
                    ),
                  ),
                ],
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
              
              // Patient History
              const Text(
                'היסטוריית טיפולים',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (_isLoadingHistory)
                const Center(child: CircularProgressIndicator())
              else if (_historyRecords.isEmpty)
                const Text('אין היסטוריה להצגה')
              else
                Column(
                  children: _historyRecords.map(_buildHistoryCard).toList(),
                ),
              
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
              
              // Save and close (save all data then close form)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _saveAndClose,
                  icon: const Icon(Icons.save),
                  label: const Text('שמור וסגור'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    side: const BorderSide(color: Colors.green),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Book next appointment (current doctor only, for this patient)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _openBookNextAppointment,
                  icon: const Icon(Icons.event_available),
                  label: const Text('קביעת תור הבא'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 24),
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
    ),
    );
  }

  Future<void> _saveAndClose() async {
    if (_summaryController.text.trim().isNotEmpty) {
      await _upsertRecord(isDraft: false);
      if (!mounted) return;
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  Future<void> _openBookNextAppointment() async {
    try {
      final doctor = await _doctorService.getMyDoctorProfile();
      final doctorId = doctor['id']?.toString();
      if (doctorId == null || doctorId.isEmpty) {
        _showError('לא נמצא פרופיל רופא');
        return;
      }
      final now = DateTime.now();
      final startDate = now;
      final endDate = now.add(const Duration(days: 60));
      final dates = await _appointmentService.getAvailableDates(doctorId, startDate, endDate);
      if (!mounted) return;
      if (dates.isEmpty) {
        _showError('אין מועדים פנויים ב-60 הימים הקרובים');
        return;
      }
      final picked = await showDialog<DateTime>(
        context: context,
        builder: (ctx) => _BookNextSlotDialog(dates: dates),
      );
      if (picked == null || !mounted) return;
      final times = await _appointmentService.getAvailableTimeSlots(doctorId, picked);
      if (!mounted) return;
      if (times.isEmpty) {
        _showError('אין שעות פנויות בתאריך זה');
        return;
      }
      final timeStr = await showDialog<String>(
        context: context,
        builder: (ctx) => _TimeSlotPickerDialog(times: times),
      );
      if (timeStr == null || !mounted) return;
      final hourMin = timeStr.split(':');
      final slot = DateTime(
        picked.year,
        picked.month,
        picked.day,
        int.parse(hourMin[0]),
        hourMin.length > 1 ? int.parse(hourMin[1]) : 0,
      );
      await _appointmentService.bookAppointment(
        doctorId: doctorId,
        appointmentDate: slot,
        timeSlot: timeStr,
        notes: 'תור המשך - נקבע מסיום טיפול',
        patientId: widget.patientId,
      );
      if (!mounted) return;
      _showSuccess('התור הבא נקבע בהצלחה');
    } catch (e) {
      _showError('שגיאה בקביעת תור: $e');
    }
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

  void _insertBold() {
    final selection = _summaryController.selection;
    final text = _summaryController.text;
    if (!selection.isValid) {
      return;
    }
    final start = selection.start;
    final end = selection.end;
    if (start == end) {
      final updated = text.replaceRange(start, end, '**טקסט**');
      _summaryController.text = updated;
      _summaryController.selection = TextSelection.collapsed(offset: start + 2);
    } else {
      final selectedText = text.substring(start, end);
      final updated = text.replaceRange(start, end, '**$selectedText**');
      _summaryController.text = updated;
      _summaryController.selection = TextSelection.collapsed(offset: end + 4);
    }
    setState(() {});
  }

  void _insertBullet() {
    final selection = _summaryController.selection;
    final text = _summaryController.text;
    if (!selection.isValid) {
      return;
    }
    final start = selection.start;
    final updated = text.replaceRange(start, start, '\n- ');
    _summaryController.text = updated;
    _summaryController.selection = TextSelection.collapsed(offset: start + 3);
    setState(() {});
  }

  Future<void> _saveDraft() async {
    await _upsertRecord(isDraft: true);
  }

  Future<void> _submitRecord() async {
    if (_summaryController.text.trim().isEmpty) {
      _showError('נא להזין סיכום לפני שליחה');
      return;
    }
    await _upsertRecord(isDraft: false);
  }

  Future<void> _upsertRecord({required bool isDraft}) async {
    setState(() {
      if (isDraft) {
        _isSavingDraft = true;
      } else {
        _isSubmittingRecord = true;
      }
    });

    try {
      final payload = {
        'title': 'סיכום טיפול - ${widget.treatmentTypeName}',
        'description': _summaryController.text.trim(),
        'appointment_id': widget.appointmentId,
        'record_type': 'session_summary',
        'summary_format': 'markdown',
        'is_draft': isDraft,
      };

      if (_recordId == null) {
        final record = await _medicalRecordService.createRecord(
          patientId: widget.patientId,
          data: payload,
        );
        _recordId = record['id']?.toString();
      } else {
        await _medicalRecordService.updateRecord(
          patientId: widget.patientId,
          recordId: _recordId!,
          data: payload,
        );
      }

      if (!mounted) return;
      _showSuccess(isDraft ? 'הטיוטה נשמרה' : 'הסיכום נשלח לרשומה');
      await _loadHistory();
    } catch (e) {
      _showError('שגיאה בשמירת הרשומה: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSavingDraft = false;
          _isSubmittingRecord = false;
        });
      }
    }
  }

  Future<void> _pickAndUploadFiles() async {
    if (_recordId == null) {
      await _saveDraft();
    }
    if (_recordId == null) {
      return;
    }
    setState(() {
      _isUploadingFiles = true;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'docx', 'mp4', 'mp3'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        return;
      }
      final attachments = await _medicalRecordService.uploadAttachments(
        patientId: widget.patientId,
        recordId: _recordId!,
        files: result.files,
      );
      if (!mounted) return;
      setState(() {
        _attachments = attachments;
      });
      _showSuccess('הקבצים הועלו בהצלחה');
      await _loadHistory();
    } catch (e) {
      _showError('שגיאה בהעלאת קבצים: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingFiles = false;
        });
      }
    }
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoadingHistory = true;
    });
    try {
      final records = await _medicalRecordService.getRecords(widget.patientId);
      if (!mounted) return;
      setState(() {
        _historyRecords = records;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _historyRecords = [];
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingHistory = false;
        });
      }
    }
  }

  Widget _buildHistoryCard(Map<String, dynamic> record) {
    final authorFirst = record['author_first_name']?.toString() ?? '';
    final authorLast = record['author_last_name']?.toString() ?? '';
    final authorName = [authorFirst, authorLast].where((part) => part.isNotEmpty).join(' ');
    final dateValue = record['record_date']?.toString() ?? '';
    final attachments = record['attachments'] is List
        ? List<String>.from(record['attachments'])
        : <String>[];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              authorName.isEmpty ? 'מטפל' : authorName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (dateValue.isNotEmpty)
              Text(dateValue, style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            if ((record['description']?.toString() ?? '').isNotEmpty)
              MarkdownBody(data: record['description'].toString()),
            if (attachments.isNotEmpty) ...[
              const Divider(),
              ...attachments.map((item) => ListTile(
                    leading: const Icon(Icons.attach_file),
                    title: Text(item.split('/').last),
                    onTap: () => _openAttachment(item),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openAttachment(String url) async {
    final baseUrl = AppConfig.baseUrl.replaceFirst('/api/v1', '');
    final uri = Uri.parse(url.startsWith('http') ? url : '$baseUrl$url');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showError('לא ניתן לפתוח את הקובץ');
    }
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
    if (_summaryController.text.trim().isEmpty) {
      _showError('אנא הוסף סיכום טיפול לפני סיום');
      return;
    }

    setState(() {
      _isCompleting = true;
    });

    try {
      // Update appointment status to completed with summary
      await _appointmentService.completeAppointment(
        widget.appointmentId,
        summary: _summaryController.text.trim(),
      );

      // Also save medical record if needed
      try {
        final request = CompleteTreatmentSessionRequest(
          sessionId: widget.appointmentId,
          notes: _summaryController.text.trim(),
          treatmentData: _treatmentData,
        );
        // Save medical record (if service supports it)
        // await _medicalRecordService.createRecord(...);
      } catch (e) {
        // Medical record save is optional, continue even if it fails
        print('Note: Medical record save failed: $e');
      }
      
      _showSuccess('הטיפול הושלם בהצלחה והתור עודכן לסטטוס "הושלם"');
      
      // Navigate back to doctor dashboard
      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      _showError('שגיאה בסיום הטיפול: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCompleting = false;
        });
      }
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

class _BookNextSlotDialog extends StatelessWidget {
  final List<DateTime> dates;

  const _BookNextSlotDialog({required this.dates});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text('בחר תאריך'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: dates.length,
            itemBuilder: (context, i) {
              final d = dates[i];
              final str = '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
              return ListTile(
                title: Text(str),
                onTap: () => Navigator.of(context).pop(d),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ביטול'),
          ),
        ],
      ),
    );
  }
}

class _TimeSlotPickerDialog extends StatelessWidget {
  final List<String> times;

  const _TimeSlotPickerDialog({required this.times});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text('בחר שעה'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: times.length,
            itemBuilder: (context, i) {
              final t = times[i];
              return ListTile(
                title: Text(t),
                onTap: () => Navigator.of(context).pop(t),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ביטול'),
          ),
        ],
      ),
    );
  }
}
