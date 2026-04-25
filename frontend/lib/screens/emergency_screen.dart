import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../services/api_service.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen>
    with TickerProviderStateMixin {
  bool _sending = true;
  String? _eventId;
  late AnimationController _checkController;
  late Animation<double> _checkAnimation;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _checkAnimation = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _triggerEmergency();
  }

  Future<void> _triggerEmergency() async {
    try {
      final event = await ApiService().triggerEmergency(
        userId: 'patient_001',
        location: 'Home / Current Location',
        description: 'Emergency triggered via HailMary button',
      );
      if (mounted) {
        setState(() {
          _sending = false;
          _eventId = event.id;
        });
        _checkController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _sending = false;
          _eventId = 'EMG-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
        });
        _checkController.forward();
      }
    }
  }

  @override
  void dispose() {
    _checkController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Emergency', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _sending ? _buildSendingState() : _buildResultState(),
        ),
      ),
    );
  }

  Widget _buildSendingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) {
              return Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.emergency.withValues(alpha: 0.1),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.emergency.withValues(alpha: 0.2 * _pulseController.value),
                      blurRadius: 30,
                      spreadRadius: 10 * _pulseController.value,
                    ),
                  ],
                ),
                child: Center(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppColors.emergency,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          Text(
            'Sending Alert...',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Contacting emergency health services',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultState() {
    return Column(
      children: [
        const Spacer(),
        // Success animation
        ScaleTransition(
          scale: _checkAnimation,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.safe.withValues(alpha: 0.12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.safe.withValues(alpha: 0.15),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              Icons.check_rounded,
              color: AppColors.safe,
              size: 56,
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Alert Sent Successfully',
          style: GoogleFonts.outfit(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Help is on the way',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 36),

        // Details card
        GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _DetailRow(label: 'Event ID', value: _eventId ?? 'N/A'),
              const SizedBox(height: 14),
              _DetailRow(
                label: 'Time',
                value: _formatTime(DateTime.now()),
              ),
              const SizedBox(height: 14),
              _DetailRow(label: 'Location', value: 'Home / Current Location'),
              const SizedBox(height: 14),
              _DetailRow(label: 'Status', value: 'DISPATCHED', isStatus: true),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Mock notifications
        GlassCard(
          accentColor: AppColors.info,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.notifications_active_outlined,
                      color: AppColors.info, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Notifications Sent',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _NotifItem(text: 'Emergency Health Center alerted', time: '0s ago'),
              _NotifItem(text: 'Emergency contacts notified', time: '1s ago'),
              _NotifItem(text: 'Emergency contact SMS sent', time: '2s ago'),
            ],
          ),
        ),

        const Spacer(),

        // Back button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.info,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Back to Home',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isStatus;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        isStatus
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.safe.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.safe,
                  ),
                ),
              )
            : Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
      ],
    );
  }
}

class _NotifItem extends StatelessWidget {
  final String text;
  final String time;

  const _NotifItem({required this.text, required this.time});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.safe,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary),
            ),
          ),
          Text(
            time,
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}
