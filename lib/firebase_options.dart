import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Konfigurasi default Firebase Options yang dihasilkan oleh FlutterFire CLI.
/// Sesuaikan dengan project Firebase Anda jika sudah menjalankan `flutterfire configure`.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static bool get isPlaceholderConfig {
    final options = currentPlatform;
    return options.apiKey.contains('Placeholder') ||
        options.appId.contains('1234567890') ||
        options.appId.contains('abcdef123456');
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDUjDQmESjNk7Nr0AOceEvvrrAAh35RjbM',
    appId: '1:105620389401:web:7c5c2d1efe98bd63b53488',
    messagingSenderId: '105620389401',
    projectId: 'edutech-smk-dd479',
    authDomain: 'edutech-smk-dd479.firebaseapp.com',
    storageBucket: 'edutech-smk-dd479.firebasestorage.app',
    measurementId: 'G-YSDF5TK88Q',
  );
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDemoAndroidApiKeyPlaceholder',
    appId: '1:1234567890:android:abcdef123456',
    messagingSenderId: '1234567890',
    projectId: 'edutech-smk',
    storageBucket: 'edutech-smk.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDemoIosApiKeyPlaceholder',
    appId: '1:1234567890:ios:abcdef123456',
    messagingSenderId: '1234567890',
    projectId: 'edutech-smk',
    storageBucket: 'edutech-smk.appspot.com',
    iosBundleId: 'com.smk.edutech',
  );
}
