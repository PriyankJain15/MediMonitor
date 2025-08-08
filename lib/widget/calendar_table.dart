import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medicine_tracker/modal/medicine.dart';
import 'package:medicine_tracker/provider/medicine_provider.dart';
import 'package:medicine_tracker/utils/medicine_utils.dart';
import 'package:medicine_tracker/widget/medicine_card_calendar.dart';
import 'package:provider/provider.dart';

class CalendarTable extends StatefulWidget {
  final Medicine? selectedMedicine;
  final bool isViewOnly;

  const CalendarTable({this.selectedMedicine, required this.isViewOnly});

  @override
  State<CalendarTable> createState() => _CalendarTableState();
}

class _CalendarTableState extends State<CalendarTable> {
  DateTime currentMonth = DateTime.now();
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      int index = (currentMonth.year - 2020) * 12 + currentMonth.month - 1;
      _scrollController.jumpTo(index * 120.0);
    });
  }

  List<Widget> _buildMonthYearScroller() {
    List<Widget> widgets = [];
    for (int year = 2020; year <= 2030; year++) {
      for (int month = 1; month <= 12; month++) {
        widgets.add(
          GestureDetector(
            onTap: () {
              setState(() {
                currentMonth = DateTime(year, month);
              });
            },
            child: Container(
              width: 110,
              margin: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              padding: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: (currentMonth.month == month && currentMonth.year == year)
                    ? Colors.blueAccent
                    : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: Center(
                child: Text(
                  '${DateFormat.MMM().format(DateTime(year, month))} $year',
                  style: TextStyle(
                    color: (currentMonth.month == month && currentMonth.year == year)
                        ? Colors.white
                        : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = AppBar().preferredSize.height;
    final bottomNavBarHeight = MediaQuery.of(context).padding.bottom + 216.0;
    final availableHeight = screenHeight - appBarHeight - bottomNavBarHeight;
    final cellHeight = availableHeight / 6.2;

    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: Row(children: _buildMonthYearScroller()),
          ),
          Expanded(child: _buildCalendar(context, currentMonth, cellHeight)),
        ],
      ),
    );
  }

  Widget _buildCalendar(BuildContext context, DateTime month, double cellHeight) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final startWeekday = firstDayOfMonth.weekday;
    final totalCells = daysInMonth + startWeekday - 1;
    final numRows = (totalCells / 7).ceil();
    List<TableRow> rows = [];

    rows.add(
      TableRow(
        children: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']
            .map(
              (day) => Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    day,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );

    int dayCounter = 1;
    for (int i = 0; i < numRows; i++) {
      List<Widget> cells = [];
      for (int j = 1; j <= 7; j++) {
        final cellIndex = i * 7 + j;

        if (cellIndex < startWeekday || dayCounter > daysInMonth) {
          cells.add(Container(height: cellHeight));
        } else {
          final date = DateTime(month.year, month.month, dayCounter);
          final dateKey = formatKeyDate(date);
          bool isTaken = widget.selectedMedicine?.takenStatus[dateKey] ?? false;
          final isToday = DateTime.now().year == date.year &&
              DateTime.now().month == date.month &&
              DateTime.now().day == date.day;

          cells.add(
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DateDetailPage(date: date)),
                );
              },
              child: Container(
                height: cellHeight,
                margin: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isTaken
                      ? Theme.of(context).colorScheme.secondary
                      : Color(0xFFF5F5F5),
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: isToday
                            ? Theme.of(context).primaryColorLight
                            : isTaken
                                ? Theme.of(context).colorScheme.secondary
                                : Color(0xFFF5F5F5),
                      ),
                      child: Text(
                        '$dayCounter',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isToday ? Colors.white : Colors.black87,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          dayCounter++;
        }
      }
      rows.add(TableRow(children: cells));
    }

    return Table(
      border: TableBorder.symmetric(
        inside: BorderSide(color: Colors.grey.shade300),
      ),
      children: rows,
    );
  }
}

class DateDetailPage extends StatelessWidget {
  final DateTime date;
  DateDetailPage({required this.date});

  @override
  Widget build(BuildContext context) {
    final medList = context.watch<MedicineProvider>().medicineL;
    final filtered = medicinesForDate(medList, date);
    final dateKey = formatKeyDate(date);
    return Scaffold(
      appBar: AppBar(
        title: Text('Details for ${DateFormat.yMMMd().format(date)}'),
      ),
      body: filtered.isEmpty
          ? Center(child: Text("No medicines for this day."))
          : MedicineCardCalendar(
              medicines: filtered,
              dateKey: dateKey,
            ),
    );
  }
}