import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "LUGGEASE",
              style: TextStyle(
                fontSize: 14,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              height: 2,
              width: 12,
              color: AppConstants.primaryColor,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, size: 20),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
        child: Column(
          children: [
            Text(
              "Choose your role",
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppConstants.textSecondary,
                      fontSize: 16,
                    ),
                children: const [
                  TextSpan(text: "Select how you'll use "),
                  TextSpan(
                    text: "LuggEase",
                    style: TextStyle(color: AppConstants.primaryColor, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: " to get started today"),
                ],
              ),
            ),
            const SizedBox(height: 48),
            _RoleCard(
              title: "Customer",
              description: "I want to send or move my luggage securely and easily.",
              icon: Icons.inventory_2_rounded,
              buttonText: "Get started",
              onTap: () => context.push('/login', extra: 'customer'),
            ),
            const SizedBox(height: 24),
            _RoleCard(
              title: "Driver",
              description: "I want to earn extra income by delivering items on my route.",
              icon: Icons.local_shipping_rounded,
              buttonText: "Start earning",
              onTap: () => context.push('/login', extra: 'driver'),
            ),
            const SizedBox(height: 24),
            _RoleCard(
              title: "Company / Admin",
              description: "Manage operations, vehicles, and delivery requests.",
              icon: Icons.admin_panel_settings_rounded,
              buttonText: "Manage system",
              onTap: () => context.push('/login', extra: 'admin'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String buttonText;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.buttonText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppConstants.secondaryColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppConstants.primaryColor.withValues(alpha: 0.3), width: 2),
                    boxShadow: [
                      BoxShadow(color: AppConstants.primaryColor.withValues(alpha: 0.2), blurRadius: 20, spreadRadius: 0),
                    ],
                  ),
                  child: Icon(icon, color: AppConstants.primaryColor, size: 28),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppConstants.textSecondary,
                        fontSize: 15,
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text(
                      buttonText,
                      style: const TextStyle(
                        color: AppConstants.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward,
                      color: AppConstants.primaryColor,
                      size: 18,
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
}
