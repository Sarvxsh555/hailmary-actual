import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class CoughScreen extends StatefulWidget {
  const CoughScreen({super.key});

  @override
  State<CoughScreen> createState() => _CoughScreenState();
}

class _CoughScreenState extends State<CoughScreen>
    with TickerProviderStateMixin {
  bool _isRecording = false;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  // Mock metrics
  final double _recoveryIndex = 0.71;
  final int _coughsToday = 14;
  final int _coughsAvgWeek = 22;
  final double _severityScore = 3.2;
  final List<double> _weeklyTrend = [38, 34, 29, 25, 22, 18]; // 6-week trend

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

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
    _pulseController.dispose();
    _waveController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _toggleRecording() {
    setState(() => _isRecording = !_isRecording);
    if (_isRecording) {
      _pulseController.repeat();
      _waveController.repeat();
    } else {
      _pulseController.stop();
      _pulseController.reset();
      _waveController.stop();
      _waveController.reset();
    }
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
        title: Text('Cough Analysis',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
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

              // ── Mic Button + Waveform ──
              Center(
                child: Column(
                  children: [
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Pulse rings
                          if (_isRecording) ...[
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (_, __) => Container(
                                width: 160 * _pulseAnimation.value,
                                height: 160 * _pulseAnimation.value,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.emergency.withValues(
                                        alpha:
                                            (1 - _pulseController.value) * 0.4),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (_, __) {
                                final delayed =
                                    (_pulseController.value + 0.5) % 1.0;
                                final scale = 1.0 + (delayed * 0.4);
                                return Container(
                                  width: 160 * scale,
                                  height: 160 * scale,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.emergency.withValues(
                                          alpha: (1 - delayed) * 0.25),
                                      width: 1.5,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                          // Mic button
                          GestureDetector(
                            onTap: _toggleRecording,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: _isRecording
                                      ? [
                                          AppColors.emergency
                                              .withValues(alpha: 0.9),
                                          AppColors.emergency,
                                        ]
                                      : [
                                          AppColors.info
                                              .withValues(alpha: 0.85),
                                          AppColors.info,
                                        ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (_isRecording
                                            ? AppColors.emergency
                                            : AppColors.info)
                                        .withValues(alpha: 0.3),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isRecording
                                    ? Icons.stop_rounded
                                    : Icons.mic_rounded,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _isRecording
                          ? 'Recording... Tap to stop'
                          : 'Tap to start recording',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: _isRecording
                            ? AppColors.emergency
                            : AppColors.textSecondary,
                        fontWeight:
                            _isRecording ? FontWeight.w500 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Animated Waveform ──
              SizedBox(
                height: 70,
                child: AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, _) {
                    return CustomPaint(
                      size: Size(MediaQuery.of(context).size.width - 48, 70),
                      painter: _WaveformPainter(
                        isActive: _isRecording,
                        phase: _waveController.value * 2 * pi,
                        color: _isRecording
                            ? AppColors.emergency
                            : AppColors.info.withValues(alpha: 0.3),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 28),

              // ── Recovery Index ──
              Text(
                'Recovery Index',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              GlassCard(
                accentColor: AppColors.safe,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _recoveryIndex.toStringAsFixed(2),
                              style: GoogleFonts.outfit(
                                fontSize: 40,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'out of 1.00',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.safe.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.trending_up_rounded,
                                  color: AppColors.safe, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                'Improving',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.safe,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        height: 12,
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.safe.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: _recoveryIndex,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.safe.withValues(alpha: 0.7),
                                      AppColors.safe,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Cough Frequency Metrics ──
              Text(
                'Cough Frequency',
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
                    child: _MetricCard(
                      icon: Icons.today_rounded,
                      label: 'Today',
                      value: '$_coughsToday',
                      unit: 'coughs',
                      color: AppColors.info,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.calendar_view_week_rounded,
                      label: 'Weekly Avg',
                      value: '$_coughsAvgWeek',
                      unit: 'coughs/day',
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.speed_rounded,
                      label: 'Severity',
                      value: _severityScore.toStringAsFixed(1),
                      unit: '/ 10',
                      color: AppColors.emergency,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.nightlight_outlined,
                      label: 'Nocturnal',
                      value: '4',
                      unit: 'episodes',
                      color: Color(0xFF7B68EE),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── 6-Week Recovery Trend ──
              Text(
                '6-Week Recovery Trend',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    SizedBox(
                      height: 160,
                      child: _TrendBars(data: _weeklyTrend),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (i) {
                        return Text(
                          'W${i + 1}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.textTertiary,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            gradient: LinearGradient(
                              colors: [
                                AppColors.info,
                                AppColors.safe,
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Coughs per day (avg)',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '↓ 53% improvement',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.safe,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
//  Waveform Painter
// ══════════════════════════════════════════════════════════════════════

class _WaveformPainter extends CustomPainter {
  final bool isActive;
  final double phase;
  final Color color;

  _WaveformPainter({
    required this.isActive,
    required this.phase,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final midY = size.height / 2;
    final barCount = 50;
    final barWidth = size.width / barCount;
    final rand = Random(42);

    if (isActive) {
      // Active waveform — animated bars
      for (int i = 0; i < barCount; i++) {
        final x = i * barWidth + barWidth / 2;
        final amplitude = (sin(phase + i * 0.3) * 0.5 + 0.5) *
            (rand.nextDouble() * 0.6 + 0.4);
        final h = amplitude * size.height * 0.8;
        canvas.drawLine(
          Offset(x, midY - h / 2),
          Offset(x, midY + h / 2),
          paint,
        );
      }
    } else {
      // Idle waveform — flat line with subtle bumps
      path.moveTo(0, midY);
      for (int i = 0; i <= barCount; i++) {
        final x = i * barWidth;
        final y = midY + sin(i * 0.5) * 3;
        path.lineTo(x, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter old) => true;
}

// ══════════════════════════════════════════════════════════════════════
//  Metric Card
// ══════════════════════════════════════════════════════════════════════

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _MetricCard({
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
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const Spacer(),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(children: [
              TextSpan(
                text: value,
                style: GoogleFonts.outfit(
                  fontSize: 24,
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
            ]),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
//  Trend Bars
// ══════════════════════════════════════════════════════════════════════

class _TrendBars extends StatelessWidget {
  final List<double> data;

  const _TrendBars({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxVal = data.reduce(max);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(data.length, (i) {
        final ratio = data[i] / maxVal;
        final isLast = i == data.length - 1;
        // Gradient from blue to green as weeks progress
        final t = i / (data.length - 1);
        final color = Color.lerp(AppColors.info, AppColors.safe, t)!;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${data[i].toInt()}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isLast ? AppColors.safe : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedContainer(
                  duration: Duration(milliseconds: 400 + i * 100),
                  curve: Curves.easeOut,
                  height: ratio * 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        color,
                        color.withValues(alpha: 0.6),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
