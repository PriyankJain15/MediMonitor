import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medicine_tracker/utils/medicine_utils.dart';
import 'package:medicine_tracker/utils/pdf_generator.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../provider/medicine_provider.dart';
import '../modal/medicine.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final Map<String, DateTimeRange> _dateRanges = {};
  // Per-medicine + section expansion state: "<medId>:taken" / "<medId>:missed"
  final Map<String, bool> _expanded = {};

  @override
  Widget build(BuildContext context) {
    final medicineList = context.watch<MedicineProvider>().medicineL;

    return Scaffold(
      appBar: AppBar(title: const Text('Medicine Report'), centerTitle: true),
      body: medicineList.isEmpty
          ? Center(
              child: Text(
                'No medicine data available.',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            )
          : ListView.builder(
              itemCount: medicineList.length,
              itemBuilder: (context, index) {
                final medicine = medicineList[index];
                final now = DateTime.now();

                if (medicine.startDate.isAfter(now)) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    child: ListTile(
                      leading: CircleAvatar(backgroundColor: _parseHexColor(medicine.color)),
                      title: Text(medicine.medicineName),
                      subtitle: Text("(Starts on ${formatDisplayDate(medicine.startDate)})"),
                    ),
                  );
                }

                final doctorName = medicine.doctorName ?? "Not specified";
                final dosage = medicine.dosage;
                final scheduleday = medicine.scheduleType.toLowerCase() == "daily"
                    ? 1
                    : medicine.customIntervalDays;
                final remainderTime = medicine.reminderTime ?? "Not Set";
                final sDate = formatDisplayDate(medicine.startDate);
                final tDoses = _expectedDoseCount(medicine).toString();
                final dateRange = _getEffectiveRange(medicine);

                // Build date lists, then format 3-per-line strings
                final takenDatesList = _getDatesList(medicine, true, dateRange);
                final missedDatesList = _getDatesList(medicine, false, dateRange);
                final takenDatesStr = _formatDates3PerLine(takenDatesList);
                final missedDatesStr = _formatDates3PerLine(missedDatesList);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: ExpansionTile(
                    title: Text(medicine.medicineName),
                    subtitle: Text("Taken ${_takenCount(medicine)} / ${_expectedDoseCount(medicine)}"),
                    leading: CircleAvatar(backgroundColor: _parseHexColor(medicine.color)),
                    children: [
                      ListTile(
                        title: const Text(
                          "Doctor Name                Dosage ",
                          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black),
                        ),
                        subtitle: Text(" $doctorName                    $dosage "),
                      ),
                      ListTile(
                        title: const Text(
                          "Schedule Type              Reminder Time ",
                          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black),
                        ),
                        subtitle: Text(" $scheduleday                                      $remainderTime "),
                      ),
                      ListTile(
                        title: const Text(
                          "Start Date                   Total Doses Expected ",
                          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black),
                        ),
                        subtitle: Text(" $sDate                      $tDoses "),
                      ),
                      _buildInfoTile(
                        "Doses Taken",
                        "Doses Missed",
                        _takenCount(medicine).toString(),
                        _missedCount(medicine).toString(),
                      ),
                      _buildInfoTiles("Adherence %", _adherencePercent(medicine)),

                      // Date range pickers
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            const Text("From: "),
                            TextButton(
                              onPressed: () => _selectDate(context, medicine.id, true),
                              child: Text(formatDisplayDate(dateRange.start)),
                            ),
                            const Text("To: "),
                            TextButton(
                              onPressed: () => _selectDate(context, medicine.id, false),
                              child: Text(formatDisplayDate(dateRange.end)),
                            ),
                          ],
                        ),
                      ),

                      // Taken Dates (expandable, left-aligned, black title, stronger date text)
                      _buildExpandableDatesTile(
                        context: context,
                        title: "Taken Dates",
                        medId: medicine.id,
                        section: "taken",
                        value: takenDatesStr,
                      ),

                      // Missed Dates (expandable)
                      _buildExpandableDatesTile(
                        context: context,
                        title: "Missed Dates",
                        medId: medicine.id,
                        section: "missed",
                        value: missedDatesStr,
                      ),

                      // PDF
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final pdf = await generateMedicineReportPdfBytes(
                              medicine,
                              _getEffectiveRange(medicine),
                            );
                            await Printing.layoutPdf(onLayout: (format) async => pdf);
                          },
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text("Download as PDF"),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  // ---------- UI helpers ----------

  Widget _buildInfoTile(String title, String title2, String value, String value2) {
    final st = value.isEmpty ? "None" : value;
    return ListTile(
      title: const Text(
        // keep spacing style as in your code
        "Doses Taken                 Doses Missed  ",
        style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black),
      ),
      subtitle: Text("$st                                      $value2"),
    );
  }

  Widget _buildInfoTiles(String title, String value) {
    return ListTile(
      visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black),
      ),
      subtitle: Text(value.isEmpty ? "None" : value),
    );
  }

  Widget _buildExpandableDatesTile({
    required BuildContext context,
    required String title,
    required String medId,
    required String section, // "taken" | "missed"
    required String value,   // formatted 3-per-line string
  }) {
    final key = "$medId:$section";
    final expanded = _expanded[key] ?? false;

    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w800,
      color: Colors.black, // force black
    );
    final textStyle = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w600, // stronger for visibility
      color: theme.textTheme.bodyMedium?.color,
      height: 1.25,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
      child: _ExpandableBlock(
        title: title,
        titleStyle: titleStyle,
        text: value.isEmpty ? "None" : value,
        textStyle: textStyle,
        expanded: expanded,
        maxLinesWhenCollapsed: 2,
        onToggle: (v) => setState(() => _expanded[key] = v),
      ),
    );
  }

  // ---------- Date range & metrics ----------

  Future<void> _selectDate(BuildContext context, String medId, bool isStart) async {
    final currentRange = _dateRanges[medId] ??
        _getEffectiveRange(context.read<MedicineProvider>().getMedicineById(medId)!);

    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      final pickedNormalized = DateTime(picked.year, picked.month, picked.day);
      setState(() {
        _dateRanges[medId] = isStart
            ? DateTimeRange(start: pickedNormalized, end: currentRange.end)
            : DateTimeRange(start: currentRange.start, end: pickedNormalized);
      });
    }
  }

  DateTimeRange _getEffectiveRange(Medicine med) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thirtyDaysAgo = today.subtract(const Duration(days: 30));
    final start = med.startDate.isAfter(thirtyDaysAgo)
        ? DateTime(med.startDate.year, med.startDate.month, med.startDate.day)
        : thirtyDaysAgo;
    return _dateRanges[med.id] ?? DateTimeRange(start: start, end: today);
  }

  int _expectedDoseCount(Medicine med) {
    final now = DateTime.now();
    if (med.startDate.isAfter(now)) return 0;
    int count = 0;
    DateTime date = DateTime(med.startDate.year, med.startDate.month, med.startDate.day);
    final isCustom = med.scheduleType.toLowerCase() == 'custom';
    final interval = isCustom ? (med.customIntervalDays ?? 1) : 1;
    while (!date.isAfter(now)) {
      count++;
      date = date.add(Duration(days: interval));
    }
    return count;
  }

  int _takenCount(Medicine med) {
    return med.takenStatus.entries.length;
  }

  int _missedCount(Medicine med) {
    return _expectedDoseCount(med) - _takenCount(med);
  }

  String _adherencePercent(Medicine med) {
    final total = _expectedDoseCount(med);
    final taken = _takenCount(med);
    return total == 0 ? "N/A" : "${(taken / total * 100).toStringAsFixed(1)}%";
  }

  /// Returns list of formatted date strings within [range] for either taken or missed.
  List<String> _getDatesList(Medicine med, bool taken, DateTimeRange range) {
    final List<String> result = [];
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final start = DateTime(range.start.year, range.start.month, range.start.day);
    final end = DateTime(range.end.year, range.end.month, range.end.day);
    final interval = med.scheduleType.toLowerCase() == 'custom'
        ? (med.customIntervalDays ?? 1)
        : 1;

    for (DateTime date = start; !date.isAfter(end); date = date.add(Duration(days: interval))) {
      final dateStr = formatter.format(date);
      final wasTaken = med.takenStatus[dateStr] == true;

      if (taken && wasTaken) {
        result.add(formatDisplayDate(date));
      } else if (!taken && !wasTaken && !date.isAfter(DateTime.now())) {
        result.add(formatDisplayDate(date));
      }
    }
    return result;
  }

  /// Formats dates into lines with exactly 3 items per line (last line can be fewer).
  String _formatDates3PerLine(List<String> dates) {
    if (dates.isEmpty) return "";
    final List<String> lines = [];
    for (int i = 0; i < dates.length; i += 3) {
      final end = (i + 3 < dates.length) ? i + 3 : dates.length;
      lines.add(dates.sublist(i, end).join(", "));
    }
    return lines.join("\n");
  }

  Color _parseHexColor(String hexColor) {
    final hex = hexColor.replaceAll("#", "");
    return Color(int.parse("FF$hex", radix: 16));
  }
}

/// Expandable block with a black, bold title and left-aligned text.
/// Uses Directionality.of(context) to avoid TextDirection enum issues.
/// Shows "See more / See less" only if collapsed text would overflow.
class _ExpandableBlock extends StatelessWidget {
  final String title;
  final TextStyle? titleStyle;
  final String text;
  final TextStyle? textStyle;
  final bool expanded;
  final int maxLinesWhenCollapsed;
  final ValueChanged<bool> onToggle;

  const _ExpandableBlock({
    required this.title,
    required this.titleStyle,
    required this.text,
    required this.textStyle,
    required this.expanded,
    required this.maxLinesWhenCollapsed,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final dir = Directionality.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Overflow detection for collapsed state
        final tp = TextPainter(
          text: TextSpan(style: textStyle, text: text.isEmpty ? "None" : text),
          maxLines: maxLinesWhenCollapsed,
          textDirection: dir,
          ellipsis: '…',
        )..layout(maxWidth: constraints.maxWidth);

        final isOverflowing = tp.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start, // left align everything
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(title, style: titleStyle),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                text.isEmpty ? "None" : text,
                style: textStyle,
                softWrap: true,
                textAlign: TextAlign.start,
                overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                maxLines: expanded ? null : maxLinesWhenCollapsed,
              ),
            ),
            if (isOverflowing)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: () => onToggle(!expanded),
                  child: Text(expanded ? 'See less' : 'See more'),
                ),
              ),
          ],
        );
      },
    );
  }
}
