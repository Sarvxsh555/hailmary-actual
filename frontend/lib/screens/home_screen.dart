import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/hailmary_button.dart';
import 'emergency_screen.dart';
import 'upload_screen.dart';
import 'vitals_screen.dart';
import 'cough_screen.dart';
import 'government_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
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
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // ── Header Row ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 15,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Stay Safe 💙',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        // The user icon can just tap locally or we disable it 
                        // since Profile is now in the taskbar. For now, doing nothing.
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person_outline_rounded,
                          color: AppColors.info,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // ── HailMary Button ──
                Center(
                  child: HailMaryButton(
                    onPressed: _onHailMaryPressed,
                    size: 190,
                  ),
                ),

                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'This will alert emergency health services and log an emergency event.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 13,
                        ),
                  ),
                ),

                const SizedBox(height: 44),

                // ── Multimodal Monitoring Dashboard ──
                Text(
                  'MULTIMODAL MONITORING',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Grid
                Row(
                  children: [
                    Expanded(child: _MonitoringCard(icon: '🗣️', title: 'Cough Acoustics', value: '0.71', subtitle: 'Recovery Index', weight: '30%')),
                    const SizedBox(width: 14),
                    Expanded(child: _MonitoringCard(icon: '🫁', title: 'Chest X-Ray / CV', value: 'Mild', valueColor: AppColors.warning, subtitle: 'White patch detected', weight: '')),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _MonitoringCard(icon: '💊', title: 'Med. Adherence', value: '93%', subtitle: '14-day window', weight: '20%')),
                    const SizedBox(width: 14),
                    Expanded(child: _MonitoringCard(icon: '🩸', title: 'SpO₂ Monitor', value: '97%', valueColor: AppColors.safe, subtitle: 'Camera PPG · Normal', weight: '+10% override')),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _MonitoringCard(icon: '😮‍💨', title: 'Breathlessness', value: 'mMRC 1', valueColor: AppColors.safe, subtitle: 'Mild, hurrying only', weight: '20%')),
                    const SizedBox(width: 14),
                    Expanded(child: _MonitoringCard(icon: '⚖️', title: 'Weight Track', value: '+0.8kg', valueColor: AppColors.textPrimary, subtitle: 'This fortnight', weight: '10%')),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Alert Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.warning.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '2 missed doses this week — ASHA worker Lakshmi Devi has been alerted.',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.warning,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // ── 8-Week TPS Trend ──
                Text(
                  '8-WEEK TPS TREND',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 16),
                
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Treatment Progress',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A237E).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.account_balance_rounded, size: 12, color: Color(0xFF1A237E)),
                                const SizedBox(width: 6),
                                Text(
                                  'Ni-Kshay Synced',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1A237E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Bar Chart
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _TrendBar(height: 30, label: 'W1', isCurrent: false),
                          _TrendBar(height: 35, label: 'W2', isCurrent: false),
                          _TrendBar(height: 42, label: 'W3', isCurrent: false),
                          _TrendBar(height: 48, label: 'W4', isCurrent: false),
                          _TrendBar(height: 52, label: 'W5', isCurrent: false),
                          _TrendBar(height: 58, label: 'W6', isCurrent: false),
                          _TrendBar(height: 60, label: 'W7', isCurrent: false),
                          _TrendBar(height: 65, label: 'W8', isCurrent: true),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 14),
                
                // Integration Live Card
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A237E).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.account_balance_rounded, color: Color(0xFF1A237E), size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ni-Kshay / ASHA Integration',
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Last sync: Today 09:30 AM · ID linked · FHIR R4',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.safe.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(width: 6, height: 6, decoration: BoxDecoration(color: AppColors.safe, shape: BoxShape.circle)),
                            const SizedBox(width: 4),
                            Text('LIVE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.safe, letterSpacing: 0.5)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Status Card ──
                GlassCard(
                  accentColor: AppColors.safe,
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.safe.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.shield_outlined,
                          color: AppColors.safe,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'System Active',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'All services are operational',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.safe,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.safe.withValues(alpha: 0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Monitoring Card ──────────────────────────────────────────

class _MonitoringCard extends StatelessWidget {
  final String icon;
  final String title;
  final String value;
  final Color? valueColor;
  final String subtitle;
  final String weight;

  const _MonitoringCard({
    required this.icon,
    required this.title,
    required this.value,
    this.valueColor,
    required this.subtitle,
    required this.weight,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
          if (weight.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Weight: $weight',
              style: GoogleFonts.inter(
                fontSize: 10,
                color: AppColors.textTertiary.withOpacity(0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Trend Bar ──────────────────────────────────────────

class _TrendBar extends StatelessWidget {
  final double height;
  final String label;
  final bool isCurrent;

  const _TrendBar({
    required this.height,
    required this.label,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 32,
          height: height,
          decoration: BoxDecoration(
            color: isCurrent 
                ? AppColors.warning.withOpacity(0.4) 
                : AppColors.safe.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
            border: isCurrent ? Border.all(color: AppColors.warning.withOpacity(0.8), width: 1.5) : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
            color: isCurrent ? AppColors.warning : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

// ── Emergency Confirmation Dialog ──────────────────────────────

class _EmergencyConfirmDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _EmergencyConfirmDialog({
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
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
                'This will alert campus health services and log an emergency event.',
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
