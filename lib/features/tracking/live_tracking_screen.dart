import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/booking_service.dart';
import '../../models/booking_model.dart';
import '../../widgets/custom_button.dart';

class LiveTrackingScreen extends StatefulWidget {
  final String? bookingId;
  const LiveTrackingScreen({super.key, this.bookingId});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  final LatLng _kInitialPosition = const LatLng(33.684422, 73.047885);
  final BookingService _bookingService = BookingService();
  GoogleMapController? _mapController;

  StreamSubscription<DocumentSnapshot>? _bookingSub;
  StreamSubscription<Position>? _positionSub;
  BookingModel? _booking;
  bool _bookingLoading = true;
  DateTime? _lastLocationWrite;

  @override
  void initState() {
    super.initState();
    final id = widget.bookingId;
    if (id == null || id.isEmpty) return;
    _bookingSub = FirebaseFirestore.instance
        .collection(AppConstants.bookingsCollection)
        .doc(id)
        .snapshots()
        .listen(_onBookingSnapshot, onError: (_) {
      if (mounted) setState(() => _bookingLoading = false);
    });
  }

  void _onBookingSnapshot(DocumentSnapshot snap) {
    if (!mounted) return;
    if (!snap.exists || snap.data() == null) {
      setState(() {
        _booking = null;
        _bookingLoading = false;
      });
      _stopPositionStream();
      return;
    }
    final booking = BookingModel.fromMap(snap.data()! as Map<String, dynamic>);
    setState(() {
      _booking = booking;
      _bookingLoading = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncCamera(booking);
    });
    _syncDriverLocationStream(booking);
  }

  bool _shouldPublishLocation(BookingModel booking, String? uid) {
    if (uid == null || booking.driverId != uid) return false;
    const active = {
      BookingStatus.accepted,
      BookingStatus.onTheWay,
      BookingStatus.arrived,
      BookingStatus.started,
    };
    return active.contains(booking.status);
  }

  Future<void> _syncDriverLocationStream(BookingModel booking) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (!_shouldPublishLocation(booking, uid)) {
      _stopPositionStream();
      return;
    }

    if (_positionSub != null) return;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission needed to share your position')),
        );
      }
      return;
    }

    final id = widget.bookingId;
    if (id == null || id.isEmpty) return;

    final stream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 40,
      ),
    );

    _positionSub = stream.listen(
      (pos) async {
        final b = _booking;
        if (b == null || !_shouldPublishLocation(b, uid)) return;
        final now = DateTime.now();
        if (_lastLocationWrite != null &&
            now.difference(_lastLocationWrite!) < const Duration(seconds: 8)) {
          return;
        }
        _lastLocationWrite = now;
        try {
          await _bookingService.updateDriverLocation(id, pos.latitude, pos.longitude);
        } catch (_) {}
      },
      onError: (_) {},
    );
  }

  void _stopPositionStream() {
    _positionSub?.cancel();
    _positionSub = null;
    _lastLocationWrite = null;
  }

  @override
  void dispose() {
    _stopPositionStream();
    _bookingSub?.cancel();
    super.dispose();
  }

  Set<Marker> _markersFor(BookingModel booking) {
    final lat = booking.driverLat;
    final lng = booking.driverLng;
    if (lat == null || lng == null) return const {};
    return {
      Marker(
        markerId: const MarkerId('driver'),
        position: LatLng(lat, lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'Driver location'),
      ),
    };
  }

  void _syncCamera(BookingModel booking) {
    final lat = booking.driverLat;
    final lng = booking.driverLng;
    if (lat == null || lng == null || _mapController == null) return;
    _mapController!.animateCamera(CameraUpdate.newLatLng(LatLng(lat, lng)));
  }

  String _arrivalHeadline(BookingModel booking) {
    if (booking.status == BookingStatus.pending) {
      return 'Waiting for a driver';
    }
    if (booking.driverLat == null || booking.driverLng == null) {
      return 'Waiting for driver location';
    }
    return 'Live tracking';
  }

  bool _isAssignedDriver(BookingModel booking) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return uid != null && booking.driverId == uid;
  }

  Future<void> _advanceStatus(BookingModel booking, BookingStatus next) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await _bookingService.advanceDriverBookingStatus(
        bookingId: booking.bookingId,
        driverUid: uid,
        nextStatus: next,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to ${next.name}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bookingId == null || widget.bookingId!.isEmpty) {
      return Scaffold(
        backgroundColor: AppConstants.backgroundColor,
        appBar: AppBar(title: const Text('Tracking')),
        body: const Center(
          child: Text('No active booking to track', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    if (_bookingLoading) {
      return const Scaffold(
        backgroundColor: AppConstants.backgroundColor,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final booking = _booking;
    if (booking == null) {
      return const Scaffold(
        backgroundColor: AppConstants.backgroundColor,
        body: Center(child: Text('Booking not found', style: TextStyle(color: Colors.white))),
      );
    }

    final markers = _markersFor(booking);
    final isDriver = _isAssignedDriver(booking);

    WidgetsBinding.instance.addPostFrameCallback((_) => _syncCamera(booking));

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            bottom: 250,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: _kInitialPosition, zoom: 15),
              onMapCreated: (c) {
                _mapController = c;
                _syncCamera(booking);
              },
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              style: _mapDarkStyle,
              markers: markers,
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppConstants.secondaryColor.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),

          if (markers.isEmpty && booking.status != BookingStatus.pending)
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 72, left: 24, right: 24),
                  child: Material(
                    color: AppConstants.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text(
                        _arrivalHeadline(booking),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 420,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppConstants.backgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 40,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        height: 4,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'STATUS',
                                style: TextStyle(
                                  color: AppConstants.textSecondary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _arrivalHeadline(booking),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppConstants.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            booking.status.name.toUpperCase().replaceAll('_', ' '),
                            style: const TextStyle(
                              color: AppConstants.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildProgressBar(booking),
                    const SizedBox(height: 16),
                    if (isDriver) ..._driverActionButtons(booking),
                    if (isDriver && booking.status == BookingStatus.arrived) ...[
                      const SizedBox(height: 12),
                      CustomButton(
                        label: 'COMPLETE DELIVERY',
                        onPressed: () =>
                            context.push(AppRoutes.deliveryCamera, extra: booking.bookingId),
                      ),
                    ],
                    if (!isDriver && booking.driverId != null) ...[
                      const SizedBox(height: 16),
                      _DriverContactRow(
                        key: ValueKey(booking.driverId),
                        booking: booking,
                        bookingService: _bookingService,
                      ),
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _driverActionButtons(BookingModel booking) {
    if (booking.status == BookingStatus.accepted) {
      return [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _advanceStatus(booking, BookingStatus.onTheWay),
            icon: const Icon(Icons.directions_car, color: AppConstants.primaryColor),
            label: const Text('En route to pickup'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: AppConstants.primaryColor),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ];
    }
    if (booking.status == BookingStatus.onTheWay) {
      return [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _advanceStatus(booking, BookingStatus.arrived),
            icon: const Icon(Icons.place, color: AppConstants.primaryColor),
            label: const Text('Arrived at pickup'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: AppConstants.primaryColor),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ];
    }
    return const [];
  }

  Widget _buildProgressBar(BookingModel booking) {
    double progress = 0.0;
    if (booking.status == BookingStatus.accepted) progress = 0.2;
    if (booking.status == BookingStatus.onTheWay) progress = 0.5;
    if (booking.status == BookingStatus.arrived) progress = 0.8;
    if (booking.status == BookingStatus.completed) progress = 1.0;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.white.withValues(alpha: 0.05),
            valueColor: const AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _StatusLabel(label: 'Pickup', active: progress >= 0.2),
            _StatusLabel(label: 'In transit', active: progress >= 0.5),
            _StatusLabel(label: 'Drop-off', active: progress >= 0.8),
          ],
        ),
      ],
    );
  }

  final String _mapDarkStyle = '''
  [
    {
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#212121"
        }
      ]
    },
    {
      "elementType": "labels.icon",
      "stylers": [
        {
          "visibility": "off"
        }
      ]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#757575"
        }
      ]
    }
  ]
  ''';
}

class _DriverContactRow extends StatelessWidget {
  final BookingModel booking;
  final BookingService bookingService;

  const _DriverContactRow({
    super.key,
    required this.booking,
    required this.bookingService,
  });

  @override
  Widget build(BuildContext context) {
    final driverId = booking.driverId!;
    return FutureBuilder<Map<String, dynamic>?>(
      future: bookingService.getDriverProfileMap(driverId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 72,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        final p = snap.data;
        final name = (p?['name'] as String?)?.trim();
        final displayName = (name != null && name.isNotEmpty) ? name : 'Driver';
        final vehicleType = (p?['vehicleType'] as String?)?.trim() ?? '';
        final vehicleNumber = (p?['vehicleNumber'] as String?)?.trim() ?? '';
        final vehicleLine = [vehicleType, vehicleNumber].where((s) => s.isNotEmpty).join(' · ');
        final phone = (p?['phone'] as String?)?.trim() ?? '';
        final photoUrl = (p?['profileImage'] as String?) ?? '';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppConstants.primaryColor,
                backgroundImage: photoUrl.isNotEmpty && photoUrl.startsWith('http')
                    ? NetworkImage(photoUrl)
                    : null,
                child: photoUrl.isEmpty || !photoUrl.startsWith('http')
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    if (vehicleLine.isNotEmpty)
                      Text(
                        vehicleLine,
                        style: const TextStyle(color: AppConstants.textSecondary, fontSize: 11),
                      ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  context.push(AppRoutes.chat, extra: {
                    'bookingId': booking.bookingId,
                    'receiverName': displayName,
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () async {
                  if (phone.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Phone number not available')),
                    );
                    return;
                  }
                  final uri = Uri(scheme: 'tel', path: phone);
                  if (await canLaunchUrl(uri)) await launchUrl(uri);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.phone_rounded, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatusLabel extends StatelessWidget {
  final String label;
  final bool active;
  const _StatusLabel({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: active ? AppConstants.primaryColor : AppConstants.textSecondary,
        fontSize: 10,
        fontWeight: active ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
