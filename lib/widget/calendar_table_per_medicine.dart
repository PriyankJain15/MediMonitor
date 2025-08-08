// import 'package:flutter/material.dart';
// import 'package:medicine_tracker/modal/medicine.dart';
// import 'package:medicine_tracker/widget/calendar_table.dart';

// class CalendarTablePerMedicine extends StatelessWidget {
//   final Medicine medicine;

//   const CalendarTablePerMedicine({required this.medicine});

//   @override
//   Widget build(BuildContext context) {
//     return CalendarTable(
//       selectedMedicine: medicine, // you'll need to adapt CalendarTable to accept this
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:medicine_tracker/modal/medicine.dart';
import 'package:medicine_tracker/widget/calendar_table.dart';

class CalendarTablePerMedicine extends StatelessWidget {
  final Medicine medicine;
  final bool isViewOnly;

  const CalendarTablePerMedicine({required this.medicine, required this.isViewOnly});

  @override
  Widget build(BuildContext context) {
    return CalendarTable(
      selectedMedicine: medicine,
      isViewOnly: isViewOnly,
    );
  }
}
