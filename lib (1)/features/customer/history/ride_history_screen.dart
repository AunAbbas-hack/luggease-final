import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/booking_model.dart';
import '../../../core/services/booking_service.dart';
import '../../../providers/app_state.dart';

class RideHistoryScreen extends StatelessWidget {
  const RideHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;
    final bookingService = BookingService();

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text("Ride History", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppConstants.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: StreamBuilder<List<BookingModel>>(
        stream: bookingService.getCustomerBookings(user?.uid ?? ''),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_outlined, size: 64, color: Colors.white12),
                  SizedBox(height: 16),
                  Text("No ride history found", style: TextStyle(color: AppConstants.textSecondary)),
                ],
              ),
            );
          }

          final bookings = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return _buildHistoryItem(context, booking);
            },
          );
        },
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, BookingModel booking) {
    final isCompleted = booking.status == BookingStatus.completed;
    final isCancelled = booking.status == BookingStatus.cancelled;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCompleted 
                    ? Colors.green.withValues(alpha: 0.1) 
                    : (isCancelled ? Colors.red.withValues(alpha: 0.1) : AppConstants.primaryColor.withValues(alpha: 0.1)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.local_shipping, 
                  color: isCompleted ? Colors.green : (isCancelled ? Colors.red : AppConstants.primaryColor), 
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.vehicleType,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMMM dd, yyyy • hh:mm a').format(booking.createdAt),
                      style: const TextStyle(color: AppConstants.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Rs. ${booking.price.toInt()}",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  _buildStatusBadge(booking.status),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 16),
          _buildLocationRow(Icons.my_location, "Pickup", booking.pickupLocation),
          const SizedBox(height: 12),
          _buildLocationRow(Icons.location_on, "Drop-off", booking.dropLocation),
          if (isCompleted) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.push('/reviews', extra: booking),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Write a Review", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, String label, String address) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppConstants.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppConstants.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(address, style: const TextStyle(color: Colors.white, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(BookingStatus status) {
    Color color;
    switch (status) {
      case BookingStatus.completed:
        color = Colors.green;
        break;
      case BookingStatus.cancelled:
        color = Colors.red;
        break;
      case BookingStatus.pending:
        color = Colors.orange;
        break;
      default:
        color = AppConstants.primaryColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }
}
