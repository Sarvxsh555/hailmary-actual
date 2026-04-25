import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_bottom_nav.dart';
import 'home_screen.dart';
import 'government_screen.dart';
import 'cough_screen.dart';
import 'upload_screen.dart';
import 'monitor_screen.dart';
import 'profile_screen.dart';
import 'emergency_screen.dart';
import 'tb_map_screen.dart';

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
    TBMapScreen(),
    GovernmentScreen(),
    ProfileScreen(),
  ];

  void _onHailMaryPressed() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _EmergencyConfirmDialog(
        onConfirm: () {
          Navigator.pop(ctx);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const EmergencyScreen(),
            ),
          );
        },
        onCancel: () => Navigator.pop(ctx),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true, // Crucial for floating nav bar
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90, right: 8), // Lift it above the CustomBottomNav
        child: SizedBox(
          width: 56,
          height: 56,
          child: FloatingActionButton(
            heroTag: 'hailmary_fab',
            onPressed: _onHailMaryPressed,
            backgroundColor: AppColors.emergency,
            elevation: 8,
            shape: const CircleBorder(),
            child: const Icon(Icons.medical_services_rounded, color: Colors.white, size: 28),
          ),
        ),
      ),
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
          CustomNavItem(icon: Icons.map_rounded, label: 'Map'),
          CustomNavItem(icon: Icons.account_balance_rounded, label: 'Gov'),
          CustomNavItem(icon: Icons.person_rounded, label: 'Profile'),
        ],
      ),
    );
  }
}

// ── Emergency Confirm Dialog ──────────────────────────────────
class _EmergencyConfirmDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _EmergencyConfirmDialog({
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.emergency.withValues(alpha: 0.15),
                blurRadius: 40,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.emergencyLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.emergency_rounded,
                  color: AppColors.emergency,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Trigger Emergency?',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This will alert health services and log an emergency event.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: BorderSide(color: AppColors.divider),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emergency,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Confirm',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
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
}
