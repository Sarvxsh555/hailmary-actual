import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import 'vitals_screen.dart';

class MonitorScreen extends StatefulWidget {
  const MonitorScreen({super.key});

  @override
  State<MonitorScreen> createState() => _MonitorScreenState();
}

class _MonitorScreenState extends State<MonitorScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 5 tabs based on screenshot: SpO2, Adherence, Weight, Symptoms, Breath
    _tabController = TabController(length: 5, vsync: this, initialIndex: 1); // Select Adherence by default
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Health Monitoring',
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Multimodal vitals • 7 interlocking modules',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Custom Tab Bar
            SizedBox(
              height: 40,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                indicator: const BoxDecoration(), // Remove default underline indicator
                dividerColor: Colors.transparent,
                labelColor: AppColors.textPrimary,
                unselectedLabelColor: AppColors.textTertiary,
                labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                unselectedLabelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
                tabs: [
                  _buildTab('SpO₂', 0),
                  _buildTab('Adherence', 1),
                  _buildTab('Weight', 2),
                  _buildTab('Symptoms', 3),
                  _buildTab('Breath', 4),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  const VitalsScreen(isEmbedded: true), // We will pass isEmbedded:true to remove its AppBar later
                  const _AdherenceTab(),
                  const Center(child: Text('Weight Data')),
                  const Center(child: Text('Symptoms Data')),
                  const Center(child: Text('Breath Data')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, _) {
        final isSelected = _tabController.index == index;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.divider : AppColors.divider.withOpacity(0.5),
            ),
          ),
          child: Text(text),
        );
      },
    );
  }
}

// ── Adherence Tab Component ─────────────────────────────────

class _AdherenceTab extends StatelessWidget {
  const _AdherenceTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 8),
          GlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Medication Adherence',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '93%',
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Progress Bar
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: AppColors.divider,
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.93,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: LinearGradient(
                          colors: [AppColors.safe, AppColors.warning],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                Text(
                  '14-day rolling window • Override: <60% or 3+ consecutive missed',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                    height: 1.4,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Calendar section
                Text(
                  'Last 14 Days',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Days header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
                    return SizedBox(
                      width: 32,
                      child: Center(
                        child: Text(
                          day,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.textTertiary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 8),
                
                // Week 1 (from screenshot)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _DayCell(status: _DayStatus.taken),
                    _DayCell(status: _DayStatus.taken),
                    _DayCell(status: _DayStatus.taken),
                    _DayCell(status: _DayStatus.taken),
                    _DayCell(status: _DayStatus.missed),
                    _DayCell(status: _DayStatus.taken),
                    _DayCell(status: _DayStatus.taken),
                  ],
                ),
                const SizedBox(height: 8),
                // Week 2 (from screenshot)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _DayCell(status: _DayStatus.taken),
                    _DayCell(status: _DayStatus.taken),
                    _DayCell(status: _DayStatus.taken),
                    _DayCell(status: _DayStatus.taken),
                    _DayCell(status: _DayStatus.missed),
                    _DayCell(status: _DayStatus.taken),
                    _DayCell(status: _DayStatus.taken),
                  ],
                ),
                const SizedBox(height: 8),
                // Next week padding (from screenshot, has some empty dots)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _DayCell(status: _DayStatus.empty),
                    _DayCell(status: _DayStatus.empty),
                    const SizedBox(width: 32),
                    const SizedBox(width: 32),
                    const SizedBox(width: 32),
                    const SizedBox(width: 32),
                    const SizedBox(width: 32),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Alert Box
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
                    '2 missed doses detected. ASHA worker notified via Ni-Kshay dashboard.',
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
          
          const SizedBox(height: 100), // padding for bottom nav
        ],
      ),
    );
  }
}

enum _DayStatus { taken, missed, empty }

class _DayCell extends StatelessWidget {
  final _DayStatus status;

  const _DayCell({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Widget child;

    switch (status) {
      case _DayStatus.taken:
        bgColor = AppColors.safe.withOpacity(0.15);
        child = Icon(Icons.check_rounded, size: 16, color: AppColors.safe);
        break;
      case _DayStatus.missed:
        bgColor = AppColors.emergency.withOpacity(0.15);
        child = Icon(Icons.close_rounded, size: 16, color: AppColors.emergency);
        break;
      case _DayStatus.empty:
      default:
        bgColor = AppColors.divider.withOpacity(0.3);
        child = Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.textTertiary.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
        );
        break;
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(child: child),
    );
  }
}
