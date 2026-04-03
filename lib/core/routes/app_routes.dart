import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/role_selection/role_selection_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/check_email_screen.dart';
import '../../features/customer/dashboard/customer_dashboard_screen.dart';
import '../../features/driver/dashboard/driver_dashboard_screen.dart';
import '../../features/customer/booking/book_ride_screen.dart';
import '../../features/customer/items/items_management_screen.dart';
import '../../features/tracking/live_tracking_screen.dart';
import '../../features/chat/chat_screen.dart';
import '../../features/payment/payment_screen.dart';
import '../../features/customer/history/ride_history_screen.dart';
import '../../features/customer/profile/customer_profile_screen.dart';
import '../../features/customer/notifications/notifications_screen.dart';
import '../../features/customer/reviews/reviews_screen.dart';
import '../../features/driver/requests/ride_requests_screen.dart';
import '../../features/driver/earnings/earnings_screen.dart';
import '../../features/driver/profile/driver_profile_screen.dart';
import '../../features/driver/delivery/delivery_camera_screen.dart';
import '../../features/customer/profile/edit_profile_screen.dart';
import '../../features/customer/profile/settings_screen.dart';
import '../../features/admin/dashboard/admin_dashboard_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String roleSelection = '/role-selection';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String checkEmail = '/check-email';
  static const String customerDashboard = '/customer-dashboard';
  static const String driverDashboard = '/driver-dashboard';
  static const String adminDashboard = '/admin-dashboard';
  static const String bookRide = '/book-ride';
  static const String itemsManagement = '/items-management';
  static const String tracking = '/tracking';
  static const String chat = '/chat-rooms';
  static const String payment = '/payment';
  static const String history = '/ride-history';
  static const String feedback = '/reviews';
  static const String customerProfile = '/profile';
  static const String notifications = '/notifications';
  static const String rideRequests = '/ride-requests';
  static const String earnings = '/earnings';
  static const String driverProfile = '/driver-profile';
  static const String deliveryCamera = '/delivery-camera';
  static const String editProfile = '/edit-profile';
  static const String settings = '/settings';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(path: splash, builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: roleSelection,
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: login,
        builder: (context, state) =>
            LoginScreen(role: state.extra as String? ?? 'customer'),
      ),
      GoRoute(
        path: signup,
        builder: (context, state) =>
            SignupScreen(role: state.extra as String? ?? 'customer'),
      ),
      GoRoute(
        path: forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: checkEmail,
        builder: (context, state) => const CheckEmailScreen(),
      ),
      GoRoute(
        path: customerDashboard,
        builder: (context, state) => const CustomerDashboardScreen(),
      ),
      GoRoute(
        path: driverDashboard,
        builder: (context, state) => const DriverDashboardScreen(),
      ),
      GoRoute(
        path: adminDashboard,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: bookRide,
        builder: (context, state) => const BookRideScreen(),
      ),
      GoRoute(
        path: itemsManagement,
        builder: (context, state) => const ItemsManagementScreen(),
      ),
      GoRoute(
        path: tracking,
        builder: (context, state) =>
            LiveTrackingScreen(bookingId: state.extra as String?),
      ),
      GoRoute(
        path: chat,
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>?;
          return ChatScreen(
            bookingId: extras?['bookingId'] ?? '',
            receiverName: extras?['receiverName'] ?? 'Driver',
          );
        },
      ),
      GoRoute(
        path: payment,
        builder: (context, state) => const PaymentScreen(),
      ),
      GoRoute(
        path: history,
        builder: (context, state) => const RideHistoryScreen(),
      ),
      GoRoute(
        path: feedback,
        builder: (context, state) => const ReviewsScreen(),
      ),
      GoRoute(
        path: customerProfile,
        builder: (context, state) => const CustomerProfileScreen(),
      ),
      GoRoute(
        path: rideRequests,
        builder: (context, state) => const RideRequestsScreen(),
      ),
      GoRoute(
        path: earnings,
        builder: (context, state) => const EarningsScreen(),
      ),
      GoRoute(
        path: driverProfile,
        builder: (context, state) => const DriverProfileScreen(),
      ),
      GoRoute(
        path: deliveryCamera,
        builder: (context, state) =>
            DeliveryCameraScreen(bookingId: state.extra as String? ?? ''),
      ),
      GoRoute(
        path: notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
