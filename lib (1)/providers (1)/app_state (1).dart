import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

enum LuggageStatus { inTransit, checkedIn, arrived, lost }

class LuggageItem {
  final String id;
  final String nickname;
  final String flightNumber;
  final String destination;
  final LuggageStatus status;
  final String weight;
  final DateTime lastUpdated;

  LuggageItem({
    required this.id,
    required this.nickname,
    required this.flightNumber,
    required this.destination,
    required this.status,
    required this.weight,
    required this.lastUpdated,
  });

  LuggageItem copyWith({
    String? nickname,
    String? flightNumber,
    String? destination,
    LuggageStatus? status,
    String? weight,
    DateTime? lastUpdated,
  }) {
    return LuggageItem(
      id: id,
      nickname: nickname ?? this.nickname,
      flightNumber: flightNumber ?? this.flightNumber,
      destination: destination ?? this.destination,
      status: status ?? this.status,
      weight: weight ?? this.weight,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class AppState extends ChangeNotifier {
  UserModel? _currentUser;
  UserRole? _userRole;
  bool _isDarkMode = true; // Default to dark mode
  bool _notificationsEnabled = true;
  SharedPreferences? _prefs;

  AppState() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs?.getBool('isDarkMode') ?? true;
    _notificationsEnabled = _prefs?.getBool('notificationsEnabled') ?? true;
    notifyListeners();
  }

  UserModel? get currentUser => _currentUser;
  UserRole? get userRole => _userRole;
  bool get isDarkMode => _isDarkMode;
  bool get notificationsEnabled => _notificationsEnabled;

  bool get isAuthenticated => _currentUser != null;

  void setUser(UserModel? user) {
    _currentUser = user;
    if (user != null) {
      _userRole = user.role;
    }
    notifyListeners();
  }

  void setRole(UserRole role) {
    _userRole = role;
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool value) async {
    _isDarkMode = value;
    await _prefs?.setBool('isDarkMode', value);
    notifyListeners();
  }

  Future<void> toggleNotifications(bool value) async {
    _notificationsEnabled = value;
    await _prefs?.setBool('notificationsEnabled', value);
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _userRole = null;
    notifyListeners();
  }

  // Luggage items omitted for brevity in this replace call if possible, 
  // but I should probably keep them or add them back if needed.
  // Actually, I should keep the whole file structure.
  
  final List<LuggageItem> _items = [
    LuggageItem(
      id: '1',
      nickname: 'Main Suitcase',
      flightNumber: 'EK202',
      destination: 'London (LHR)',
      status: LuggageStatus.inTransit,
      weight: '22.5 kg',
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    LuggageItem(
      id: '2',
      nickname: 'Cabin Bag',
      flightNumber: 'EK202',
      destination: 'London (LHR)',
      status: LuggageStatus.arrived,
      weight: '7.8 kg',
      lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  List<LuggageItem> get items => List.unmodifiable(_items);

  void addItem(LuggageItem item) {
    _items.add(item);
    notifyListeners();
  }

  void updateStatus(String id, LuggageStatus status) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index] = _items[index].copyWith(
        status: status,
        lastUpdated: DateTime.now(),
      );
      notifyListeners();
    }
  }
}
