import 'package:flutter/material.dart';
import '../../../data/services/auth_storage_service.dart';
import '../../../routes/app_routes.dart';

/// Widget wrapper untuk halaman auth yang mencegah back navigation jika user sudah login
class AuthPageWrapper extends StatelessWidget {
  final Widget child;

  const AuthPageWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent default back behavior
      onPopInvoked: (didPop) async {
        if (!didPop) {
          // Check if user is logged in
          final authStorage = AuthStorageService();
          final isLoggedIn = await authStorage.isLoggedIn();
          
          if (isLoggedIn) {
            // Jika sudah login, redirect ke home (mencegah kembali ke auth page)
            if (context.mounted) {
              Navigator.of(context).pushReplacementNamed(AppRoutes.home);
            }
          } else {
            // Jika belum login, biarkan kembali normal
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          }
        }
      },
      child: child,
    );
  }
}

