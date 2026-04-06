import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../providers/app_state.dart';
import '../../../models/booking_model.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  bool _isOnline = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppState>(context).currentUser;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Stack(
        children: [
          // Simulated Google Map Background
          Positioned.fill(
            child: Container(
              color: Colors.grey[900], 
              child: Image.network(
                "https://images.unsplash.com/photo-1596701062351-8c2c14d1fdd0?q=80&w=2187&auto=format&fit=crop", // Dark city map texture
                fit: BoxFit.cover,
                opacity: const AlwaysStoppedAnimation(0.3),
              ),
            ),
          ),

          // Side-by-side Markers for Requests
          if (_isOnline) ...[
            const Positioned(top: 200, left: 100, child: _RequestMarker(price: "Rs. 450")),
            const Positioned(top: 350, right: 80, child: _RequestMarker(price: "Rs. 1,200")),
          ],

          // Top Bars (Header)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppConstants.secondaryColor.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: const Icon(Icons.menu, color: Colors.white),
                      ),
                      
                      // Online/Offline Toggle
                      GestureDetector(
                        onTap: () => setState(() => _isOnline = !_isOnline),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: _isOnline ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: _isOnline ? Colors.green : Colors.red, width: 2),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _isOnline ? Colors.green : Colors.red,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _isOnline ? "ONLINE" : "OFFLINE",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      GestureDetector(
                        onTap: () => context.push(AppRoutes.driverProfile),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppConstants.primaryColor.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppConstants.primaryColor.withValues(alpha: 0.5)),
                          ),
                          child: const CircleAvatar(
                            radius: 18,
                            backgroundColor: AppConstants.primaryColor,
                            child: Icon(Icons.person, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bottom Stats Panel
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.3,
            maxChildSize: 0.7,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: AppConstants.backgroundColor.withValues(alpha: 0.95),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 40, offset: const Offset(0, -10)),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
                  children: [
                    Center(
                      child: Container(
                        height: 4,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Text(
                              "Welcome, ${user?.name ?? 'Driver'}",
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
                            ),
                            const Text(
                              "Ready to earn today?",
                              style: TextStyle(color: AppConstants.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                        const Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Stats Grid
                    StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('bookings')
                          .where('driverId', isEqualTo: user?.uid)
                          .where('status', isEqualTo: BookingStatus.completed.name)
                          .snapshots(),
                      builder: (context, bookingSnapshot) {
                        double totalEarnings = 0;
                        int totalTrips = 0;
                        if (bookingSnapshot.hasData) {
                          totalTrips = bookingSnapshot.data!.docs.length;
                          for (var doc in bookingSnapshot.data!.docs) {
                            totalEarnings += (doc.data() as Map<String, dynamic>)['price'] ?? 0;
                          }
                        }

                        return StreamBuilder<QuerySnapshot>(
                          stream: _firestore
                              .collection('ratings')
                              .where('driverId', isEqualTo: user?.uid)
                              .snapshots(),
                          builder: (context, ratingSnapshot) {
                            double avgRating = 0;
                            int totalRatings = 0;
                            if (ratingSnapshot.hasData && ratingSnapshot.data!.docs.isNotEmpty) {
                              totalRatings = ratingSnapshot.data!.docs.length;
                              double sum = 0;
                              for (var doc in ratingSnapshot.data!.docs) {
                                sum += (doc.data() as Map<String, dynamic>)['ratingValue'] ?? 0;
                              }
                              avgRating = sum / totalRatings;
                            }

                            return Row(
                              children: [
                                Expanded(
                                  child: _StatCard(
                                    label: "Total Earnings",
                                    value: "Rs. ${totalEarnings.toStringAsFixed(0)}",
                                    icon: Icons.account_balance_wallet_rounded,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _StatCard(
                                    label: "Reviews ($totalTrips Trips)",
                                    value: "${avgRating.toStringAsFixed(1)} ($totalRatings)",
                                    icon: Icons.star_rounded,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 32),
                    const Text(
                      "QUICK ACTIONS",
                      style: TextStyle(color: AppConstants.textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                    const SizedBox(height: 20),
                    
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 16,
                      children: [
                        _QuickAction(icon: Icons.list_alt_rounded, label: "Requests", onTap: () => context.push(AppRoutes.rideRequests)),
                        _QuickAction(icon: Icons.chat_bubble_rounded, label: "Chats", onTap: () => context.push(AppRoutes.rideRequests)),
                        _QuickAction(icon: Icons.history_rounded, label: "History", onTap: () => context.push(AppRoutes.history)),
                        _QuickAction(icon: Icons.person_rounded, label: "Profile", onTap: () => context.push(AppRoutes.driverProfile)),
                        _QuickAction(icon: Icons.settings_rounded, label: "Settings", onTap: () {}),
                        _QuickAction(icon: Icons.help_rounded, label: "Help", onTap: () {}),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Go Online Center Button if offline
          if (!_isOnline)
            Center(
              child: GestureDetector(
                onTap: () => setState(() => _isOnline = true),
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppConstants.primaryColor.withValues(alpha: 0.1),
                    border: Border.all(color: AppConstants.primaryColor.withValues(alpha: 0.3), width: 2),
                  ),
                  child: Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppConstants.primaryColor,
                        boxShadow: [
                           BoxShadow(color: AppConstants.primaryColor.withValues(alpha: 0.5), blurRadius: 30, spreadRadius: 5),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.power_settings_new, color: Colors.white, size: 40),
                          SizedBox(height: 8),
                          Text("GO ONLINE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppConstants.secondaryColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppConstants.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppConstants.primaryColor, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: AppConstants.textSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _RequestMarker extends StatelessWidget {
  final String price;
  const _RequestMarker({required this.price});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10)],
          ),
          child: Text(price, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
        Container(
          width: 2,
          height: 8,
          color: AppConstants.primaryColor,
        ),
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: AppConstants.primaryColor),
        ),
      ],
    );
  }
}
