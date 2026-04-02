import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../providers/app_state.dart';

class LuggageCard extends StatelessWidget {
  final LuggageItem item;

  const LuggageCard({super.key, required this.item});

  Color _getStatusColor(LuggageStatus status) {
    switch (status) {
      case LuggageStatus.inTransit:
        return Colors.orange;
      case LuggageStatus.checkedIn:
        return Colors.blue;
      case LuggageStatus.arrived:
        return Colors.green;
      case LuggageStatus.lost:
        return Colors.red;
    }
  }

  String _getStatusText(LuggageStatus status) {
    switch (status) {
      case LuggageStatus.inTransit:
        return 'In Transit';
      case LuggageStatus.checkedIn:
        return 'Checked In';
      case LuggageStatus.arrived:
        return 'Arrived';
      case LuggageStatus.lost:
        return 'Delayed / Lost';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/luggage-detail', extra: item),
        borderRadius: BorderRadius.circular(24),
        child: Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.nickname,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          'Flight ${item.flightNumber}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          item.status,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getStatusText(item.status),
                        style: TextStyle(
                          color: _getStatusColor(item.status),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoColumn('Destination', item.destination),
                    _buildInfoColumn('Weight', item.weight),
                    _buildInfoColumn(
                      'Last Seen',
                      DateFormat('HH:mm').format(item.lastUpdated),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }
}
