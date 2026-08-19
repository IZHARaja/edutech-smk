import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/auth/models/user_model.dart';
import '../constants/user_role.dart';
import '../../firebase_options.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream status autentikasi dari Firebase Auth
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Mendapatkan user Firebase Auth saat ini
  User? get currentUser => _auth.currentUser;

  /// Login menggunakan Email & Password
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (DefaultFirebaseOptions.isPlaceholderConfig) {
      throw Exception(
        'Firebase belum dikonfigurasi untuk project ini. Ganti file lib/firebase_options.dart dengan hasil flutterfire configure terlebih dahulu.',
      );
    }

    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final User? firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('User tidak ditemukan setelah login.');
      }

      // Ambil data profil & role dari Firestore collection 'users'
      final UserModel? userModel = await getUserProfile(firebaseUser.uid);
      if (userModel == null) {
        throw Exception('Dokumen profil pengguna tidak ditemukan di database.');
      }

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      final message = e.toString().replaceAll('Exception: ', '').trim();
      if (message.contains('CONFIGURATION_NOT_FOUND')) {
        throw Exception(
          'Firebase Authentication belum diaktifkan untuk project ini. Buka Firebase Console, aktifkan Authentication, lalu nyalakan metode Email/Password.',
        );
      }
      if (message.contains('network AuthError') ||
          message.contains('network-request-failed') ||
          message.contains('unreachable host')) {
        throw Exception(
          'Koneksi ke Firebase Auth terputus atau diblokir. Matikan ekstensi Adblocker di browser atau lakukan refresh (Ctrl + F5).',
        );
      }
      throw Exception(message.isEmpty ? 'Terjadi kesalahan saat login.' : message);
    }
  }

  /// Mengambil data profil user dari Firestore berdasarkan UID
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Gagal mengambil data profil pengguna: $e');
    }
  }

  /// Registrasi pengguna baru dengan Role tertentu (Dapat digunakan oleh Admin / Seeder)
  Future<UserModel> registerUser({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? nisnOrNip,
    String? kelas,
  }) async {
    try {
      final UserCredential credential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final User? firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('Gagal membuat akun.');
      }

      final UserModel newUser = UserModel(
        uid: firebaseUser.uid,
        email: email.trim(),
        name: name.trim(),
        role: role,
        nisnOrNip: nisnOrNip,
        kelas: kelas,
        createdAt: DateTime.now(),
      );

      // Simpan data user ke collection 'users'
      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(newUser.toMap());

      return newUser;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Logout dari Firebase Auth
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Handler pesan error ramah pengguna untuk FirebaseAuthException
  String _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Akun dengan email tersebut tidak ditemukan.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Password atau email yang Anda masukkan salah.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'operation-not-allowed':
        return 'Firebase Authentication belum diaktifkan atau metode Email/Password belum dinyalakan.';
      case 'user-disabled':
        return 'Akun pengguna telah dinonaktifkan oleh administrator.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan login gagal. Silakan coba beberapa saat lagi.';
      case 'network-request-failed':
        return 'Koneksi ke Firebase Auth terputus atau diblokir. Matikan ekstensi Adblocker di browser atau lakukan refresh (Ctrl + F5).';
      default:
        if ((e.message ?? '').contains('CONFIGURATION_NOT_FOUND')) {
          return 'Firebase Authentication belum diaktifkan untuk project ini. Aktifkan metode Email/Password di Firebase Console.';
        }
        if ((e.message ?? '').contains('network AuthError') ||
            (e.message ?? '').contains('unreachable host')) {
          return 'Koneksi ke Firebase Auth terputus atau diblokir. Matikan ekstensi Adblocker di browser atau lakukan refresh (Ctrl + F5).';
        }
        return e.message ?? 'Terjadi kesalahan pada sistem autentikasi.';
    }
  }
}
