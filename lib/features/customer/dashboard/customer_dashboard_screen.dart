import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/app_routes.dart';
import 'widgets/dashboard_drawer.dart';
import 'widgets/vehicle_selector_widget.dart';

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  State<CustomerDashboardScreen> createState() => _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(24.8607, 67.0011); // Default to Karachi

  VehicleType? _selectedVehicle;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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

  void _openBookRide() {
    if (_selectedVehicle == null) {
      _showSnackBar('Please select a vehicle first.');
      return;
    }
    context.push(AppRoutes.bookRide);
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
            markers: const <Marker>{},
            polylines: const <Polyline>{},
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

          // 3. Top pickup panel
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

          // 4. Bottom panel
          _buildBottomPanel(),
        ],
      ),
    );
  }

  Widget _buildBottomPanel() {
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
            GestureDetector(
              onTap: () => context.push(AppRoutes.bookRide),
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
                      'Where to move your luggage?',
                      style: TextStyle(color: AppConstants.textSecondary, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            VehicleSelectorWidget(onSelected: (v) => _selectedVehicle = v),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _openBookRide,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Confirm Ride', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

