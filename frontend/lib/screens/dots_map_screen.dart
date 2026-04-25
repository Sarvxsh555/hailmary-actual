import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class DotsCenter {
  final String name;
  final LatLng location;
  final String address;
  final String hours;
  final String distance;

  DotsCenter({
    required this.name,
    required this.location,
    required this.address,
    required this.hours,
    required this.distance,
  });
}

class DotsMapScreen extends StatefulWidget {
  const DotsMapScreen({super.key});

  @override
  State<DotsMapScreen> createState() => _DotsMapScreenState();
}

class _DotsMapScreenState extends State<DotsMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  
  bool _isLoading = true;
  bool _permissionDenied = false;
  LatLng? _userLocation;
  Set<Marker> _markers = {};
  DotsCenter? _selectedCenter;

  // Fallback location if location services are disabled
  static const LatLng _fallbackLocation = LatLng(28.6139, 77.2090); // New Delhi

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _setLocation(null);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _permissionDenied = true;
          _isLoading = false;
        });
        _setLocation(null);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _permissionDenied = true;
        _isLoading = false;
      });
      _setLocation(null);
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      _setLocation(LatLng(position.latitude, position.longitude));
    } catch (e) {
      _setLocation(null);
    }
  }

  void _setLocation(LatLng? actualLocation) {
    setState(() {
      _userLocation = actualLocation ?? _fallbackLocation;
      _isLoading = false;
      _generateMockSpots(_userLocation!);
    });
  }

  void _generateMockSpots(LatLng center) {
    // Generate 4 mock DOTS centers around the user's location
    final List<DotsCenter> mockCenters = [
      DotsCenter(
        name: 'City General Hospital (DOTS Clinic)',
        location: LatLng(center.latitude + 0.012, center.longitude + 0.015),
        address: '123 Health Ave, North Wing',
        hours: 'Mon-Sat: 8 AM - 4 PM',
        distance: '1.2 km',
      ),
      DotsCenter(
        name: 'Community Health Center TB Unit',
        location: LatLng(center.latitude - 0.02, center.longitude + 0.01),
        address: '45 Wellness Blvd',
        hours: 'Mon-Fri: 9 AM - 5 PM',
        distance: '2.5 km',
      ),
      DotsCenter(
        name: 'Downtown Medical DOTS Center',
        location: LatLng(center.latitude + 0.005, center.longitude - 0.018),
        address: '77 Care Lane, Basement 2',
        hours: 'Everyday: 10 AM - 6 PM',
        distance: '0.8 km',
      ),
      DotsCenter(
        name: 'Suburban Care Poly Clinic',
        location: LatLng(center.latitude - 0.015, center.longitude - 0.025),
        address: '109 Outer Ring Road',
        hours: 'Mon-Sat: 7 AM - 3 PM',
        distance: '3.1 km',
      ),
    ];

    Set<Marker> newMarkers = {};
    for (int i = 0; i < mockCenters.length; i++) {
      final centerInfo = mockCenters[i];
      newMarkers.add(
        Marker(
          markerId: MarkerId('dots_center_$i'),
          position: centerInfo.location,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          onTap: () {
            setState(() {
              _selectedCenter = centerInfo;
            });
          },
        ),
      );
    }

    setState(() {
      _markers = newMarkers;
    });
  }

  void _unfocusCenter() {
    if (_selectedCenter != null) {
      setState(() {
        _selectedCenter = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.info),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Find DOTS Centers',
          style: GoogleFonts.outfit(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: _userLocation!,
                zoom: 13.5,
              ),
              markers: _markers,
              myLocationEnabled: !_permissionDenied, 
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                if (!_controller.isCompleted) {
                  _controller.complete(controller);
                }
              },
              onTap: (_) => _unfocusCenter(),
            ),
          ),

          // Search bar overlay (visual only for prototype)
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, color: AppColors.textSecondary),
                  const SizedBox(width: 12),
                  Text(
                    'Search nearby clinics...',
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Details Card
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            bottom: _selectedCenter != null ? 30 : -200,
            left: 20,
            right: 20,
            child: _selectedCenter == null
                ? const SizedBox.shrink()
                : GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _selectedCenter!.name,
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.info.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _selectedCenter!.distance,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.info,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _selectedCenter!.address,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _selectedCenter!.hours,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Navigation feature coming soon!'),
                                  backgroundColor: AppColors.info,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.info,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              'Get Directions',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          
          // User location permission error
          if (_permissionDenied && _selectedCenter == null)
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: GlassCard(
                accentColor: AppColors.warning,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.location_off_rounded, color: AppColors.warning),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Location access denied. Showing default map area.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _selectedCenter == null ? FloatingActionButton(
        onPressed: () async {
          if (_userLocation != null) {
            final controller = await _controller.future;
            controller.animateCamera(CameraUpdate.newLatLng(_userLocation!));
          }
        },
        backgroundColor: AppColors.info,
        child: const Icon(Icons.my_location_rounded, color: Colors.white),
      ) : null,
    );
  }
}
