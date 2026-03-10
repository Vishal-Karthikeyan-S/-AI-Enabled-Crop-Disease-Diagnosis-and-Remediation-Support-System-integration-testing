import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crop_disease_app/services/auth_service.dart';

void main() {
  group('AuthService', () {
    late AuthService authService;

    setUp(() async {
      // Set up mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      authService = AuthService(prefs);
      // Give time for _loadUserSession to complete
      await Future.delayed(const Duration(milliseconds: 100));
    });

    group('Initial State', () {
      test('should not be logged in initially', () {
        expect(authService.isLoggedIn, false);
      });

      test('should have null currentUser initially', () {
        expect(authService.currentUser, isNull);
      });
    });

    group('register', () {
      test('should successfully register a new user', () async {
        final result = await authService.register(
          username: 'farmer_john',
          password: 'securePassword123',
          name: 'John Farmer',
          email: 'john@farm.com',
          phone: '+1234567890',
          location: 'Rural Area',
        );

        expect(result['success'], true);
        expect(result['message'], 'Registration successful');
      });

      test('should fail to register with duplicate username', () async {
        // First registration
        await authService.register(
          username: 'farmer_john',
          password: 'password1',
          name: 'John',
          email: 'john@farm.com',
        );

        // Second registration with same username
        final result = await authService.register(
          username: 'farmer_john',
          password: 'password2',
          name: 'Another John',
          email: 'another@farm.com',
        );

        expect(result['success'], false);
        expect(result['message'], 'Username already exists');
      });

      test('should fail to register with duplicate email', () async {
        // First registration
        await authService.register(
          username: 'user1',
          password: 'password1',
          name: 'User 1',
          email: 'same@email.com',
        );

        // Second registration with same email
        final result = await authService.register(
          username: 'user2',
          password: 'password2',
          name: 'User 2',
          email: 'same@email.com',
        );

        expect(result['success'], false);
        expect(result['message'], 'Email already registered');
      });

      test('should register user without optional fields', () async {
        final result = await authService.register(
          username: 'simple_user',
          password: 'password123',
          name: 'Simple User',
          email: 'simple@test.com',
        );

        expect(result['success'], true);
      });
    });

    group('login', () {
      setUp(() async {
        // Register a user first
        await authService.register(
          username: 'test_user',
          password: 'correct_password',
          name: 'Test User',
          email: 'test@test.com',
        );
      });

      test('should successfully login with correct credentials', () async {
        final result = await authService.login(
          username: 'test_user',
          password: 'correct_password',
        );

        expect(result['success'], true);
        expect(result['message'], 'Login successful');
        expect(authService.isLoggedIn, true);
        expect(authService.currentUser, isNotNull);
        expect(authService.currentUser!.username, 'test_user');
      });

      test('should fail to login with wrong password', () async {
        final result = await authService.login(
          username: 'test_user',
          password: 'wrong_password',
        );

        expect(result['success'], false);
        expect(result['message'], 'Invalid username or password');
        expect(authService.isLoggedIn, false);
      });

      test('should fail to login with non-existent username', () async {
        final result = await authService.login(
          username: 'non_existent_user',
          password: 'some_password',
        );

        expect(result['success'], false);
        expect(result['message'], 'Invalid username or password');
      });

      test('should update lastLogin on successful login', () async {
        final beforeLogin = DateTime.now();

        await authService.login(
          username: 'test_user',
          password: 'correct_password',
        );

        final afterLogin = DateTime.now();
        final lastLogin = authService.currentUser!.lastLogin;

        expect(
            lastLogin.isAfter(beforeLogin) ||
                lastLogin.isAtSameMomentAs(beforeLogin),
            true);
        expect(
            lastLogin.isBefore(afterLogin) ||
                lastLogin.isAtSameMomentAs(afterLogin),
            true);
      });
    });

    group('loginAsGuest', () {
      test('should successfully login as guest', () async {
        final result = await authService.loginAsGuest();

        expect(result['success'], true);
        expect(result['message'], 'Logged in as guest');
        expect(authService.isLoggedIn, true);
        expect(authService.currentUser, isNotNull);
      });

      test('should create guest user with correct username', () async {
        await authService.loginAsGuest();

        expect(authService.currentUser!.username, 'guest');
        expect(authService.currentUser!.name, 'Farmer');
      });

      test('should create guest user with guest email', () async {
        await authService.loginAsGuest();

        expect(authService.currentUser!.email, 'guest@cropdisease.app');
      });

      test('should create unique guest IDs', () async {
        await authService.loginAsGuest();
        final firstGuestId = authService.currentUser!.id;

        // Logout and login again as guest
        await authService.logout();
        await Future.delayed(const Duration(milliseconds: 10));
        await authService.loginAsGuest();
        final secondGuestId = authService.currentUser!.id;

        expect(firstGuestId, isNot(secondGuestId));
      });
    });

    group('logout', () {
      test('should clear session on logout', () async {
        // Login first
        await authService.register(
          username: 'logout_test',
          password: 'password',
          name: 'Logout Test',
          email: 'logout@test.com',
        );
        await authService.login(
          username: 'logout_test',
          password: 'password',
        );

        expect(authService.isLoggedIn, true);
        expect(authService.currentUser, isNotNull);

        // Logout
        await authService.logout();

        expect(authService.isLoggedIn, false);
        expect(authService.currentUser, isNull);
      });

      test('should clear guest session on logout', () async {
        await authService.loginAsGuest();
        expect(authService.isLoggedIn, true);

        await authService.logout();

        expect(authService.isLoggedIn, false);
        expect(authService.currentUser, isNull);
      });
    });

    group('updateProfile', () {
      test('should update user profile', () async {
        // Login first
        await authService.register(
          username: 'profile_user',
          password: 'password',
          name: 'Original Name',
          email: 'profile@test.com',
        );
        await authService.login(
          username: 'profile_user',
          password: 'password',
        );

        final originalUser = authService.currentUser!;
        final updatedUser = originalUser.copyWith(
          name: 'Updated Name',
          phone: '+9876543210',
        );

        await authService.updateProfile(updatedUser);

        expect(authService.currentUser!.name, 'Updated Name');
        expect(authService.currentUser!.phone, '+9876543210');
        expect(authService.currentUser!.email, 'profile@test.com');
      });
    });

    group('Session Persistence', () {
      test('should persist login session', () async {
        // Register and login
        await authService.register(
          username: 'persistent_user',
          password: 'password',
          name: 'Persistent User',
          email: 'persist@test.com',
        );
        await authService.login(
          username: 'persistent_user',
          password: 'password',
        );

        expect(authService.isLoggedIn, true);

        // Create new AuthService instance with same prefs
        final prefs = await SharedPreferences.getInstance();
        final newAuthService = AuthService(prefs);
        await Future.delayed(const Duration(milliseconds: 100));

        expect(newAuthService.isLoggedIn, true);
        expect(newAuthService.currentUser?.username, 'persistent_user');
      });
    });

    group('ChangeNotifier', () {
      test('should notify listeners on login', () async {
        await authService.register(
          username: 'notify_user',
          password: 'password',
          name: 'Notify User',
          email: 'notify@test.com',
        );

        var notified = false;
        authService.addListener(() {
          notified = true;
        });

        await authService.login(
          username: 'notify_user',
          password: 'password',
        );

        expect(notified, true);
      });

      test('should notify listeners on logout', () async {
        await authService.loginAsGuest();

        var notified = false;
        authService.addListener(() {
          notified = true;
        });

        await authService.logout();

        expect(notified, true);
      });
    });
  });
}
