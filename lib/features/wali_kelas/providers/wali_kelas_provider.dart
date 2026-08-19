import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/user_role.dart';
import '../../../core/services/firestore_service.dart';
import '../../auth/models/user_model.dart';

class WaliStudentAlertItem {
  const WaliStudentAlertItem({
    required this.student,
    required this.alphaCount,
    required this.previousAverage,
    required this.latestAverage,
    required this.alertReasons,
  });

  final UserModel student;
  final int alphaCount;
  final double previousAverage;
  final double latestAverage;
  final List<String> alertReasons;

  bool get hasAlert => alertReasons.isNotEmpty;

  String get statusLabel {
    if (alertReasons.length >= 2) {
      return 'Kritis';
    }
    if (alertReasons.length == 1) {
      return 'Waspada';
    }
    return 'Normal';
  }

  String get scoreTrendLabel {
    final delta = latestAverage - previousAverage;
    final prefix = delta >= 0 ? '+' : '';
    return '$prefix${delta.toStringAsFixed(0)}%';
  }

  double get scoreDropPercentage {
    if (previousAverage <= 0) {
      return 0;
    }
    return ((previousAverage - latestAverage) / previousAverage) * 100;
  }
}

class WaliKelasProvider extends ChangeNotifier {
  WaliKelasProvider({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  final FirestoreService _firestoreService;
  StreamSubscription<List<Map<String, dynamic>>>? _attendanceSubscription;
  StreamSubscription<List<Map<String, dynamic>>>? _reportsSubscription;
  StreamSubscription<List<Map<String, dynamic>>>? _incidentLogsSubscription;

  List<UserModel> _students = const [];
  List<WaliStudentAlertItem> _studentAlerts = const [];
  List<Map<String, dynamic>> _attendanceRecordsToday = const [];
  List<Map<String, dynamic>> _reports = const [];
  List<Map<String, dynamic>> _incidentLogs = const [];
  Map<String, int> _attendanceSummary = const {
    'hadir': 0,
    'izin': 0,
    'sakit': 0,
    'alpha': 0,
  };
  Map<String, int> _incidentSummary = const {
    'Keterlambatan': 0,
    'Izin Pulang': 0,
  };
  bool _isLoading = false;
  String? _errorMessage;
  String? _waliClass;
  String _selectedDate = DateTime.now().toIso8601String().substring(0, 10);
  String _attendanceStatusFilter = 'Semua';
  String _reportStatusFilter = 'Semua';

  List<UserModel> get students => _students;
  List<WaliStudentAlertItem> get studentAlerts => _studentAlerts;
  List<Map<String, dynamic>> get attendanceRecordsToday => _attendanceRecordsToday;
  List<Map<String, dynamic>> get reports => _reports;
  List<Map<String, dynamic>> get incidentLogs => _incidentLogs;
  Map<String, int> get attendanceSummary => _attendanceSummary;
  Map<String, int> get incidentSummary => _incidentSummary;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get waliClass => _waliClass;
  String get selectedDate => _selectedDate;
  String get attendanceStatusFilter => _attendanceStatusFilter;
  String get reportStatusFilter => _reportStatusFilter;
  int get totalStudents => _students.length;
  int get activeAlertsCount =>
      _studentAlerts.where((item) => item.hasAlert).length;
  int get pendingReportCount =>
      _reports.where((item) => (item['status'] ?? '').toString() != 'Selesai').length;
  int get completedReportCount =>
      _reports.where((item) => (item['status'] ?? '').toString() == 'Selesai').length;

  Future<void> loadStudentsForWaliClass(String kelas) async {
    _isLoading = true;
    _errorMessage = null;
    _waliClass = kelas;
    notifyListeners();

    try {
      final rawStudents = await _firestoreService.getStudentsByClass(kelas);
      _students = rawStudents
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
      _studentAlerts = _buildAlertItems(_students);
      _bindClassStreams(kelas);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _students = const [];
      _studentAlerts = const [];
      _attendanceRecordsToday = const [];
      _reports = const [];
      _errorMessage = 'Gagal memuat data perwalian: $e';
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (_waliClass == null || _waliClass!.isEmpty) {
      return;
    }
    await loadStudentsForWaliClass(_waliClass!);
  }

  Future<void> setSelectedDate(String date) async {
    _selectedDate = date;
    if (_waliClass == null || _waliClass!.isEmpty) {
      notifyListeners();
      return;
    }
    _bindClassStreams(_waliClass!);
    notifyListeners();
  }

  void setAttendanceStatusFilter(String value) {
    _attendanceStatusFilter = value;
    notifyListeners();
  }

  void setReportStatusFilter(String value) {
    _reportStatusFilter = value;
    notifyListeners();
  }

  List<Map<String, dynamic>> get filteredAttendanceRecords {
    if (_attendanceStatusFilter == 'Semua') {
      return _attendanceRecordsToday;
    }
    return _attendanceRecordsToday
        .where((record) => (record['status'] ?? '').toString().toLowerCase() == _attendanceStatusFilter.toLowerCase())
        .toList();
  }

  List<Map<String, dynamic>> get filteredReports {
    if (_reportStatusFilter == 'Semua') {
      return _reports;
    }
    return _reports
        .where((report) => (report['status'] ?? '').toString() == _reportStatusFilter)
        .toList();
  }

  void _bindClassStreams(String kelas) {
    _attendanceSubscription?.cancel();
    _reportsSubscription?.cancel();
    _incidentLogsSubscription?.cancel();

    _attendanceSubscription = _firestoreService
        .streamAbsensiByKelas(kelas, _selectedDate)
        .listen((records) {
      _attendanceRecordsToday = records;
      _attendanceSummary = _buildAttendanceSummary(records);
      notifyListeners();
    });

    _reportsSubscription = _firestoreService.streamReportsByClass(kelas).listen((items) {
      _reports = items;
      notifyListeners();
    });

    _incidentLogsSubscription = _firestoreService.streamIncidentLogsByDate(_selectedDate).listen((items) {
      _incidentLogs = items;
      _incidentSummary = _buildIncidentSummary(items);
      notifyListeners();
    });
  }

  Map<String, int> _buildAttendanceSummary(List<Map<String, dynamic>> records) {
    final latestByStudent = <String, Map<String, dynamic>>{};

    for (final record in records) {
      final studentId = (record['studentId'] ?? '').toString();
      if (studentId.isEmpty) {
        continue;
      }

      final existing = latestByStudent[studentId];
      final currentTime = _extractComparableDate(record['timestamp']);
      final existingTime = existing == null
          ? DateTime.fromMillisecondsSinceEpoch(0)
          : _extractComparableDate(existing['timestamp']);

      if (existing == null || currentTime.isAfter(existingTime)) {
        latestByStudent[studentId] = record;
      }
    }

    final summary = {
      'hadir': 0,
      'izin': 0,
      'sakit': 0,
      'alpha': 0,
    };

    for (final record in latestByStudent.values) {
      final status = (record['status'] ?? '').toString().toLowerCase();
      if (summary.containsKey(status)) {
        summary[status] = summary[status]! + 1;
      }
    }

    return summary;
  }

  Map<String, int> _buildIncidentSummary(List<Map<String, dynamic>> items) {
    final summary = {
      'Keterlambatan': 0,
      'Izin Pulang': 0,
    };

    for (final item in items) {
      final type = (item['incidentType'] ?? '').toString();
      if (summary.containsKey(type)) {
        summary[type] = summary[type]! + 1;
      }
    }

    return summary;
  }

  DateTime _extractComparableDate(dynamic value) {
    if (value == null) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
    if (value is DateTime) {
      return value;
    }
    final dynamicType = value.runtimeType.toString();
    if (dynamicType == 'Timestamp') {
      return value.toDate() as DateTime;
    }
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  @override
  void dispose() {
    _attendanceSubscription?.cancel();
    _reportsSubscription?.cancel();
    _incidentLogsSubscription?.cancel();
    super.dispose();
  }

  List<WaliStudentAlertItem> _buildAlertItems(List<UserModel> students) {
    return List.generate(students.length, (index) {
      final student = students[index];
      final alphaCount = _simulateAlphaCount(student, index);
      final previousAverage = _simulatePreviousAverage(student, index);
      final latestAverage = _simulateLatestAverage(student, index, previousAverage);

      final alertReasons = <String>[];
      if (alphaCount > 3) {
        alertReasons.add('Peringatan: Alpha $alphaCount x');
      }

      final dropPercentage = previousAverage <= 0
          ? 0.0
          : ((previousAverage - latestAverage) / previousAverage) * 100;
      if (dropPercentage > 20) {
        alertReasons.add('Peringatan: Nilai turun ${dropPercentage.round()}%');
      }

      return WaliStudentAlertItem(
        student: student,
        alphaCount: alphaCount,
        previousAverage: previousAverage,
        latestAverage: latestAverage,
        alertReasons: alertReasons,
      );
    });
  }

  int _simulateAlphaCount(UserModel student, int index) {
    final seed = student.uid.hashCode.abs() + index;
    return seed % 6;
  }

  double _simulatePreviousAverage(UserModel student, int index) {
    final seed = student.name.hashCode.abs() + index;
    return 72 + (seed % 19).toDouble();
  }

  double _simulateLatestAverage(
    UserModel student,
    int index,
    double previousAverage,
  ) {
    final seed = (student.nisnOrNip ?? student.uid).hashCode.abs() + index;
    final delta = (seed % 31) - 10;
    return (previousAverage + delta).clamp(40, 100).toDouble();
  }
}