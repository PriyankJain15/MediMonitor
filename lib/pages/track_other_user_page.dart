
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medicine_tracker/main.dart';
import 'package:medicine_tracker/services/firestore_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrackOtherUserPage extends StatefulWidget {
  const TrackOtherUserPage({super.key});

  @override
  State<TrackOtherUserPage> createState() => _TrackOtherUserPageState();
}

class _TrackOtherUserPageState extends State<TrackOtherUserPage> {
  final FirestoreService _firestore = FirestoreService();

  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;

  // recent code history (most-recent first)
  List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('codeHistory') ?? <String>[];
    setState(() => _history = list.map((e) => e.toUpperCase()).toList());
  }

  Future<void> _saveToHistory(String code) async {
    final prefs = await SharedPreferences.getInstance();
    final up = code.toUpperCase();
    _history.removeWhere((c) => c == up);
    _history.insert(0, up);
    await prefs.setStringList('codeHistory', _history.take(5).toList()); // keep last 8
  }

  Future<void> _handleTrack() async {
    final code = _codeController.text.trim().toUpperCase();

    if (code.length != 6) {
      setState(() => _errorText = 'Please enter a valid 6-character code');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    final userId = await _firestore.fetchOtherPersonId(code);
    if (!mounted) return;

    if (userId == null) {
      setState(() {
        _isLoading = false;
        _errorText = 'Invalid code or user not found';
      });
      return;
    }

    await _saveToHistory(code);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('viewingUserId', userId);
    await prefs.setBool('isViewingOtherUser', true);

    setState(() => _isLoading = false);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => MyHomePage(viewOnlyUserId: userId)),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(), // unfocus when tapping outside
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Track for Someone Else'),
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 1,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Enter Share Code',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              Autocomplete<String>(
                optionsBuilder: (TextEditingValue tev) {
                  final q = tev.text.trim().toUpperCase();
                  if (_history.isEmpty) return const Iterable<String>.empty();
                  if (q.isEmpty) return _history;
                  return _history.where((h) => h.contains(q));
                },
                fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                  // keep our controller in sync so _handleTrack reads same value
                  _codeController.value = controller.value;
                  _codeController.addListener(() {
                    if (_codeController.text != controller.text) {
                      controller.text = _codeController.text;
                      controller.selection = _codeController.selection;
                    }
                  });

                  return TextField(
                    controller: _codeController,
                    focusNode: focusNode, // must use Autocomplete's focus node
                    maxLength: 6,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                      UpperCaseTextFormatter(),
                    ],
                    decoration: InputDecoration(
                      hintText: 'Eg: A1B2C3',
                      counterText: '',
                      errorText: _errorText,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onSubmitted: (_) => onFieldSubmitted(),
                    onTapOutside: (_) => focusNode.unfocus(), // close overlay on outside tap
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  final opts = options.toList(growable: false);
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(8),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 240, minWidth: 280),
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: opts.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, idx) {
                            final code = opts[idx];
                            return ListTile(
                              dense: true,
                              title: Text(code),
                              onTap: () => onSelected(code),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
                onSelected: (code) {
                  _codeController.text = code;
                  _codeController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _codeController.text.length),
                  );
                },
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleTrack,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Start Tracking', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Uppercase formatter
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
