import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicine_tracker/modal/medicine.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addMedicine(String userId, Medicine medicine) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('medicines')
        .doc(medicine.id)
        .set(medicine.toMap());
  }

  Future<List<Medicine>> fetchMedicines(String userId) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('medicines')
        .get();

    return snapshot.docs
        .map((doc) => Medicine.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<void> markMedicineTaken(String userId, String medicineId, String dateKey) async {
  final ref = _db.collection('users').doc(userId).collection('medicines').doc(medicineId);

  await ref.update({
    'takenStatus.$dateKey': true,
    'takenTimes.$dateKey': DateTime.now().toIso8601String(),
  });
}

Future<void> deleteMedicine(String userId, String medicineId) {
  return _db.collection('users')
    .doc(userId)
    .collection('medicines')
    .doc(medicineId)
    .delete();
}

Future<void> updateMedicine(String userId, Medicine medicine) {
  return _db.collection('users')
    .doc(userId)
    .collection('medicines')
    .doc(medicine.id)
    .update(medicine.toMap());
}

Future<void> generateAndSaveCode(String userId, String code) async {
  final db = FirebaseFirestore.instance;

  // 1. Store in `sharecodes` collection
  await db.collection('sharecodes').doc(code).set({
    'userId': userId,
  });

  // 2. Save under user's own document
  await db.collection('users').doc(userId).set({
  'shareCode': code,
}, SetOptions(merge: true));

}

  Future<String?> fetchOwnShareCode(String userId) async {
  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .get();

  return doc.data()?['shareCode'] as String?;
}

Future<String?> fetchOtherPersonId(String code) async {
  final doc = await FirebaseFirestore.instance
      .collection('sharecodes')
      .doc(code)
      .get();

  return doc.data()?['userId'] as String?;
}

}
