import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  final RxBool isLoggedIn = false.obs;
  final RxString userRole = ''.obs;
  final RxString userEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _checkAuthState();
  }

  void _checkAuthState() {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      isLoggedIn.value = true;
      userEmail.value = session.user.email ?? '';
      userRole.value = session.user.appMetadata?['role'] ?? 'authenticated';
    } else {
      isLoggedIn.value = false;
      userEmail.value = '';
      userRole.value = '';
    }

    // Listen to auth state changes
    _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        isLoggedIn.value = true;
        userEmail.value = session.user.email ?? '';
        userRole.value = session.user.appMetadata?['role'] ?? 'authenticated';
      } else {
        isLoggedIn.value = false;
        userEmail.value = '';
        userRole.value = '';
      }
    });
  }

  Future<bool> signIn(String email, String password) async {
    try {
      print('🔐 Attempting sign in for $email');
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      print('🔐 Sign in response: $response');

      if (response.session != null) {
        isLoggedIn.value = true;
        userEmail.value = email;
        userRole.value = response.session!.user.appMetadata?['role'] ?? 'authenticated';
        return true;
      }
      return false;
    } catch (e, stackTrace) {
      print('❌ Sign in failed: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    isLoggedIn.value = false;
    userEmail.value = '';
    userRole.value = '';
  }

  bool get isAuthenticated => isLoggedIn.value;

  String get currentUserEmail => userEmail.value;

  String get currentUserRole => userRole.value;

  bool hasPermission(String requiredRole) {
    if (userRole.value == 'admin') return true;
    return userRole.value == requiredRole;
  }
}
