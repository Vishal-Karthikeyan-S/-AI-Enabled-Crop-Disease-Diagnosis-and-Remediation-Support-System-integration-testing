import 'package:flutter_test/flutter_test.dart';
import 'package:crop_disease_app/models/user_model.dart';

void main() {
  group('UserModel', () {
    late UserModel testUser;
    late DateTime testCreatedAt;
    late DateTime testLastLogin;

    setUp(() {
      testCreatedAt = DateTime(2024, 1, 15, 10, 30);
      testLastLogin = DateTime(2024, 2, 1, 14, 45);
      testUser = UserModel(
        id: 'user123',
        username: 'farmer_john',
        name: 'John Farmer',
        email: 'john@farm.com',
        phone: '+1234567890',
        location: 'Rural Area',
        createdAt: testCreatedAt,
        lastLogin: testLastLogin,
      );
    });

    group('Constructor', () {
      test('should create UserModel with all required fields', () {
        expect(testUser.id, 'user123');
        expect(testUser.username, 'farmer_john');
        expect(testUser.name, 'John Farmer');
        expect(testUser.email, 'john@farm.com');
        expect(testUser.phone, '+1234567890');
        expect(testUser.location, 'Rural Area');
        expect(testUser.createdAt, testCreatedAt);
        expect(testUser.lastLogin, testLastLogin);
      });

      test('should create UserModel with null optional fields', () {
        final userWithNulls = UserModel(
          id: 'user456',
          username: 'test_user',
          name: 'Test User',
          email: 'test@test.com',
          createdAt: testCreatedAt,
          lastLogin: testLastLogin,
        );

        expect(userWithNulls.phone, isNull);
        expect(userWithNulls.location, isNull);
      });
    });

    group('toJson', () {
      test('should serialize all fields correctly', () {
        final json = testUser.toJson();

        expect(json['id'], 'user123');
        expect(json['username'], 'farmer_john');
        expect(json['name'], 'John Farmer');
        expect(json['email'], 'john@farm.com');
        expect(json['phone'], '+1234567890');
        expect(json['location'], 'Rural Area');
        expect(json['createdAt'], testCreatedAt.toIso8601String());
        expect(json['lastLogin'], testLastLogin.toIso8601String());
      });

      test('should serialize null optional fields', () {
        final userWithNulls = UserModel(
          id: 'user456',
          username: 'test_user',
          name: 'Test User',
          email: 'test@test.com',
          createdAt: testCreatedAt,
          lastLogin: testLastLogin,
        );

        final json = userWithNulls.toJson();

        expect(json['phone'], isNull);
        expect(json['location'], isNull);
      });
    });

    group('fromJson', () {
      test('should deserialize all fields correctly', () {
        final json = {
          'id': 'user123',
          'username': 'farmer_john',
          'name': 'John Farmer',
          'email': 'john@farm.com',
          'phone': '+1234567890',
          'location': 'Rural Area',
          'createdAt': '2024-01-15T10:30:00.000',
          'lastLogin': '2024-02-01T14:45:00.000',
        };

        final user = UserModel.fromJson(json);

        expect(user.id, 'user123');
        expect(user.username, 'farmer_john');
        expect(user.name, 'John Farmer');
        expect(user.email, 'john@farm.com');
        expect(user.phone, '+1234567890');
        expect(user.location, 'Rural Area');
      });

      test('should handle null optional fields', () {
        final json = {
          'id': 'user456',
          'username': 'test_user',
          'name': 'Test User',
          'email': 'test@test.com',
          'phone': null,
          'location': null,
          'createdAt': '2024-01-15T10:30:00.000',
          'lastLogin': '2024-02-01T14:45:00.000',
        };

        final user = UserModel.fromJson(json);

        expect(user.phone, isNull);
        expect(user.location, isNull);
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        final updatedUser = testUser.copyWith(
          name: 'John Smith',
          email: 'john.smith@farm.com',
        );

        expect(updatedUser.id, testUser.id);
        expect(updatedUser.username, testUser.username);
        expect(updatedUser.name, 'John Smith');
        expect(updatedUser.email, 'john.smith@farm.com');
        expect(updatedUser.phone, testUser.phone);
        expect(updatedUser.location, testUser.location);
      });

      test('should preserve original fields when not specified', () {
        final copy = testUser.copyWith();

        expect(copy.id, testUser.id);
        expect(copy.username, testUser.username);
        expect(copy.name, testUser.name);
        expect(copy.email, testUser.email);
        expect(copy.phone, testUser.phone);
        expect(copy.location, testUser.location);
        expect(copy.createdAt, testUser.createdAt);
        expect(copy.lastLogin, testUser.lastLogin);
      });
    });

    group('Round-trip serialization', () {
      test('should maintain data integrity through toJson/fromJson cycle', () {
        final json = testUser.toJson();
        final reconstructed = UserModel.fromJson(json);

        expect(reconstructed.id, testUser.id);
        expect(reconstructed.username, testUser.username);
        expect(reconstructed.name, testUser.name);
        expect(reconstructed.email, testUser.email);
        expect(reconstructed.phone, testUser.phone);
        expect(reconstructed.location, testUser.location);
      });
    });
  });
}
