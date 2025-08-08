import 'package:flutter/material.dart';
import 'package:medicine_tracker/modal/medicine.dart';
import 'package:medicine_tracker/services/firestore_services.dart';

class MedicineProvider extends ChangeNotifier {
  final FirestoreService _fs = FirestoreService();

  List<Medicine> _medicines = [];
  List<Medicine> get medicineL => _medicines;

  String? userId;
  String? _viewingUserId;
  bool _isViewingOtherUser = false;

  bool get isViewingOtherUser => _isViewingOtherUser;
  String? get viewingUserId => _viewingUserId;


  // Set current user and disable view-only mode
  void setUserId(String id) {
    userId = id;
    _isViewingOtherUser = false;
    _viewingUserId = null;
    notifyListeners();
    loadMedicine();
  }

  String getId() => userId!;

  // Load medicines for either own or viewed user
  Future<void> loadMedicine() async {
    final uidToFetch = _viewingUserId ?? userId;
    if (uidToFetch == null) return;
    _medicines = await _fs.fetchMedicines(uidToFetch);
    notifyListeners();
  }

  Future<void> addMedicine(Medicine medicine) async {
    if (_isViewingOtherUser || userId == null) return;
    await _fs.addMedicine(userId!, medicine);
    _medicines.add(medicine);
    notifyListeners();
  }

  Future<void> toggleTakenStatus(String medicineId, String dateKey) async {
    if (_isViewingOtherUser || userId == null) return;

    final index = _medicines.indexWhere((m) => m.id == medicineId);
    if (index == -1) return;

    final medicine = _medicines[index];
    final wasTaken = medicine.takenStatus[dateKey] == true;

    if (wasTaken) {
      medicine.takenStatus.remove(dateKey);
      medicine.takenTimes.remove(dateKey);
    } else {
      medicine.takenStatus[dateKey] = true;
      medicine.takenTimes[dateKey] = DateTime.now();
    }

    await _fs.updateMedicine(userId!, medicine);
    _medicines[index] = medicine;
    notifyListeners();
  }




  Future<void> removeMedicine(String medicineId) async {
    if (_isViewingOtherUser || userId == null) return;
    await _fs.deleteMedicine(userId!, medicineId);
    _medicines.removeWhere((m) => m.id == medicineId);
    notifyListeners();
  }

  Future<void> updateMedicine(Medicine updated) async {
    if (_isViewingOtherUser || userId == null) return;
    await _fs.updateMedicine(userId!, updated);
    final index = _medicines.indexWhere((m) => m.id == updated.id);
    if (index != -1) {
      _medicines[index] = updated;
      notifyListeners();
    }
  }

  /// Enable view-only mode to show another user's medicines
  void setViewingUser(String? otherUserId) {
    _viewingUserId = otherUserId;
    _isViewingOtherUser = true;
    notifyListeners();
    loadMedicine(); // reload data
  }

  /// Reset to current user's data
  void clearViewingUser() {
    _viewingUserId = null;
    _isViewingOtherUser = false;
    notifyListeners();
    loadMedicine();
  }

  Medicine? getMedicineById(String id) {
  try {
    return _medicines.firstWhere((m) => m.id == id);
  } catch (_) {
    return null;
  }
}

}
