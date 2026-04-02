import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'dart:async';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/booking_service.dart';
import '../../../../models/booking_model.dart';
import '../../../../providers/app_state.dart' hide LuggageItem, LuggageStatus;
import '../dashboard/widgets/vehicle_selector_widget.dart';
import '../dashboard/widgets/driver_info_panel.dart';

class BookRideScreen extends StatefulWidget {
  const BookRideScreen({super.key});

  @override
  State<BookRideScreen> createState() => _BookRideScreenState();
}

class _BookRideScreenState extends State<BookRideScreen> {
  final LatLng _kInitialPosition = const LatLng(24.8607, 67.0011); // Karachi
  VehicleType? _selectedVehicle;
  final _pickupController = TextEditingController();
  final _dropController = TextEditingController();
  final _bidController = TextEditingController();
  
  final List<LuggageItem> _items = [];
  final _bookingService = BookingService();
  final ImagePicker _picker = ImagePicker();
  
  BookingStatus _rideStatus = BookingStatus.pending;
  BookingModel? _activeBooking;
  
  GoogleMapController? _mapController;
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};
  Timer? _trackingTimer;

  @override
  void dispose() {
    _trackingTimer?.cancel();
    _pickupController.dispose();
    _dropController.dispose();
    _bidController.dispose();
    super.dispose();
  }

  void _updateRoute() {
    if (_pickupController.text.isNotEmpty && _dropController.text.isNotEmpty) {
      setState(() {
        _markers.clear();
        _markers.add(
          const Marker(
            markerId: MarkerId('origin'),
            position: LatLng(24.8607, 67.0011),
            infoWindow: InfoWindow(title: 'Origin'),
          ),
        );
        _markers.add(
          const Marker(
            markerId: MarkerId('destination'),
            position: LatLng(24.8707, 67.0111),
            infoWindow: InfoWindow(title: 'Destination'),
          ),
        );
        _polylines.add(
          const Polyline(
            polylineId: PolylineId('route'),
            points: [
              LatLng(24.8607, 67.0011),
              LatLng(24.8657, 67.0051),
              LatLng(24.8707, 67.0111),
            ],
            color: AppConstants.primaryColor,
            width: 5,
          ),
        );
      });
    }
  }

  Future<void> _addItem() async {
    String name = "";
    int quantity = 1;
    XFile? image;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppConstants.surfaceColor,
          title: const Text("Add Luggage Item", style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Item Name (e.g. Chair)", 
                    hintStyle: TextStyle(color: Colors.white30),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  ),
                  onChanged: (val) => name = val,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text("Quantity: ", style: TextStyle(color: Colors.white70)),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: AppConstants.primaryColor),
                      onPressed: () { if (quantity > 1) setDialogState(() => quantity--); },
                    ),
                    Text("$quantity", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: AppConstants.primaryColor),
                      onPressed: () => setDialogState(() => quantity++),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final picked = await _picker.pickImage(source: ImageSource.gallery);
                    if (picked != null) setDialogState(() => image = picked);
                  },
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: image == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, color: Colors.white54), 
                              SizedBox(height: 4),
                              Text("Upload Image", style: TextStyle(color: Colors.white54, fontSize: 12))
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12), 
                            child: Image.file(File(image!.path), fit: BoxFit.cover)
                          ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                if (name.isNotEmpty) {
                  setState(() {
                    _items.add(LuggageItem(name: name, quantity: quantity, imageUrl: image?.path)); 
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Add"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createBooking() async {
    final appState = Provider.of<AppState>(context, listen: false);
    if (!appState.isAuthenticated) {
      _showSnackBar("Please login to book a ride");
      return;
    }

    if (_pickupController.text.isEmpty || 
        _dropController.text.isEmpty || 
        _bidController.text.isEmpty || 
        _items.isEmpty || 
        _selectedVehicle == null) {
      _showSnackBar("Please fill all details and select a vehicle");
      return;
    }

    setState(() => _rideStatus = BookingStatus.searching);

    try {
      final booking = BookingModel(
        bookingId: DateTime.now().millisecondsSinceEpoch.toString(),
        customerId: appState.currentUser!.uid,
        pickupLocation: _pickupController.text.trim(),
        dropLocation: _dropController.text.trim(),
        vehicleType: _selectedVehicle!.name,
        price: double.tryParse(_bidController.text.trim()) ?? 0.0,
        status: BookingStatus.searching,
        createdAt: DateTime.now(),
        items: _items,
      );

      _activeBooking = booking;
      await _bookingService.createBooking(booking);

      Future.delayed(const Duration(seconds: 4), () {
        if (mounted && _rideStatus == BookingStatus.searching) {
          setState(() {
            _rideStatus = BookingStatus.accepted;
            _startTrackingSimulation();
          });
        }
      });

    } catch (e) {
      if (mounted) {
        _showSnackBar("Error: ${e.toString()}");
        setState(() => _rideStatus = BookingStatus.pending);
      }
    }
  }

  void _startTrackingSimulation() {
    _trackingTimer?.cancel();
    double lat = 24.8707;
    double lng = 67.0111;
    
    _trackingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted || _rideStatus != BookingStatus.accepted) {
        timer.cancel();
        return;
      }
      setState(() {
        lat -= 0.0005;
        lng -= 0.0005;
        _markers.clear();
        _markers.add(Marker(
          markerId: const MarkerId('driver'),
          position: LatLng(lat, lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: "Driver Location"),
        ));
        _mapController?.animateCamera(CameraUpdate.newLatLng(LatLng(lat, lng)));
      });
    });
  }

  void _showRideSummary() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Center(child: Text("Ride Completed!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Fare", style: TextStyle(color: Colors.white70)),
                Text("Rs. ${_activeBooking?.price ?? 0.0}", style: const TextStyle(color: AppConstants.primaryColor, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(color: Colors.white12, height: 32),
            const Text("Rate your driver", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => const Icon(Icons.star, color: Colors.amber, size: 32)),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                setState(() => _rideStatus = BookingStatus.pending);
                context.pop(); // Go back to dashboard
              },
              child: const Text("Done"),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: _kInitialPosition, zoom: 14),
              onMapCreated: (c) => _mapController = c,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              myLocationEnabled: true,
              style: _mapDarkStyle,
              polylines: _polylines,
              markers: _markers,
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (_rideStatus == BookingStatus.pending) {
                            context.pop();
                          } else {
                            setState(() => _rideStatus = BookingStatus.pending);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppConstants.backgroundColor,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_rideStatus == BookingStatus.pending)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppConstants.backgroundColor.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                      ),
                      child: Column(
                        children: [
                          _buildFloatingInput(
                            controller: _pickupController,
                            hint: "Origin address",
                            icon: Icons.my_location,
                            iconColor: AppConstants.primaryColor,
                            onChanged: (_) => _updateRoute(),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Divider(color: Colors.white.withOpacity(0.05), height: 1),
                          ),
                          _buildFloatingInput(
                            controller: _dropController,
                            hint: "Destination address",
                            icon: Icons.location_on,
                            iconColor: Colors.redAccent,
                            onChanged: (_) => _updateRoute(),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomUI(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomUI() {
    if (_rideStatus == BookingStatus.searching) {
      return Container(
        padding: const EdgeInsets.all(32),
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppConstants.surfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppConstants.primaryColor),
            const SizedBox(height: 24),
            const Text("Searching for Driver...", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text("Finding the best available driver near you", style: TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => setState(() => _rideStatus = BookingStatus.pending),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent), 
                  foregroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Cancel Search"),
              ),
            ),
          ],
        ),
      );
    }

    if (_rideStatus == BookingStatus.accepted) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DriverInfoPanel(
            name: "Ahmed Khan",
            vehicleInfo: "Mini Truck",
            vehicleNumber: "KHI-4567",
            rating: 4.8,
            photoUrl: "https://i.pravatar.cc/150?u=driver",
            onCall: () async {
              final Uri url = Uri(scheme: 'tel', path: '03123456789');
              if (await canLaunchUrl(url)) await launchUrl(url);
            },
            onChat: () => context.push('/chat-rooms', extra: {'bookingId': _activeBooking?.bookingId, 'receiverName': 'Ahmed Khan'}),
            onCancel: () => setState(() => _rideStatus = BookingStatus.pending),
          ),
          Container(
            color: AppConstants.surfaceColor,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _showRideSummary,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Finish Ride (Simulate)"),
            ),
          ),
        ],
      );
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 40, offset: const Offset(0, -10))],
      ),
      child: Column(
        children: [
          Container(height: 4, width: 40, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("LUGGAGE ITEMS", style: TextStyle(color: AppConstants.textSecondary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      TextButton.icon(
                        onPressed: _addItem,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text("Add Item", style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_items.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppConstants.surfaceColor, 
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: const Center(child: Text("No items added yet", style: TextStyle(color: Colors.white24, fontSize: 13))),
                    )
                  else
                    ..._items.map((item) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppConstants.surfaceColor, 
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Row(
                        children: [
                          if (item.imageUrl != null)
                            ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(item.imageUrl!), width: 40, height: 40, fit: BoxFit.cover))
                          else
                            Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.inventory_2, color: Colors.white24, size: 20)),
                          const SizedBox(width: 12),
                          Expanded(child: Text(item.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500))),
                          Text("x${item.quantity}", style: const TextStyle(color: AppConstants.primaryColor, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )),
                  const SizedBox(height: 24),
                  const Text("SELECT VEHICLE", style: TextStyle(color: AppConstants.textSecondary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 12),
                  VehicleSelectorWidget(onSelected: (v) => setState(() => _selectedVehicle = v)),
                  const SizedBox(height: 24),
                  const Text("YOUR OFFER", style: TextStyle(color: AppConstants.textSecondary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppConstants.surfaceColor, 
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Row(
                      children: [
                        const Text("Rs. ", style: TextStyle(color: AppConstants.primaryColor, fontSize: 18, fontWeight: FontWeight.bold)),
                        Expanded(
                          child: TextField(
                            controller: _bidController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(border: InputBorder.none, hintText: "0.00", hintStyle: TextStyle(color: Colors.white10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _createBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text("Confirm Ride", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingInput({required TextEditingController controller, required String hint, required IconData icon, required Color iconColor, void Function(String)? onChanged}) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              hintText: hint, 
              hintStyle: const TextStyle(color: AppConstants.textSecondary, fontSize: 14), 
              border: InputBorder.none, 
              contentPadding: const EdgeInsets.symmetric(vertical: 12)
            ),
          ),
        ),
      ],
    );
  }

  final String _mapDarkStyle = '''
  [
    {"elementType": "geometry", "stylers": [{"color": "#212121"}]},
    {"elementType": "labels.icon", "stylers": [{"visibility": "off"}]},
    {"elementType": "labels.text.fill", "stylers": [{"color": "#757575"}]},
    {"elementType": "labels.text.stroke", "stylers": [{"color": "#212121"}]},
    {"featureType": "administrative", "elementType": "geometry", "stylers": [{"color": "#757575"}]},
    {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#000000"}]}
  ]
  ''';
}
