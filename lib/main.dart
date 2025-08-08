import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medicine_tracker/pages/home_screen.dart';
import 'package:medicine_tracker/pages/report_screen.dart';
import 'package:medicine_tracker/pages/splash_screen.dart';
import 'package:medicine_tracker/pages/tabbed_calendar_screen.dart';
import 'package:medicine_tracker/provider/medicine_provider.dart';
import 'package:medicine_tracker/provider/share_code_provider.dart';
import 'package:medicine_tracker/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  final prefs = await SharedPreferences.getInstance();
  final isViewingOther = prefs.getBool('isViewingOtherUser') ?? false;
  final viewingUserId = prefs.getString('viewingUserId');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MedicineProvider()),
        ChangeNotifierProvider(create: (_) => ShareCodeProvider()),
      ],
      child: MyApp(viewingUserId: isViewingOther ? viewingUserId : null),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String? viewingUserId;
  const MyApp({super.key, required this.viewingUserId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: medicineAppTheme,
      debugShowCheckedModeBanner: false,
      home: SplashScreen(viewOnlyUserId: viewingUserId),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String? viewOnlyUserId;
  const MyHomePage({super.key, this.viewOnlyUserId});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 1;

  final List<Widget> _screens = [
    TabbedCalendarScreen(), // Bottom tab 1
    HomeScreen(),           // Bottom tab 2
    ReportScreen(), // Bottom tab 3
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

    // If viewOnlyUserId was passed from splash, activate view mode
    if (widget.viewOnlyUserId != null) {
      final provider = Provider.of<MedicineProvider>(context, listen: false);
      provider.setViewingUser(widget.viewOnlyUserId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            label: 'Medicines',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Report',
          ),
        ],
      ),
    );
  }
}
