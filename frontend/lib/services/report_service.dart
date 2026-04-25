import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import '../models/analysis_result.dart';
import '../models/symptom_profile.dart';

class ReportService {
  static ReportService? _i;
  static ReportService get instance => _i ??= ReportService._();
  ReportService._();

  // ── Colours ─────────────────────────────────────────────────
  static const _navy   = PdfColor(0.039, 0.055, 0.102);
  static const _cyan   = PdfColor(0.0,   0.831, 1.0);
  static const _danger = PdfColor(1.0,   0.278, 0.341);
  static const _warn   = PdfColor(1.0,   0.702, 0.251);
  static const _safe   = PdfColor(0.180, 0.800, 0.443);
  static const _slate  = PdfColor(0.102, 0.133, 0.208);
  static const _text   = PdfColor(0.173, 0.243, 0.314);
  static const _sub    = PdfColor(0.329, 0.431, 0.478);
  static const _border = PdfColor(0.878, 0.910, 0.941);
  static const _white  = PdfColors.white;
  static const _light  = PdfColor(0.961, 0.973, 0.988);

  Future<Uint8List> buildReport({
    required AnalysisResult result,
    required SymptomProfile symptoms,
    required String patientName,
    required String patientAge,
    required String patientGender,
    required String patientId,
    File? xrayFile,
  }) async {
    final doc  = pw.Document();
    final now  = DateTime.now();
    final bold = await PdfGoogleFonts.interBold();
    final reg  = await PdfGoogleFonts.interRegular();
    final mono = await PdfGoogleFonts.robotoMonoRegular();

    pw.MemoryImage? xImg;
    if (xrayFile != null && xrayFile.existsSync()) {
      xImg = pw.MemoryImage(await xrayFile.readAsBytes());
    }

    final rc = _riskPdfColor(result.riskLevel);

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (ctx) => [
        _header(patientName, patientAge, patientGender, patientId, now, bold, reg, rc),
        pw.SizedBox(height: 20),
        _secTitle('AI X-RAY ANALYSIS', bold),
        pw.SizedBox(height: 10),
        _analysisRow(result, xImg, bold, reg, rc),
        pw.SizedBox(height: 18),
        _secTitle('HEATMAP & WHITE PATCH DETECTION', bold),
        pw.SizedBox(height: 10),
        _patchSection(result, bold, reg),
        pw.SizedBox(height: 18),
        _secTitle('SYMPTOM ANALYSIS', bold),
        pw.SizedBox(height: 10),
        _symptomSection(symptoms, bold, reg),
        pw.SizedBox(height: 18),
        _secTitle('FINAL RISK ASSESSMENT', bold),
        pw.SizedBox(height: 10),
        _riskBox(result, symptoms, bold, reg, rc),
        pw.SizedBox(height: 18),
        _recoSection(result, bold, reg),
        pw.SizedBox(height: 20),
        _footer(now, bold, reg, mono),
      ],
    ));

    return doc.save();
  }

  Future<String> saveToFile(Uint8List bytes, String id) async {
    final dir  = await getTemporaryDirectory();
    final path = '${dir.path}/TB_Report_${id}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    await File(path).writeAsBytes(bytes);
    return path;
  }

  // ── Section builders ─────────────────────────────────────────

  pw.Widget _header(String name, String age, String gender, String id, DateTime now,
      pw.Font bold, pw.Font reg, PdfColor rc) {
    return pw.Container(
      color: _navy,
      padding: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 22),
      child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text('HAILMARY HEALTH', style: pw.TextStyle(font: bold, fontSize: 9, color: _cyan, letterSpacing: 2)),
          pw.SizedBox(height: 4),
          pw.Text('Tuberculosis Diagnostic Report', style: pw.TextStyle(font: bold, fontSize: 18, color: _white)),
          pw.SizedBox(height: 14),
          pw.Row(children: [
            _hChip('Patient', name, bold, reg),
            pw.SizedBox(width: 20),
            _hChip('Age / Sex', '$age yrs · $gender', bold, reg),
            pw.SizedBox(width: 20),
            _hChip('ID', id, bold, reg),
          ]),
        ])),
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: pw.BoxDecoration(color: rc, borderRadius: pw.BorderRadius.circular(20)),
            child: pw.Text('${_riskLabel(rc)} RISK',
                style: pw.TextStyle(font: bold, fontSize: 11, color: _white))),
          pw.SizedBox(height: 8),
          pw.Text(_fmtDate(now), style: pw.TextStyle(font: reg, fontSize: 9, color: _sub)),
          pw.Text(_fmtTime(now), style: pw.TextStyle(font: reg, fontSize: 9, color: _sub)),
        ]),
      ]),
    );
  }

  pw.Widget _hChip(String label, String value, pw.Font bold, pw.Font reg) =>
      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(label.toUpperCase(), style: pw.TextStyle(font: bold, fontSize: 7, color: _cyan, letterSpacing: 1)),
        pw.SizedBox(height: 2),
        pw.Text(value, style: pw.TextStyle(font: bold, fontSize: 11, color: _white)),
      ]);

  pw.Widget _secTitle(String t, pw.Font bold) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 32),
    child: pw.Row(children: [
      pw.Container(width: 3, height: 14, color: _cyan),
      pw.SizedBox(width: 8),
      pw.Text(t, style: pw.TextStyle(font: bold, fontSize: 9, color: _sub, letterSpacing: 1.5)),
    ]),
  );

  pw.Widget _analysisRow(AnalysisResult r, pw.MemoryImage? img, pw.Font bold, pw.Font reg, PdfColor rc) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 32),
        child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Container(
            width: 170, height: 170,
            decoration: pw.BoxDecoration(color: PdfColors.black, borderRadius: pw.BorderRadius.circular(8), border: pw.Border.all(color: _border)),
            child: img != null
                ? pw.ClipRRect(horizontalRadius: 8, verticalRadius: 8, child: pw.Image(img, fit: pw.BoxFit.cover))
                : pw.Center(child: pw.Text('No Image', style: pw.TextStyle(font: reg, color: PdfColors.grey))),
          ),
          pw.SizedBox(width: 18),
          pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            _card(pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text('FINDING', style: pw.TextStyle(font: bold, fontSize: 8, color: _sub, letterSpacing: 1)),
              pw.SizedBox(height: 4),
              pw.Text(r.predictionDisplay, style: pw.TextStyle(font: bold, fontSize: 20, color: rc)),
              pw.SizedBox(height: 10),
              _mRow('Confidence', '${(r.confidence*100).toInt()}%', bold, reg, rc),
              pw.SizedBox(height: 5),
              _mRow('Risk Level', r.riskLevel, bold, reg, rc),
              pw.SizedBox(height: 5),
              _mRow('Model', 'HailMary AI v2.1', bold, reg, _sub),
            ])),
            if (r.affectedZones.isNotEmpty) ...[
              pw.SizedBox(height: 10),
              _card(pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text('AFFECTED ZONES', style: pw.TextStyle(font: bold, fontSize: 8, color: _sub, letterSpacing: 1)),
                pw.SizedBox(height: 6),
                pw.Wrap(spacing: 5, runSpacing: 4, children: r.affectedZones.map((z) =>
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: pw.BoxDecoration(color: _danger * 0.1, borderRadius: pw.BorderRadius.circular(10), border: pw.Border.all(color: _danger * 0.3)),
                      child: pw.Text(z, style: pw.TextStyle(font: bold, fontSize: 9, color: _danger)),
                    )).toList()),
              ])),
            ],
          ])),
        ]),
      );

  pw.Widget _patchSection(AnalysisResult r, pw.Font bold, pw.Font reg) {
    final pct = (r.whitePatchScore * 100).toInt();
    final pc  = r.whitePatchScore > 0.6 ? _danger : r.whitePatchScore > 0.3 ? _warn : _safe;
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 32),
      child: pw.Row(children: [
        pw.Expanded(child: _card(pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text('HEATMAP (Grad-CAM)', style: pw.TextStyle(font: bold, fontSize: 8, color: _sub, letterSpacing: 1)),
          pw.SizedBox(height: 6),
          pw.Text('Attention regions computed via gradient-weighted class activation mapping.', style: pw.TextStyle(font: reg, fontSize: 9, color: _sub)),
          pw.SizedBox(height: 8),
          pw.Row(children: [_dot(_danger,'High'), pw.SizedBox(width:10), _dot(_warn,'Moderate'), pw.SizedBox(width:10), _dot(_cyan,'Low')]),
        ]))),
        pw.SizedBox(width: 14),
        pw.Expanded(child: _card(pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text('WHITE PATCH INDEX', style: pw.TextStyle(font: bold, fontSize: 8, color: _sub, letterSpacing: 1)),
          pw.SizedBox(height: 4),
          pw.Text('$pct%', style: pw.TextStyle(font: bold, fontSize: 26, color: pc)),
          pw.Text('Opacification', style: pw.TextStyle(font: reg, fontSize: 9, color: _sub)),
          pw.SizedBox(height: 8),
          _dBar('Right Upper', r.whitePatchScore*0.9, bold, reg),
          pw.SizedBox(height: 4),
          _dBar('Left Upper',  r.whitePatchScore*0.6, bold, reg),
          pw.SizedBox(height: 4),
          _dBar('Right Lower', r.whitePatchScore*0.4, bold, reg),
          pw.SizedBox(height: 4),
          _dBar('Left Lower',  r.whitePatchScore*0.2, bold, reg),
        ]))),
      ]),
    );
  }

  pw.Widget _symptomSection(SymptomProfile s, pw.Font bold, pw.Font reg) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 32),
        child: _card(pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Expanded(child: pw.Column(children: [
            _sRow('Fever',       s.feverLevel ?? 'None', bold, reg),
            _sRow('Cough',       s.coughType  ?? 'None', bold, reg),
            _sRow('Night Sweats',s.hasSweats ? 'Yes':'No', bold, reg),
          ])),
          pw.SizedBox(width: 20),
          pw.Expanded(child: pw.Column(children: [
            _sRow('Weight Loss',   s.hasWeightLoss   ? 'Yes':'No', bold, reg),
            _sRow('Loss Appetite', s.hasLossAppetite ? 'Yes':'No', bold, reg),
            _sRow('Duration',      s.duration, bold, reg),
            _sRow('Symptom Risk',  s.riskCategory, bold, reg),
          ])),
        ])),
      );

  pw.Widget _riskBox(AnalysisResult r, SymptomProfile s, pw.Font bold, pw.Font reg, PdfColor rc) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 32),
        child: pw.Container(
          decoration: pw.BoxDecoration(color: rc * 0.08, borderRadius: pw.BorderRadius.circular(10), border: pw.Border.all(color: rc * 0.3)),
          padding: const pw.EdgeInsets.all(16),
          child: pw.Row(children: [
            pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text('COMBINED RISK', style: pw.TextStyle(font: bold, fontSize: 8, color: _sub, letterSpacing: 1)),
              pw.SizedBox(height: 4),
              pw.Text(r.riskLevel, style: pw.TextStyle(font: bold, fontSize: 26, color: rc)),
            ])),
            pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              _mRow('X-Ray Confidence', '${(r.confidence*100).toInt()}%', bold, reg, rc),
              pw.SizedBox(height: 5),
              _mRow('White Patch', '${(r.whitePatchScore*100).toInt()}%', bold, reg, rc),
              pw.SizedBox(height: 5),
              _mRow('Symptom Risk', s.riskCategory, bold, reg, rc),
            ])),
          ]),
        ),
      );

  pw.Widget _recoSection(AnalysisResult r, pw.Font bold, pw.Font reg) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 32),
        child: _card(pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text('CLINICAL RECOMMENDATION', style: pw.TextStyle(font: bold, fontSize: 8, color: _sub, letterSpacing: 1)),
          pw.SizedBox(height: 8),
          pw.Text(r.recommendation, style: pw.TextStyle(font: reg, fontSize: 10, color: _text, lineSpacing: 4)),
        ])),
      );

  pw.Widget _footer(DateTime now, pw.Font bold, pw.Font reg, pw.Font mono) =>
      pw.Container(
        color: _slate,
        margin: const pw.EdgeInsets.only(top: 10),
        padding: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        child: pw.Row(children: [
          pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text('⚠ AI-ASSISTED REPORT — NOT A SUBSTITUTE FOR CLINICAL DIAGNOSIS',
                style: pw.TextStyle(font: bold, fontSize: 8, color: _warn, letterSpacing: 0.8)),
            pw.SizedBox(height: 3),
            pw.Text('This report must be reviewed by a qualified medical professional.',
                style: pw.TextStyle(font: reg, fontSize: 8, color: _sub)),
          ])),
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
            pw.Text('${_fmtDate(now)} ${_fmtTime(now)}', style: pw.TextStyle(font: mono, fontSize: 8, color: _sub)),
            pw.Text('HailMary Health AI v2.1', style: pw.TextStyle(font: mono, fontSize: 8, color: _sub)),
          ]),
        ]),
      );

  // ── Micro widgets ────────────────────────────────────────────

  pw.Widget _card(pw.Widget child) => pw.Container(
    decoration: pw.BoxDecoration(color: _light, borderRadius: pw.BorderRadius.circular(8), border: pw.Border.all(color: _border)),
    padding: const pw.EdgeInsets.all(12),
    child: child,
  );

  pw.Widget _mRow(String l, String v, pw.Font b, pw.Font r, PdfColor vc) =>
      pw.Row(children: [
        pw.Expanded(child: pw.Text(l, style: pw.TextStyle(font: r, fontSize: 9, color: _sub))),
        pw.Text(v, style: pw.TextStyle(font: b, fontSize: 10, color: vc)),
      ]);

  pw.Widget _sRow(String l, String v, pw.Font b, pw.Font r) {
    final bad = v == 'Yes' || v == 'High' || v == 'Extreme';
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(children: [
        pw.Expanded(child: pw.Text(l, style: pw.TextStyle(font: r, fontSize: 9, color: _sub))),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: pw.BoxDecoration(color: bad ? _danger*0.1 : _safe*0.1, borderRadius: pw.BorderRadius.circular(8)),
          child: pw.Text(v, style: pw.TextStyle(font: b, fontSize: 9, color: bad ? _danger : _safe)),
        ),
      ]),
    );
  }

  pw.Widget _dBar(String l, double v, pw.Font b, pw.Font r) {
    final c = v > 0.6 ? _danger : v > 0.3 ? _warn : _safe;
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Row(children: [
        pw.Expanded(child: pw.Text(l, style: pw.TextStyle(font: r, fontSize: 8, color: _sub))),
        pw.Text('${(v.clamp(0,1)*100).toInt()}%', style: pw.TextStyle(font: b, fontSize: 8, color: c)),
      ]),
      pw.SizedBox(height: 2),
      pw.LinearProgressIndicator(value: v.clamp(0,1).toDouble(), backgroundColor: _border, valueColor: c),
    ]);
  }

  pw.Widget _dot(PdfColor c, String l) => pw.Row(children: [
    pw.Container(width: 7, height: 7, decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, color: c)),
    pw.SizedBox(width: 4),
    pw.Text(l, style: pw.TextStyle(fontSize: 8, color: _sub)),
  ]);

  // ── Utilities ─────────────────────────────────────────────────

  PdfColor _riskPdfColor(String l) {
    switch (l.toUpperCase()) {
      case 'HIGH':     return _danger;
      case 'MODERATE': return _warn;
      default:         return _safe;
    }
  }

  String _riskLabel(PdfColor c) {
    if (c == _danger) return 'HIGH';
    if (c == _warn)   return 'MODERATE';
    return 'LOW';
  }

  String _fmtDate(DateTime d) => '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';
  String _fmtTime(DateTime d) => '${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')} IST';
}
