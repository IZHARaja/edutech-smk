import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'core/services/auth_service.dart';
import 'core/services/firestore_service.dart';
import 'core/services/seeder_service.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/auth_wrapper.dart';
import 'features/student/providers/student_provider.dart';
import 'features/teacher/providers/teacher_provider.dart';
import 'features/wali_kelas/providers/wali_kelas_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Peringatan: Firebase.initializeApp: $e');
  }

  runApp(const EduTechApp());
}

class EduTechApp extends StatelessWidget {
  const EduTechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<FirestoreService>(
          create: (_) => FirestoreService(),
        ),
        Provider<StorageService>(
          create: (_) => StorageService(),
        ),
        Provider<SeederService>(
          create: (_) => SeederService(),
        ),
        ChangeNotifierProvider<AppAuthProvider>(
          create: (ctx) => AppAuthProvider(
            authService: ctx.read<AuthService>(),
          ),
        ),
        ChangeNotifierProvider<StudentProvider>(
          create: (ctx) => StudentProvider(
            firestoreService: ctx.read<FirestoreService>(),
          ),
        ),
        ChangeNotifierProvider<TeacherProvider>(
          create: (ctx) => TeacherProvider(
            firestoreService: ctx.read<FirestoreService>(),
            storageService: ctx.read<StorageService>(),
          ),
        ),
        ChangeNotifierProvider<WaliKelasProvider>(
          create: (ctx) => WaliKelasProvider(
            firestoreService: ctx.read<FirestoreService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'EduTech SMK',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}
