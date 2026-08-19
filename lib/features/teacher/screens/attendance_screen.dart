import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/models/user_model.dart';
import '../providers/teacher_provider.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({
    super.key,
    this.title = 'Input Absensi Real-time',
    this.mapelLabel = 'Pemrograman Mobile',
    this.fixedClass,
    this.lockClassSelection = false,
  });

  final String title;
  final String mapelLabel;
  final String? fixedClass;
  final bool lockClassSelection;

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final Map<String, String> _attendanceStatus = {};
  String? _selectedKelas;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<TeacherProvider>();
      provider.loadAvailableClasses();
      if (widget.fixedClass != null && widget.fixedClass!.isNotEmpty) {
        _loadStudentsForClass(widget.fixedClass!);
      }
    });
  }

  Future<void> _loadStudentsForClass(String kelas) async {
    setState(() {
      _selectedKelas = kelas;
      _attendanceStatus.clear();
    });

    await context.read<TeacherProvider>().loadStudentsByClass(kelas);
    if (!mounted) {
      return;
    }

    final students = context.read<TeacherProvider>().studentsInClass;
    setState(() {
      for (final student in students) {
        _attendanceStatus.putIfAbsent(student.uid, () => 'hadir');
      }
    });
  }

  Future<void> _saveAttendance() async {
    final authProvider = context.read<AppAuthProvider>();
    final teacherProvider = context.read<TeacherProvider>();
    final currentUser = authProvider.currentUser;
    final students = teacherProvider.studentsInClass;

    if (_selectedKelas == null || students.isEmpty) {
      return;
    }

    final records = students
        .map(
          (student) => {
            'studentId': student.uid,
            'studentName': student.name,
            'nisn': student.nisnOrNip ?? '-',
            'kelas': student.kelas ?? _selectedKelas!,
            'status': _attendanceStatus[student.uid] ?? 'hadir',
          },
        )
        .toList();

    final success = await teacherProvider.saveAttendance(
      records: records,
      recordedBy: currentUser?.uid ?? 'unknown-teacher',
      mapel: widget.mapelLabel,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Absensi berhasil disimpan ke Firestore.'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(teacherProvider.attendanceError ?? 'Gagal menyimpan absensi.'),
        backgroundColor: AppColors.danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final teacherProvider = context.watch<TeacherProvider>();
    final availableClasses = teacherProvider.availableClasses;
    final students = teacherProvider.studentsInClass;
    final canSubmit = !teacherProvider.isSavingAttendance &&
        _selectedKelas != null &&
      students.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.roleTeacher,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedKelas == null
                      ? 'Pilih Kelas untuk Absensi'
                      : 'Absensi Kelas $_selectedKelas',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Pilih kelas lalu atur status kehadiran tiap siswa untuk mencatat presensi sesi mapel hari ini.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),
                if (widget.lockClassSelection && widget.fixedClass != null)
                  _AttendanceInfoCard(
                    icon: Icons.class_outlined,
                    message: 'Mode absensi untuk kelas ${widget.fixedClass!}.',
                    color: AppColors.secondary,
                  )
                else
                if (teacherProvider.isClassesLoading)
                  const _AttendanceInfoCard(
                    icon: Icons.sync,
                    message: 'Memuat daftar kelas dari Firestore...',
                  )
                else if (teacherProvider.classesError != null)
                  _AttendanceInfoCard(
                    icon: Icons.error_outline,
                    message: teacherProvider.classesError!,
                    color: AppColors.danger,
                  )
                else if (availableClasses.isEmpty)
                  const _AttendanceInfoCard(
                    icon: Icons.school_outlined,
                    message: 'Belum ada data kelas siswa pada koleksi users.',
                    color: AppColors.warning,
                  )
                else
                  DropdownButtonFormField<String>(
                    initialValue: availableClasses.contains(_selectedKelas)
                        ? _selectedKelas
                        : null,
                    items: availableClasses
                        .map(
                          (kelas) => DropdownMenuItem<String>(
                            value: kelas,
                            child: Text(kelas),
                          ),
                        )
                        .toList(),
                    onChanged: teacherProvider.isSavingAttendance
                        || widget.lockClassSelection
                        ? null
                        : (value) {
                            if (value != null) {
                              _loadStudentsForClass(value);
                            }
                          },
                    decoration: const InputDecoration(
                      labelText: 'Pilih Kelas',
                      prefixIcon: Icon(Icons.class_outlined),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _selectedKelas == null
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Pilih kelas untuk menampilkan daftar siswa dan mulai input absensi.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                : teacherProvider.isStudentsLoading
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 12),
                            Text('Memuat daftar siswa dari Firestore...'),
                          ],
                        ),
                      )
                    : teacherProvider.studentsError != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                teacherProvider.studentsError!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: AppColors.danger),
                              ),
                            ),
                          )
                        : students.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Text(
                                    'Belum ada siswa di kelas ini.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: AppColors.textSecondary),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                                itemCount: students.length,
                                itemBuilder: (context, index) {
                                  final UserModel student = students[index];
                                  final studentId = student.uid;

                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            student.name,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'NISN: ${student.nisnOrNip ?? '-'} • ${student.kelas ?? '-'}',
                                            style: const TextStyle(color: AppColors.textSecondary),
                                          ),
                                          const SizedBox(height: 14),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: [
                                              _AttendanceChoiceChip(
                                                label: 'Hadir',
                                                selected: _attendanceStatus[studentId] == 'hadir',
                                                color: AppColors.success,
                                                onSelected: () => setState(
                                                  () => _attendanceStatus[studentId] = 'hadir',
                                                ),
                                              ),
                                              _AttendanceChoiceChip(
                                                label: 'Izin',
                                                selected: _attendanceStatus[studentId] == 'izin',
                                                color: AppColors.info,
                                                onSelected: () => setState(
                                                  () => _attendanceStatus[studentId] = 'izin',
                                                ),
                                              ),
                                              _AttendanceChoiceChip(
                                                label: 'Sakit',
                                                selected: _attendanceStatus[studentId] == 'sakit',
                                                color: AppColors.warning,
                                                onSelected: () => setState(
                                                  () => _attendanceStatus[studentId] = 'sakit',
                                                ),
                                              ),
                                              _AttendanceChoiceChip(
                                                label: 'Alpha',
                                                selected: _attendanceStatus[studentId] == 'alpha',
                                                color: AppColors.danger,
                                                onSelected: () => setState(
                                                  () => _attendanceStatus[studentId] = 'alpha',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ElevatedButton.icon(
          onPressed: canSubmit ? _saveAttendance : null,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
          icon: teacherProvider.isSavingAttendance
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.save_outlined),
          label: Text(
            teacherProvider.isSavingAttendance ? 'Menyimpan...' : 'Simpan Absensi',
          ),
        ),
      ),
    );
  }
}

class _AttendanceInfoCard extends StatelessWidget {
  const _AttendanceInfoCard({
    required this.icon,
    required this.message,
    this.color = AppColors.textSecondary,
  });

  final IconData icon;
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceChoiceChip extends StatelessWidget {
  const _AttendanceChoiceChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: color.withValues(alpha: 0.18),
      labelStyle: TextStyle(
        color: selected ? color : AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
      side: BorderSide(color: selected ? color : AppColors.border),
      avatar: selected ? Icon(Icons.check_circle, size: 18, color: color) : null,
    );
  }
}
