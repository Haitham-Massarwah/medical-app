import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:medical_appointment_system/core/utils/error_handler.dart';

import '../../services/appointment_service.dart';
import '../../services/doctor_service.dart';

class DoctorCalendarPage extends StatefulWidget {
  const DoctorCalendarPage({super.key});

  @override
  State<DoctorCalendarPage> createState() => _DoctorCalendarPageState();
}

class _DoctorCalendarPageState extends State<DoctorCalendarPage> {
  final AppointmentService _appointmentService = AppointmentService();
  final DoctorService _doctorService = DoctorService();
  final List<String> _dayNames = const [
    'ראשון',
    'שני',
    'שלישי',
    'רביעי',
    'חמישי',
    'שישי',
    'שבת',
  ];

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  bool _loading = true;
  bool _saving = false;
  String _doctorId = '';

  final Map<int, Map<String, String>> _workingHours = {};
  List<Map<String, Object>> _breaks = [];
  List<Map<String, Object>> _timeOff = [];
  final Map<DateTime, List<Map<String, dynamic>>> _appointmentsByDate = {};
  String? _resendingNotificationAppointmentId;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 7; i++) {
      _workingHours[i] = {'start': '', 'end': ''};
    }
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final doctor = await _doctorService.getMyDoctorProfile();
      _doctorId = (doctor['id'] ?? '').toString();
      if (_doctorId.isEmpty) {
        throw Exception('לא נמצא מזהה רופא');
      }
      await Future.wait([_loadSchedule(), _loadAppointments()]);
    } catch (e) {
      if (!mounted) return;
      ErrorHandler.showSnackBarAsDialog(context, 
        SnackBar(content: Text('שגיאה בטעינת נתוני יומן: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadSchedule() async {
    final data = await _doctorService.getScheduleSettings(_doctorId);
    final hours = (data['working_hours'] as List?)?.cast<Map>() ?? <Map>[];
    final breaks = (data['breaks'] as List?)?.cast<Map>() ?? <Map>[];
    final timeOff = (data['time_off'] as List?)?.cast<Map>() ?? <Map>[];

    for (int i = 0; i < 7; i++) {
      _workingHours[i] = {'start': '', 'end': ''};
    }
    for (final row in hours) {
      final day = int.tryParse('${row['day_of_week']}') ?? -1;
      if (day < 0 || day > 6) continue;
      _workingHours[day] = {
        'start': (row['start_time'] ?? '').toString().substring(0, 5),
        'end': (row['end_time'] ?? '').toString().substring(0, 5),
      };
    }

    _breaks = breaks
        .map(
          (e) => <String, Object>{
            'day_of_week': int.tryParse('${e['day_of_week']}') ?? 0,
            'start_time': (e['start_time'] ?? '').toString().substring(0, 5),
            'end_time': (e['end_time'] ?? '').toString().substring(0, 5),
          },
        )
        .toList();
    _breaks = _dedupeBreaks(_breaks);

    _timeOff = timeOff
        .map(
          (e) => <String, Object>{
            'start_date': _normalizeIncomingDate((e['start_date'] ?? '').toString()),
            'end_date': _normalizeIncomingDate((e['end_date'] ?? '').toString()),
            'reason': (e['reason'] ?? '').toString(),
            'is_holiday': e['is_holiday'] == true,
          },
        )
        .toList();
    _timeOff = _mergeTimeOffAfterLoad(_timeOff);
  }

  Future<void> _loadAppointments() async {
    final appointments = await _appointmentService.getAppointments();
    _appointmentsByDate.clear();
    for (final item in appointments) {
      final date = DateTime.tryParse((item['appointment_date'] ?? '').toString());
      if (date == null) continue;
      final key = DateTime(date.year, date.month, date.day);
      _appointmentsByDate.putIfAbsent(key, () => []).add(Map<String, dynamic>.from(item));
    }
  }

  List<Map<String, dynamic>> _appointmentsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _appointmentsByDate[key] ?? <Map<String, dynamic>>[];
  }

  String _calendarPatientName(Map<String, dynamic> apt) {
    final n = '${apt['patientName'] ?? apt['patient_name'] ?? apt['guest_name'] ?? ''}'.trim();
    if (n.isNotEmpty) return n;
    return 'מטופל';
  }

  String? _calendarPatientPhone(Map<String, dynamic> apt) {
    final p = '${apt['patientPhone'] ?? apt['patient_phone'] ?? apt['guest_phone'] ?? ''}'.trim();
    return p.isEmpty ? null : p;
  }

  Future<void> _resendPatientNotification(Map<String, dynamic> apt) async {
    final id = (apt['id'] ?? '').toString();
    if (id.isEmpty) return;
    setState(() => _resendingNotificationAppointmentId = id);
    try {
      await _appointmentService.resendPatientNotification(id);
      if (!mounted) return;
      ErrorHandler.showSnackBarAsDialog(
        context,
        const SnackBar(
          content: Text('ההודעה למטופל נשלחה מחדש'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ErrorHandler.showSnackBarAsDialog(
        context,
        SnackBar(
          content: Text('שליחה חוזרת נכשלה: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _resendingNotificationAppointmentId = null);
    }
  }

  bool _isBlockedDay(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    for (final off in _timeOff) {
      final s = _parseYmdLocal((off['start_date'] ?? '').toString());
      final e = _parseYmdLocal((off['end_date'] ?? '').toString());
      if (!d.isBefore(s) && !d.isAfter(e)) return true;
    }
    return false;
  }

  /// Calendar cell color: `true` = holiday, `false` = vacation, `null` = none.
  bool? _timeOffKindForDay(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    var hasHoliday = false;
    var hasVacation = false;
    for (final off in _timeOff) {
      final s = _parseYmdLocal((off['start_date'] ?? '').toString());
      final e = _parseYmdLocal((off['end_date'] ?? '').toString());
      if (d.isBefore(s) || d.isAfter(e)) continue;
      if (off['is_holiday'] == true) {
        hasHoliday = true;
      } else {
        hasVacation = true;
      }
    }
    if (hasHoliday) return true;
    if (hasVacation) return false;
    return null;
  }

  Future<void> _pickTime(int day, String key) async {
    final initial = (_workingHours[day]?[key] ?? '').split(':');
    final initialTime = initial.length == 2
        ? TimeOfDay(hour: int.tryParse(initial[0]) ?? 9, minute: int.tryParse(initial[1]) ?? 0)
        : const TimeOfDay(hour: 9, minute: 0);
    final picked = await showTimePicker(context: context, initialTime: initialTime);
    if (picked == null) return;
    setState(() {
      _workingHours[day]![key] = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    });
  }

  Future<bool> _saveSchedule() async {
    setState(() => _saving = true);
    try {
      final workingHours = <Map<String, dynamic>>[];
      for (int i = 0; i < 7; i++) {
        final start = _workingHours[i]?['start'] ?? '';
        final end = _workingHours[i]?['end'] ?? '';
        if (start.isNotEmpty && end.isNotEmpty) {
          workingHours.add({'day_of_week': i, 'start_time': start, 'end_time': end});
        }
      }
      final sanitizedBreaks = _dedupeBreaks(_breaks);
      final sanitizedTimeOff = _mergeTimeOffAfterLoad(_timeOff);
      await _doctorService.saveScheduleSettings(
        _doctorId,
        workingHours: workingHours,
        breaks: sanitizedBreaks.map((e) => Map<String, dynamic>.from(e)).toList(),
        timeOff: sanitizedTimeOff.map((e) => Map<String, dynamic>.from(e)).toList(),
      );
      if (!mounted) return false;
      ErrorHandler.showSnackBarAsDialog(context, 
        const SnackBar(content: Text('הגדרות היומן נשמרו בהצלחה'), backgroundColor: Colors.green),
      );
      await _loadData();
      return true;
    } catch (e) {
      if (!mounted) return false;
      ErrorHandler.showSnackBarAsDialog(context, 
        SnackBar(content: Text('שגיאה בשמירת הגדרות: $e'), backgroundColor: Colors.red),
      );
      return false;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _addBreakDialog() async {
    int day = _selectedDay.weekday % 7;
    String start = '12:00';
    String end = '13:00';
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text('הוספת הפסקה'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: day,
                items: List.generate(7, (i) => DropdownMenuItem(value: i, child: Text(_dayNames[i]))),
                onChanged: (v) => setStateDialog(() => day = v ?? 0),
                decoration: const InputDecoration(labelText: 'יום'),
              ),
              const SizedBox(height: 8),
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text('שעת התחלה: $start'),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final parts = start.split(':');
                  final picked = await showTimePicker(
                    context: ctx,
                    initialTime: TimeOfDay(
                      hour: int.tryParse(parts[0]) ?? 12,
                      minute: int.tryParse(parts[1]) ?? 0,
                    ),
                  );
                  if (picked == null) return;
                  setStateDialog(() {
                    start =
                        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                  });
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text('שעת סיום: $end'),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final parts = end.split(':');
                  final picked = await showTimePicker(
                    context: ctx,
                    initialTime: TimeOfDay(
                      hour: int.tryParse(parts[0]) ?? 13,
                      minute: int.tryParse(parts[1]) ?? 0,
                    ),
                  );
                  if (picked == null) return;
                  setStateDialog(() {
                    end =
                        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ביטול')),
            ElevatedButton(
              onPressed: () async {
                final startMin = _timeToMinutes(start);
                final endMin = _timeToMinutes(end);
                if (startMin == null || endMin == null || endMin <= startMin) {
                  ErrorHandler.showSnackBarAsDialog(context, 
                    const SnackBar(
                      content: Text('יש להזין טווח הפסקה תקין (שעת סיום אחרי התחלה)'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                if (_hasBreakDuplicate(day, start, end)) {
                  ErrorHandler.showSnackBarAsDialog(context, 
                    const SnackBar(
                      content: Text('הפסקה זהה כבר קיימת'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                setState(() {
                  _breaks.add(<String, Object>{'day_of_week': day, 'start_time': start, 'end_time': end});
                });
                final saved = await _saveSchedule();
                if (mounted && saved) {
                  Navigator.pop(ctx);
                }
              },
              child: const Text('הוסף'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addTimeOffDialog() async {
    DateTime start = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    DateTime end = start.add(const Duration(days: 1));
    bool holiday = false;
    bool endDateManuallyChanged = false;
    final reasonController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text('הוספת חופשה/חג'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('מתאריך: ${_formatLocalYmd(start)}'),
                trailing: const Icon(Icons.date_range),
                onTap: () async {
                  final d = await showDatePicker(
                    context: ctx,
                    initialDate: start,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                  );
                  if (d != null) {
                    setStateDialog(() {
                      start = d;
                      if (!endDateManuallyChanged) {
                        end = d.add(const Duration(days: 1));
                      } else if (end.isBefore(d)) {
                        end = d;
                      }
                    });
                  }
                },
              ),
              ListTile(
                title: Text('עד תאריך: ${_formatLocalYmd(end)}'),
                trailing: const Icon(Icons.date_range),
                onTap: () async {
                  final d = await showDatePicker(
                    context: ctx,
                    initialDate: end,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                  );
                  if (d != null) {
                    setStateDialog(() {
                      end = d;
                      endDateManuallyChanged = true;
                    });
                  }
                },
              ),
              SwitchListTile(
                value: holiday,
                onChanged: (v) => setStateDialog(() => holiday = v),
                title: const Text('האם מדובר בחג'),
              ),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(labelText: 'הערה/סיבה'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ביטול')),
            ElevatedButton(
              onPressed: () async {
                if (end.isBefore(start)) {
                  ErrorHandler.showSnackBarAsDialog(context, 
                    const SnackBar(
                      content: Text('תאריך סיום חייב להיות אחרי תאריך התחלה'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                final startDate = _formatLocalYmd(start);
                final endDate = _formatLocalYmd(end);
                final reason = reasonController.text.trim();
                if (_hasExactSameRangeOppositeType(startDate, endDate, holiday)) {
                  Navigator.pop(ctx);
                  if (!mounted) return;
                  final choice = await showDialog<bool>(
                    context: context,
                    builder: (c2) => AlertDialog(
                      title: const Text('תקופה כבר קיימת'),
                      content: Text(
                        'בתאריכים $startDate עד $endDate כבר קיימת הגדרה מסוג '
                        '${holiday ? 'חופשה' : 'חג'}. בחר את הסוג הרצוי:',
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(c2), child: const Text('ביטול')),
                        TextButton(onPressed: () => Navigator.pop(c2, false), child: const Text('חופשה')),
                        TextButton(onPressed: () => Navigator.pop(c2, true), child: const Text('חג')),
                      ],
                    ),
                  );
                  if (!mounted || choice == null) return;
                  setState(() {
                    _timeOff.removeWhere(
                      (e) =>
                          _normalizeIncomingDate((e['start_date'] ?? '').toString()) == startDate &&
                          _normalizeIncomingDate((e['end_date'] ?? '').toString()) == endDate,
                    );
                    _timeOff.add(<String, Object>{
                      'start_date': startDate,
                      'end_date': endDate,
                      'reason': reason,
                      'is_holiday': choice,
                    });
                    _timeOff = _mergeTimeOffAfterLoad(_timeOff);
                  });
                  await _saveSchedule();
                  return;
                }
                setState(() {
                  _timeOff = _integrateTimeOffRange(_timeOff, startDate, endDate, holiday, reason);
                });
                final saved = await _saveSchedule();
                if (mounted && saved) {
                  Navigator.pop(ctx);
                }
              },
              child: const Text('הוסף'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dayAppointments = _appointmentsForDay(_selectedDay);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('יומן רופא'),
          actions: [
            IconButton(onPressed: _loadData, icon: const Icon(Icons.refresh), tooltip: 'רענון'),
            IconButton(
              onPressed: _saving
                  ? null
                  : () async {
                      await _saveSchedule();
                    },
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save),
              tooltip: 'שמירת הגדרות',
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: TableCalendar<Map<String, dynamic>>(
                          firstDay: DateTime.utc(2020, 1, 1),
                          lastDay: DateTime.utc(2035, 12, 31),
                          focusedDay: _focusedDay,
                          calendarFormat: _calendarFormat,
                          eventLoader: _appointmentsForDay,
                          selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                          enabledDayPredicate: (day) => !_isBlockedDay(day),
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                            });
                          },
                          onFormatChanged: (format) => setState(() => _calendarFormat = format),
                          calendarBuilders: CalendarBuilders<Map<String, dynamic>>(
                            defaultBuilder: (context, day, focusedDay) {
                              final kind = _timeOffKindForDay(day);
                              if (kind == null) return null;
                              final isSelected = isSameDay(day, _selectedDay);
                              final bg = kind
                                  ? Colors.deepOrange.shade100
                                  : Colors.blueGrey.shade200;
                              return Container(
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: bg,
                                  shape: BoxShape.circle,
                                  border: isSelected ? Border.all(color: Colors.blue, width: 2) : null,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${day.day}',
                                  style: TextStyle(
                                    color: _isBlockedDay(day) ? Colors.grey.shade700 : null,
                                  ),
                                ),
                              );
                            },
                          ),
                          calendarStyle: const CalendarStyle(
                            disabledTextStyle: TextStyle(color: Colors.grey),
                            holidayTextStyle: TextStyle(color: Colors.red),
                            weekendTextStyle: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('שעות עבודה לפי יום', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            ...List.generate(7, (i) {
                              final start = _workingHours[i]?['start'] ?? '';
                              final end = _workingHours[i]?['end'] ?? '';
                              final active = start.isNotEmpty && end.isNotEmpty;
                              return Row(
                                children: [
                                  SizedBox(width: 70, child: Text(_dayNames[i])),
                                  Switch(
                                    value: active,
                                    onChanged: (v) {
                                      setState(() {
                                        if (!v) {
                                          _workingHours[i] = {'start': '', 'end': ''};
                                        } else {
                                          _workingHours[i] = {'start': '09:00', 'end': '17:00'};
                                        }
                                      });
                                    },
                                  ),
                                  Expanded(
                                    child: Text(active ? '$start - $end' : 'לא עובד'),
                                  ),
                                  IconButton(
                                    onPressed: active
                                        ? () async {
                                            await _pickTime(i, 'start');
                                            await _pickTime(i, 'end');
                                          }
                                        : null,
                                    icon: const Icon(Icons.access_time),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  child: Text('הפסקות', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                ),
                                TextButton.icon(
                                  onPressed: _addBreakDialog,
                                  icon: const Icon(Icons.add),
                                  label: const Text('הוסף הפסקה'),
                                ),
                              ],
                            ),
                            if (_breaks.isEmpty) const Text('לא הוגדרו הפסקות'),
                            ..._breaks.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final b = entry.value;
                              return ListTile(
                                title: Text('${_dayNames[b['day_of_week'] as int]} ${b['start_time']} - ${b['end_time']}'),
                                trailing: IconButton(
                                  onPressed: () => setState(() => _breaks.removeAt(idx)),
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  child: Text('חגים וחופשות', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                ),
                                TextButton.icon(
                                  onPressed: _addTimeOffDialog,
                                  icon: const Icon(Icons.add),
                                  label: const Text('הוסף'),
                                ),
                              ],
                            ),
                            if (_timeOff.isEmpty) const Text('לא הוגדרו חגים/חופשות'),
                            ..._timeOff.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final item = entry.value;
                              final startDate = _normalizeIncomingDate((item['start_date'] ?? '').toString());
                              final endDate = _normalizeIncomingDate((item['end_date'] ?? '').toString());
                              final title =
                                  '$startDate עד $endDate ${item['is_holiday'] == true ? '(חג)' : '(חופשה)'}';
                              final subtitle = (item['reason'] ?? '').toString();
                              return ListTile(
                                title: Text(title),
                                subtitle: subtitle.isEmpty ? null : Text(subtitle),
                                trailing: IconButton(
                                  onPressed: () => setState(() => _timeOff.removeAt(idx)),
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'תורים בתאריך ${_formatLocalYmd(_selectedDay)}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            if (dayAppointments.isEmpty) const Text('אין תורים ליום זה'),
                            ...dayAppointments.map((apt) {
                              final dt = DateTime.tryParse((apt['appointment_date'] ?? '').toString());
                              final local = dt?.toLocal();
                              final time = local == null
                                  ? '--:--'
                                  : '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
                              final name = _calendarPatientName(apt);
                              final phone = _calendarPatientPhone(apt);
                              final status = (apt['status'] ?? 'scheduled').toString();
                              final aid = (apt['id'] ?? '').toString();
                              final busy = _resendingNotificationAppointmentId == aid;
                              return ListTile(
                                leading: const Icon(Icons.event_note),
                                title: Text(name),
                                subtitle: Text(
                                  [
                                    time,
                                    if (phone != null) '☎ $phone',
                                    'סטטוס: $status',
                                  ].join(' • '),
                                ),
                                isThreeLine: phone != null,
                                trailing: IconButton(
                                  tooltip: 'שלח הודעה שוב למטופל',
                                  onPressed:
                                      busy || aid.isEmpty ? null : () => _resendPatientNotification(apt),
                                  icon: busy
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Icon(Icons.send_outlined),
                                ),
                              );
                            }),
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

  int? _timeToMinutes(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    if (h < 0 || h > 23 || m < 0 || m > 59) return null;
    return h * 60 + m;
  }

  /// Calendar date string from local [DateTime] (no UTC shift).
  String _formatLocalYmd(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  /// Parse API / DB value to a **local calendar** date (fixes `T…Z` off-by-one).
  String _normalizeIncomingDate(String raw) {
    return _formatLocalYmd(_parseYmdLocal(raw));
  }

  DateTime _parseYmdLocal(String raw) {
    final t = raw.trim();
    if (t.length >= 10 && !t.contains('T') && !t.contains(' ')) {
      final core = t.substring(0, 10);
      final p = core.split('-');
      if (p.length == 3) {
        final y = int.tryParse(p[0]);
        final m = int.tryParse(p[1]);
        final d = int.tryParse(p[2]);
        if (y != null && m != null && d != null) return DateTime(y, m, d);
      }
    }
    final dt = DateTime.tryParse(t);
    if (dt == null) return DateTime(1970);
    final l = dt.toLocal();
    return DateTime(l.year, l.month, l.day);
  }

  bool _hasExactSameRangeOppositeType(String startYmd, String endYmd, bool newHoliday) {
    return _timeOff.any((e) {
      final s = _normalizeIncomingDate((e['start_date'] ?? '').toString());
      final en = _normalizeIncomingDate((e['end_date'] ?? '').toString());
      final h = e['is_holiday'] == true;
      return s == startYmd && en == endYmd && h != newHoliday;
    });
  }

  List<Map<String, Object>> _integrateTimeOffRange(
    List<Map<String, Object>> current,
    String newStartYmd,
    String newEndYmd,
    bool newHoliday,
    String reason,
  ) {
    final ns = _parseYmdLocal(newStartYmd);
    final ne = _parseYmdLocal(newEndYmd);
    final merged = <_OffSeg>[];
    for (final m in current) {
      merged.add(
        _OffSeg(
          _parseYmdLocal((m['start_date'] ?? '').toString()),
          _parseYmdLocal((m['end_date'] ?? '').toString()),
          m['is_holiday'] == true,
          (m['reason'] ?? '').toString(),
        ),
      );
    }
    final afterSubtract = <_OffSeg>[];
    for (final e in merged) {
      if (e.isHoliday == newHoliday) {
        afterSubtract.add(e);
        continue;
      }
      afterSubtract.addAll(_subtractInclusive(e, ns, ne));
    }
    final withoutOverlapSame = afterSubtract
        .where((e) => e.isHoliday != newHoliday || !_rangesOverlapInclusive(e.start, e.end, ns, ne))
        .toList();
    withoutOverlapSame.add(_OffSeg(ns, ne, newHoliday, reason));
    return _mergeAllIntervals(withoutOverlapSame).map((e) => e.toMap()).toList();
  }

  List<Map<String, Object>> _mergeTimeOffAfterLoad(List<Map<String, Object>> input) {
    final segs = input
        .map(
          (m) => _OffSeg(
            _parseYmdLocal((m['start_date'] ?? '').toString()),
            _parseYmdLocal((m['end_date'] ?? '').toString()),
            m['is_holiday'] == true,
            (m['reason'] ?? '').toString(),
          ),
        )
        .where((s) => !s.start.isAfter(s.end))
        .toList();
    return _mergeAllIntervals(segs).map((e) => e.toMap()).toList();
  }

  List<_OffSeg> _subtractInclusive(_OffSeg e, DateTime ns, DateTime ne) {
    final os = e.start.isAfter(ns) ? e.start : ns;
    final oe = e.end.isBefore(ne) ? e.end : ne;
    if (os.isAfter(oe)) return [e];
    final out = <_OffSeg>[];
    if (e.start.isBefore(os)) {
      out.add(_OffSeg(e.start, _addDays(os, -1), e.isHoliday, e.reason));
    }
    if (oe.isBefore(e.end)) {
      out.add(_OffSeg(_addDays(oe, 1), e.end, e.isHoliday, e.reason));
    }
    return out.where((s) => !s.start.isAfter(s.end)).toList();
  }

  DateTime _addDays(DateTime d, int n) =>
      DateTime(d.year, d.month, d.day).add(Duration(days: n));

  bool _rangesOverlapInclusive(DateTime a1, DateTime a2, DateTime b1, DateTime b2) {
    return !a1.isAfter(b2) && !b1.isAfter(a2);
  }

  List<_OffSeg> _mergeAllIntervals(List<_OffSeg> list) {
    final out = <_OffSeg>[];
    for (final holiday in [false, true]) {
      final group = list.where((s) => s.isHoliday == holiday).toList()
        ..sort((a, b) => a.start.compareTo(b.start));
      _OffSeg? cur;
      for (final seg in group) {
        if (cur == null) {
          cur = seg;
        } else if (!seg.start.isAfter(_addDays(cur.end, 1))) {
          cur = _OffSeg(
            cur.start,
            seg.end.isAfter(cur.end) ? seg.end : cur.end,
            holiday,
            seg.reason.isNotEmpty ? seg.reason : cur.reason,
          );
        } else {
          out.add(cur);
          cur = seg;
        }
      }
      if (cur != null) out.add(cur);
    }
    return out;
  }

  String _breakKey(Map<String, Object> item) {
    return '${item['day_of_week']}|${item['start_time']}|${item['end_time']}';
  }

  List<Map<String, Object>> _dedupeBreaks(List<Map<String, Object>> input) {
    final seen = <String>{};
    final result = <Map<String, Object>>[];
    for (final item in input) {
      final key = _breakKey(item);
      if (seen.contains(key)) continue;
      seen.add(key);
      result.add(item);
    }
    return result;
  }

  bool _hasBreakDuplicate(int day, String start, String end) {
    final key = '$day|$start|$end';
    return _breaks.any((b) => _breakKey(b) == key);
  }

}

class _OffSeg {
  _OffSeg(this.start, this.end, this.isHoliday, this.reason);

  final DateTime start;
  final DateTime end;
  final bool isHoliday;
  final String reason;

  Map<String, Object> toMap() => <String, Object>{
        'start_date':
            '${start.year.toString().padLeft(4, '0')}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}',
        'end_date':
            '${end.year.toString().padLeft(4, '0')}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}',
        'reason': reason,
        'is_holiday': isHoliday,
      };
}
