import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/services/firestore_service.dart';

class StudentProvider extends ChangeNotifier {
  StudentProvider({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  final FirestoreService _firestoreService;

  StreamSubscription<List<Map<String, dynamic>>>? _materiSubscription;
  StreamSubscription<List<Map<String, dynamic>>>? _tugasSubscription;

  List<Map<String, dynamic>> _materiList = const [];
  List<Map<String, dynamic>> _tugasList = const [];
  bool _isMateriLoading = false;
  bool _isTugasLoading = false;
  String? _materiError;
  String? _tugasError;
  String? _activeKelas;

  List<Map<String, dynamic>> get materiList => _materiList;
  List<Map<String, dynamic>> get tugasList => _tugasList;
  bool get isMateriLoading => _isMateriLoading;
  bool get isTugasLoading => _isTugasLoading;
  bool get isInitialLoading => _isMateriLoading || _isTugasLoading;
  String? get materiError => _materiError;
  String? get tugasError => _tugasError;

  void startListening({required String kelas}) {
    if (_activeKelas == kelas &&
        (_materiSubscription != null || _tugasSubscription != null)) {
      return;
    }

    _activeKelas = kelas;
    _isMateriLoading = true;
    _isTugasLoading = true;
    _materiError = null;
    _tugasError = null;
    notifyListeners();

    _materiSubscription?.cancel();
    _tugasSubscription?.cancel();

    _materiSubscription = _firestoreService.streamMateriList(kelas: kelas).listen(
      (items) {
        _materiList = items;
        _isMateriLoading = false;
        _materiError = null;
        notifyListeners();
      },
      onError: (error) {
        _materiList = const [];
        _isMateriLoading = false;
        _materiError = 'Gagal memuat materi: $error';
        notifyListeners();
      },
    );

    _tugasSubscription = _firestoreService.streamTugasList(kelas: kelas).listen(
      (items) {
        _tugasList = items;
        _isTugasLoading = false;
        _tugasError = null;
        notifyListeners();
      },
      onError: (error) {
        _tugasList = const [];
        _isTugasLoading = false;
        _tugasError = 'Gagal memuat tugas: $error';
        notifyListeners();
      },
    );
  }

  Future<void> refresh({required String kelas}) async {
    _activeKelas = null;
    startListening(kelas: kelas);
  }

  @override
  void dispose() {
    _materiSubscription?.cancel();
    _tugasSubscription?.cancel();
    super.dispose();
  }
}