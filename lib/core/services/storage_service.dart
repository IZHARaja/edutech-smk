import 'dart:async';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

/// Service untuk mengelola unggahan berkas (PDF materi, foto, dokumen) ke Firebase Storage
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Mengunggah berkas materi (mendukung Android, iOS, dan Web via Uint8List)
  Future<String> uploadMateriFile({
    required String fileName,
    required Uint8List fileBytes,
    String? mimeType,
    String folder = 'materi',
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final safeFileName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final path = '$folder/${timestamp}_$safeFileName';

      final ref = _storage.ref().child(path);
      final metadata = SettableMetadata(
        contentType: mimeType ?? _guessMimeType(fileName),
      );

      final snapshot = await ref
          .putData(fileBytes, metadata)
          .timeout(const Duration(seconds: 5));
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } on TimeoutException {
      throw Exception(
        'Upload file ke Firebase Storage terlalu lama atau tidak merespons. Pastikan Firebase Storage sudah diaktifkan dan bucket project sudah dibuat.',
      );
    } on FirebaseException catch (e) {
      final message = (e.message ?? '').trim();

      if (message.contains('bucket does not exist') ||
          message.contains('Object does not exist') ||
          e.code == 'bucket-not-found') {
        throw Exception(
          'Firebase Storage belum diaktifkan atau bucket project belum dibuat. Buka Firebase Console > Storage > Get started lalu buat bucket terlebih dahulu.',
        );
      }

      if (e.code == 'unauthorized' || e.code == 'unauthenticated') {
        throw Exception(
          'Akses ke Firebase Storage ditolak. Periksa aturan Storage atau status login akun Anda.',
        );
      }

      if (e.code == 'retry-limit-exceeded' || e.code == 'canceled') {
        throw Exception(
          'Upload file dibatalkan atau melebihi batas retry. Coba lagi setelah memastikan Firebase Storage aktif.',
        );
      }

      throw Exception(
        message.isEmpty ? 'Gagal mengunggah file ke Firebase Storage.' : 'Gagal mengunggah file ke Firebase Storage: $message',
      );
    } catch (e) {
      throw Exception('Gagal mengunggah file ke Storage: $e');
    }
  }

  /// Menghapus file dari Firebase Storage berdasarkan URL
  Future<void> deleteFileByUrl(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Gagal menghapus file: $e');
    }
  }

  /// Helper tebak MIME type sederhana berdasarkan ekstensi berkas
  String _guessMimeType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'ppt':
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'mp4':
        return 'video/mp4';
      default:
        return 'application/octet-stream';
    }
  }
}
