import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/app_state.dart';
import '../../../core/services/auth_service.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppConstants.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppConstants.primaryColor),
            onPressed: () => context.push('/edit-profile'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Image & Name
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppConstants.primaryColor, width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: AppConstants.surfaceColor,
                      backgroundImage: user?.profileImage != null 
                        ? (user!.profileImage!.startsWith('http') 
                            ? NetworkImage(user.profileImage!) 
                            : FileImage(File(user.profileImage!)) as ImageProvider)
                        : const NetworkImage('https://i.pravatar.cc/150?u=customer'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    user?.name ?? "Customer Name",
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? "email@example.com",
                    style: const TextStyle(color: AppConstants.textSecondary, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Profile Sections
            _buildInfoSection(
              "Account Information",
              [
                _buildInfoTile(Icons.phone_outlined, "Phone", user?.phone ?? "Not provided"),
                _buildInfoTile(Icons.email_outlined, "Email", user?.email ?? "Not provided"),
                _buildInfoTile(Icons.location_on_outlined, "Address", user?.address ?? "Not provided"),
              ],
            ),
            const SizedBox(height: 24),
            _buildInfoSection(
              "Preferences & Settings",
              [
                _buildToggleTile(
                  Icons.notifications_none, 
                  "Push Notifications", 
                  appState.notificationsEnabled,
                  onChanged: (v) => appState.toggleNotifications(v),
                ),
                _buildToggleTile(
                  Icons.dark_mode_outlined, 
                  "Dark Mode", 
                  appState.isDarkMode,
                  onChanged: (v) => appState.toggleDarkMode(v),
                ),
                _buildSettingsTile(
                  Icons.settings_outlined, 
                  "App Settings", 
                  () => context.push('/settings'),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Logout Button
            ElevatedButton(
              onPressed: () => _showLogoutDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                foregroundColor: Colors.redAccent,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Colors.redAccent, width: 1),
                ),
                elevation: 0,
              ),
              child: const Text("Log Out", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            const Text(
              "Version 1.0.0",
              style: TextStyle(color: Colors.white24, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: AppConstants.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppConstants.surfaceColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: AppConstants.primaryColor, size: 22),
      title: Text(label, style: const TextStyle(color: AppConstants.textSecondary, fontSize: 12)),
      subtitle: Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
    );
  }

  Widget _buildToggleTile(IconData icon, String label, bool value, {required ValueChanged<bool> onChanged}) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      secondary: Icon(icon, color: AppConstants.primaryColor, size: 22),
      title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
      activeColor: AppConstants.primaryColor,
      activeTrackColor: AppConstants.primaryColor.withValues(alpha: 0.3),
      inactiveThumbColor: Colors.white24,
      inactiveTrackColor: Colors.white10,
    );
  }

  Widget _buildSettingsTile(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppConstants.primaryColor, size: 22),
      title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Log Out", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to log out?", style: TextStyle(color: AppConstants.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text("Cancel", style: TextStyle(color: AppConstants.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              final authService = Provider.of<AuthService>(context, listen: false);
              await authService.logout();
              if (context.mounted) {
                context.go('/role-selection');
              }
            },
            child: const Text("Log Out", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
