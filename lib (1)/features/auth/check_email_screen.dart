import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';

class CheckEmailScreen extends StatelessWidget {
  const CheckEmailScreen({super.key});

  Future<void> _openEmailApp(BuildContext context) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
    );
    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Could not open email app")),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.mail_outline_rounded,
                size: 60,
                color: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              "Check Your Email",
              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
            ),
            const SizedBox(height: 12),
            Text(
              "We've sent a password recovery link to your email address. Please follow the instructions to reset your password.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppConstants.textSecondary,
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: () => _openEmailApp(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.open_in_new_rounded, size: 20),
                  SizedBox(width: 12),
                  Text("Open Email App"),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Didn't receive the email?", style: TextStyle(color: AppConstants.textSecondary)),
                TextButton(
                  onPressed: () {},
                  child: const Text("Resend Email", style: TextStyle(color: AppConstants.primaryColor, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.luggage, color: AppConstants.primaryColor.withValues(alpha: 0.3), size: 20),
                const SizedBox(width: 8),
                Text(
                  "LUGGEASE PREMIUM",
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 2,
                    color: AppConstants.textSecondary.withValues(alpha: 0.8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => context.go('/login'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                backgroundColor: Colors.white.withValues(alpha: 0.1),
              ),
              child: const Text("Back to Login", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
