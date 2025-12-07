import 'package:flutter/material.dart';
import '../../data/services/auth_storage_service.dart';
import '../../routes/app_routes.dart';

class AuthGuard {
  static final AuthStorageService _authStorage = AuthStorageService();

  // Check if route requires authentication
  static bool requiresAuth(String routeName) {
    return routeName == AppRoutes.home || 
           routeName == AppRoutes.profile ||
           routeName == AppRoutes.rooms ||
           routeName == AppRoutes.videoCall;
  }

  // Check if route is auth page (login, register, etc)
  static bool isAuthRoute(String routeName) {
    return routeName == AppRoutes.login ||
        routeName == AppRoutes.register ||
        routeName == AppRoutes.verifyOtp ||
        routeName == AppRoutes.resetPassword ||
        routeName == AppRoutes.verifyOtpReset ||
        routeName == AppRoutes.verifyResetPassword;
  }

  /// Middleware: Mencegah user yang sudah login mengakses halaman auth
  /// Jika user sudah login dan mencoba akses login/register/etc, redirect ke home
  static Future<String?> guardAuthRoute(
    String routeName,
    BuildContext context,
  ) async {
    // Cek apakah route ini adalah halaman auth
    if (!isAuthRoute(routeName)) {
      return null; // Bukan halaman auth, biarkan lewat
    }

    // Cek apakah user sudah login
    final isLoggedIn = await _authStorage.isLoggedIn();

    if (isLoggedIn) {
      // User sudah login tapi mencoba akses halaman auth
      // Redirect ke home untuk mencegah akses ke halaman auth
      debugPrint('[AuthGuard] User sudah login, redirect dari $routeName ke ${AppRoutes.home}');
      return AppRoutes.home;
    }

    // User belum login, boleh akses halaman auth
    return null;
  }

  /// Middleware: Mencegah user yang belum login mengakses halaman protected
  /// Jika user belum login dan mencoba akses home/profile/etc, redirect ke login
  static Future<String?> guardProtectedRoute(
    String routeName,
    BuildContext context,
  ) async {
    // Cek apakah route ini memerlukan authentication
    if (!requiresAuth(routeName)) {
      return null; // Route tidak memerlukan auth, biarkan lewat
    }

    // Cek apakah user sudah login
    final isLoggedIn = await _authStorage.isLoggedIn();

    if (!isLoggedIn) {
      // User belum login tapi mencoba akses halaman protected
      // Redirect ke login
      debugPrint('[AuthGuard] User belum login, redirect dari $routeName ke ${AppRoutes.login}');
      return AppRoutes.login;
    }

    // User sudah login, boleh akses halaman protected
    return null;
  }
}

