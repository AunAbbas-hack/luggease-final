import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../providers/app_state.dart';

class DashboardDrawer extends StatelessWidget {
  const DashboardDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;

    return Drawer(
      backgroundColor: AppConstants.backgroundColor,
      child: Column(
        children: [
          // Header
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppConstants.surfaceColor,
              border: Border(bottom: BorderSide(color: Colors.white12)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppConstants.primaryColor,
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: user?.profileImage != null
                        ? NetworkImage(user!.profileImage!)
                        : const NetworkImage(
                            'https://i.pravatar.cc/150?u=customer',
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Guest User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? 'Join LuggEase today',
                        style: const TextStyle(
                          color: AppConstants.textSecondary,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  context,
                  Icons.person_outline,
                  "Profile",
                  '/profile',
                ),
                _buildMenuItem(
                  context,
                  Icons.history,
                  "Booking History",
                  '/ride-history',
                ),
                _buildMenuItem(
                  context,
                  Icons.local_shipping_outlined,
                  "Active Bookings",
                  '/ride-history',
                ), // Logic handles tabs or filtering
                _buildMenuItem(
                  context,
                  Icons.notifications_none,
                  "Notifications",
                  '/notifications',
                ),
                _buildMenuItem(
                  context,
                  Icons.star_border,
                  "Reviews",
                  '/reviews',
                ),
                const Divider(color: Colors.white12, height: 32),
                _buildMenuItem(context, Icons.help_outline, "Help", null),
                _buildMenuItem(
                  context,
                  Icons.settings_outlined,
                  "Settings",
                  '/settings',
                ),
              ],
            ),
          ),

          // Logout
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ListTile(
              leading: const Icon(
                Icons.logout,
                color: Color.fromARGB(255, 44, 38, 82),
              ),
              title: const Text(
                "Logout",
                style: TextStyle(
                  color: Color.fromARGB(255, 34, 17, 94),
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () => _handleLogout(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: const Color.fromARGB(
                255,
                19,
                32,
                90,
              ).withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    String? route,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70, size: 22),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      onTap: () {
        Navigator.pop(context);
        if (route != null) {
          context.push(route);
        }
      },
      horizontalTitleGap: 0,
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.logoutFromApp();
    if (context.mounted) {
      context.go('/role-selection');
    }
  }
}
