import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

import '../../../../core/constants/app_constants.dart';
import 'widgets/dashboard_drawer.dart';
import 'widgets/vehicle_selector_widget.dart';
import 'widgets/driver_info_panel.dart';

enum RideState { idle, searching, assigned, inProgress }

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  State<CustomerDashboardScreen> createState() => _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(24.8607, 67.0011); // Default to Karachi
  
  RideState _rideState = RideState.idle;
  VehicleType? _selectedVehicle;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  static const LatLng _initialPosition = LatLng(24.8607, 67.0011);

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showPermissionDialog(
        "Location Services Disabled",
        "Please enable location services to use the map features.",
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showPermissionDialog(
          "Permission Denied",
          "Location permission is required to show your current position on the map.",
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showPermissionDialog(
        "Permission Permanently Denied",
        "Location permission is permanently denied. Please enable it in settings to use this feature.",
      );
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_currentPosition, 15),
    );
  }

  void _showPermissionDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.surfaceColor,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: AppConstants.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: AppConstants.primaryColor)),
          ),
          if (title.contains("Denied"))
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Geolocator.openAppSettings();
              },
              child: const Text("Open Settings", style: TextStyle(color: AppConstants.primaryColor)),
            ),
        ],
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_currentPosition, 15),
    );
  }

  void _handleBookRide() {
    if (_selectedVehicle == null) {
      _showSnackBar("Please select a vehicle first.");
      return;
    }
    setState(() {
      _rideState = RideState.searching;
      _markers.clear();
      // Add some random "drivers" nearby
      _markers.add(Marker(
        markerId: const MarkerId('dr1'),
        position: LatLng(_currentPosition.latitude + 0.002, _currentPosition.longitude + 0.002),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ));
      _markers.add(Marker(
        markerId: const MarkerId('dr2'),
        position: LatLng(_currentPosition.latitude - 0.002, _currentPosition.longitude - 0.001),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ));
    });
    
    // Simulate finding a driver after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _rideState == RideState.searching) {
        setState(() {
          _rideState = RideState.assigned;
          _markers.clear();
          // Assigned driver marker
          final driverPos = LatLng(_currentPosition.latitude + 0.003, _currentPosition.longitude + 0.003);
          _markers.add(Marker(
            markerId: const MarkerId('assigned_driver'),
            position: driverPos,
            infoWindow: const InfoWindow(title: "Ahmed Khan (Mini Truck)"),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          ));
          // Route simulation
          _polylines.add(Polyline(
            polylineId: const PolylineId('route'),
            points: [_currentPosition, driverPos],
            color: AppConstants.primaryColor,
            width: 5,
          ));
        });
      }
    });
  }

  void _cancelRide() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.surfaceColor,
        title: const Text("Cancel Ride", style: TextStyle(color: Colors.white)),
        content: const Text("Are you sure you want to cancel this ride?", style: TextStyle(color: AppConstants.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _rideState = RideState.idle;
                _markers.clear();
                _polylines.clear();
              });
            },
            child: const Text("Yes, Cancel", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const DashboardDrawer(),
      body: Stack(
        children: [
          // 1. Full Screen Map
          GoogleMap(
            initialCameraPosition: const CameraPosition(target: _initialPosition, zoom: 15),
            onMapCreated: _onMapCreated,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            markers: _markers,
            polylines: _polylines,
          ),

          // 2. Floating Menu Button
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppConstants.backgroundColor,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                ),
                child: const Icon(Icons.menu, color: Colors.white),
              ),
            ),
          ),

          // 3. Top Pickup Panel (Idle/Searching)
          if (_rideState == RideState.idle || _rideState == RideState.searching)
            Positioned(
              top: 50,
              left: 80,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppConstants.backgroundColor,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: AppConstants.primaryColor, size: 20),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Current Location",
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.edit, color: AppConstants.textSecondary, size: 16),
                  ],
                ),
              ),
            ),

          // 4. Bottom Panels based on state
          _buildBottomPanel(),
        ],
      ),
    );
  }

  Widget _buildBottomPanel() {
    switch (_rideState) {
      case RideState.idle:
        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppConstants.surfaceColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 20, offset: Offset(0, -5))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Search Bar
                GestureDetector(
                  onTap: () => context.push('/book-ride'),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppConstants.backgroundColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: AppConstants.primaryColor),
                        const SizedBox(width: 12),
                        const Text(
                          "Where to move your luggage?",
                          style: TextStyle(color: AppConstants.textSecondary, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Vehicle Selector
                VehicleSelectorWidget(onSelected: (v) => _selectedVehicle = v),
                const SizedBox(height: 24),
                // Confirm Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _handleBookRide,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text("Confirm Ride", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      
      case RideState.searching:
        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(
              color: AppConstants.surfaceColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: AppConstants.primaryColor),
                const SizedBox(height: 24),
                const Text(
                  "Searching for drivers...",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Nearby drivers are being notified",
                  style: TextStyle(color: AppConstants.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: _cancelRide,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      foregroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Cancel Search"),
                  ),
                ),
              ],
            ),
          ),
        );

      case RideState.assigned:
      case RideState.inProgress:
        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: DriverInfoPanel(
            name: "Ahmed Khan",
            vehicleInfo: "Mini Truck",
            vehicleNumber: "KHI-4567",
            rating: 4.8,
            photoUrl: "https://i.pravatar.cc/150?u=driver",
            onCall: () {},
            onChat: () => context.push('/chat-rooms'),
            onCancel: _cancelRide,
          ),
        );
    }
  }

}
