import 'package:flutter/material.dart';
import 'package:medicine_tracker/pages/add_medicine.dart';
import 'package:medicine_tracker/widget/calendar_table_per_medicine.dart';
import 'package:medicine_tracker/widget/navigat_drawer.dart';
import 'package:provider/provider.dart';
import 'package:medicine_tracker/provider/medicine_provider.dart';

class TabbedCalendarScreen extends StatefulWidget {
  final String? viewOnlyUserId;
  const TabbedCalendarScreen({super.key, this.viewOnlyUserId});

  @override
  State<TabbedCalendarScreen> createState() => _TabbedCalendarScreenState();
}

class _TabbedCalendarScreenState extends State<TabbedCalendarScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    final medicines = context.read<MedicineProvider>().medicineL;
    if (medicines.isNotEmpty) {
      _createController(medicines.length);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final medicines = context.read<MedicineProvider>().medicineL;
    if (medicines.isEmpty) {
      _disposeControllerIfAny();
      setState(() {});
      return;
    }

    if (_tabController == null) {
      _createController(medicines.length);
      setState(() {});
      return;
    }

    if (_tabController!.length != medicines.length) {
      _disposeControllerIfAny();
      _createController(medicines.length);
      setState(() {});
    }
  }

  void _createController(int length) {
    _tabController = TabController(length: length, vsync: this);
    _tabController!.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void _disposeControllerIfAny() {
    _tabController?.removeListener(() {});
    _tabController?.dispose();
    _tabController = null;
  }

  @override
  void dispose() {
    _disposeControllerIfAny();
    super.dispose();
  }

  void _goToAddMedicine() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddMedicine(title: "Add Medicine", bText: "Add"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final medicines = context.watch<MedicineProvider>().medicineL;
    final isViewOnly = context.read<MedicineProvider>().isViewingOtherUser;

    final hasMeds = medicines.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: const Text('Calendar', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        bottom: hasMeds
            ? PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: TabBar(
                    isScrollable: true,
                    controller: _tabController!,
                    indicatorColor: Colors.transparent,
                    indicatorPadding: EdgeInsets.zero,
                    labelPadding: const EdgeInsets.only(right: 6),
                    tabs: List.generate(medicines.length, (index) {
                      final med = medicines[index];
                      final isSelected =
                          (_tabController?.index ?? 0) == index;
                      return Container(
                        margin: const EdgeInsets.only(left: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blue.shade100
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? Colors.blue
                                : Colors.grey.shade400,
                          ),
                        ),
                        child: Text(
                          med.medicineName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: isSelected
                                ? Colors.blue.shade900
                                : Colors.black54,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              )
            : null,
      ),
      drawer: const NavigatDrawer(),
      body: hasMeds
          ? TabBarView(
              controller: _tabController!,
              children: medicines
                  .map((med) => CalendarTablePerMedicine(
                        medicine: med,
                        isViewOnly: isViewOnly,
                      ))
                  .toList(),
            )
          : _CalendarEmptyState(
              isViewOnly: isViewOnly,
              onAddPressed: isViewOnly ? null : _goToAddMedicine,
            ),
    );
  }
}

class _CalendarEmptyState extends StatelessWidget {
  final bool isViewOnly;
  final VoidCallback? onAddPressed;

  const _CalendarEmptyState({
    required this.isViewOnly,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title =
        isViewOnly ? "No medicines to show" : "No medicines added yet";
    final subtitle = isViewOnly
        ? "The user hasn’t shared any medicines."
        : "Add a medicine to see its monthly calendar here.";

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_month, size: 56, color: theme.primaryColor),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style:
                  theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
              textAlign: TextAlign.center,
            ),
            if (!isViewOnly) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onAddPressed,
                icon: const Icon(Icons.add),
                label: const Text("Add Medicine"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
