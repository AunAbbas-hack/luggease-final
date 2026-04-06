import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

class DriverInfoPanel extends StatelessWidget {
  final String name;
  final String vehicleInfo;
  final String vehicleNumber;
  final double rating;
  final String photoUrl;
  final VoidCallback onCall;
  final VoidCallback onChat;
  final VoidCallback onCancel;

  const DriverInfoPanel({
    super.key,
    required this.name,
    required this.vehicleInfo,
    required this.vehicleNumber,
    required this.rating,
    required this.photoUrl,
    required this.onCall,
    required this.onChat,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: Colors.black45, blurRadius: 20, offset: Offset(0, -5)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppConstants.primaryColor.withValues(alpha: 0.3),
                backgroundImage: photoUrl.isNotEmpty && photoUrl.startsWith('http')
                    ? NetworkImage(photoUrl)
                    : null,
                child: photoUrl.isEmpty || !photoUrl.startsWith('http')
                    ? const Icon(Icons.person, color: Colors.white, size: 32)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (rating > 0) ...[
                          const Icon(Icons.star, color: Colors.orange, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            rating.toString(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      "$vehicleInfo • $vehicleNumber",
                      style: const TextStyle(color: AppConstants.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildCompactButton(Icons.call, "Call", Colors.green, onCall),
              const SizedBox(width: 12),
              _buildCompactButton(Icons.chat_bubble, "Chat", AppConstants.primaryColor, onChat),
              const SizedBox(width: 12),
              _buildCompactButton(Icons.close, "Cancel", Colors.redAccent, onCancel),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildCompactButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.1),
          foregroundColor: color,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: color.withValues(alpha: 0.3)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
