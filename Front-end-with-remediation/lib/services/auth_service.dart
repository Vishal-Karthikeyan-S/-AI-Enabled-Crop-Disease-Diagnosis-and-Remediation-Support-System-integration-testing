import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';
import 'package:uuid/uuid.dart';

class AuthService extends ChangeNotifier {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyCurrentUser = 'current_user';
  static const String _keyUsers = 'registered_users';

  final SharedPreferences _prefs;
  UserModel? _currentUser;
  bool _isLoggedIn = false;

  AuthService(this._prefs) {
    _loadUserSession();
  }

  bool get isLoggedIn => _isLoggedIn;
  UserModel? get currentUser => _currentUser;

  // Load user session from storage
  Future<void> _loadUserSession() async {
    _isLoggedIn = _prefs.getBool(_keyIsLoggedIn) ?? false;

    if (_isLoggedIn) {
      final userJson = _prefs.getString(_keyCurrentUser);
      if (userJson != null) {
        _currentUser = UserModel.fromJson(jsonDecode(userJson));
      } else {
        _isLoggedIn = false;
      }
    }
    notifyListeners();
  }

  // Register new user
  Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    required String name,
    required String email,
    String? phone,
    String? location,
  }) async {
    try {
      // Get existing users
      final usersJson = _prefs.getString(_keyUsers) ?? '[]';
      final List<dynamic> users = jsonDecode(usersJson);

      // Check if username already exists
      final existingUser = users.firstWhere(
        (u) => u['username'] == username,
        orElse: () => null,
      );

      if (existingUser != null) {
        return {
          'success': false,
          'message': 'Username already exists',
        };
      }

      // Check if email already exists
      final existingEmail = users.firstWhere(
        (u) => u['email'] == email,
        orElse: () => null,
      );

      if (existingEmail != null) {
        return {
          'success': false,
          'message': 'Email already registered',
        };
      }

      // Create new user
      final now = DateTime.now();
      final newUser = UserModel(
        id: const Uuid().v4(),
        username: username,
        name: name,
        email: email,
        phone: phone,
        location: location,
        createdAt: now,
        lastLogin: now,
      );

      // Store user with password (in production, hash the password!)
      final userWithPassword = {
        ...newUser.toJson(),
        'password': password, // WARNING: Store hashed in production
      };

      users.add(userWithPassword);
      await _prefs.setString(_keyUsers, jsonEncode(users));

      return {
        'success': true,
        'message': 'Registration successful',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Registration failed: $e',
      };
    }
  }

  // Login user
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final usersJson = _prefs.getString(_keyUsers) ?? '[]';
      final List<dynamic> users = jsonDecode(usersJson);

      // Find user
      final userJson = users.firstWhere(
        (u) => u['username'] == username && u['password'] == password,
        orElse: () => null,
      );

      if (userJson == null) {
        return {
          'success': false,
          'message': 'Invalid username or password',
        };
      }

      // Update last login
      userJson['lastLogin'] = DateTime.now().toIso8601String();

      // Save updated users list
      await _prefs.setString(_keyUsers, jsonEncode(users));

      // Create user model (without password)
      final Map<String, dynamic> userDataWithoutPassword =
          Map<String, dynamic>.from(userJson)..remove('password');

      _currentUser = UserModel.fromJson(userDataWithoutPassword);
      _isLoggedIn = true;

      // Save session
      await _prefs.setBool(_keyIsLoggedIn, true);
      await _prefs.setString(
          _keyCurrentUser, jsonEncode(_currentUser!.toJson()));

      notifyListeners();

      return {
        'success': true,
        'message': 'Login successful',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Login failed: $e',
      };
    }
  }

  // Login as guest (no registration required)
  Future<Map<String, dynamic>> loginAsGuest() async {
    try {
      final now = DateTime.now();
      final guestUser = UserModel(
        id: 'guest_${now.millisecondsSinceEpoch}',
        username: 'guest',
        name: 'Farmer',
        email: 'guest@cropdisease.app',
        phone: null,
        location: 'Local Farm',
        createdAt: now,
        lastLogin: now,
      );

      _currentUser = guestUser;
      _isLoggedIn = true;

      // Save session
      await _prefs.setBool(_keyIsLoggedIn, true);
      await _prefs.setString(
          _keyCurrentUser, jsonEncode(_currentUser!.toJson()));

      notifyListeners();

      return {
        'success': true,
        'message': 'Logged in as guest',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Guest login failed: $e',
      };
    }
  }

  // Logout user
  Future<void> logout() async {
    _currentUser = null;
    _isLoggedIn = false;
    await _prefs.setBool(_keyIsLoggedIn, false);
    await _prefs.remove(_keyCurrentUser);
    notifyListeners();
  }

  // Update user profile
  Future<void> updateProfile(UserModel updatedUser) async {
    _currentUser = updatedUser;
    await _prefs.setString(_keyCurrentUser, jsonEncode(updatedUser.toJson()));

    // Also update in users list
    final usersJson = _prefs.getString(_keyUsers) ?? '[]';
    final List<dynamic> users = jsonDecode(usersJson);

    final index = users.indexWhere((u) => u['id'] == updatedUser.id);
    if (index != -1) {
      final password = users[index]['password'];
      users[index] = {...updatedUser.toJson(), 'password': password};
      await _prefs.setString(_keyUsers, jsonEncode(users));
    }

    notifyListeners();
  }
}
