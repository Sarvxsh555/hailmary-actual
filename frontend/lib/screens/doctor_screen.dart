import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import 'login_screen.dart';

class DoctorScreen extends StatefulWidget {
  const DoctorScreen({super.key});

  @override
  State<DoctorScreen> createState() => _DoctorScreenState();
}

class _DoctorScreenState extends State<DoctorScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  int _selectedTab = 0;

  // Mock data
  final List<_PatientData> _patients = [
    _PatientData(
      name: 'Arjun Kumar',
      id: 'PAT-2026-001',
      age: 20,
      lastVisit: DateTime.now().subtract(const Duration(hours: 2)),
      condition: 'Chest Pain — Under Observation',
      riskLevel: _RiskLevel.high,
      vitals: _VitalsSnapshot(hr: 92, spo2: 96, bp: '138/88', temp: 99.1),
    ),
    _PatientData(
      name: 'Priya Sharma',
      id: 'PAT-2026-019',
      age: 19,
      lastVisit: DateTime.now().subtract(const Duration(hours: 5)),
      condition: 'Seasonal Allergies',
      riskLevel: _RiskLevel.low,
      vitals: _VitalsSnapshot(hr: 74, spo2: 99, bp: '118/76', temp: 98.4),
    ),
    _PatientData(
      name: 'Rahul Desai',
      id: 'PAT-2026-042',
      age: 21,
      lastVisit: DateTime.now().subtract(const Duration(days: 1)),
      condition: 'Post-Fracture Follow-up',
      riskLevel: _RiskLevel.medium,
      vitals: _VitalsSnapshot(hr: 80, spo2: 98, bp: '125/82', temp: 98.6),
    ),
    _PatientData(
      name: 'Sneha Patel',
      id: 'PAT-2026-007',
      age: 20,
      lastVisit: DateTime.now().subtract(const Duration(hours: 8)),
      condition: 'Migraine — Recurring Episodes',
      riskLevel: _RiskLevel.medium,
      vitals: _VitalsSnapshot(hr: 68, spo2: 98, bp: '110/70', temp: 98.2),
    ),
    _PatientData(
      name: 'Vikram Singh',
      id: 'PAT-2026-033',
      age: 22,
      lastVisit: DateTime.now().subtract(const Duration(days: 3)),
      condition: 'Routine Checkup',
      riskLevel: _RiskLevel.low,
      vitals: _VitalsSnapshot(hr: 72, spo2: 99, bp: '120/78', temp: 98.5),
    ),
  ];

  final List<_EmergencyAlert> _emergencyAlerts = [
    _EmergencyAlert(
      patientName: 'Arjun Kumar',
      patientId: 'PAT-2026-001',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      location: 'Sector 4, Building B, Room 204',
      description: 'Severe chest pain, difficulty breathing',
      isResolved: false,
    ),
    _EmergencyAlert(
      patientName: 'Neha Gupta',
      patientId: 'PAT-2026-055',
      timestamp: DateTime.now().subtract(const Duration(hours: 18)),
      location: 'Downtown Mall, Ground Floor',
      description: 'Fainting episode, hit head on desk',
      isResolved: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 40,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.warning,
                  size: 28,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Sign Out?',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You will be returned to the login screen.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
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
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => const LoginScreen(),
                            transitionsBuilder: (_, animation, __, child) {
                              return FadeTransition(
                                  opacity: animation, child: child);
                            },
                            transitionDuration:
                                const Duration(milliseconds: 400),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warning,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Sign Out',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // ── Header ──
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Dr. Mehra',
                          style: GoogleFonts.outfit(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Notification badge
                        Stack(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.safe.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.notifications_outlined,
                                color: AppColors.safe,
                                size: 22,
                              ),
                            ),
                            Positioned(
                              right: 2,
                              top: 2,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: AppColors.emergency,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.background,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '2',
                                    style: GoogleFonts.inter(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: _handleLogout,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.safe.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                'DM',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.safe,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Tab Bar ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      _DoctorTab(
                        label: 'Overview',
                        icon: Icons.dashboard_outlined,
                        isSelected: _selectedTab == 0,
                        onTap: () => setState(() => _selectedTab = 0),
                      ),
                      _DoctorTab(
                        label: 'Patients',
                        icon: Icons.people_outline_rounded,
                        isSelected: _selectedTab == 1,
                        onTap: () => setState(() => _selectedTab = 1),
                      ),
                      _DoctorTab(
                        label: 'Alerts',
                        icon: Icons.warning_amber_rounded,
                        isSelected: _selectedTab == 2,
                        onTap: () => setState(() => _selectedTab = 2),
                        badgeCount: _emergencyAlerts
                            .where((a) => !a.isResolved)
                            .length,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Content ──
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _selectedTab == 0
                      ? _buildOverview()
                      : _selectedTab == 1
                          ? _buildPatientList()
                          : _buildAlerts(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Overview Tab ──────────────────────────────────────────────────

  Widget _buildOverview() {
    final activeAlerts = _emergencyAlerts.where((a) => !a.isResolved).length;
    final highRisk =
        _patients.where((p) => p.riskLevel == _RiskLevel.high).length;

    return SingleChildScrollView(
      key: const ValueKey('overview'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Stats Row ──
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.people_outline_rounded,
                  label: 'Total Patients',
                  value: '${_patients.length}',
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.warning_amber_rounded,
                  label: 'Active Alerts',
                  value: '$activeAlerts',
                  color: AppColors.emergency,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.priority_high_rounded,
                  label: 'High Risk',
                  value: '$highRisk',
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.check_circle_outline,
                  label: 'Resolved Today',
                  value: '${_emergencyAlerts.where((a) => a.isResolved).length}',
                  color: AppColors.safe,
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ── Active Emergency ──
          if (activeAlerts > 0) ...[
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.emergency,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.emergency.withValues(alpha: 0.4),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Active Emergencies',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._emergencyAlerts
                .where((a) => !a.isResolved)
                .map((alert) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _EmergencyAlertCard(alert: alert),
                    )),
            const SizedBox(height: 16),
          ],

          // ── Recent Patients ──
          Text(
            'Recent Patients',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ..._patients.take(3).map((patient) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _PatientCard(
                  patient: patient,
                  onTap: () => _showPatientDetail(patient),
                ),
              )),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Patient List Tab ──────────────────────────────────────────────

  Widget _buildPatientList() {
    return SingleChildScrollView(
      key: const ValueKey('patients'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded,
                    color: AppColors.textTertiary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search patients...',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textTertiary,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Patient list
          ..._patients.map((patient) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _PatientCard(
                  patient: patient,
                  onTap: () => _showPatientDetail(patient),
                ),
              )),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Alerts Tab ────────────────────────────────────────────────────

  Widget _buildAlerts() {
    return SingleChildScrollView(
      key: const ValueKey('alerts'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_emergencyAlerts.where((a) => !a.isResolved).isNotEmpty) ...[
            Text(
              'Active',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.emergency,
              ),
            ),
            const SizedBox(height: 10),
            ..._emergencyAlerts
                .where((a) => !a.isResolved)
                .map((alert) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _EmergencyAlertCard(alert: alert),
                    )),
            const SizedBox(height: 20),
          ],
          Text(
            'Resolved',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.safe,
            ),
          ),
          const SizedBox(height: 10),
          ..._emergencyAlerts
              .where((a) => a.isResolved)
              .map((alert) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _EmergencyAlertCard(alert: alert),
                  )),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Patient Detail Bottom Sheet ───────────────────────────────────

  void _showPatientDetail(_PatientData patient) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PatientDetailSheet(patient: patient),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
//  WIDGET: Doctor Tab
// ══════════════════════════════════════════════════════════════════════

class _DoctorTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final int badgeCount;

  const _DoctorTab({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textTertiary,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.textTertiary,
                ),
              ),
              if (badgeCount > 0) ...[
                const SizedBox(width: 5),
                Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: AppColors.emergency,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$badgeCount',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
//  WIDGET: Stat Card
// ══════════════════════════════════════════════════════════════════════

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      accentColor: color,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
//  WIDGET: Patient Card
// ══════════════════════════════════════════════════════════════════════

class _PatientCard extends StatefulWidget {
  final _PatientData patient;
  final VoidCallback onTap;

  const _PatientCard({required this.patient, required this.onTap});

  @override
  State<_PatientCard> createState() => _PatientCardState();
}

class _PatientCardState extends State<_PatientCard> {
  bool _isPressed = false;

  Color get _riskColor {
    switch (widget.patient.riskLevel) {
      case _RiskLevel.high:
        return AppColors.emergency;
      case _RiskLevel.medium:
        return AppColors.warning;
      case _RiskLevel.low:
        return AppColors.safe;
    }
  }

  String get _riskLabel {
    switch (widget.patient.riskLevel) {
      case _RiskLevel.high:
        return 'HIGH';
      case _RiskLevel.medium:
        return 'MED';
      case _RiskLevel.low:
        return 'LOW';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _riskColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    widget.patient.name
                        .split(' ')
                        .map((n) => n[0])
                        .take(2)
                        .join(),
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _riskColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.patient.name,
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _riskColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _riskLabel,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _riskColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.patient.condition,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Last visit: ${_formatTimeAgo(widget.patient.lastVisit)}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
//  WIDGET: Emergency Alert Card
// ══════════════════════════════════════════════════════════════════════

class _EmergencyAlertCard extends StatelessWidget {
  final _EmergencyAlert alert;

  const _EmergencyAlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final bgColor = alert.isResolved ? AppColors.safe : AppColors.emergency;
    return GlassCard(
      accentColor: bgColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: bgColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  alert.isResolved
                      ? Icons.check_circle_outline
                      : Icons.emergency_rounded,
                  color: bgColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.patientName,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      alert.patientId,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: bgColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  alert.isResolved ? 'RESOLVED' : 'ACTIVE',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: bgColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _AlertInfoRow(
            icon: Icons.location_on_outlined,
            text: alert.location,
          ),
          const SizedBox(height: 6),
          _AlertInfoRow(
            icon: Icons.description_outlined,
            text: alert.description,
          ),
          const SizedBox(height: 6),
          _AlertInfoRow(
            icon: Icons.access_time_rounded,
            text: _formatTimeAgo(alert.timestamp),
          ),
          if (!alert.isResolved) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Marked as resolved'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: AppColors.safe,
                    ),
                  );
                },
                icon: const Icon(Icons.check_rounded, size: 18),
                label: Text(
                  'Resolve',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.safe,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AlertInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _AlertInfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textTertiary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
//  WIDGET: Patient Detail Bottom Sheet
// ══════════════════════════════════════════════════════════════════════

class _PatientDetailSheet extends StatelessWidget {
  final _PatientData patient;

  const _PatientDetailSheet({required this.patient});

  Color get _riskColor {
    switch (patient.riskLevel) {
      case _RiskLevel.high:
        return AppColors.emergency;
      case _RiskLevel.medium:
        return AppColors.warning;
      case _RiskLevel.low:
        return AppColors.safe;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              const SizedBox(height: 12),
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Patient Header
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _riskColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Text(
                        patient.name
                            .split(' ')
                            .map((n) => n[0])
                            .take(2)
                            .join(),
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: _riskColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.name,
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${patient.id}  •  Age ${patient.age}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Text(
                patient.condition,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: _riskColor,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 28),

              // Vitals Grid
              Text(
                'Current Vitals',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _VitalsCard(
                      icon: Icons.favorite_rounded,
                      label: 'Heart Rate',
                      value: '${patient.vitals.hr}',
                      unit: 'bpm',
                      color: AppColors.emergency,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _VitalsCard(
                      icon: Icons.water_drop_rounded,
                      label: 'SpO₂',
                      value: '${patient.vitals.spo2}',
                      unit: '%',
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _VitalsCard(
                      icon: Icons.speed_rounded,
                      label: 'Blood Pressure',
                      value: patient.vitals.bp,
                      unit: 'mmHg',
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _VitalsCard(
                      icon: Icons.thermostat_rounded,
                      label: 'Temperature',
                      value: '${patient.vitals.temp}',
                      unit: '°F',
                      color: AppColors.safe,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Actions
              Text(
                'Actions',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),

              _ActionButton(
                icon: Icons.medical_information_outlined,
                label: 'View X-Ray Reports',
                color: AppColors.info,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Feature coming soon!'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: AppColors.info,
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _ActionButton(
                icon: Icons.note_add_outlined,
                label: 'Add Clinical Notes',
                color: AppColors.warning,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Feature coming soon!'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: AppColors.warning,
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _ActionButton(
                icon: Icons.history_rounded,
                label: 'View Full History',
                color: AppColors.safe,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Feature coming soon!'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: AppColors.safe,
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
//  WIDGET: Vitals Card (Doctor Detail)
// ══════════════════════════════════════════════════════════════════════

class _VitalsCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _VitalsCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      accentColor: color,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
//  WIDGET: Action Button
// ══════════════════════════════════════════════════════════════════════

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.color.withValues(alpha: 0.12),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(widget.icon, color: widget.color, size: 20),
              ),
              const SizedBox(width: 14),
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: widget.color.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
//  DATA MODELS
// ══════════════════════════════════════════════════════════════════════

enum _RiskLevel { high, medium, low }

class _PatientData {
  final String name;
  final String id;
  final int age;
  final DateTime lastVisit;
  final String condition;
  final _RiskLevel riskLevel;
  final _VitalsSnapshot vitals;

  const _PatientData({
    required this.name,
    required this.id,
    required this.age,
    required this.lastVisit,
    required this.condition,
    required this.riskLevel,
    required this.vitals,
  });
}

class _VitalsSnapshot {
  final int hr;
  final int spo2;
  final String bp;
  final double temp;

  const _VitalsSnapshot({
    required this.hr,
    required this.spo2,
    required this.bp,
    required this.temp,
  });
}

class _EmergencyAlert {
  final String patientName;
  final String patientId;
  final DateTime timestamp;
  final String location;
  final String description;
  final bool isResolved;

  const _EmergencyAlert({
    required this.patientName,
    required this.patientId,
    required this.timestamp,
    required this.location,
    required this.description,
    required this.isResolved,
  });
}

// ══════════════════════════════════════════════════════════════════════
//  HELPER
// ══════════════════════════════════════════════════════════════════════

String _formatTimeAgo(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}
