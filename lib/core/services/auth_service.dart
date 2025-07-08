import 'dart:async';
import 'package:invoicepatch_contractor/shared/models/user.dart';
import 'package:invoicepatch_contractor/shared/models/client.dart';
import 'package:invoicepatch_contractor/shared/models/billing_preferences.dart';
import 'package:invoicepatch_contractor/shared/models/address.dart';

abstract class AuthService {
  Future<User?> getCurrentUser();
  Future<User?> signInWithEmail(String email, String password);
  Future<User?> signUpWithEmail(String email, String password, String fullName);
  Future<void> signOut();
  Future<void> sendPasswordReset(String email);
  Stream<User?> get authStateChanges;
}

// Simple in-memory mock implementation for development
class MockAuthService implements AuthService {
  User? _currentUser;
  final StreamController<User?> _authStateController = StreamController<User?>.broadcast();

  MockAuthService() {
    // Optionally, initialize with a mock user
    _currentUser = null;
  }

  @override
  Future<User?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<User?> signInWithEmail(String email, String password) async {
    // For mock: any email/password works, create a fake user
    _currentUser = User(
      id: 'mock-id',
      email: email,
      fullName: 'Mock User',
      businessInfo: BusinessInfo(
        businessName: 'Mock Business',
        businessAddress: Address.empty(),
        province: 'ON',
      ),
      billingPreferences: BillingPreferences.empty(),
      userPreferences: UserPreferences(),
      onboardingCompleted: false,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
    _authStateController.add(_currentUser);
    return _currentUser;
  }

  @override
  Future<User?> signUpWithEmail(String email, String password, String fullName) async {
    // For mock: create a new user
    _currentUser = User(
      id: 'mock-id',
      email: email,
      fullName: fullName,
      businessInfo: BusinessInfo(
        businessName: 'Mock Business',
        businessAddress: Address.empty(),
        province: 'ON',
      ),
      billingPreferences: BillingPreferences.empty(),
      userPreferences: UserPreferences(),
      onboardingCompleted: false,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
    _authStateController.add(_currentUser);
    return _currentUser;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _authStateController.add(null);
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    // Mock: do nothing
    return;
  }

  @override
  Stream<User?> get authStateChanges => _authStateController.stream;

  void dispose() {
    _authStateController.close();
  }
} 