import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/*
Logic part => onDateSelected method yaha bna hain or call onTap pr ho rha hain so that apan parent me define kr ske ki yeh kya kaam krega 
aur selected date hume yha mil gyi hain
UI part => initially selectedDate aaj ki hain and isSelected first wala true hoga kyyuki .builder toh ek array ki tarah kaam krta hain
toh first index trues hain toh uske hisab se ui me show hoga color and all baaki saare ke lie false hain toh us hisab se shuru hoga
pr jaise hi hum kisi aur pr click krte hain date woh wali ho jayegi and selecteddate bhi update ho jayegi gesture detector me
toh ui uske hisab se color show krega

*/
class HorizontalDateStrip extends StatefulWidget {
  final Function(DateTime selectedDate) onDateSelected;

  const HorizontalDateStrip({super.key, required this.onDateSelected});

  @override
  State<HorizontalDateStrip> createState() => _HorizontalDateStripState();
}

class _HorizontalDateStripState extends State<HorizontalDateStrip> {
  DateTime selectedDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 30,
        itemBuilder: (_, index) {
          final date = DateTime.now().add(Duration(days: index));
          final isSelected = isSameDay(date, selectedDate);

          return GestureDetector(
            onTap: () {
              setState(() => selectedDate = date);
              widget.onDateSelected(date);
            },
            child:Container(
              width: 65,
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: isSelected
                    ? [BoxShadow(color: Colors.black12, blurRadius: 6)]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat('E').format(date), // Mon, Tue, etc
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      )),
                  const SizedBox(height: 4),
                  Text(date.day.toString().padLeft(2, '0'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black,
                      )),
                  Text(DateFormat.MMM().format(date),style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black,
                      ))
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
