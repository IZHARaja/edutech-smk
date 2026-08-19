import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/user_role.dart';
import '../../admin/screens/admin_dashboard.dart';
import '../../bk/screens/bk_dashboard.dart';
import '../../piket/screens/piket_dashboard.dart';
import '../../student/screens/student_dashboard.dart';
import '../../teacher/screens/teacher_dashboard.dart';
import '../../wali_kelas/screens/wali_kelas_dashboard.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

/// Widget wrapper utama yang menangani State Autentikasi dan
/// melakukan Automatic Role-Based Routing ke Dashboard masing-masing role.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AppAuthProvider>();

    // 1. Kondisi saat aplikasi pertama kali memuat / memeriksa token
    if (authProvider.status == AuthStatus.uninitialized ||
        (authProvider.status == AuthStatus.loading && authProvider.currentUser == null)) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              SizedBox(height: 16),
              Text(
                'Memuat EduTech SMK...',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 2. Jika user belum login atau sesi telah berakhir
    if (authProvider.status == AuthStatus.unauthenticated || authProvider.currentUser == null) {
      return const LoginScreen();
    }

    // 3. Jika user berhasil terautentikasi -> Route otomatis berdasarkan Role
    final user = authProvider.currentUser!;
    switch (user.role) {
      case UserRole.student:
        return const StudentDashboard();
      case UserRole.teacher:
        return const TeacherDashboard();
      case UserRole.waliKelas:
        return const WaliKelasDashboard();
      case UserRole.bk:
        return const BKDashboard();
      case UserRole.piket:
        return const PiketDashboard();
      case UserRole.admin:
        return const AdminDashboard();
    }
  }
}
