import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text("Notifications", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppConstants.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildNotificationItem(
            title: "Ride Confirmed!",
            body: "Your request for a Loader has been accepted by Driver Ahmed.",
            time: "2 mins ago",
            icon: Icons.check_circle_outline,
            iconColor: Colors.green,
          ),
          _buildNotificationItem(
            title: "New Message",
            body: "Driver Ahmed: 'I am arriving at the pickup location.'",
            time: "15 mins ago",
            icon: Icons.chat_bubble_outline,
            iconColor: AppConstants.primaryColor,
            isUnread: true,
          ),
          _buildNotificationItem(
            title: "Promotion",
            body: "Get Rs. 500 off on your next inter-city luggage shifting!",
            time: "1 hour ago",
            icon: Icons.local_offer_outlined,
            iconColor: Colors.orange,
          ),
          _buildNotificationItem(
            title: "Ride Cancelled",
            body: "The booking #82736 has been cancelled by you.",
            time: "Yesterday",
            icon: Icons.cancel_outlined,
            iconColor: Colors.redAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required String body,
    required String time,
    required IconData icon,
    required Color iconColor,
    bool isUnread = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUnread ? iconColor.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      time,
                      style: const TextStyle(color: AppConstants.textSecondary, fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(color: AppConstants.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
