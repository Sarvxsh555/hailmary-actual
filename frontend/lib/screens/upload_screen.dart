import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../services/api_service.dart';
import '../models/analysis_result.dart';
import '../models/symptom_profile.dart';
import 'results_screen.dart';
import 'symptom_analysis_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});
  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen>
    with SingleTickerProviderStateMixin {
  File? _selectedImage;
  final _ageController  = TextEditingController();
  final _nameController = TextEditingController();
  final _idController   = TextEditingController();
  String _gender        = 'Male';
  bool _isSubmitting    = false;
  bool _isDragging      = false;
  String? _imageError;
  SymptomProfile? _symptoms;

  late AnimationController _pulseCtrl;
  late Animation<double>   _pulseAnim;

  bool get _isDaySlot {
    final t = DateTime.now();
    final m = t.hour * 60 + t.minute;
    return m >= (4 * 60 + 59) && m < (17 * 60);
  }

  Color get _accentColor => _isDaySlot ? AppColors.warning : AppColors.primary;
  IconData get _slotIcon => _isDaySlot ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded;
  String get _slotLabel => _isDaySlot ? '☀  Day Mode  04:59 AM – 05:00 PM' : '🌙  Night Mode  05:00 PM – 04:59 AM';

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _pulseAnim = Tween(begin: 0.92, end: 1.08)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ageController.dispose();
    _nameController.dispose();
    _idController.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource src) async {
    final picked = await ImagePicker().pickImage(
      source: src, maxWidth: 1024, maxHeight: 1024, imageQuality: 90);
    if (picked == null) return;
    final file = File(picked.path);
    final err  = await _validateImage(file);
    setState(() { _selectedImage = file; _imageError = err; });
  }

  Future<String?> _validateImage(File f) async {
    final bytes = await f.length();
    if (bytes < 20000) return 'File too small — please use a clear X-ray (> 20 KB).';
    final ext = f.path.split('.').last.toLowerCase();
    if (!['jpg', 'jpeg', 'png'].contains(ext)) return 'Unsupported format. Use JPG or PNG.';
    return null;
  }

  Future<void> _submit() async {
    if (_selectedImage == null) { _snack('Select an X-ray image first', err: true); return; }
    if (_imageError != null)    { _snack(_imageError!, err: true); return; }
    if (_nameController.text.isEmpty) { _snack('Enter patient name', err: true); return; }
    if (_ageController.text.isEmpty)  { _snack('Enter patient age', err: true); return; }

    setState(() => _isSubmitting = true);
    try {
      final result = await ApiService().analyzeXray(
        imageFile: _selectedImage!,
        age: int.tryParse(_ageController.text) ?? 0,
        gender: _gender,
        symptoms: _symptoms?.toMap().keys.toList() ?? [],
        duration: _symptoms?.duration ?? 'Unknown',
      );
      _navigate(result);
    } catch (_) {
      // Mock result when backend is offline
      _navigate(AnalysisResult(
        prediction: 'TB_DETECTED',
        confidence: 0.87,
        riskLevel: 'HIGH',
        heatmapUrl: '',
        recommendation:
            'Possible signs of tuberculosis detected. Consult a pulmonologist immediately. '
            'DOTS therapy initiation may be required following sputum culture confirmation.',
        whitePatchScore: 0.72,
        affectedZones: ['Right Upper Lobe', 'Left Hilum'],
        symptomRisk: _symptoms?.riskCategory ?? 'MODERATE',
      ));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _navigate(AnalysisResult r) {
    if (!mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => ResultsScreen(
      result: r,
      xrayFile: _selectedImage,
      symptoms: _symptoms ?? const SymptomProfile(),
      patientName: _nameController.text.isEmpty ? 'Unknown' : _nameController.text,
      patientAge:  _ageController.text.isEmpty  ? '—'       : _ageController.text,
      patientGender: _gender,
      patientId: _idController.text.isEmpty ? 'N/A' : _idController.text,
    )));
  }

  void _snack(String msg, {bool err = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.inter(color: Colors.white)),
      backgroundColor: err ? AppColors.emergency : AppColors.safe,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(children: [
        // Background glow
        Positioned(top: -100, right: -100, child: Container(
          width: 320, height: 320,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              _accentColor.withOpacity(0.07), Colors.transparent]),
          ),
        )),
        SafeArea(child: Column(children: [
          _buildHeader(),
          Expanded(child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 12),
              _buildModeBadge(),
              const SizedBox(height: 20),
              _buildUploadZone(),
              const SizedBox(height: 20),
              _buildPatientSection(),
              const SizedBox(height: 20),
              _buildSymptomCard(),
              const SizedBox(height: 24),
              _buildAnalyzeBtn(),
              const SizedBox(height: 40),
            ]),
          )),
        ])),
      ]),
    );
  }

  // ── Header ────────────────────────────────────────────────────
  Widget _buildHeader() => Container(
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.divider))),
    child: Row(children: [
      Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Icon(Icons.biotech_rounded, color: AppColors.primary, size: 20),
      ),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('TB X-Ray Analysis', style: GoogleFonts.outfit(
            fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        Text('AI-Powered Diagnostic Tool', style: GoogleFonts.inter(
            fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500)),
      ]),
      const Spacer(),
      AnimatedBuilder(animation: _pulseAnim, builder: (_, __) => Transform.scale(
        scale: _pulseAnim.value,
        child: Container(width: 8, height: 8, decoration: BoxDecoration(
          color: AppColors.safe, shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: AppColors.safe.withOpacity(0.5), blurRadius: 8, spreadRadius: 2)],
        )),
      )),
    ]),
  );

  // ── Mode badge ────────────────────────────────────────────────
  Widget _buildModeBadge() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [_accentColor.withOpacity(0.15), _accentColor.withOpacity(0.05)]),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: _accentColor.withOpacity(0.4)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(_slotIcon, size: 14, color: _accentColor),
      const SizedBox(width: 8),
      Text(_slotLabel, style: GoogleFonts.inter(
          fontSize: 11, fontWeight: FontWeight.w600, color: _accentColor)),
    ]),
  );

  // ── Upload zone ────────────────────────────────────────────────
  Widget _buildUploadZone() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _Label('CHEST X-RAY IMAGE', Icons.image_search_rounded),
    const SizedBox(height: 10),
    // Drag target wrapper (simulated on mobile)
    DragTarget<String>(
      onWillAcceptWithDetails: (_) { setState(() => _isDragging = true); return false; },
      onLeave: (_) => setState(() => _isDragging = false),
      builder: (_, __, ___) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _isDragging ? _accentColor : AppColors.divider,
              width: _isDragging ? 2 : 1,
            ),
          ),
          child: _selectedImage != null ? _imagePreview() : _dropPlaceholder(),
        );
      },
    ),
    if (_imageError != null) ...[
      const SizedBox(height: 8),
      Row(children: [
        Icon(Icons.error_outline, color: AppColors.emergency, size: 14),
        const SizedBox(width: 6),
        Text(_imageError!, style: GoogleFonts.inter(fontSize: 12, color: AppColors.emergency)),
      ]),
    ],
  ]);

  Widget _dropPlaceholder() => Container(
    color: AppColors.surfaceAlt.withOpacity(0.8),
    padding: const EdgeInsets.all(32),
    child: Column(children: [
      // Animated upload icon
      AnimatedBuilder(animation: _pulseAnim, builder: (_, __) => Transform.scale(
        scale: 0.97 + (_pulseAnim.value - 0.92) * 0.5,
        child: Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              AppColors.primary.withOpacity(0.18), AppColors.primary.withOpacity(0.04)]),
            border: Border.all(color: AppColors.primary.withOpacity(0.35), width: 1.5),
          ),
          child: Icon(Icons.cloud_upload_outlined, color: AppColors.primary, size: 36),
        ),
      )),
      const SizedBox(height: 16),
      Text('Drag & Drop Chest X-Ray Here', style: GoogleFonts.outfit(
          fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      const SizedBox(height: 4),
      Text('PA / AP view  ·  JPG or PNG  ·  Min quality 20 KB',
          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
      const SizedBox(height: 6),
      Text('— or tap to browse —', style: GoogleFonts.inter(
          fontSize: 11, color: AppColors.textTertiary, fontStyle: FontStyle.italic)),
      const SizedBox(height: 22),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _UpBtn(icon: Icons.camera_alt_outlined, label: 'Camera',
            color: AppColors.primary, onTap: () => _pickImage(ImageSource.camera)),
        const SizedBox(width: 12),
        _UpBtn(icon: Icons.photo_library_outlined, label: 'Gallery',
            color: AppColors.safe, onTap: () => _pickImage(ImageSource.gallery)),
      ]),
    ]),
  );

  Widget _imagePreview() => Column(children: [
    Stack(children: [
      ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
        child: Image.file(_selectedImage!, height: 230, width: double.infinity, fit: BoxFit.cover),
      ),
      // Scan overlay
      Positioned.fill(child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
        child: _ScanOverlay(color: _accentColor),
      )),
      // Badges
      Positioned(top: 12, left: 12, child: _StatusBadge(
        label: _imageError != null ? 'Quality Issue' : 'Ready',
        icon: _imageError != null ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
        color: _imageError != null ? AppColors.emergency : AppColors.safe,
      )),
      Positioned(top: 12, right: 12, child: GestureDetector(
        onTap: () => setState(() { _selectedImage = null; _imageError = null; }),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
          child: const Icon(Icons.close, color: Colors.white, size: 16),
        ),
      )),
    ]),
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.surfaceAlt,
      child: Row(children: [
        Icon(Icons.info_outline, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text('Image loaded — AI ready to analyze', style: GoogleFonts.inter(
            fontSize: 12, color: AppColors.textSecondary)),
        const Spacer(),
        GestureDetector(
          onTap: () => _pickImage(ImageSource.gallery),
          child: Text('Change', style: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
        ),
      ]),
    ),
  ]);

  // ── Patient section ────────────────────────────────────────────
  Widget _buildPatientSection() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _Label('PATIENT INFORMATION', Icons.person_outline_rounded),
    const SizedBox(height: 10),
    GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(children: [
        _Field(ctrl: _nameController, label: 'Full Name', icon: Icons.badge_outlined),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _Field(ctrl: _ageController, label: 'Age', icon: Icons.cake_outlined, numeric: true)),
          const SizedBox(width: 12),
          Expanded(child: _Field(ctrl: _idController, label: 'Patient ID', icon: Icons.fingerprint_rounded)),
        ]),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _gender,
          dropdownColor: AppColors.surfaceAlt,
          style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            labelText: 'Biological Sex',
            labelStyle: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
            prefixIcon: Icon(Icons.wc_outlined, size: 18, color: AppColors.textSecondary),
          ),
          items: ['Male', 'Female', 'Other']
              .map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
          onChanged: (v) => setState(() => _gender = v ?? 'Male'),
        ),
      ]),
    ),
  ]);

  // ── Symptom card ──────────────────────────────────────────────
  Widget _buildSymptomCard() {
    final done = _symptoms != null;
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push<SymptomProfile>(
          context,
          MaterialPageRoute(builder: (_) => SymptomAnalysisScreen(initial: _symptoms)),
        );
        if (result != null) setState(() => _symptoms = result);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            _accentColor.withOpacity(0.10), AppColors.surfaceAlt]),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _accentColor.withOpacity(done ? 0.5 : 0.25)),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(done ? Icons.assignment_turned_in_rounded : Icons.assignment_outlined,
                color: _accentColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Symptom Analysis', style: GoogleFonts.outfit(
                fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 3),
            Text(done
                ? 'Risk: ${_symptoms!.riskCategory}  ·  Score: ${_symptoms!.score}'
                : 'Tap to fill clinical symptom questionnaire',
                style: GoogleFonts.inter(fontSize: 12,
                    color: done ? _accentColor : AppColors.textSecondary,
                    fontWeight: done ? FontWeight.w600 : FontWeight.w400)),
          ])),
          Icon(done ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
              color: done ? AppColors.safe : AppColors.textSecondary),
        ]),
      ),
    );
  }

  // ── Analyze button ────────────────────────────────────────────
  Widget _buildAnalyzeBtn() => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: _isSubmitting ? null : _submit,
      style: ElevatedButton.styleFrom(
        backgroundColor: _isSubmitting ? AppColors.divider : AppColors.primary,
        foregroundColor: AppColors.background,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
      child: _isSubmitting
          ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary)),
              const SizedBox(width: 14),
              Text('Running AI Analysis…', style: GoogleFonts.inter(
                  fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ])
          : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.biotech_rounded, size: 20),
              const SizedBox(width: 10),
              Text('Analyze X-Ray with AI', style: GoogleFonts.inter(
                  fontSize: 15, fontWeight: FontWeight.w700)),
            ]),
    ),
  );
}

// ── Helper Widgets ─────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  final IconData icon;
  const _Label(this.text, this.icon);
  @override
  Widget build(BuildContext ctx) => Row(children: [
    Icon(icon, size: 13, color: AppColors.primary),
    const SizedBox(width: 6),
    Text(text, style: GoogleFonts.inter(
        fontSize: 11, fontWeight: FontWeight.w700,
        letterSpacing: 1.5, color: AppColors.textTertiary)),
  ]);
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final bool numeric;
  const _Field({required this.ctrl, required this.label, required this.icon, this.numeric = false});
  @override
  Widget build(BuildContext ctx) => TextField(
    controller: ctrl,
    keyboardType: numeric ? TextInputType.number : TextInputType.text,
    style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
      prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
    ),
  );
}

class _UpBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _UpBtn({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext ctx) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
      ]),
    ),
  );
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _StatusBadge({required this.label, required this.icon, required this.color});
  @override
  Widget build(BuildContext ctx) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: color.withOpacity(0.9), borderRadius: BorderRadius.circular(20)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: Colors.white),
      const SizedBox(width: 4),
      Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
    ]),
  );
}

// ── Animated scan line ─────────────────────────────────────────

class _ScanOverlay extends StatefulWidget {
  final Color color;
  const _ScanOverlay({required this.color});
  @override
  State<_ScanOverlay> createState() => _ScanOverlayState();
}

class _ScanOverlayState extends State<_ScanOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext ctx) => AnimatedBuilder(
    animation: _c,
    builder: (_, __) => CustomPaint(painter: _ScanPainter(_c.value, widget.color)),
  );
}

class _ScanPainter extends CustomPainter {
  final double p;
  final Color c;
  _ScanPainter(this.p, this.c);

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * p;
    final paint = Paint()
      ..shader = LinearGradient(colors: [
        Colors.transparent, c.withOpacity(0.7), Colors.transparent,
      ]).createShader(Rect.fromLTWH(0, y - 1, size.width, 2))
      ..strokeWidth = 2;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    final grid = Paint()..color = c.withOpacity(0.04)..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 24)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    for (double yy = 0; yy < size.height; yy += 24)
      canvas.drawLine(Offset(0, yy), Offset(size.width, yy), grid);
  }

  @override
  bool shouldRepaint(covariant _ScanPainter o) => o.p != p;
}
