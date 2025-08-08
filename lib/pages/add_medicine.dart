import 'package:flutter/material.dart';
import 'package:medicine_tracker/main.dart';
import 'package:medicine_tracker/modal/medicine.dart';
import 'package:medicine_tracker/provider/medicine_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddMedicine extends StatefulWidget {
  final String title;
  final String bText;
  final Medicine? existing;

  const AddMedicine({
    super.key,
    required this.title,
    required this.bText,
    this.existing,
  });
  @override
  State<StatefulWidget> createState() => _AddMedicineState();
}

class _AddMedicineState extends State<AddMedicine> {
  @override
  void initState() {
    super.initState();
    final med = widget.existing;
    if (med != null) {
      _nameController.text = med.medicineName;
      _doctorController.text = med.doctorName ?? '';
      _dosageController.text = med.dosage;
      _scheduleType = med.scheduleType;
      _customIntervalController.text = med.customIntervalDays?.toString() ?? '';
      _startDate = med.startDate;
      _reminderTime = med.reminderTime != null
          ? TimeOfDay(
              hour: int.parse(med.reminderTime!.split(':')[0]),
              minute: int.parse(med.reminderTime!.split(':')[1]),
            )
          : null;
      _needReminder = med.needReminder;
      selectedColor = med.color;
    }
  }

  final List<String> colorHexList = [
    '#4CAF50',
    '#4BBC8E',
    '#F9F871',
    '#ff2e5c',
    '#92665a',
    '#ff6184',
    '#ecfd98',
    '#c67538',
    '#c6a0f8',
    '#faac69',
  ];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _doctorController = TextEditingController();
  final _dosageController = TextEditingController();
  final _customIntervalController = TextEditingController();
  String selectedColor = '#4CAF50'; // default selected

  String _scheduleType = 'Daily';
  DateTime _startDate = DateTime(
  DateTime.now().year,
  DateTime.now().month,
  DateTime.now().day,
);
  TimeOfDay? _reminderTime;
  bool _needReminder = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        automaticallyImplyLeading: false, // Theme blue
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_nameController, "Medicine Name", required: true),
              _buildTextField(_doctorController, "Doctor Name (Optional)"),
              _buildTextField(
                _dosageController,
                "Dosage (e.g. 1 tablet)",
                required: true,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: DropdownButtonFormField<String>(
                  value: _scheduleType,
                  decoration: InputDecoration(labelText: "Schedule Type"),
                  items: ['Daily', 'Custom']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => setState(() => _scheduleType = val!),
                ),
              ),
              SizedBox(height: 8),
              if (_scheduleType == 'Custom')
                _buildTextField(
                  _customIntervalController,
                  "Custom Interval (in days)",
                  maxlength: 2,
                  keyboardType: TextInputType.number,
                  required: true,
                ),
              const SizedBox(height: 16),
              _buildDatePicker(context),
              // _buildTimePicker(context),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 3),
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: colorHexList.length,
                    itemBuilder: (context, index) {
                      final hex = colorHexList[index];
                      final color = Color(
                        int.parse('FF${hex.substring(1)}', radix: 16),
                      );
                      final isSelected = selectedColor == hex;
                      return GestureDetector(
                        onTap: () {
                          setState(() => selectedColor = hex);
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.black, width: 2)
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 5),
              // SwitchListTile(
              //   title: const Text("Need Reminder?"),inactiveTrackColor: Colors.black45,
              //   value: _needReminder,
              //   onChanged: (val) => setState(() => _needReminder = val),
              // ),

              const SizedBox(height: 24),

              Row(
                children: [
                  SizedBox(width: 40),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 44,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child:Text(
                      'Cancel',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  SizedBox(width: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 44,
                      ),
                    ),
                    onPressed: _saveMedicine,
                    child: Text(
                      widget.bText,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int? maxlength,
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,maxLength: maxlength,
        keyboardType: keyboardType,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black), // normal border color
          ),
        ),
        validator: (value) =>
            required && (value == null || value.isEmpty) ? 'Required' : null,
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return ListTile(
      title: Text(
        "Start Date: ${_startDate.toLocal().toIso8601String().split('T').first}",
      ),
      trailing: const Icon(Icons.calendar_today),
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _startDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) setState(() => _startDate = picked);
      },
    );
  }

  Widget _buildTimePicker(BuildContext context) {
    return ListTile(
      title: Text(
        "Reminder Time: ${_reminderTime?.format(context) ?? '--:--'}",
      ),
      trailing: const Icon(Icons.access_time),
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (picked != null) setState(() => _reminderTime = picked);
      },
    );
  }

  void _saveMedicine() async {
    if (_formKey.currentState!.validate()) {
      // Call provider or backend here

      final newMedicine = Medicine(
        id: widget.existing?.id ?? Uuid().v4(),
        medicineName: _nameController.text.toString(),
        doctorName: _doctorController.text.trim().isEmpty
            ? null
            : _doctorController.text.trim(),
        dosage: _dosageController.text.toString(),
        scheduleType: _scheduleType,
        startDate: _startDate,
        takenStatus: widget.existing?.takenStatus ?? {},
        takenTimes: widget.existing?.takenTimes ?? {},
        isActive: true,
        needReminder: _needReminder,
        color: selectedColor,
        showOnCalendar: true,
        customIntervalDays: _scheduleType == 'Custom'
            ? int.tryParse(_customIntervalController.text.trim())
            : null,
        reminderTime: _reminderTime?.format(context),
      );

      if (widget.existing != null) {
        await context.read<MedicineProvider>().updateMedicine(newMedicine);
      } else {
        await context.read<MedicineProvider>().addMedicine(newMedicine);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Medicine saved successfully")),
      );
      Navigator.pop(context);
    }
  }
}
// #4CAF50  #4BBC8E  #F9F871  #ff2e5c  #92665a   #ff6184   #ecfd98  #c67538   #c6a0f8  #faac69