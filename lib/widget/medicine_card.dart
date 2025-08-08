import 'package:flutter/material.dart';
import 'package:medicine_tracker/modal/medicine.dart';
import 'package:medicine_tracker/pages/add_medicine.dart';
import 'package:medicine_tracker/provider/medicine_provider.dart';
import 'package:provider/provider.dart';

class MedicineCard extends StatelessWidget {
  final List<Medicine> medicines;
  final String dateKey;
  final void Function(Medicine, bool) onToggleTaken;
  final void Function(Medicine) onDelete;

  const MedicineCard({
    super.key,
    required this.medicines,
    required this.dateKey,
    required this.onToggleTaken,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isViewingOther =
        context.watch<MedicineProvider>().isViewingOtherUser;

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
                      const Spacer(),
                      if (!isViewingOther) ...[
                        InkWell(
                          child: Icon(Icons.edit, color: Colors.black45),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddMedicine(
                                  title: "Edit Medicine",
                                  bText: "Update",
                                  existing: med,
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(width: 15),
                        InkWell(
                          child: Icon(Icons.delete, color: Colors.black54),
                          onTap: () => onDelete(med),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Column(
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
                      Tooltip(
                        message: isFuture || isViewingOther
                            ? "Toggle disabled"
                            : "",
                        child: Switch(
                          value: isTaken,
                          onChanged: (isFuture || isViewingOther)
                              ? null
                              : (value) => onToggleTaken(med, value),
                          activeColor: Colors.white,
                          activeTrackColor: Theme.of(context).primaryColor,
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: Colors.black45,
                        ),
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

  int _hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return int.parse(hex, radix: 16);
  }
}
