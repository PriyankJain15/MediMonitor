import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medicine_tracker/main.dart';
import 'package:medicine_tracker/pages/phone_authentication.dart';
import 'package:medicine_tracker/provider/medicine_provider.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  final String? viewOnlyUserId;

  const SplashScreen({super.key, this.viewOnlyUserId});

  @override
  State<StatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF2D75C9),
        statusBarIconBrightness: Brightness.light,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      final provider = context.read<MedicineProvider>();

      if (user != null) {
        provider.setUserId(user.uid);

        // Enable view-only mode if applicable
        if (widget.viewOnlyUserId != null) {
          provider.setViewingUser(widget.viewOnlyUserId);
        }

        Timer(const Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => MyHomePage(viewOnlyUserId: widget.viewOnlyUserId),
            ),
          );
        });
      } else {
        Timer(const Duration(seconds: 3), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => PhoneAuthentication()),
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2D75C9),
              Color(0xFF3498DB),
              Color.fromARGB(255, 106, 222, 238),
            ],
          ),
        ),
        child: const Center(
          child: CircleAvatar(
            backgroundColor: Colors.white,
            backgroundImage: AssetImage("assets/icon.png"),
            radius: 100,
          ),
        ),
      ),
    );
  }
}
