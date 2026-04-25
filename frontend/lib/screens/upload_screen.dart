import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../services/api_service.dart';
import '../models/analysis_result.dart';
import 'results_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _selectedImage;
  final _ageController = TextEditingController();
  String _gender = 'Male';
  final List<String> _selectedSymptoms = [];
  String _duration = 'Less than a week';
  bool _isSubmitting = false;

  final _symptoms = [
    'Cough',
    'Fever',
    'Chest Pain',
    'Shortness of Breath',
    'Fatigue',
    'Weight Loss',
    'Night Sweats',
    'Loss of Appetite',
  ];

  final _durations = [
    'Less than a week',
    '1-2 weeks',
    '2-4 weeks',
    'More than a month',
  ];

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (_selectedImage == null) {
      _showSnack('Please select an X-ray image');
      return;
    }
    if (_ageController.text.isEmpty) {
      _showSnack('Please enter your age');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final result = await ApiService().analyzeXray(
        imageFile: _selectedImage!,
        age: int.tryParse(_ageController.text) ?? 0,
        gender: _gender,
        symptoms: _selectedSymptoms,
        duration: _duration,
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResultsScreen(result: result),
          ),
        );
      }
    } catch (e) {
      // For prototype: navigate with mock result if backend is down
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResultsScreen(
              result: AnalysisResult(
                prediction: 'TB_DETECTED',
                confidence: 0.87,
                riskLevel: 'HIGH',
                heatmapUrl: '/mock/heatmap.png',
                recommendation:
                    'Possible signs of tuberculosis detected. Please consult a pulmonologist immediately for further evaluation.',
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
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
        title: Text('Upload & Analyze', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ── Image Upload ──
            _SectionTitle(title: 'Chest X-Ray Image'),
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.all(24),
              child: _selectedImage != null
                  ? Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            _selectedImage!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: () => setState(() => _selectedImage = null),
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text('Remove'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.emergency,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: AppColors.info.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.add_photo_alternate_outlined,
                            color: AppColors.info,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Upload Chest X-Ray',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Supported: JPG, PNG',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _UploadBtn(
                              icon: Icons.camera_alt_outlined,
                              label: 'Camera',
                              onTap: () => _pickImage(ImageSource.camera),
                            ),
                            const SizedBox(width: 16),
                            _UploadBtn(
                              icon: Icons.photo_library_outlined,
                              label: 'Gallery',
                              onTap: () => _pickImage(ImageSource.gallery),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 28),

            // ── Patient Details ──
            _SectionTitle(title: 'Patient Details'),
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Age
                  TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Age',
                      prefixIcon: const Icon(Icons.cake_outlined, size: 20),
                      labelStyle: GoogleFonts.inter(color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Gender
                  DropdownButtonFormField<String>(
                    value: _gender,
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      prefixIcon: const Icon(Icons.person_outline, size: 20),
                      labelStyle: GoogleFonts.inter(color: AppColors.textSecondary),
                    ),
                    items: ['Male', 'Female', 'Other']
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (v) => setState(() => _gender = v ?? 'Male'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Symptoms ──
            _SectionTitle(title: 'Symptoms'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _symptoms.map((symptom) {
                final selected = _selectedSymptoms.contains(symptom);
                return FilterChip(
                  selected: selected,
                  label: Text(symptom),
                  selectedColor: AppColors.info.withValues(alpha: 0.15),
                  checkmarkColor: AppColors.info,
                  labelStyle: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected ? AppColors.info : AppColors.textSecondary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: selected
                          ? AppColors.info.withValues(alpha: 0.3)
                          : AppColors.divider,
                    ),
                  ),
                  backgroundColor: Colors.white.withValues(alpha: 0.5),
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _selectedSymptoms.add(symptom);
                      } else {
                        _selectedSymptoms.remove(symptom);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 28),

            // ── Duration ──
            _SectionTitle(title: 'Duration'),
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: _durations.map((d) {
                  final selected = d == _duration;
                  return RadioListTile<String>(
                    value: d,
                    groupValue: _duration,
                    onChanged: (v) => setState(() => _duration = v!),
                    title: Text(
                      d,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        color: selected ? AppColors.info : AppColors.textSecondary,
                      ),
                    ),
                    activeColor: AppColors.info,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    dense: true,
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 36),

            // ── Submit ──
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Analyze X-Ray',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _UploadBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _UploadBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.info.withValues(alpha: 0.1),
        foregroundColor: AppColors.info,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
