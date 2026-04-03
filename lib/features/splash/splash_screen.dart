import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../models/user_model.dart';
import '../../providers/app_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
    _simulateLoading();
    _checkAuthAndNavigate();
  }

  void _simulateLoading() async {
    for (int i = 0; i <= 65; i++) {
      await Future.delayed(const Duration(milliseconds: 30));
      if (mounted) {
        setState(() {
          _progress = i / 100;
        });
      }
    }
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(AppConstants.splashDelay);
    if (!mounted) return;

    final appState = Provider.of<AppState>(context, listen: false);
    await appState.waitForPrefsReady();
    if (!mounted) return;

    final authService = AuthService();
    final userModel = await authService.loadCurrentUserProfile();

    if (!mounted) return;

    if (userModel != null) {
      appState.setUser(userModel);
      switch (userModel.role) {
        case UserRole.driver:
          context.go(AppRoutes.driverDashboard);
          break;
        case UserRole.admin:
          context.go(AppRoutes.adminDashboard);
          break;
        case UserRole.customer:
          context.go(AppRoutes.customerDashboard);
          break;
      }
      return;
    }

    await appState.logoutFromApp();
    if (!mounted) return;
    context.go(AppRoutes.roleSelection);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Stack(
        children: [
          // Background subtle design (dots or waves could be added here)
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Premium Logo Icon with Glow
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: AppConstants.primaryColor.withValues(alpha: 0.2),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.local_shipping_rounded,
                        size: 80,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // App Name
                    Text(
                      "LuggEase",
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            letterSpacing: 2,
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(height: 8),
                    // Tagline
                    Text(
                      "SHIFT SMART. MOVE EASY.",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            letterSpacing: 4,
                            fontWeight: FontWeight.w300,
                            color: AppConstants.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Loading Indicator at Bottom
          Positioned(
            bottom: 100,
            left: 40,
            right: 40,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "INITIALIZING",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              letterSpacing: 2,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.textSecondary,
                            ),
                      ),
                      Text(
                        "${(_progress * 100).toInt()}%",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppConstants.primaryColor,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _progress,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    "V2.4.0 • PREMIUM LOGISTICS",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          letterSpacing: 1,
                          color: AppConstants.textSecondary.withValues(alpha: 0.5),
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
