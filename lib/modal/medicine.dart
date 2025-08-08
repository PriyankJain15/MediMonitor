class Medicine {
  final String id;
  final String medicineName;
  final String? doctorName;
  final String dosage;
  final String scheduleType; // e.g., daily, custom, weekly
  final int? customIntervalDays;
  final DateTime startDate;
  final Map<String, bool> takenStatus; // e.g., { "2025-07-10": true }
  final Map<String, DateTime> takenTimes; // e.g., { "2025-07-10": DateTime }
  final String? reminderTime; // e.g., "08:00"
  final bool isActive;
  final bool needReminder;
  final String color; // HEX format, e.g., "#FF6B6B"
  final bool showOnCalendar;

  Medicine({
    required this.id,
    required this.medicineName,
    this.doctorName,
    required this.dosage,
    required this.scheduleType,
    this.customIntervalDays,
    required this.startDate,
    required this.takenStatus,
    required this.takenTimes,
    this.reminderTime,
    required this.isActive,
    required this.needReminder,
    required this.color,
    required this.showOnCalendar,
  });

   factory Medicine.fromMap(String id, Map<String, dynamic> data) {
    return Medicine(
      id: id,
      medicineName: data['medicineName'] ?? '',
      doctorName: data['doctorName'],
      dosage: data['dosage'] ?? '',
      scheduleType: data['scheduleType'] ?? 'daily',
      customIntervalDays: data['customIntervalDays'],
      startDate: DateTime.parse(data['startDate']),
      takenStatus: Map<String, bool>.from(data['takenStatus'] ?? {}),
      takenTimes: (data['takenTimes'] as Map<String, dynamic>? ?? {}).map(
        (key, value) => MapEntry(key, DateTime.parse(value)),
      ),
      reminderTime: data['reminderTime'],
      isActive: data['isActive'] ?? true,
      needReminder: data['needReminder'] ?? false,
      color: data['color'] ?? '#000000',
      showOnCalendar: data['showOnCalendar'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'medicineName': medicineName,
      'doctorName': doctorName,
      'dosage': dosage,
      'scheduleType': scheduleType,
      'customIntervalDays': customIntervalDays,
      'startDate': startDate.toIso8601String(),
      'takenStatus': takenStatus,
      'takenTimes': takenTimes.map(
        (key, value) => MapEntry(key, value.toIso8601String()),
      ),
      'reminderTime': reminderTime,
      'isActive': isActive,
      'needReminder': needReminder,
      'color': color,
      'showOnCalendar': showOnCalendar,
    };
  }

  
}
