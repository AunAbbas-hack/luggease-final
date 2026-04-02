import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/booking_model.dart';

class ReviewsScreen extends StatefulWidget {
  final BookingModel? booking;
  const ReviewsScreen({super.key, this.booking});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  int _rating = 0;
  final _commentController = TextEditingController();
  final List<String> _tags = ["On time", "Professional", "Safety First", "Careful", "Friendly"];
  final Set<String> _selectedTags = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text("Write Review", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppConstants.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.booking != null) ...[
              Text(
                "How was your trip with ${widget.booking!.vehicleType}?",
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Booking ID: ${widget.booking!.bookingId.substring(0, 8).toUpperCase()}",
                style: const TextStyle(color: AppConstants.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 32),
            ],
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () => setState(() => _rating = index + 1),
                    icon: Icon(
                      index < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: index < _rating ? Colors.amber : Colors.white24,
                      size: 48,
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              "What did you like?",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _tags.map((tag) => _buildTag(tag)).toList(),
            ),
            const SizedBox(height: 32),
            const Text(
              "Additional Comments",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Share your experience...",
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: AppConstants.surfaceColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _rating == 0 ? null : () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                disabledBackgroundColor: Colors.white12,
              ),
              child: const Text("Submit Review", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String tag) {
    final isSelected = _selectedTags.contains(tag);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedTags.remove(tag);
          } else {
            _selectedTags.add(tag);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppConstants.primaryColor : AppConstants.surfaceColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: isSelected ? AppConstants.primaryColor : Colors.white10),
        ),
        child: Text(
          tag,
          style: TextStyle(color: isSelected ? Colors.white : AppConstants.textSecondary, fontSize: 13),
        ),
      ),
    );
  }
}
