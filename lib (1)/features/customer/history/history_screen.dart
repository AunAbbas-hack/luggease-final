import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking History')),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: 5, // Simulated history
        itemBuilder: (context, index) => _buildHistoryCard(context, index),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, int index) {
    final bool isCompleted = index % 2 == 0;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isCompleted ? 'Completed' : 'Cancelled',
                  style: TextStyle(
                    color: isCompleted ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat(
                    'MMM dd, yyyy',
                  ).format(DateTime.now().subtract(Duration(days: index))),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildLocationRow(Icons.my_location, 'Lahore (Pickup)'),
            const SizedBox(height: 12),
            _buildLocationRow(Icons.location_on, 'Islamabad (Drop)'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'PKR 4,500',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if (isCompleted)
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.star, size: 16),
                    label: const Text('Rated 5.0'),
                  )
                else
                  const Text(
                    'Refunded',
                    style: TextStyle(color: Colors.blue, fontSize: 13),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, String city) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 12),
        Text(city, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
