import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:medicine_tracker/pages/splash_screen.dart';
import 'package:medicine_tracker/pages/track_other_user_page.dart';
import 'package:medicine_tracker/utils/medicine_utils.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicine_tracker/provider/share_code_provider.dart';
import 'package:medicine_tracker/provider/medicine_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavigatDrawer extends StatefulWidget {
  const NavigatDrawer({super.key});

  @override
  State<NavigatDrawer> createState() => _NavigatDrawerState();
}

class _NavigatDrawerState extends State<NavigatDrawer> {
  String? _shareCode;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadShareCode();
  }

  Future<void> _loadShareCode() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final provider = context.read<ShareCodeProvider>();
    final code = await provider.fetchOwnShareCode(user.uid);

    setState(() {
      _shareCode = code;
      _isLoading = false;
    });
  }

  Future<void> _generateCodeIfNotExists() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final provider = Provider.of<ShareCodeProvider>(context, listen: false);
      final existingCode = await provider.fetchOwnShareCode(user.uid);

      if (existingCode != null) {
        setState(() {
          _shareCode = existingCode;
        });
      } else {
        final code = await generateUniqueCode(FirebaseFirestore.instance);
        await provider.generateAndSaveCode(userId: user.uid, code: code);

        setState(() {
          _shareCode = code;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isViewingOtherUser = context
        .watch<MedicineProvider>()
        .isViewingOtherUser;
    final viewingUserId = context.watch<MedicineProvider>().viewingUserId ?? '';

    return Drawer(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: ListView(
          children: [
            const DrawerHeader(
              child: Center(
                child: Text("LOGO", style: TextStyle(fontSize: 35)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                isViewingOtherUser
                    ? "You are tracking someone else\n(ID: $viewingUserId)"
                    : "You are tracking yourself",
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.my_location),
              title: const Text("Track yourself"),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isViewingOtherUser', false);
                await prefs.remove('viewingUserId');

                if (mounted) {
                  // Show confirmation before navigating
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Switched back to your profile"),
                      duration: Duration(seconds: 2),
                    ),
                  );

                  // Wait for snack bar to show (optional: add slight delay)
                  await Future.delayed(Duration(milliseconds: 500));

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => SplashScreen()),
                    (route) => false,
                  );
                }
              },
            ),

            ListTile(
              leading: const Icon(Icons.person_search),
              title: const Text("Track for someone else"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TrackOtherUserPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.vpn_key),
              title: Text(
                _shareCode != null
                    ? "Code already generated"
                    : "Generate Share Code",
              ),
              onTap: _shareCode != null || _isLoading
                  ? null
                  : () => _generateCodeIfNotExists(),
            ),
            if (_shareCode != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 60,
                  vertical: 8,
                ),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black26),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_open, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "CODE: $_shareCode",
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Log Out"),
              onTap: () async{await logout(context);}, // Log out logic intentionally skipped
            ),
          ],
        ),
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
  // 1. Sign out from Firebase
  await FirebaseAuth.instance.signOut();

  // 3. Clear SharedPreferences keys for view-only mode
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('isViewingOtherUser');
  await prefs.remove('viewingUserId');
  await prefs.remove('userId');

  // 4. Navigate to splash/login
  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => SplashScreen()),
                    (route) => false,
                  );
}
}
