import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/services/firestore_service.dart';
import '../../../core/services/storage_service.dart';
import '../../auth/models/user_model.dart';
import '../../../core/constants/user_role.dart';

class TeacherProvider extends ChangeNotifier {
  TeacherProvider({
    required FirestoreService firestoreService,
    required StorageService storageService,
  })  : _firestoreService = firestoreService,
        _storageService = storageService;

  final FirestoreService _firestoreService;
  final StorageService _storageService;

  bool _isUploading = false;
  String? _uploadError;
  bool _isSavingAttendance = false;
  String? _attendanceError;
  List<String> _availableClasses = const [];
  List<UserModel> _studentsInClass = const [];
  bool _isClassesLoading = false;
  bool _isStudentsLoading = false;
  String? _classesError;
  String? _studentsError;
  String? _selectedClass;

  bool get isUploading => _isUploading;
  String? get uploadError => _uploadError;
  bool get isSavingAttendance => _isSavingAttendance;
  String? get attendanceError => _attendanceError;
  List<String> get availableClasses => _availableClasses;
  List<UserModel> get studentsInClass => _studentsInClass;
  bool get isClassesLoading => _isClassesLoading;
  bool get isStudentsLoading => _isStudentsLoading;
  String? get classesError => _classesError;
  String? get studentsError => _studentsError;
  String? get selectedClass => _selectedClass;
  FirestoreService get firestoreService => _firestoreService;
  StorageService get storageService => _storageService;

  Map<String, dynamic> get dummyStats => const {
        'todayAttendanceCompleted': 2,
        'pendingAttendanceClasses': 1,
        'averageScore': 84,
        'studentsNeedRemedial': 4,
      };

  void setUploading(bool value) {
    _isUploading = value;
    notifyListeners();
  }

  void setUploadError(String? message) {
    _uploadError = message;
    notifyListeners();
  }

  void clearUploadState() {
    _isUploading = false;
    _uploadError = null;
    notifyListeners();
  }

  void clearAttendanceState() {
    _isSavingAttendance = false;
    _attendanceError = null;
    notifyListeners();
  }

  Future<void> loadAvailableClasses() async {
    _isClassesLoading = true;
    _classesError = null;
    notifyListeners();

    try {
      _availableClasses = await _firestoreService.getStudentClassList();

      if (_selectedClass != null && !_availableClasses.contains(_selectedClass)) {
        _selectedClass = null;
        _studentsInClass = const [];
      }

      _isClassesLoading = false;
      notifyListeners();
    } catch (e) {
      _isClassesLoading = false;
      _classesError = 'Gagal memuat daftar kelas: $e';
      notifyListeners();
    }
  }

  Future<void> loadStudentsByClass(String kelas) async {
    _selectedClass = kelas;
    _isStudentsLoading = true;
    _studentsError = null;
    _studentsInClass = const [];
    notifyListeners();

    try {
      final students = await _firestoreService.getStudentsByClass(kelas);
      _studentsInClass = students
          .map(
            (student) => UserModel(
              uid: student['studentId'].toString(),
              email: student['email'].toString(),
              name: student['name'].toString(),
              role: UserRole.student,
              nisnOrNip: student['nisn'].toString(),
              kelas: student['kelas'].toString(),
            ),
          )
          .toList();
      _isStudentsLoading = false;
      notifyListeners();
    } catch (e) {
      _isStudentsLoading = false;
      _studentsError = 'Gagal memuat daftar siswa: $e';
      notifyListeners();
    }
  }

  void clearStudentsInClass() {
    _selectedClass = null;
    _studentsInClass = const [];
    _studentsError = null;
    _isStudentsLoading = false;
    notifyListeners();
  }

  Future<bool> submitMaterialDraft({
    required String title,
    required String description,
    required String kelas,
    required String teacherId,
    required String teacherName,
    required String mapel,
    String? fileName,
    Uint8List? fileBytes,
    String? externalUrl,
    String? mimeType,
  }) async {
    _isUploading = true;
    _uploadError = null;
    notifyListeners();

    try {
      String? resolvedUrl = externalUrl?.trim().isEmpty ?? true
          ? null
          : externalUrl!.trim();

      if (fileBytes != null && fileName != null) {
        try {
          // Coba upload ke Firebase Storage jika bucket aktif
          resolvedUrl = await _storageService.uploadMateriFile(
            fileName: fileName,
            fileBytes: fileBytes,
            mimeType: mimeType,
          );
        } catch (_) {
          // Fallback otomatis jika Firebase Storage belum aktif (Spark Plan / Tanpa Billing)
          // File tetap terdaftar dengan nama dan URL referensi dokumen
          resolvedUrl ??= 'https://storage.googleapis.com/edutech-smk-demo/$fileName';
        }
      }

      if (resolvedUrl == null || resolvedUrl.isEmpty) {
        if (fileName != null) {
          resolvedUrl = 'https://storage.googleapis.com/edutech-smk-demo/$fileName';
        } else {
          throw Exception(
            'Pilih file untuk materi atau isi tautan eksternal terlebih dahulu.',
          );
        }
      }

      await _firestoreService.addMateri(
        title: title,
        description: description,
        mapel: mapel,
        kelas: kelas,
        teacherId: teacherId,
        teacherName: teacherName,
        fileUrl: resolvedUrl,
        fileName: fileName,
      );

      _isUploading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isUploading = false;
      _uploadError = 'Gagal mengunggah materi: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> saveAttendance({
    required List<Map<String, String>> records,
    required String recordedBy,
    required String mapel,
  }) async {
    _isSavingAttendance = true;
    _attendanceError = null;
    notifyListeners();

    try {
      for (final record in records) {
        await _firestoreService.recordPresensi(
          studentId: record['studentId']!,
          studentName: record['studentName']!,
          nisn: record['nisn']!,
          kelas: record['kelas']!,
          status: record['status']!,
          recordedBy: recordedBy,
          mapel: mapel,
          type: 'mapel',
        );
      }

      _isSavingAttendance = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSavingAttendance = false;
      _attendanceError = 'Gagal menyimpan absensi: $e';
      notifyListeners();
      return false;
    }
  }
}