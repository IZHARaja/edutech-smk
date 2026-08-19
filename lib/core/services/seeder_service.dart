import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../features/auth/models/user_model.dart';
import '../constants/user_role.dart';
import '../../firebase_options.dart';

class DemoSeedResult {
  const DemoSeedResult({
    required this.createdCount,
    required this.updatedCount,
  });

  final int createdCount;
  final int updatedCount;
}

class SeederService {
  static const String demoPassword = 'password123';

  static final List<_DemoAccountSeed> _demoAccounts = [
    ..._buildStudentDemoAccounts(),
    const _DemoAccountSeed(
      email: 'guru@edutech.sch.id',
      name: 'Dimas Pratama',
      role: UserRole.teacher,
      nisnOrNip: '198812102020011001',
    ),
    const _DemoAccountSeed(
      email: 'walikelas@edutech.sch.id',
      name: 'Rina Suryani',
      role: UserRole.waliKelas,
      nisnOrNip: '198501172010012002',
      kelas: 'XII RPL 1',
    ),
    const _DemoAccountSeed(
      email: 'walikelas2@edutech.sch.id',
      name: 'Budi Santoso',
      role: UserRole.waliKelas,
      nisnOrNip: '198402032009011005',
      kelas: 'XI RPL 1',
    ),
    const _DemoAccountSeed(
      email: 'bk@edutech.sch.id',
      name: 'Maya Kusuma',
      role: UserRole.bk,
      nisnOrNip: '198703082011012003',
    ),
    const _DemoAccountSeed(
      email: 'piket@edutech.sch.id',
      name: 'Arif Hidayat',
      role: UserRole.piket,
      nisnOrNip: '198609192012011004',
    ),
    const _DemoAccountSeed(
      email: 'admin@edutech.sch.id',
      name: 'Administrator EduTech',
      role: UserRole.admin,
      nisnOrNip: 'ADM-001',
    ),
  ];

  static List<_DemoAccountSeed> _buildStudentDemoAccounts() {
    const classes = <String>['XII RPL 1', 'XI RPL 1', 'XII TKJ 1'];
    const studentNames = <String>[
      'Ahmad Fauzi',
      'Salsa Maharani',
      'Dimas Saputra',
      'Alya Putri',
      'Rafi Pratama',
      'Nadia Khairunisa',
      'Fikri Ramadhan',
      'Nabila Azzahra',
      'Rizky Maulana',
      'Citra Lestari',
      'Bagas Prakoso',
      'Siti Rahma',
      'Daffa Alfarizi',
      'Laras Wulandari',
      'Yoga Saputro',
      'Nayla Safitri',
      'Ilham Hidayat',
      'Tiara Oktaviani',
      'Gilang Permana',
      'Putri Amelia',
      'Rangga Kurniawan',
      'Dewi Anggraini',
      'Miko Prasetyo',
      'Zahra Aulia',
      'Farhan Akbar',
      'Keisya Maharani',
      'Yusuf Maulana',
      'Anisa Fitri',
      'Raka Aditya',
      'Shafa Humaira',
    ];

    return List<_DemoAccountSeed>.generate(studentNames.length, (index) {
      final number = index + 1;
      final email = number == 1
          ? 'siswa@edutech.sch.id'
          : 'siswa${number.toString().padLeft(2, '0')}@edutech.sch.id';
      final nisn = (1029384700 + number).toString();
      final kelas = classes[index % classes.length];

      return _DemoAccountSeed(
        email: email,
        name: studentNames[index],
        role: UserRole.student,
        nisnOrNip: nisn,
        kelas: kelas,
      );
    });
  }

  Future<DemoSeedResult> seedDemoAccounts() async {
    if (DefaultFirebaseOptions.isPlaceholderConfig) {
      throw Exception(
        'Firebase belum dikonfigurasi. Jalankan flutterfire configure terlebih dahulu.',
      );
    }

    final appName = 'seeder-${DateTime.now().millisecondsSinceEpoch}';
    final FirebaseApp secondaryApp = await Firebase.initializeApp(
      name: appName,
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final FirebaseAuth secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
    final FirebaseFirestore secondaryFirestore = FirebaseFirestore.instanceFor(app: secondaryApp);

    int createdCount = 0;
    int updatedCount = 0;

    try {
      for (final account in _demoAccounts) {
        final User user = await _ensureDemoUser(
          auth: secondaryAuth,
          email: account.email,
          password: demoPassword,
        );

        final existingDoc = await secondaryFirestore.collection('users').doc(user.uid).get();
        if (existingDoc.exists) {
          updatedCount++;
        } else {
          createdCount++;
        }

        final userModel = UserModel(
          uid: user.uid,
          email: account.email,
          name: account.name,
          role: account.role,
          nisnOrNip: account.nisnOrNip,
          kelas: account.kelas,
          createdAt: DateTime.now(),
        );

        await secondaryFirestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toMap(), SetOptions(merge: true));
      }

      await secondaryAuth.signOut();
      return DemoSeedResult(
        createdCount: createdCount,
        updatedCount: updatedCount,
      );
    } finally {
      await secondaryApp.delete();
    }
  }

  Future<User> _ensureDemoUser({
    required FirebaseAuth auth,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Gagal membuat akun demo $email.');
      }
      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'operation-not-allowed' ||
          (e.message ?? '').contains('CONFIGURATION_NOT_FOUND')) {
        throw Exception(
          'Firebase Authentication belum diaktifkan. Buka Firebase Console > Authentication > Get started, lalu aktifkan metode Email/Password.',
        );
      }

      if (e.code != 'email-already-in-use') {
        throw Exception(e.message ?? 'Gagal membuat akun demo $email.');
      }

      try {
        final signInCredential = await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        final user = signInCredential.user;
        if (user == null) {
          throw Exception('Akun demo $email tidak bisa dipakai setelah login ulang.');
        }
        return user;
      } on FirebaseAuthException {
        throw Exception(
          'Akun demo $email sudah ada, tetapi password-nya berbeda dari password standar seeder.',
        );
      }
    }
  }
}

class _DemoAccountSeed {
  const _DemoAccountSeed({
    required this.email,
    required this.name,
    required this.role,
    required this.nisnOrNip,
    this.kelas,
  });

  final String email;
  final String name;
  final UserRole role;
  final String nisnOrNip;
  final String? kelas;
}