import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../modal/medicine.dart';

Future<Uint8List> generateMedicineReportPdfBytes(
  Medicine med,
  DateTimeRange range,
) async {
  final pdf = pw.Document();
  final takenStatus = med.takenStatus;
  final dateFormat = DateFormat('yyyy-MM-dd');
  final monthFormat = DateFormat('MMMM yyyy');

  final startMonth = DateTime(range.start.year, range.start.month);
  final endMonth = DateTime(range.end.year, range.end.month);

  DateTime currentMonth = startMonth;
  List<pw.Widget> monthlyTables = [];

  while (!currentMonth.isAfter(endMonth)) {
    final year = currentMonth.year;
    final month = currentMonth.month;

    final monthStart = DateTime(year, month, 1);
    final monthEnd = DateTime(year, month + 1, 0);
    final daysInMonth = monthEnd.day;
    final firstWeekday = monthStart.weekday % 7; // Sunday=0

    final totalCells = ((firstWeekday + daysInMonth) / 7).ceil() * 7;
    int day = 1;

    List<pw.Widget> tableRows = [];

    // Header: Weekdays
    tableRows.add(
      pw.Row(
        children: List.generate(7, (i) {
          return pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.all(5),
              alignment: pw.Alignment.center,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 0.5),
                color: PdfColors.grey300,
              ),
              child: pw.Text(
                ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][i],
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
          );
        }),
      ),
    );

    // Days
    for (int i = 0; i < totalCells / 7; i++) {
      tableRows.add(
        pw.Row(
          children: List.generate(7, (j) {
            final cellIndex = i * 7 + j;
            if (cellIndex < firstWeekday || day > daysInMonth) {
              return pw.Expanded(
                child: pw.Container(
                  height: 40,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black, width: 0.5),
                  ),
                ),
              );
            } else {
              final date = DateTime(year, month, day);
              final dateStr = dateFormat.format(date);
              final isFuture = date.isAfter(DateTime.now());
              final isBeforeStart = date.isBefore(med.startDate);
              final isTaken = takenStatus[dateStr] == true;

              PdfColor cellColor = PdfColors.white;
              if (isFuture || isBeforeStart) {
                cellColor = PdfColors.grey200;
              } else {
                cellColor = isTaken ? PdfColors.lightGreen : PdfColors.redAccent;
              }

              final cell = pw.Container(
                height: 40,
                alignment: pw.Alignment.center,
                decoration: pw.BoxDecoration(
                  color: cellColor,
                  border: pw.Border.all(color: PdfColors.black, width: 0.5),
                ),
                child: pw.Text('$day', style: const pw.TextStyle(fontSize: 12)),
              );

              day++;
              return pw.Expanded(child: cell);
            }
          }),
        ),
      );
    }

    // Add to list
    monthlyTables.add(
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(monthFormat.format(currentMonth),
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              )),
          pw.SizedBox(height: 6),
          ...tableRows,
          pw.SizedBox(height: 20),
        ],
      ),
    );

    currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
  }

  // Add to single page if space allows
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(16),
      build: (context) => [
        pw.Text(
          "Medicine Report: ${med.medicineName}",
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 20),
        ...monthlyTables,
      ],
    ),
  );

  return pdf.save();
}
