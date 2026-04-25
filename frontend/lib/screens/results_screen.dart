import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/risk_badge.dart';
import '../models/analysis_result.dart';
import '../models/symptom_profile.dart';
import '../services/report_service.dart';

class ResultsScreen extends StatefulWidget {
  final AnalysisResult result;
  final File? xrayFile;
  final SymptomProfile symptoms;
  final String patientName, patientAge, patientGender, patientId;
  const ResultsScreen({
    super.key,
    required this.result,
    required this.symptoms,
    required this.patientName,
    required this.patientAge,
    required this.patientGender,
    required this.patientId,
    this.xrayFile,
  });
  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> with TickerProviderStateMixin {
  late AnimationController _fade, _gauge;
  late Animation<double> _gaugeAnim;
  int _tab = 0;
  bool _showHeatmap = true;
  bool _generatingPdf = false;

  Color get _rc {
    switch (widget.result.riskLevel) {
      case 'HIGH': return AppColors.emergency;
      case 'MODERATE': return AppColors.warning;
      default: return AppColors.safe;
    }
  }

  bool get _detected => widget.result.prediction != 'NORMAL';

  @override
  void initState() {
    super.initState();
    _fade = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..forward();
    _gauge = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _gaugeAnim = CurvedAnimation(parent: _gauge, curve: Curves.easeOutCubic);
    Future.delayed(const Duration(milliseconds: 300), _gauge.forward);
  }

  @override
  void dispose() { _fade.dispose(); _gauge.dispose(); super.dispose(); }

  Future<void> _generatePdf() async {
    setState(() => _generatingPdf = true);
    try {
      final bytes = await ReportService.instance.buildReport(
        result: widget.result,
        symptoms: widget.symptoms,
        patientName: widget.patientName,
        patientAge: widget.patientAge,
        patientGender: widget.patientGender,
        patientId: widget.patientId,
        xrayFile: widget.xrayFile,
      );
      await Printing.layoutPdf(onLayout: (_) async => bytes, name: 'TB_Report_${widget.patientId}');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('PDF error: $e', style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: AppColors.emergency, behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _generatingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: CurvedAnimation(parent: _fade, curve: Curves.easeOut),
        child: SafeArea(child: Column(children: [
          _header(),
          _tabBar(),
          Expanded(child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(children: [
              const SizedBox(height: 4),
              if (_tab == 0) _analysisTab(),
              if (_tab == 1) _heatmapTab(),
              if (_tab == 2) _patchTab(),
              if (_tab == 3) _reportTab(),
              const SizedBox(height: 40),
            ]),
          )),
        ])),
      ),
    );
  }

  Widget _header() => Container(
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.divider))),
    child: Row(children: [
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.divider)),
          child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.textPrimary),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('AI Analysis Results', style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        Text('${widget.patientName} · ${widget.patientAge}y · ${widget.patientGender}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.primary)),
      ])),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: _rc.withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: _rc.withOpacity(0.4))),
        child: Text(widget.result.riskLevel, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: _rc)),
      ),
    ]),
  );

  Widget _tabBar() {
    final tabs = [(Icons.analytics_outlined, 'Analysis'), (Icons.thermostat_outlined, 'Heatmap'), (Icons.blur_on_rounded, 'Patches'), (Icons.description_outlined, 'Report')];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider)),
      child: Row(children: tabs.asMap().entries.map((e) {
        final sel = _tab == e.key;
        return Expanded(child: GestureDetector(
          onTap: () => setState(() => _tab = e.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: sel ? AppColors.primary.withOpacity(0.18) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: sel ? Border.all(color: AppColors.primary.withOpacity(0.4)) : null,
            ),
            child: Column(children: [
              Icon(e.value.$1, size: 16, color: sel ? AppColors.primary : AppColors.textTertiary),
              const SizedBox(height: 3),
              Text(e.value.$2, style: GoogleFonts.inter(fontSize: 10, fontWeight: sel ? FontWeight.w700 : FontWeight.w400, color: sel ? AppColors.primary : AppColors.textTertiary)),
            ]),
          ),
        ));
      }).toList()),
    );
  }

  // ── Tab 0: Analysis ────────────────────────────────────────────
  Widget _analysisTab() => Column(children: [
    GlassCard(accentColor: _rc, padding: const EdgeInsets.all(24), borderRadius: 18, child: Column(children: [
      Container(width: 64, height: 64, decoration: BoxDecoration(shape: BoxShape.circle, color: _rc.withOpacity(0.15), border: Border.all(color: _rc.withOpacity(0.4), width: 2)),
        child: Icon(_detected ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded, color: _rc, size: 30)),
      const SizedBox(height: 14),
      Text(widget.result.predictionDisplay, style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w800, color: _rc)),
      const SizedBox(height: 8),
      RiskBadge(riskLevel: widget.result.riskLevel, fontSize: 12),
    ])),
    const SizedBox(height: 16),
    GlassCard(padding: const EdgeInsets.all(24), borderRadius: 18, child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Confidence Score', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        Text('HailMary AI v2.1', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textTertiary)),
      ]),
      const SizedBox(height: 20),
      SizedBox(width: 140, height: 140, child: AnimatedBuilder(
        animation: _gaugeAnim,
        builder: (_, __) => CustomPaint(
          painter: _GaugePainter(widget.result.confidence * _gaugeAnim.value, _rc),
          child: Center(child: Text('${(widget.result.confidence * _gaugeAnim.value * 100).toInt()}%',
              style: GoogleFonts.outfit(fontSize: 34, fontWeight: FontWeight.w800, color: AppColors.textPrimary))),
        ),
      )),
    ])),
    const SizedBox(height: 16),
    if (widget.result.affectedZones.isNotEmpty) ...[
      GlassCard(padding: const EdgeInsets.all(18), borderRadius: 18, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(Icons.location_on_outlined, size: 15, color: AppColors.emergency), const SizedBox(width: 6),
          Text('Affected Zones', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary))]),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: widget.result.affectedZones.map((z) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: AppColors.emergency.withOpacity(0.12), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.emergency.withOpacity(0.35))),
          child: Text(z, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.emergency)),
        )).toList()),
      ])),
      const SizedBox(height: 16),
    ],
    GlassCard(accentColor: AppColors.info, padding: const EdgeInsets.all(18), borderRadius: 18, child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.info.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
        child: Icon(Icons.lightbulb_outline_rounded, color: AppColors.info, size: 18)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Clinical Recommendation', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        Text(widget.result.recommendation, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
      ])),
    ])),
  ]);

  // ── Tab 1: Heatmap ─────────────────────────────────────────────
  Widget _heatmapTab() => Column(children: [
    GlassCard(padding: const EdgeInsets.all(16), borderRadius: 18, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.thermostat_outlined, size: 15, color: AppColors.warning),
        const SizedBox(width: 6),
        Text('Attention Heatmap (Grad-CAM)', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const Spacer(),
        GestureDetector(
          onTap: () => setState(() => _showHeatmap = !_showHeatmap),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: (_showHeatmap ? AppColors.primary : AppColors.surfaceAlt).withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.primary.withOpacity(0.3))),
            child: Text(_showHeatmap ? 'Hide' : 'Show', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
          ),
        ),
      ]),
      const SizedBox(height: 12),
      ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(children: [
          widget.xrayFile != null
              ? Image.file(widget.xrayFile!, height: 240, width: double.infinity, fit: BoxFit.cover)
              : Container(height: 240, color: AppColors.surfaceAlt, child: Center(child: Icon(Icons.image_not_supported_outlined, color: AppColors.textTertiary, size: 40))),
          if (_showHeatmap) Positioned.fill(child: CustomPaint(painter: _HeatPainter(widget.result.whitePatchScore))),
        ]),
      ),
      const SizedBox(height: 14),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _Dot(AppColors.emergency, 'High'),
        _Dot(AppColors.warning, 'Moderate'),
        _Dot(AppColors.info, 'Low'),
        _Dot(AppColors.safe, 'Normal'),
      ]),
    ])),
  ]);

  // ── Tab 2: White Patch ─────────────────────────────────────────
  Widget _patchTab() {
    final s = widget.result.whitePatchScore;
    final pc = (s * 100).toInt();
    final c = s > 0.6 ? AppColors.emergency : s > 0.3 ? AppColors.warning : AppColors.safe;
    return Column(children: [
      GlassCard(accentColor: c, padding: const EdgeInsets.all(20), borderRadius: 18, child: Column(children: [
        Row(children: [Icon(Icons.blur_on_rounded, size: 15, color: c), const SizedBox(width: 6),
          Text('White Patch Detection', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary))]),
        const SizedBox(height: 20),
        SizedBox(height: 130, width: 130, child: AnimatedBuilder(
          animation: _gaugeAnim,
          builder: (_, __) => CustomPaint(
            painter: _GaugePainter(s * _gaugeAnim.value, c),
            child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('${(pc * _gaugeAnim.value).toInt()}%', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w800, color: c)),
              Text('opacity', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textTertiary)),
            ])),
          ),
        )),
        const SizedBox(height: 16),
        Text(s > 0.6 ? 'Significant opacification — consistent with active TB or consolidation.'
            : s > 0.3 ? 'Moderate haziness — possible early infiltrates. Monitor closely.'
            : 'Minimal opacity — lung fields appear relatively clear.',
            textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
      ])),
      const SizedBox(height: 16),
      GlassCard(padding: const EdgeInsets.all(18), borderRadius: 18, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Density Distribution', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 14),
        _Bar('Right Upper Lobe', s * 0.9, c),
        const SizedBox(height: 10),
        _Bar('Left Upper Lobe',  s * 0.6, c),
        const SizedBox(height: 10),
        _Bar('Right Lower Lobe', s * 0.4, AppColors.warning),
        const SizedBox(height: 10),
        _Bar('Left Lower Lobe',  s * 0.2, AppColors.safe),
      ])),
    ]);
  }

  // ── Tab 3: Report ──────────────────────────────────────────────
  Widget _reportTab() {
    final r = widget.result;
    final s = widget.symptoms;
    final now = DateTime.now();
    final d = '${now.day.toString().padLeft(2,'0')}/${now.month.toString().padLeft(2,'0')}/${now.year}';
    final t = '${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')} IST';
    return Column(children: [
      GlassCard(padding: const EdgeInsets.all(20), borderRadius: 18, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.primary.withOpacity(0.3))),
            child: Icon(Icons.description_outlined, color: AppColors.primary, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Clinical Report', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            Text('Generated $d at $t', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
          ])),
        ]),
        Divider(color: AppColors.divider, height: 24),
        _RRow('Patient', widget.patientName),
        _RRow('Age / Gender', '${widget.patientAge} yrs · ${widget.patientGender}'),
        _RRow('Patient ID', widget.patientId),
        Divider(color: AppColors.divider, height: 20),
        _RRow('Finding', r.predictionDisplay, vc: _rc),
        _RRow('Risk Level', r.riskLevel, vc: _rc),
        _RRow('AI Confidence', '${(r.confidence * 100).toInt()}%'),
        _RRow('White Patch Index', '${(r.whitePatchScore * 100).toInt()}%'),
        if (r.affectedZones.isNotEmpty) _RRow('Affected Zones', r.affectedZones.join(', ')),
        Divider(color: AppColors.divider, height: 20),
        _RRow('Fever', s.feverLevel ?? 'None'),
        _RRow('Cough', s.coughType ?? 'None'),
        _RRow('Night Sweats', s.hasSweats ? 'Yes' : 'No'),
        _RRow('Weight Loss', s.hasWeightLoss ? 'Yes' : 'No'),
        _RRow('Loss of Appetite', s.hasLossAppetite ? 'Yes' : 'No'),
        _RRow('Symptom Risk', s.riskCategory),
        Divider(color: AppColors.divider, height: 20),
        Text('Recommendation', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textTertiary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(r.recommendation, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
        Divider(color: AppColors.divider, height: 20),
        Text('⚠ AI-assisted — not a substitute for professional diagnosis.', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textTertiary, height: 1.5)),
      ])),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: _Btn(Icons.picture_as_pdf_rounded, 'Generate PDF', AppColors.primary, _generatingPdf ? null : _generatePdf)),
        const SizedBox(width: 12),
        Expanded(child: _Btn(Icons.save_alt_rounded, 'Save Record', AppColors.safe, () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Saved to records', style: GoogleFonts.inter(color: Colors.white)),
            backgroundColor: AppColors.safe, behavior: SnackBarBehavior.floating,
          ));
          Navigator.popUntil(context, (r) => r.isFirst);
        })),
      ]),
    ]);
  }
}

// ── Micro-widgets ──────────────────────────────────────────────

class _Dot extends StatelessWidget {
  final Color c; final String l;
  const _Dot(this.c, this.l);
  @override Widget build(BuildContext _) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: c)),
    const SizedBox(width: 4),
    Text(l, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
  ]);
}

class _Bar extends StatelessWidget {
  final String label; final double val; final Color c;
  const _Bar(this.label, this.val, this.c);
  @override Widget build(BuildContext _) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
      Text('${(val.clamp(0,1)*100).toInt()}%', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: c)),
    ]),
    const SizedBox(height: 5),
    ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(
      value: val.clamp(0,1), backgroundColor: AppColors.divider,
      valueColor: AlwaysStoppedAnimation(c), minHeight: 6)),
  ]);
}

class _RRow extends StatelessWidget {
  final String l, v; final Color? vc;
  const _RRow(this.l, this.v, {this.vc});
  @override Widget build(BuildContext _) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      Expanded(flex: 2, child: Text(l, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textTertiary))),
      Expanded(flex: 3, child: Text(v, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: vc ?? AppColors.textPrimary))),
    ]),
  );
}

class _Btn extends StatelessWidget {
  final IconData icon; final String label; final Color color; final VoidCallback? onTap;
  const _Btn(this.icon, this.label, this.color, this.onTap);
  @override Widget build(BuildContext _) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(onTap == null ? 0.15 : 0.4))),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 18, color: onTap == null ? AppColors.textTertiary : color),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: onTap == null ? AppColors.textTertiary : color)),
      ]),
    ),
  );
}

// ── Painters ──────────────────────────────────────────────────

class _GaugePainter extends CustomPainter {
  final double p; final Color c;
  _GaugePainter(this.p, this.c);
  @override void paint(Canvas cv, Size sz) {
    final ctr = Offset(sz.width/2, sz.height/2);
    final r = min(sz.width, sz.height)/2 - 8;
    cv.drawArc(Rect.fromCircle(center: ctr, radius: r), -pi*0.75, pi*1.5, false,
      Paint()..color=AppColors.divider..style=PaintingStyle.stroke..strokeWidth=10..strokeCap=StrokeCap.round);
    if (p > 0) {
      cv.drawArc(Rect.fromCircle(center: ctr, radius: r), -pi*0.75, pi*1.5*p, false,
        Paint()..color=c..style=PaintingStyle.stroke..strokeWidth=10..strokeCap=StrokeCap.round
          ..maskFilter=const MaskFilter.blur(BlurStyle.solid, 0));
      cv.drawArc(Rect.fromCircle(center: ctr, radius: r), -pi*0.75, pi*1.5*p, false,
        Paint()..color=c.withOpacity(0.25)..style=PaintingStyle.stroke..strokeWidth=18..strokeCap=StrokeCap.round
          ..maskFilter=const MaskFilter.blur(BlurStyle.normal, 8));
    }
  }
  @override bool shouldRepaint(covariant _GaugePainter o) => o.p != p;
}

class _HeatPainter extends CustomPainter {
  final double intensity;
  _HeatPainter(this.intensity);
  @override void paint(Canvas cv, Size sz) {
    if (intensity <= 0.1) return;
    final spots = [Offset(sz.width*0.35, sz.height*0.25), Offset(sz.width*0.55, sz.height*0.30), Offset(sz.width*0.42, sz.height*0.45)];
    for (final s in spots) {
      for (int i = 3; i >= 0; i--) {
        final col = i < 2 ? AppColors.emergency : AppColors.warning;
        cv.drawCircle(s, 30.0+i*14,
          Paint()..color=col.withOpacity((intensity*0.4*(4-i)/4).clamp(0,0.55))
            ..maskFilter=MaskFilter.blur(BlurStyle.normal, 10.0+i*5));
      }
    }
    final g = Paint()..color=AppColors.primary.withOpacity(0.04)..strokeWidth=0.5;
    for (double x=0; x<sz.width; x+=20) cv.drawLine(Offset(x,0), Offset(x,sz.height), g);
    for (double y=0; y<sz.height; y+=20) cv.drawLine(Offset(0,y), Offset(sz.width,y), g);
  }
  @override bool shouldRepaint(covariant _HeatPainter o) => o.intensity != intensity;
}
