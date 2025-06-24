import 'package:flutter/foundation.dart';
import 'package:woodline/models/user_model.dart';
import 'package:woodline/services/auth_service.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isWoodworker => _user?.role == 'woodworker';

  UserProvider() {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    _user = _authService.getCurrentUser();
    notifyListeners();
  }

  Future<UserModel?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      _user = await _authService.signInWithEmailAndPassword(email, password);
      return _user;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<UserModel?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
    required String role,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      _user = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
        role: role,
      );
      return _user;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<UserModel?> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();

      _user = await _authService.signInWithGoogle();
      return _user;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.signOut();
      _user = null;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
