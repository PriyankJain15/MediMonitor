import 'package:flutter/foundation.dart';
import 'package:medicine_tracker/services/firestore_services.dart';

class ShareCodeProvider extends ChangeNotifier {
  final FirestoreService _fs = FirestoreService();

  /// Generates a share code, stores it in `sharecodes` collection,
  /// and updates the current user's document with it.
  Future<void> generateAndSaveCode({
    required String userId,
    required String code,
  }) async {
    try {
      _fs.generateAndSaveCode(userId,code);
    } catch (e) {
      debugPrint("Error generating/saving code: $e");
      rethrow;
    }
  }

  /// Fetches the saved share code from the user's Firestore document.
  Future<String?> fetchOwnShareCode(String userId) async {
    try {
      return _fs.fetchOwnShareCode(userId);
    } catch (e) {
      debugPrint("Error fetching share code: $e");
      return null;
    }
  }

  Future<String?> fetchOtherPersonId(String code) async {
    try {
      return _fs.fetchOtherPersonId(code);
    } catch (e) {
      debugPrint("Error fetching share code: $e");
      return null;
    }
  }
}
