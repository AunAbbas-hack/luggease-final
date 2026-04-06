import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../models/booking_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_routes.dart';

class RideRequestsScreen extends StatefulWidget {
  const RideRequestsScreen({super.key});

  @override
  State<RideRequestsScreen> createState() => _RideRequestsScreenState();
}

class _RideRequestsScreenState extends State<RideRequestsScreen> {
  Future<void> _handleAccept(BookingModel booking) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final openStatuses = {BookingStatus.pending, BookingStatus.searching};
      if (!openStatuses.contains(booking.status)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This request is no longer available.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      await FirebaseFirestore.instance
          .collection(AppConstants.bookingsCollection)
          .doc(booking.bookingId)
          .update({
            'status': BookingStatus.accepted.name,
            'driverId': user.uid,
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ride Accepted!"), backgroundColor: Colors.green),
        );
        context.push(AppRoutes.tracking, extra: booking.bookingId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text("Ride Requests", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(AppConstants.bookingsCollection)
            .where('status', whereIn: [
              BookingStatus.pending.name,
              BookingStatus.searching.name,
            ])
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white)));
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final booking = BookingModel.fromMap(docs[index].data() as Map<String, dynamic>);
              return _RequestCard(
                booking: booking,
                onAccept: () => _handleAccept(booking),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.near_me_disabled_rounded, color: Colors.white.withValues(alpha: 0.1), size: 100),
          const SizedBox(height: 20),
          Text(
            "No requests available",
            style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            "New requests will appear here in real-time",
            style: TextStyle(color: Colors.white.withValues(alpha: 0.2), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onAccept;

  const _RequestCard({required this.booking, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppConstants.secondaryColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                                color: AppConstants.primaryColor.withValues(alpha: 0.1),
                                border: Border.all(color: AppConstants.primaryColor.withValues(alpha: 0.2)),
                ),
                child: Text(
                  booking.vehicleType.toUpperCase(),
                  style: const TextStyle(color: AppConstants.primaryColor, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1),
                ),
              ),
              Text(
                "Rs. ${booking.price.toInt()}",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _LocationRow(icon: Icons.my_location, color: AppConstants.primaryColor, label: "PICKUP", address: booking.pickupLocation),
          const SizedBox(height: 20),
          _LocationRow(icon: Icons.location_on, color: Colors.redAccent, label: "DROP-OFF", address: booking.dropLocation),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text("Details", style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text("Accept Ride"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String address;

  const _LocationRow({required this.icon, required this.color, required this.label, required this.address});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppConstants.textSecondary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 4),
              Text(address, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}
