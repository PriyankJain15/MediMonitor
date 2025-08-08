import 'package:flutter/material.dart';
import 'package:medicine_tracker/pages/add_medicine.dart';
import 'package:medicine_tracker/provider/medicine_provider.dart';
import 'package:medicine_tracker/utils/medicine_utils.dart';
import 'package:medicine_tracker/widget/horizontal_date_strip.dart';
import 'package:medicine_tracker/widget/medicine_card.dart';
import 'package:medicine_tracker/widget/navigat_drawer.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  DateTime selectedDate = DateTime.now();
  bool isViewingOtherUser = false;

  @override
  void initState() {
    super.initState();
    _loadViewMode();
  }

  Future<void> _loadViewMode() async {
    final prefs = await SharedPreferences.getInstance();
    final flag = prefs.getBool('isViewingOtherUser') ?? false;
    if (mounted) {
      setState(() {
        isViewingOtherUser = flag;
      });
    }
  }

  void _goToAddMedicine() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMedicine(title: "Add Medicine", bText: "Add"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final med = context.watch<MedicineProvider>().medicineL;
    final medsForSelected = medicinesForDate(med, selectedDate);
    final isEmptyForDay = medsForSelected.isEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: const Text("Your Medicines"),
        centerTitle: true,
      ),
      drawer: NavigatDrawer(),
      body: Column(
        children: [
          HorizontalDateStrip(
            onDateSelected: (date) {
              setState(() => selectedDate = date);
            },
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(color: Theme.of(context).primaryColor, height: 5),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: isEmptyForDay
                      ? _EmptyState(
                          isViewingOtherUser: isViewingOtherUser,
                          onAddPressed: isViewingOtherUser ? null : _goToAddMedicine,
                          dateLabel: formatKeyDate(selectedDate),
                        )
                      : MedicineCard(
                          medicines: medsForSelected,
                          dateKey: formatKeyDate(selectedDate),
                          onToggleTaken: (m, i) {
                            context.read<MedicineProvider>().toggleTakenStatus(
                                  m.id,
                                  formatKeyDate(selectedDate),
                                );
                          },
                          onDelete: (med) async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Confirm Deletion"),
                                content: const Text(
                                  "Are you sure you want to delete this medicine?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text(
                                      "Delete",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (!context.mounted) return;
                            if (confirm == true) {
                              context.read<MedicineProvider>().removeMedicine(med.id);
                            }
                          },
                        ),
                ),

                // Keep your FAB as-is (hidden in view-only mode)
                if (!isViewingOtherUser)
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: FloatingActionButton.extended(
                      onPressed: _goToAddMedicine,
                      icon: const Icon(Icons.medication),
                      label: const Text("Add Medicine"),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isViewingOtherUser;
  final VoidCallback? onAddPressed;
  final String dateLabel;

  const _EmptyState({
    required this.isViewingOtherUser,
    required this.onAddPressed,
    required this.dateLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = isViewingOtherUser
        ? "No medicines to show"
        : "No medicines scheduled";
    final subtitle = isViewingOtherUser
        ? "Nothing was shared for $dateLabel."
        : "You don’t have any medicines on $dateLabel.";

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.medication_outlined, size: 56, color: theme.primaryColor),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
              textAlign: TextAlign.center,
            ),
            if (!isViewingOtherUser) ...[
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
