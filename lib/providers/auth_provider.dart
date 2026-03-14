import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import '../models/user_model.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated, loading }

class AuthProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  AuthStatus _status = AuthStatus.uninitialized;
  User? _supabaseUser;
  UserModel? _userModel;
  String? _errorMessage;

  // Getters
  AuthStatus get status => _status;
  User? get supabaseUser => _supabaseUser;
  UserModel? get userModel => _userModel;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  AuthProvider() {
    _init();
  }

  void _init() {
    _supabase.auth.onAuthStateChange.listen((data) {
      _onAuthStateChanged(data.session?.user);
    });
  }

  Future<void> _onAuthStateChanged(User? user) async {
    if (user == null) {
      _status = AuthStatus.unauthenticated;
      _supabaseUser = null;
      _userModel = null;
      await _clearLocalStorage();
      notifyListeners();
    } else {
      _supabaseUser = user;
      _status = AuthStatus.loading;
      notifyListeners();
      await _loadUserData();
      notifyListeners();
    }
  }

  Future<void> _loadUserData() async {
    try {
      if (_supabaseUser != null) {
        final response = await _supabase
            .from('users')
            .select()
            .eq('id', _supabaseUser!.id)
            .maybeSingle();

        if (response != null) {
          _userModel = UserModel.fromJson(response);
          _status = AuthStatus.authenticated;
          await _saveLocalStorage();
          await _saveUserToCache();
          await _updateLastLogin();
        } else {
          await _createMissingUserDocument();
        }
      }
    } catch (e) {
      await _handleSupabaseError(e);
    }
  }

  Future<void> _createMissingUserDocument() async {
    try {
      if (_supabaseUser == null) return;

      final userData = {
        'id': _supabaseUser!.id,
        'name':
            _supabaseUser!.userMetadata?['name'] ??
            _supabaseUser!.email?.split('@')[0] ??
            'User',
        'email': _supabaseUser!.email ?? '',
        'role': 'user',
        'status': 'active',
        'subscription_plan': 'free',
        'created_at': DateTime.now().toIso8601String(),
        'last_login': DateTime.now().toIso8601String(),
        'organization_id': null,
      };

      await _supabase.from('users').insert(userData);

      final response = await _supabase
          .from('users')
          .select()
          .eq('id', _supabaseUser!.id)
          .single();

      _userModel = UserModel.fromJson(response);
      _status = AuthStatus.authenticated;
      await _saveLocalStorage();
      await _updateLastLogin();
    } catch (e) {
      await _handleSupabaseError(e);
    }
  }

  Future<void> _handleSupabaseError(dynamic error) async {
    try {
      if (_supabaseUser == null) return;
      _userModel = UserModel(
        id: _supabaseUser!.id,
        name:
            _supabaseUser!.userMetadata?['name'] ??
            _supabaseUser!.email?.split('@')[0] ??
            'User',
        email: _supabaseUser!.email ?? '',
        role: 'user',
        status: 'active',
        subscriptionPlan: 'free',
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        organizationId: null,
      );
      _status = AuthStatus.authenticated;
      await _saveLocalStorage();
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _setError('Authentication failed');
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String businessName,
  }) async {
    _setLoading();
    try {
      // 1. Sign up user
      final AuthResponse res = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      final user = res.user;
      if (user == null) throw Exception('User creation failed');

      // 2. Create organization
      final orgData = await _supabase
          .from('organizations')
          .insert({'name': businessName, 'owner_uid': user.id})
          .select()
          .single();

      // 3. Create user record
      await _supabase.from('users').insert({
        'id': user.id,
        'name': name,
        'email': email,
        'role': 'owner',
        'status': 'active',
        'subscription_plan': 'free',
        'organization_id': orgData['id'],
      });

      await _supabase.auth.signOut();
      _clearError();
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred during signup.');
      return false;
    } finally {
      _setNotLoading();
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    try {
      _setLoading();
      await _supabase.auth.signInWithPassword(email: email, password: password);
      _clearError();
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Unexpected error: ${e.toString()}');
      return false;
    } finally {
      _setNotLoading();
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    await _clearLocalStorage();
    await _clearCachedUser();
  }

  Future<void> _clearCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    notifyListeners();
  }

  void _setNotLoading() {
    if (_supabaseUser != null && _userModel != null) {
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  Future<void> _updateLastLogin() async {
    if (_supabaseUser != null) {
      await _supabase
          .from('users')
          .update({'last_login': DateTime.now().toIso8601String()})
          .eq('id', _supabaseUser!.id);
    }
  }

  Future<void> _saveLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
  }

  Future<void> _clearLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
  }

  Future<void> _saveUserToCache() async {
    if (_userModel != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(_userModel!.toJson()));
    }
  }

  bool hasRole(String role) => _userModel?.role == role;
}
