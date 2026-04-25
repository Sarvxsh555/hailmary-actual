import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_bottom_nav.dart';
import 'home_screen.dart';
import 'government_screen.dart';
import 'cough_screen.dart';
import 'upload_screen.dart';
import 'monitor_screen.dart';
import 'profile_screen.dart';

class PatientMainScreen extends StatefulWidget {
  const PatientMainScreen({super.key});

  @override
  State<PatientMainScreen> createState() => _PatientMainScreenState();
}

class _PatientMainScreenState extends State<PatientMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CoughScreen(),
    UploadScreen(),
    MonitorScreen(),
    GovernmentScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true, // Crucial for floating nav bar
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          CustomNavItem(icon: Icons.home_rounded, label: 'Home'),
          CustomNavItem(icon: Icons.graphic_eq_rounded, label: 'Cough'),
          CustomNavItem(icon: Icons.medical_information_outlined, label: 'X-Ray'),
          CustomNavItem(icon: Icons.timeline_rounded, label: 'Monitor'),
          CustomNavItem(icon: Icons.account_balance_rounded, label: 'Gov'),
          CustomNavItem(icon: Icons.person_rounded, label: 'Profile'),
        ],
      ),
    );
  }
}
