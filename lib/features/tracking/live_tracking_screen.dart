import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
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

  @override
  Widget build(BuildContext context) {
    if (widget.bookingId == null || widget.bookingId!.isEmpty) {
      return Scaffold(
        backgroundColor: AppConstants.backgroundColor,
        appBar: AppBar(title: const Text("Tracking")),
        body: const Center(child: Text("No active booking to track", style: TextStyle(color: Colors.white))),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection(AppConstants.bookingsCollection)
          .doc(widget.bookingId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppConstants.backgroundColor,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            backgroundColor: AppConstants.backgroundColor,
            body: Center(child: Text("Booking not found", style: TextStyle(color: Colors.white))),
          );
        }

        final booking = BookingModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);

        return Scaffold(
          backgroundColor: AppConstants.backgroundColor,
          body: Stack(
            children: [
              // Google Map
              Positioned.fill(
                bottom: 250,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(target: _kInitialPosition, zoom: 15),
                  onMapCreated: (c) {
                    // _mapController = c;
                  },
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                  style: _mapDarkStyle,
                  markers: {
                    Marker(markerId: const MarkerId('driver'), position: _kInitialPosition, icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure)),
                    Marker(markerId: const MarkerId('pickup'), position: const LatLng(33.686, 73.048)),
                  },
                ),
              ),

              // Back Button
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

              // Tracking Card
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 380,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppConstants.backgroundColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 40, offset: const Offset(0, -10))],
                  ),
                  child: Column(
                    children: [
                      Center(
                        child: Container(height: 4, width: 40, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(2))),
                      ),
                      const SizedBox(height: 24),
                      
                      // Status and Progress
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("ESTIMATED ARRIVAL", style: TextStyle(color: AppConstants.textSecondary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                              const SizedBox(height: 4),
                              Text(booking.status == BookingStatus.accepted ? "8 - 10 Mins" : "In Transit", 
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppConstants.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              booking.status.name.toUpperCase().replaceAll('_', ' '),
                              style: const TextStyle(color: AppConstants.primaryColor, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      _buildProgressBar(booking),
                      const SizedBox(height: 32),
                      
                      const SizedBox(height: 24),

                      // Complete Delivery Button (Only for Driver)
                      if (booking.status == BookingStatus.arrived || booking.status == BookingStatus.onTheWay)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: CustomButton(
                            label: "COMPLETE DELIVERY",
                            onPressed: () => context.push(AppRoutes.deliveryCamera, extra: booking.bookingId),
                          ),
                        ),
                      
                      // Driver Info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 24,
                              backgroundColor: AppConstants.primaryColor,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Saad Ur Rehman", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                  Row(
                                    children: const [
                                      Icon(Icons.star, color: Colors.orange, size: 14),
                                      SizedBox(width: 4),
                                      Text("4.9 • Suzuki Pickup (ABC-1233)", style: TextStyle(color: AppConstants.textSecondary, fontSize: 11)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.push('/chat', extra: booking.bookingId),
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
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.phone_rounded, color: Colors.white, size: 20),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
             _StatusLabel(label: "Pickup", active: progress >= 0.2),
             _StatusLabel(label: "In Transit", active: progress >= 0.5),
             _StatusLabel(label: "Drop-off", active: progress >= 0.8),
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
