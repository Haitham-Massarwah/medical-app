class AppointmentCartItem {
  final String doctorId;
  final String doctorName;
  final String specialty;
  final DateTime appointmentDate;
  final String timeSlot;
  final double consultationFee;
  final String doctorEmail;

  AppointmentCartItem({
    required this.doctorId,
    required this.doctorName,
    required this.specialty,
    required this.appointmentDate,
    required this.timeSlot,
    required this.consultationFee,
    required this.doctorEmail,
  });

  Map<String, dynamic> toJson() {
    return {
      'doctorId': doctorId,
      'doctorName': doctorName,
      'specialty': specialty,
      'appointmentDate': appointmentDate.toIso8601String(),
      'timeSlot': timeSlot,
      'consultationFee': consultationFee,
      'doctorEmail': doctorEmail,
    };
  }

  AppointmentCartItem.fromJson(Map<String, dynamic> json)
      : doctorId = json['doctorId'],
        doctorName = json['doctorName'],
        specialty = json['specialty'],
        appointmentDate = DateTime.parse(json['appointmentDate']),
        timeSlot = json['timeSlot'],
        consultationFee = json['consultationFee'].toDouble(),
        doctorEmail = json['doctorEmail'];
}

class AppointmentCart {
  List<AppointmentCartItem> _items = [];
  String? _customerEmail;
  String? _customerPhone;
  String? _customerName;

  List<AppointmentCartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;
  double get totalAmount => _items.fold(0.0, (sum, item) => sum + item.consultationFee);
  String? get customerEmail => _customerEmail;
  String? get customerPhone => _customerPhone;
  String? get customerName => _customerName;

  void addItem(AppointmentCartItem item) {
    // Check for conflicts (same doctor, same date/time)
    bool hasConflict = _items.any((existingItem) =>
        existingItem.doctorId == item.doctorId &&
        existingItem.appointmentDate.year == item.appointmentDate.year &&
        existingItem.appointmentDate.month == item.appointmentDate.month &&
        existingItem.appointmentDate.day == item.appointmentDate.day &&
        existingItem.timeSlot == item.timeSlot);

    if (!hasConflict) {
      _items.add(item);
    }
  }

  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
    }
  }

  void clear() {
    _items.clear();
  }

  void setCustomerInfo({
    required String email,
    required String phone,
    required String name,
  }) {
    _customerEmail = email;
    _customerPhone = phone;
    _customerName = name;
  }

  Map<String, dynamic> toJson() {
    return {
      'items': _items.map((item) => item.toJson()).toList(),
      'customerEmail': _customerEmail,
      'customerPhone': _customerPhone,
      'customerName': _customerName,
    };
  }

  AppointmentCart.fromJson(Map<String, dynamic> json)
      : _items = (json['items'] as List)
            .map((item) => AppointmentCartItem.fromJson(item))
            .toList(),
        _customerEmail = json['customerEmail'],
        _customerPhone = json['customerPhone'],
        _customerName = json['customerName'];
}








