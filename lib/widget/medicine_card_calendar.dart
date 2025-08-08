import 'package:flutter/material.dart';
import 'package:medicine_tracker/modal/medicine.dart';

class MedicineCardCalendar extends StatelessWidget {
  final List<Medicine> medicines;
  final String dateKey;

  const MedicineCardCalendar({
    super.key,
    required this.medicines,
    required this.dateKey,
  });

  // final color = Colors.amber;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: medicines.length,
      itemBuilder: (context, index) {
        final med = medicines[index];
        final isTaken = med.takenStatus[dateKey] ?? false;
        final isFuture = DateTime.parse(dateKey).isAfter(DateTime.now());
        return Opacity(
          opacity: isTaken ? 0.7 : 1.0,
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Color(_hexToColor(med.color)),
            child: Padding(
              padding: const EdgeInsets.all(11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        med.medicineName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Dosage: ${med.dosage}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          if (med.doctorName != null &&
                              med.doctorName!.isNotEmpty)
                            Text(
                              "Prescribed by: Dr. ${med.doctorName}",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                        ],
                      ),
                      const Spacer(),
                      Switch(
                          value: isTaken,
                          onChanged: isFuture
                              ? null
                              : (value) {
                                },
                          activeColor: Colors.white,
                          activeTrackColor: Theme.of(context).primaryColor,
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: Colors.black45,
                        ),
                      
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Converts hex string like "#FF6B6B" to integer color
  int _hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex'; // add alpha if not present
    return int.parse(hex, radix: 16);
  }
}
