import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../models/symptom_profile.dart';

class SymptomAnalysisScreen extends StatefulWidget {
  final SymptomProfile? initial;
  const SymptomAnalysisScreen({super.key, this.initial});

  @override
  State<SymptomAnalysisScreen> createState() => _SymptomAnalysisScreenState();
}

class _SymptomAnalysisScreenState extends State<SymptomAnalysisScreen> {
  String? _fever;
  String? _cough;
  bool _sweats      = false;
  bool _weightLoss  = false;
  bool _lossApp     = false;
  bool _fatigue     = false;
  bool _chestPain   = false;
  String _duration  = '< 1 Week';

  bool get _isDaySlot {
    final m = DateTime.now().hour * 60 + DateTime.now().minute;
    return m >= (4 * 60 + 59) && m < (17 * 60);
  }
  Color get _slot => _isDaySlot ? AppColors.warning : AppColors.primary;

  @override
  void initState() {
    super.initState();
    final s = widget.initial;
    if (s != null) {
      _fever     = s.feverLevel;
      _cough     = s.coughType;
      _sweats    = s.hasSweats;
      _weightLoss = s.hasWeightLoss;
      _lossApp   = s.hasLossAppetite;
      _fatigue   = s.hasFatigue;
      _chestPain = s.hasChestPain;
      _duration  = s.duration;
    }
  }

  SymptomProfile get _profile => SymptomProfile(
    feverLevel: _fever,
    coughType: _cough,
    hasSweats: _sweats,
    hasWeightLoss: _weightLoss,
    hasLossAppetite: _lossApp,
    hasFatigue: _fatigue,
    hasChestPain: _chestPain,
    duration: _duration,
  );

  Color _riskCol(String r) {
    switch (r) {
      case 'HIGH':     return AppColors.emergency;
      case 'MODERATE': return AppColors.warning;
      case 'LOW':      return AppColors.safe;
      default:         return AppColors.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p   = _profile;
    final rc  = _riskCol(p.riskCategory);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(children: [
        Positioned(bottom: -80, left: -80, child: Container(
          width: 260, height: 260,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [_slot.withOpacity(0.06), Colors.transparent]),
          ),
        )),
        SafeArea(child: Column(children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.divider))),
            child: Row(children: [
              _BackBtn(onTap: () => Navigator.pop(context)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Symptom Analysis', style: GoogleFonts.outfit(
                    fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                Text(_isDaySlot ? 'Day Mode · 04:59 AM – 05:00 PM'
                    : 'Night Mode · 05:00 PM – 04:59 AM',
                    style: GoogleFonts.inter(fontSize: 11, color: _slot, fontWeight: FontWeight.w600)),
              ])),
              // Live score chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: rc.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: rc.withOpacity(0.4))),
                child: Text(p.riskCategory == 'NONE' ? 'NO RISK' : '${p.riskCategory} RISK',
                    style: GoogleFonts.inter(
                        fontSize: 11, fontWeight: FontWeight.w800, color: rc)),
              ),
            ]),
          ),
          Expanded(child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 14),
              _buildScoreBanner(p, rc),
              const SizedBox(height: 20),
              _buildFeverSection(),
              const SizedBox(height: 16),
              _buildCoughSection(),
              const SizedBox(height: 16),
              _buildOtherSection(),
              const SizedBox(height: 16),
              _buildDurationSection(),
              const SizedBox(height: 24),
              _buildSaveBtn(p, rc),
              const SizedBox(height: 40),
            ]),
          )),
        ])),
      ]),
    );
  }

  // ── Score banner ───────────────────────────────────────────────
  Widget _buildScoreBanner(SymptomProfile p, Color rc) => GlassCard(
    accentColor: rc,
    padding: const EdgeInsets.all(16),
    borderRadius: 16,
    child: Row(children: [
      Container(
        width: 50, height: 50,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: rc.withOpacity(0.15),
            border: Border.all(color: rc.withOpacity(0.4))),
        child: Center(child: Text('${p.score}',
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: rc))),
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Symptom Severity Score', style: GoogleFonts.inter(
            fontSize: 12, color: AppColors.textSecondary)),
        Text(p.riskCategory == 'NONE'
            ? 'No symptoms selected yet'
            : '${p.riskCategory} RISK — ${_riskDesc(p.riskCategory)}',
            style: GoogleFonts.outfit(
                fontSize: 14, fontWeight: FontWeight.w700, color: rc)),
      ])),
      Icon(Icons.auto_graph_rounded, color: rc.withOpacity(0.5), size: 30),
    ]),
  );

  String _riskDesc(String r) {
    switch (r) {
      case 'HIGH':     return 'Immediate evaluation needed';
      case 'MODERATE': return 'Clinical review advised';
      case 'LOW':      return 'Monitor symptoms';
      default:         return '';
    }
  }

  // ── Fever ──────────────────────────────────────────────────────
  Widget _buildFeverSection() => _Section(
    label: 'FEVER', icon: Icons.thermostat_rounded, iconColor: AppColors.emergency,
    child: Column(children: [
      _OptionTile(value: 'None',  label: 'No Fever',    sub: '< 37.5°C',              color: AppColors.safe,      selected: _fever == 'None',  onTap: () => setState(() => _fever = _fever == 'None'  ? null : 'None')),
      _OptionTile(value: 'Low',   label: 'Low Grade',   sub: '37.5 – 38.0°C',         color: AppColors.warning,   selected: _fever == 'Low',   onTap: () => setState(() => _fever = _fever == 'Low'   ? null : 'Low')),
      _OptionTile(value: 'Mid',   label: 'Moderate',    sub: '38.1 – 39.0°C',         color: AppColors.warning,   selected: _fever == 'Mid',   onTap: () => setState(() => _fever = _fever == 'Mid'   ? null : 'Mid')),
      _OptionTile(value: 'High',  label: 'High Grade',  sub: '> 39.0°C · Alarming',   color: AppColors.emergency, selected: _fever == 'High',  onTap: () => setState(() => _fever = _fever == 'High'  ? null : 'High')),
    ]),
  );

  // ── Cough ──────────────────────────────────────────────────────
  Widget _buildCoughSection() => _Section(
    label: 'COUGH', icon: Icons.air_rounded, iconColor: AppColors.info,
    child: Column(children: [
      _CoughTile(label: 'No Cough',     sub: 'Absent',                             icon: Icons.check_circle_outline, color: AppColors.safe,      selected: _cough == 'None',    onTap: () => setState(() => _cough = _cough == 'None'    ? null : 'None')),
      _CoughTile(label: 'Dry Cough',    sub: 'Non-productive, persistent',         icon: Icons.graphic_eq_rounded,   color: AppColors.warning,   selected: _cough == 'Dry',     onTap: () => setState(() => _cough = _cough == 'Dry'     ? null : 'Dry')),
      _CoughTile(label: 'Extreme Cough',sub: 'Severe, haemoptysis possible',       icon: Icons.crisis_alert_rounded, color: AppColors.emergency, selected: _cough == 'Extreme', onTap: () => setState(() => _cough = _cough == 'Extreme' ? null : 'Extreme')),
    ]),
  );

  // ── Other symptoms ─────────────────────────────────────────────
  Widget _buildOtherSection() => _Section(
    label: 'ADDITIONAL SYMPTOMS', icon: Icons.list_alt_rounded, iconColor: AppColors.warning,
    child: Column(children: [
      _ToggleTile(label: 'Night Sweats',    sub: 'Drenching sweats during sleep',      icon: Icons.water_drop_rounded,       color: AppColors.info,      val: _sweats,    onChanged: (v) => setState(() => _sweats    = v)),
      _ToggleTile(label: 'Weight Loss',     sub: '> 5% body weight in past month',     icon: Icons.monitor_weight_outlined,  color: AppColors.warning,   val: _weightLoss, onChanged: (v) => setState(() => _weightLoss = v)),
      _ToggleTile(label: 'Loss of Appetite',sub: 'Reduced or absent hunger',           icon: Icons.no_food_outlined,         color: AppColors.warning,   val: _lossApp,    onChanged: (v) => setState(() => _lossApp    = v)),
      _ToggleTile(label: 'Fatigue / Malaise',sub: 'Persistent tiredness',              icon: Icons.battery_0_bar_rounded,    color: AppColors.textSecondary, val: _fatigue,  onChanged: (v) => setState(() => _fatigue    = v)),
      _ToggleTile(label: 'Chest Pain',      sub: 'Pleuritic or pressure-type pain',    icon: Icons.heart_broken_outlined,    color: AppColors.emergency, val: _chestPain,  onChanged: (v) => setState(() => _chestPain  = v)),
    ]),
  );

  // ── Duration ───────────────────────────────────────────────────
  Widget _buildDurationSection() => _Section(
    label: 'SYMPTOM DURATION', icon: Icons.schedule_rounded, iconColor: AppColors.primary,
    child: Wrap(spacing: 8, runSpacing: 8, children: [
      '< 1 Week', '1–2 Weeks', '2–4 Weeks', '1–3 Months', '> 3 Months',
    ].map((d) {
      final sel = d == _duration;
      return GestureDetector(
        onTap: () => setState(() => _duration = d),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: sel ? AppColors.primary.withOpacity(0.16) : AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: sel ? AppColors.primary.withOpacity(0.55) : AppColors.divider),
          ),
          child: Text(d, style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
              color: sel ? AppColors.primary : AppColors.textSecondary)),
        ),
      );
    }).toList()),
  );

  // ── Save btn ───────────────────────────────────────────────────
  Widget _buildSaveBtn(SymptomProfile p, Color rc) => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: () => Navigator.pop(context, p),
      style: ElevatedButton.styleFrom(
        backgroundColor: rc,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.save_alt_rounded, size: 20),
        const SizedBox(width: 10),
        Text('Save — ${p.riskCategory} RISK  (Score: ${p.score})',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
      ]),
    ),
  );
}

// ── Shared Tile Widgets ────────────────────────────────────────

class _Section extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final Widget child;
  const _Section({required this.label, required this.icon, required this.iconColor, required this.child});
  @override
  Widget build(BuildContext ctx) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      Icon(icon, size: 13, color: iconColor),
      const SizedBox(width: 6),
      Text(label, style: GoogleFonts.inter(
          fontSize: 11, fontWeight: FontWeight.w700,
          letterSpacing: 1.5, color: AppColors.textTertiary)),
    ]),
    const SizedBox(height: 10),
    child,
  ]);
}

class _OptionTile extends StatelessWidget {
  final String value, label, sub;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _OptionTile({required this.value, required this.label, required this.sub,
    required this.color, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext ctx) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: selected ? color.withOpacity(0.12) : AppColors.surfaceAlt.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: selected ? color.withOpacity(0.5) : AppColors.divider),
      ),
      child: Row(children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 20, height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected ? color : Colors.transparent,
            border: Border.all(color: selected ? color : AppColors.textTertiary, width: 2),
          ),
          child: selected ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? color : AppColors.textPrimary))),
        Text(sub, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
      ]),
    ),
  );
}

class _CoughTile extends StatelessWidget {
  final String label, sub;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _CoughTile({required this.label, required this.sub, required this.icon,
    required this.color, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext ctx) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: selected ? color.withOpacity(0.12) : AppColors.surfaceAlt.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: selected ? color.withOpacity(0.5) : AppColors.divider),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (selected ? color : AppColors.textTertiary).withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: selected ? color : AppColors.textTertiary),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? color : AppColors.textPrimary)),
          Text(sub, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary, height: 1.4)),
        ])),
        if (selected) Icon(Icons.check_circle_rounded, color: color, size: 18),
      ]),
    ),
  );
}

class _ToggleTile extends StatelessWidget {
  final String label, sub;
  final IconData icon;
  final Color color;
  final bool val;
  final ValueChanged<bool> onChanged;
  const _ToggleTile({required this.label, required this.sub, required this.icon,
    required this.color, required this.val, required this.onChanged});
  @override
  Widget build(BuildContext ctx) => GestureDetector(
    onTap: () => onChanged(!val),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: val ? color.withOpacity(0.10) : AppColors.surfaceAlt.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: val ? color.withOpacity(0.45) : AppColors.divider),
      ),
      child: Row(children: [
        Icon(icon, size: 18, color: val ? color : AppColors.textTertiary),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: val ? FontWeight.w600 : FontWeight.w400,
              color: val ? color : AppColors.textPrimary)),
          Text(sub, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
        ])),
        Switch.adaptive(value: val, onChanged: onChanged,
            activeColor: color, inactiveTrackColor: AppColors.divider),
      ]),
    ),
  );
}

class _BackBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _BackBtn({required this.onTap});
  @override
  Widget build(BuildContext ctx) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.divider)),
      child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.textPrimary),
    ),
  );
}
