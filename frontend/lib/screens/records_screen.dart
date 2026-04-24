import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/risk_badge.dart';
import '../models/health_record.dart';
import '../services/api_service.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  String _selectedFilter = 'all';
  List<HealthRecord> _records = [];
  bool _isLoading = true;

  final _filters = [
    {'key': 'all', 'label': 'All'},
    {'key': 'xray', 'label': 'X-Ray'},
    {'key': 'vitals', 'label': 'Vitals'},
    {'key': 'emergency', 'label': 'Emergency'},
  ];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    try {
      final records = await ApiService().getRecords(userId: 'student_001');
      if (mounted) {
        setState(() {
          _records = records;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Use mock data for prototype
      if (mounted) {
        setState(() {
          _records = _mockRecords();
          _isLoading = false;
        });
      }
    }
  }

  List<HealthRecord> _mockRecords() {
    return [
      HealthRecord(
        id: 'rec_001',
        userId: 'patient_001',
        type: 'xray',
        date: '2026-04-23T15:30:00',
        resultSummary: 'TB Detected — High Risk',
        riskLevel: 'HIGH',
        details: {
          'prediction': 'TB_DETECTED',
          'confidence': 0.87,
          'recommendation': 'Consult a pulmonologist immediately',
        },
      ),
      HealthRecord(
        id: 'rec_002',
        userId: 'patient_001',
        type: 'vitals',
        date: '2026-04-23T14:00:00',
        resultSummary: 'HR: 78 BPM • SpO₂: 97%',
        riskLevel: 'LOW',
        details: {
          'heart_rate': 78,
          'spo2_estimate': 97,
          'confidence': 0.72,
        },
      ),
      HealthRecord(
        id: 'rec_003',
        userId: 'patient_001',
        type: 'emergency',
        date: '2026-04-22T22:15:00',
        resultSummary: 'Emergency triggered — Dispatched',
        riskLevel: 'HIGH',
        details: {
          'location': 'Home',
          'status': 'RESOLVED',
        },
      ),
      HealthRecord(
        id: 'rec_004',
        userId: 'patient_001',
        type: 'vitals',
        date: '2026-04-21T10:30:00',
        resultSummary: 'HR: 72 BPM • SpO₂: 98%',
        riskLevel: 'LOW',
        details: {
          'heart_rate': 72,
          'spo2_estimate': 98,
          'confidence': 0.81,
        },
      ),
      HealthRecord(
        id: 'rec_005',
        userId: 'patient_001',
        type: 'xray',
        date: '2026-04-20T09:00:00',
        resultSummary: 'Normal — No abnormalities',
        riskLevel: 'LOW',
        details: {
          'prediction': 'NORMAL',
          'confidence': 0.93,
          'recommendation': 'No immediate action required',
        },
      ),
    ];
  }

  List<HealthRecord> get _filteredRecords {
    if (_selectedFilter == 'all') return _records;
    return _records.where((r) => r.type == _selectedFilter).toList();
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
        title: Text('Health Records',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          // ── Filter Tabs ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((f) {
                  final selected = _selectedFilter == f['key'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: selected,
                      label: Text(f['label']!),
                      selectedColor: AppColors.info.withValues(alpha: 0.15),
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
                      checkmarkColor: AppColors.info,
                      onSelected: (_) {
                        setState(() => _selectedFilter = f['key']!);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Records List ──
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.info,
                      strokeWidth: 2,
                    ),
                  )
                : _filteredRecords.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: _filteredRecords.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _RecordCard(
                            record: _filteredRecords[index],
                            onTap: () => _showRecordDetail(_filteredRecords[index]),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_outlined,
            size: 56,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No records found',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your health records will appear here',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  void _showRecordDetail(HealthRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RecordDetailSheet(record: record),
    );
  }
}

// ── Record Card ───────────────────────────────────────────────

class _RecordCard extends StatelessWidget {
  final HealthRecord record;
  final VoidCallback onTap;

  const _RecordCard({required this.record, required this.onTap});

  Color get _typeColor {
    switch (record.type) {
      case 'xray':
        return AppColors.info;
      case 'vitals':
        return AppColors.emergency;
      case 'emergency':
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }

  IconData get _typeIcon {
    switch (record.type) {
      case 'xray':
        return Icons.medical_information_outlined;
      case 'vitals':
        return Icons.favorite_outline;
      case 'emergency':
        return Icons.emergency_outlined;
      default:
        return Icons.description_outlined;
    }
  }

  String get _formattedDate {
    try {
      final dt = DateTime.parse(record.date);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year} · ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return record.date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _typeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_typeIcon, color: _typeColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.typeDisplay,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  record.resultSummary,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formattedDate,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          RiskBadge(riskLevel: record.riskLevel, fontSize: 11),
        ],
      ),
    );
  }
}

// ── Record Detail Bottom Sheet ────────────────────────────────

class _RecordDetailSheet extends StatelessWidget {
  final HealthRecord record;

  const _RecordDetailSheet({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(28),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Header
                Row(
                  children: [
                    Text(
                      record.typeDisplay,
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    RiskBadge(riskLevel: record.riskLevel),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  record.resultSummary,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // Details
                Text(
                  'Details',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                ...record.details.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key.replaceAll('_', ' ').toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textTertiary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            '${entry.value}',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 24),

                // Record ID
                Center(
                  child: Text(
                    'Record ID: ${record.id}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
