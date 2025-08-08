import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicine_tracker/modal/medicine.dart';

String formatKeyDate(DateTime date) =>
    "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";


/// Converts Firebase-style date string "YYYY-MM-DD" to display format "DD-MMM-YYYY"
String displayFromKey(String dateKey) {
  try {
    final date = DateTime.parse(dateKey);
    return formatDisplayDate(date);
  } catch (_) {
    return dateKey; // fallback if parsing fails
  }
}

String formatDisplayDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = _monthName(date.month);
  final year = date.year.toString();
  return '$day-$month-$year';
}

String _monthName(int month) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return months[month - 1];
}

bool shouldShowOnDate(Medicine med, String dateKey) {
  final start = formatKeyDate(med.startDate);
  if (dateKey.compareTo(start) < 0) return false;

  switch (med.scheduleType) {
    case 'Daily':
      return true;
    case 'Custom':
      final interval = med.customIntervalDays ?? 1;
      final diff = DateTime.parse(dateKey).difference(med.startDate).inDays;
      return diff % interval == 0;
    default:
      return false;
  }
}

List<Medicine> medicinesForDate(List<Medicine> list, DateTime date) {
  final formatted = formatKeyDate(date);
  return list
      .where((m) => m.isActive && shouldShowOnDate(m, formatted))
      .toList();
} 

List<Medicine> takenMedicines(List<Medicine> list, DateTime date) {
  final formatted = formatKeyDate(date);
  return list
      .where(
        (m) =>
            m.isActive &&
            shouldShowOnDate(m, formatted) &&
            m.takenStatus[formatted] == true,
      )
      .toList();
}

List<Medicine> missedMedicines(List<Medicine> list, DateTime date) {
  final formatted = formatKeyDate(date);
  return list
      .where(
        (m) =>
            m.isActive &&
            shouldShowOnDate(m, formatted) &&
            m.takenStatus[formatted] != true,
      )
      .toList();
}

Medicine? getMedicineById(List<Medicine> list, String id) {
  try {
    return list.firstWhere((m) => m.id == id);
  } catch (e) {
    return null;
  }
}


String generateRandomCode({int length = 6}) {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final rand = Random.secure();
  return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
}

Future<String> generateUniqueCode(FirebaseFirestore db) async {
  String code;
  bool exists = true;

  do {
    code = generateRandomCode(length: 6); // from method #1
    final doc = await db.collection('sharecodes').doc(code).get();
    exists = doc.exists;
  } while (exists);

  return code;
}