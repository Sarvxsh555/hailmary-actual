import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';
import '../widgets/glass_card.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Toggle states
  bool _offlineMode = false;
  bool _autoSync = true;
  bool _emergencyAlerts = true;
  String _language = 'English';

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
                child: Icon(Icons.logout_rounded,
                    color: AppColors.warning, size: 28),
              ),
              const SizedBox(height: 18),
              Text('Sign Out?',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  )),
              const SizedBox(height: 8),
              Text('You will be returned to the login screen.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  )),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        side: BorderSide(color: AppColors.divider),
                      ),
                      child: Text('Cancel',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          )),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.of(context).pushAndRemoveUntil(
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => const LoginScreen(),
                            transitionsBuilder: (_, animation, __, child) =>
                                FadeTransition(
                                    opacity: animation, child: child),
                            transitionDuration:
                                const Duration(milliseconds: 400),
                          ),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warning,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text('Sign Out',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          )),
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Profile',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, size: 20),
            onPressed: _handleLogout,
            tooltip: 'Sign Out',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // ══════════════════════════════════════════════════════
              //  Patient Demographics
              // ══════════════════════════════════════════════════════
              GlassCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.info.withValues(alpha: 0.7),
                            AppColors.info,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'AK',
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Arjun Kumar',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'STU-2026-001',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Demographics grid
                    Row(
                      children: [
                        _DemoChip(label: 'Age', value: '20'),
                        const SizedBox(width: 8),
                        _DemoChip(label: 'Gender', value: 'Male'),
                        const SizedBox(width: 8),
                        _DemoChip(label: 'Blood', value: 'B+'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _DemoChip(label: 'Weight', value: '68 kg'),
                        const SizedBox(width: 8),
                        _DemoChip(label: 'Height', value: '175 cm'),
                        const SizedBox(width: 8),
                        _DemoChip(label: 'BMI', value: '22.2'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ══════════════════════════════════════════════════════
              //  Settings Toggles
              // ══════════════════════════════════════════════════════
              Text(
                'Settings',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: [
                    ValueListenableBuilder<ThemeMode>(
                      valueListenable: ThemeProvider.instance,
                      builder: (context, _, __) {
                        return _ToggleTile(
                          icon: Icons.dark_mode_rounded,
                          title: 'Dark Mode',
                          subtitle: 'Deep slate medical aesthetic',
                          value: ThemeProvider.instance.isDarkMode,
                          onChanged: (v) => ThemeProvider.instance.toggleTheme(),
                          color: const Color(0xFF7B68EE),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 60),
                    _ToggleTile(
                      icon: Icons.wifi_off_rounded,
                      title: 'Offline Mode',
                      subtitle: 'Cache data for areas with poor connectivity',
                      value: _offlineMode,
                      onChanged: (v) => setState(() => _offlineMode = v),
                      color: AppColors.warning,
                    ),
                    const Divider(height: 1, indent: 60),
                    _ToggleTile(
                      icon: Icons.sync_rounded,
                      title: 'Auto-Sync',
                      subtitle: 'Sync records when connected to internet',
                      value: _autoSync,
                      onChanged: (v) => setState(() => _autoSync = v),
                      color: AppColors.info,
                    ),
                    const Divider(height: 1, indent: 60),
                    _ToggleTile(
                      icon: Icons.notifications_active_outlined,
                      title: 'Emergency Alerts',
                      subtitle: 'Push notifications for critical updates',
                      value: _emergencyAlerts,
                      onChanged: (v) => setState(() => _emergencyAlerts = v),
                      color: AppColors.emergency,
                    ),
                    const Divider(height: 1, indent: 60),
                    _LanguageTile(
                      currentLanguage: _language,
                      onChanged: (lang) =>
                          setState(() => _language = lang),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ══════════════════════════════════════════════════════
              //  ML Model Info
              // ══════════════════════════════════════════════════════
              Text(
                'AI Model Information',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                accentColor: const Color(0xFF7B68EE),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF7B68EE)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.psychology_rounded,
                              color: Color(0xFF7B68EE), size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'EfficientNet-B3',
                                style: GoogleFonts.outfit(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'Chest X-Ray Classification Model',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Model metrics
                    Row(
                      children: [
                        Expanded(
                          child: _ModelMetric(
                            label: 'AUC-ROC',
                            value: '0.86',
                            color: AppColors.safe,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ModelMetric(
                            label: 'Accuracy',
                            value: '84.2%',
                            color: AppColors.info,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ModelMetric(
                            label: 'F1-Score',
                            value: '0.83',
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7B68EE).withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              const Color(0xFF7B68EE).withValues(alpha: 0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Architecture Details',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _DetailRow('Input Resolution', '300 × 300 px'),
                          _DetailRow('Parameters', '12.2M'),
                          _DetailRow('Inference Time', '~180ms'),
                          _DetailRow('Classes', '14 pathologies'),
                          _DetailRow('Framework', 'PyTorch → ONNX'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ══════════════════════════════════════════════════════
              //  Dataset Attributions
              // ══════════════════════════════════════════════════════
              Text(
                'Dataset Attributions',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _DatasetCard(
                name: 'NIH ChestX-ray14',
                description:
                    '112,120 frontal-view X-ray images from 30,805 unique patients with 14 disease labels.',
                source: 'National Institutes of Health Clinical Center',
                license: 'CC0 1.0 Public Domain',
                color: AppColors.info,
              ),
              const SizedBox(height: 10),
              _DatasetCard(
                name: 'CheXpert',
                description:
                    '224,316 chest radiographs from 65,240 patients with radiologist-labeled observations.',
                source: 'Stanford Machine Learning Group',
                license: 'Stanford Research Use Agreement',
                color: AppColors.safe,
              ),
              const SizedBox(height: 10),
              _DatasetCard(
                name: 'MIMIC-CXR',
                description:
                    '377,110 chest X-rays with structured labels and free-text radiology reports.',
                source: 'PhysioNet / MIT-LCP',
                license: 'PhysioNet Credentialed Health Data',
                color: AppColors.warning,
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
//  Demographics Chip
// ══════════════════════════════════════════════════════════════════════

class _DemoChip extends StatelessWidget {
  final String label;
  final String value;

  const _DemoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.info.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.info.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
//  Toggle Tile
// ══════════════════════════════════════════════════════════════════════

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color color;

  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 11,
          color: AppColors.textTertiary,
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: color,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
//  Language Tile
// ══════════════════════════════════════════════════════════════════════

class _LanguageTile extends StatelessWidget {
  final String currentLanguage;
  final ValueChanged<String> onChanged;

  const _LanguageTile({
    required this.currentLanguage,
    required this.onChanged,
  });

  static const _languages = [
    'English',
    'हिन्दी',
    'தமிழ்',
    'తెలుగు',
    'ಕನ್ನಡ',
    'मराठी',
  ];

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.safe.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child:
            Icon(Icons.translate_rounded, color: AppColors.safe, size: 20),
      ),
      title: Text(
        'Language',
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        currentLanguage,
        style: GoogleFonts.inter(
          fontSize: 11,
          color: AppColors.textTertiary,
        ),
      ),
      trailing: PopupMenuButton<String>(
        onSelected: onChanged,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        offset: const Offset(0, 40),
        itemBuilder: (_) => _languages
            .map((lang) => PopupMenuItem(
                  value: lang,
                  child: Row(
                    children: [
                      if (lang == currentLanguage)
                        Icon(Icons.check_rounded,
                            size: 16, color: AppColors.safe)
                      else
                        const SizedBox(width: 16),
                      const SizedBox(width: 8),
                      Text(lang, style: GoogleFonts.inter(fontSize: 14)),
                    ],
                  ),
                ))
            .toList(),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.safe.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                currentLanguage,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.safe,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.expand_more_rounded,
                  size: 16, color: AppColors.safe),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
//  Model Metric
// ══════════════════════════════════════════════════════════════════════

class _ModelMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ModelMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
//  Detail Row (for model architecture)
// ══════════════════════════════════════════════════════════════════════

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 11, color: AppColors.textTertiary)),
          Text(value,
              style: GoogleFonts.sourceCodePro(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
//  Dataset Card
// ══════════════════════════════════════════════════════════════════════

class _DatasetCard extends StatelessWidget {
  final String name;
  final String description;
  final String source;
  final String license;
  final Color color;

  const _DatasetCard({
    required this.name,
    required this.description,
    required this.source,
    required this.license,
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
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.dataset_outlined, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.business_rounded,
                  size: 12, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  source,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.gavel_rounded,
                  size: 12, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text(
                license,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
