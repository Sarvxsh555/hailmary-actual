import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/tb_center.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────
//  Colour + icon helpers
// ─────────────────────────────────────────────────────────
Color _centerColor(TBCenter c) =>
    c.isDots ? const Color(0xFF2EB87A) : const Color(0xFFE87D2E);

IconData _centerIcon(TBCenter c) =>
    c.isDots ? Icons.coronavirus_rounded : Icons.local_hospital_rounded;

String _centerLabel(TBCenter c) =>
    c.isDots ? 'TB / DOTS Centre' : 'Govt. Hospital';

// ─────────────────────────────────────────────────────────
//  TBMapWidget
// ─────────────────────────────────────────────────────────
class TBMapWidget extends StatefulWidget {
  const TBMapWidget({super.key});

  @override
  State<TBMapWidget> createState() => _TBMapWidgetState();
}

class _TBMapWidgetState extends State<TBMapWidget> {
  LatLng? _currentLocation;
  List<TBCenter> _allCenters = []; // full loaded dataset
  List<TBCenter> _nearby = []; // filtered + prioritised
  TBCenter? _selected;

  bool _loadingLocation = true;
  bool _loadingData = true;
  String? _error;

  final MapController _mapController = MapController();
  final _distCalc = const Distance();

  @override
  void initState() {
    super.initState();
    _init();
  }

  // ────────────────────────────────────────
  //  Init: load JSON + get GPS in parallel
  // ────────────────────────────────────────
  Future<void> _init() async {
    await Future.wait([_loadDataset(), _initLocation()]);
    _applyFilter();
  }

  // ── Load JSON asset ──
  Future<void> _loadDataset() async {
    try {
      final raw = await rootBundle.loadString('assets/tb_centers.json');
      final list = jsonDecode(raw) as List<dynamic>;
      _allCenters = list
          .map((e) => TBCenter.fromJson(e as Map<String, dynamic>))
          .toList();
      debugPrint('[TBMap] Dataset loaded: ${_allCenters.length} centres');
    } catch (e) {
      debugPrint('[TBMap] Dataset load error: $e');
    } finally {
      if (mounted) setState(() => _loadingData = false);
    }
  }

  // ── GPS permission + position ──
  Future<void> _initLocation() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        setState(() {
          _error =
              'Location permission permanently denied.\nPlease enable it in device settings.';
          _loadingLocation = false;
        });
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      _currentLocation = LatLng(pos.latitude, pos.longitude);
      debugPrint('[TBMap] Location: ${pos.latitude}, ${pos.longitude}');
    } catch (e) {
      setState(() {
        _error = 'Could not get your location.\n$e';
      });
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  // ────────────────────────────────────────
  //  Filter + priority logic
  // ────────────────────────────────────────
  void _applyFilter() {
    if (_allCenters.isEmpty) {
      setState(() => _nearby = []);
      return;
    }

    // No location yet → show full dataset
    if (_currentLocation == null) {
      setState(() => _nearby = List.from(_allCenters));
      return;
    }

    final origin = _currentLocation!;

    // Pre-compute distances once
    final withDist = _allCenters.map((c) {
      final d = _distCalc(origin, LatLng(c.lat, c.lon));
      return MapEntry(c, d);
    }).toList();

    debugPrint('[TBMap] Total dataset: ${_allCenters.length} centres');

    // ── Progressive radius: expand until ≥ 10 results ──
    const radii = [5000, 10000, 15000, 25000, 40000];
    List<MapEntry<TBCenter, double>> nearby = [];

    for (final r in radii) {
      nearby = withDist.where((e) => e.value <= r).toList();
      debugPrint('[TBMap] Radius ${r}m → ${nearby.length} centres');
      if (nearby.length >= 10) break;
    }

    // Full-dataset fallback (user outside all covered cities)
    if (nearby.isEmpty) {
      nearby = List.from(withDist);
      debugPrint('[TBMap] Fallback: showing all ${nearby.length} centres');
    }

    // Sort by distance
    nearby.sort((a, b) => a.value.compareTo(b.value));

    // ── Balanced merge: up to 7 DOTS + up to 8 Govt ──
    final dots = nearby.where((e) => e.key.isDots).take(7).toList();
    final govt = nearby.where((e) => !e.key.isDots).take(8).toList();

    // Merge DOTS first, then govt, then re-sort merged by distance
    final merged = [...dots, ...govt]
      ..sort((a, b) => a.value.compareTo(b.value));

    debugPrint(
        '[TBMap] Merged: ${dots.length} DOTS + ${govt.length} Govt = ${merged.length}');

    // Cap at 15
    final top15 = merged.take(15).map((e) => e.key).toList();
    final nearest = top15.isNotEmpty ? top15.first : null;

    setState(() {
      _nearby = top15;
      _selected = nearest;
    });

    // Auto-zoom to nearest centre
    if (nearest != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(LatLng(nearest.lat, nearest.lon), 13.0);
      });
    }
  }

  // ────────────────────────────────────────
  //  Google Maps navigation
  // ────────────────────────────────────────
  Future<void> _openInGoogleMaps(TBCenter center) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${center.lat},${center.lon}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      final geo = Uri.parse(
        'geo:${center.lat},${center.lon}?q=${center.lat},${center.lon}(${Uri.encodeComponent(center.name)})',
      );
      if (await canLaunchUrl(geo)) await launchUrl(geo);
    }
  }

  // ────────────────────────────────────────
  //  Build
  // ────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_loadingLocation || _loadingData) {
      return _buildLoader(
        _loadingLocation ? 'Getting your location…' : 'Loading TB centres…',
      );
    }
    if (_error != null) return _buildError(_error!);

    return Column(
      children: [
        Expanded(child: _buildMap()),
        if (_selected != null) _buildInfoBar(_selected!),
        _buildStatusBar(),
      ],
    );
  }

  // ── Map ──
  Widget _buildMap() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation ?? const LatLng(13.0827, 80.2707),
              initialZoom: 13.0,
              onTap: (_, __) => setState(() => _selected = null),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.hailmary.health',
                maxZoom: 19,
              ),
              MarkerLayer(markers: _buildMarkers()),
            ],
          ),

          // ── Legend ──
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _legendRow(const Color(0xFF2EB87A), 'TB / DOTS Centre'),
                  const SizedBox(height: 4),
                  _legendRow(const Color(0xFFE87D2E), 'Govt. Hospital'),
                  const SizedBox(height: 4),
                  _legendRow(AppColors.info, 'You'),
                ],
              ),
            ),
          ),

          // ── Re-centre / re-focus nearest FAB ──
          Positioned(
            bottom: 12,
            right: 12,
            child: FloatingActionButton.small(
              heroTag: 'tb_map_recenter',
              backgroundColor: Colors.white,
              elevation: 4,
              onPressed: () {
                final target = _nearby.isNotEmpty
                    ? LatLng(_nearby.first.lat, _nearby.first.lon)
                    : _currentLocation;
                if (target != null) {
                  _mapController.move(target, 13.0);
                  if (_nearby.isNotEmpty) {
                    setState(() => _selected = _nearby.first);
                  }
                }
              },
              child: Icon(
                Icons.my_location_rounded,
                color: AppColors.info,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendRow(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration:
              BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // ── Markers ──
  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    // TB centre markers
    for (final center in _nearby) {
      final color = _centerColor(center);
      final icon = _centerIcon(center);
      final isSelected = _selected == center;

      markers.add(
        Marker(
          point: LatLng(center.lat, center.lon),
          width: isSelected ? 56 : 44,
          height: isSelected ? 56 : 44,
          child: GestureDetector(
            onTap: () => setState(() {
              _selected = (_selected == center) ? null : center;
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: Colors.white, width: 3)
                    : Border.all(
                        color: Colors.white.withValues(alpha: 0.6),
                        width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(
                        alpha: isSelected ? 0.6 : 0.35),
                    blurRadius: isSelected ? 18 : 7,
                    spreadRadius: isSelected ? 4 : 1,
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: isSelected ? 28 : 22,
              ),
            ),
          ),
        ),
      );
    }

    // User location marker (always on top)
    if (_currentLocation != null) {
      markers.add(
        Marker(
          point: _currentLocation!,
          width: 58,
          height: 58,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.13),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.info.withValues(alpha: 0.28),
                    width: 1.5,
                  ),
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.info,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.info.withValues(alpha: 0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.navigation_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return markers;
  }

  // ── Info bar ──
  Widget _buildInfoBar(TBCenter center) {
    final color = _centerColor(center);
    final icon = _centerIcon(center);
    final distM = _currentLocation != null
        ? _distCalc(_currentLocation!, LatLng(center.lat, center.lon))
        : 0.0;
    final distStr = distM >= 1000
        ? '${(distM / 1000).toStringAsFixed(1)} km'
        : '${distM.toStringAsFixed(0)} m';

    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 4),
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          // Icon badge
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),

          // Name + meta
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  center.name,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _centerLabel(center),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '$distStr away · ${center.city}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Navigate button
          GestureDetector(
            onTap: () => _openInGoogleMaps(center),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: color.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.directions_rounded,
                      color: color, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Navigate',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Close
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 16),
            color: AppColors.textTertiary,
            onPressed: () => setState(() => _selected = null),
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  // ── Status bar ──
  Widget _buildStatusBar() {
    final dotsCount = _nearby.where((c) => c.isDots).length;
    final govtCount = _nearby.where((c) => !c.isDots).length;

    String text;
    if (_nearby.isEmpty) {
      text = 'No TB centres found nearby';
    } else {
      final parts = <String>[];
      if (dotsCount > 0) parts.add('$dotsCount DOTS');
      if (govtCount > 0) parts.add('$govtCount Govt');
      text = '${parts.join(' · ')} · tap marker for directions';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(20)),
        border: Border(
          top: BorderSide(
              color: AppColors.divider.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on_rounded,
            size: 14,
            color: AppColors.emergency,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _loadingLocation = true;
                _loadingData = true;
                _error = null;
                _allCenters = [];
                _nearby = [];
                _selected = null;
              });
              _init();
            },
            child: Text(
              'Refresh',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.info,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Loader / Error ──
  Widget _buildLoader(String msg) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
              color: AppColors.info, strokeWidth: 2.5),
          const SizedBox(height: 14),
          Text(
            msg,
            style: GoogleFonts.inter(
                fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_off_rounded,
                size: 48, color: AppColors.emergency),
            const SizedBox(height: 16),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _error = null;
                  _loadingLocation = true;
                  _loadingData = true;
                  _allCenters = [];
                  _nearby = [];
                });
                _init();
              },
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
