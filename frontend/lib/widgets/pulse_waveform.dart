import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PulseWaveform extends StatelessWidget {
  final List<double> data;
  final Color? color;
  final double height;
  final double strokeWidth;

  const PulseWaveform({
    super.key,
    required this.data,
    this.color,
    this.height = 120,
    this.strokeWidth = 2.5,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.emergency;
    
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _WaveformPainter(
          data: data,
          color: activeColor,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final double strokeWidth;

  _WaveformPainter({
    required this.data,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Gradient fill under the curve
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.3),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();

    final double dx = size.width / (data.length - 1);

    // Normalize data
    double minVal = data.reduce((a, b) => a < b ? a : b);
    double maxVal = data.reduce((a, b) => a > b ? a : b);
    double range = maxVal - minVal;
    if (range == 0) range = 1;

    double normalizedY(int i) {
      return size.height - ((data[i] - minVal) / range) * size.height * 0.85 - size.height * 0.075;
    }

    path.moveTo(0, normalizedY(0));
    fillPath.moveTo(0, size.height);
    fillPath.lineTo(0, normalizedY(0));

    for (int i = 1; i < data.length; i++) {
      final x = i * dx;
      final y = normalizedY(i);

      // Smooth curve using cubic bezier
      final prevX = (i - 1) * dx;
      final prevY = normalizedY(i - 1);
      final cpx1 = prevX + dx / 3;
      final cpx2 = x - dx / 3;

      path.cubicTo(cpx1, prevY, cpx2, y, x, y);
      fillPath.cubicTo(cpx1, prevY, cpx2, y, x, y);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Draw grid lines
    final gridPaint = Paint()
      ..color = color.withValues(alpha: 0.08)
      ..strokeWidth = 0.5;

    for (int i = 0; i < 5; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw latest point indicator
    if (data.isNotEmpty) {
      final lastX = (data.length - 1) * dx;
      final lastY = normalizedY(data.length - 1);
      canvas.drawCircle(
        Offset(lastX, lastY),
        4,
        Paint()..color = color,
      );
      canvas.drawCircle(
        Offset(lastX, lastY),
        7,
        Paint()
          ..color = color.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.data.length != data.length ||
        (data.isNotEmpty &&
            oldDelegate.data.isNotEmpty &&
            oldDelegate.data.last != data.last);
  }
}
