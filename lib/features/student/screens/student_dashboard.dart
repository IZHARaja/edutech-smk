import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/firestore_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/student_provider.dart';
import '../widgets/material_card.dart';
import '../widgets/task_card.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _currentIndex = 0;
  String? _listeningKelas;

  static const List<Map<String, String>> _scheduleList = [
    {
      'time': '07.00 - 08.30',
      'subject': 'Matematika',
      'teacher': 'Ibu Rina',
      'status': 'Hadir',
    },
    {
      'time': '08.45 - 10.15',
      'subject': 'Bahasa Indonesia',
      'teacher': 'Pak Arif',
      'status': 'Hadir',
    },
    {
      'time': '10.30 - 12.00',
      'subject': 'Pemrograman Mobile',
      'teacher': 'Pak Dimas',
      'status': 'Belum Absen',
    },
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final user = context.read<AppAuthProvider>().currentUser;
    final kelas = user?.kelas;
    if (kelas != null && kelas.isNotEmpty && _listeningKelas != kelas) {
      _listeningKelas = kelas;
      context.read<StudentProvider>().startListening(kelas: kelas);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AppAuthProvider>();
    final user = authProvider.currentUser;

    final pages = [
      _MateriTugasTab(userName: user?.name ?? 'Siswa'),
      _JadwalPresensiTab(
        kelas: user?.kelas ?? '-',
        studentId: user?.uid ?? '',
        studentName: user?.name ?? 'Siswa',
        nisn: user?.nisnOrNip ?? '-',
      ),
      _BookingBKTab(userName: user?.name ?? 'Siswa'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle),
        backgroundColor: AppColors.roleStudent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => context.read<AppAuthProvider>().logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          _StudentHeaderCard(userName: user?.name ?? 'Siswa', nisn: user?.nisnOrNip ?? '-', kelas: user?.kelas ?? '-'),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: pages,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (value) => setState(() => _currentIndex = value),
        selectedItemColor: AppColors.roleStudent,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'Materi & Tugas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Jadwal & Presensi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.support_agent_outlined),
            activeIcon: Icon(Icons.support_agent),
            label: 'Booking BK',
          ),
        ],
      ),
    );
  }

  String get _appBarTitle {
    switch (_currentIndex) {
      case 0:
        return 'Materi & Tugas';
      case 1:
        return 'Jadwal & Presensi';
      case 2:
        return 'Booking BK';
      default:
        return 'Dashboard Siswa';
    }
  }
}

class _StudentHeaderCard extends StatelessWidget {
  const _StudentHeaderCard({
    required this.userName,
    required this.nisn,
    required this.kelas,
  });

  final String userName;
  final String nisn;
  final String kelas;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.roleStudent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.roleStudent.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.roleStudent,
            child: Icon(Icons.school, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('NISN: $nisn', style: const TextStyle(color: AppColors.textSecondary)),
                Text('Kelas: $kelas', style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MateriTugasTab extends StatelessWidget {
  const _MateriTugasTab({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, studentProvider, _) {
        final materiList = studentProvider.materiList;
        final tugasList = studentProvider.tugasList;
        final isLoading = studentProvider.isInitialLoading;
        final materiError = studentProvider.materiError;
        final tugasError = studentProvider.tugasError;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          children: [
            _SectionBanner(
              color: AppColors.roleStudent,
              title: 'Halo, $userName',
              subtitle: isLoading
                  ? 'Memuat materi dan tugas terbaru dari Firestore.'
                  : '${materiList.length} materi dan ${tugasList.length} tugas aktif untuk ditinjau.',
              icon: Icons.auto_stories_rounded,
            ),
            const SizedBox(height: 16),
            const Text('Materi Terbaru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (isLoading) const _DataLoadingCard(message: 'Mengambil materi dan tugas...'),
            if (!isLoading && materiError != null)
              _DataInfoCard(
                message: materiError,
                color: AppColors.danger,
                icon: Icons.error_outline,
              ),
            if (!isLoading && materiError == null && materiList.isEmpty)
              const _DataInfoCard(
                message: 'Belum ada materi untuk kelas ini. Guru mapel dapat mengunggah materi dari dashboard mereka.',
                color: AppColors.textSecondary,
                icon: Icons.inbox_outlined,
              ),
            if (!isLoading && materiList.isNotEmpty)
              ...materiList.map(
                (item) => StudentMaterialCard(
                  title: (item['title'] ?? 'Materi tanpa judul').toString(),
                  subtitle: _buildMateriSubtitle(item),
                  onTap: () => _showMaterialDetail(context, item),
                ),
              ),
            const SizedBox(height: 20),
            const Text('Tugas Kelas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (!isLoading && tugasError != null)
              _DataInfoCard(
                message: tugasError,
                color: AppColors.danger,
                icon: Icons.error_outline,
              ),
            if (!isLoading && tugasError == null && tugasList.isEmpty)
              const _DataInfoCard(
                message: 'Belum ada tugas aktif pada koleksi Firestore untuk kelas ini.',
                color: AppColors.textSecondary,
                icon: Icons.assignment_outlined,
              ),
            if (!isLoading && tugasList.isNotEmpty)
              ...tugasList.map(
                (item) {
                  final authProvider = context.read<AppAuthProvider>();
                  final currentUser = authProvider.currentUser;
                  final submissions = item['submissions'] is Map<String, dynamic>
                      ? item['submissions'] as Map<String, dynamic>
                      : <String, dynamic>{};
                  final submission = currentUser != null ? submissions[currentUser.uid] : null;
                  final statusLabel = submission is Map<String, dynamic>
                      ? (submission['status'] ?? 'Belum Dikumpulkan').toString()
                      : 'Belum Dikumpulkan';
                  final statusColor = statusLabel == 'Dikumpulkan' || statusLabel == 'Selesai'
                      ? AppColors.success
                      : AppColors.warning;

                  return StudentTaskCard(
                    title: (item['title'] ?? 'Tugas tanpa judul').toString(),
                    subtitle: _buildTugasSubtitle(item),
                    statusLabel: statusLabel,
                    statusColor: statusColor,
                    onTap: () => _showTaskDetail(context, item),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  String _buildMateriSubtitle(Map<String, dynamic> item) {
    final mapel = (item['mapel'] ?? 'Mapel belum diatur').toString();
    final teacherName = (item['teacherName'] ?? 'Guru belum diatur').toString();
    final fileName = item['fileName'] != null ? ' • File: ${item['fileName']}' : '';
    return '$mapel • $teacherName$fileName';
  }

  String _buildTugasSubtitle(Map<String, dynamic> item) {
    final mapel = (item['mapel'] ?? 'Mapel belum diatur').toString();
    final deadline = item['deadline'] != null ? ' • Deadline tersedia' : ' • Deadline belum diatur';
    return '$mapel$deadline';
  }

  void _showTaskDetail(BuildContext context, Map<String, dynamic> item) {
    final authProvider = context.read<AppAuthProvider>();
    final firestoreService = context.read<FirestoreService>();
    final currentUser = authProvider.currentUser;
    final title = (item['title'] ?? 'Tugas / Kuis').toString();
    final mapel = (item['mapel'] ?? 'Umum').toString();
    final teacher = (item['teacherName'] ?? 'Guru Mapel').toString();
    final description = (item['description'] ?? 'Tidak ada deskripsi tugas.').toString();
    final deadline = item['deadline']?.toString() ?? 'Belum diatur';
    final tugasId = (item['id'] ?? '').toString();
    final submissions = item['submissions'] is Map<String, dynamic>
        ? item['submissions'] as Map<String, dynamic>
        : <String, dynamic>{};
    final submission = currentUser != null ? submissions[currentUser.uid] : null;
    final currentStatus = submission is Map<String, dynamic>
        ? (submission['status'] ?? 'Belum Dikumpulkan').toString()
        : 'Belum Dikumpulkan';
    bool isSubmitting = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: AppColors.accent,
                    child: Icon(Icons.assignment, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '$mapel • $teacher',
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Deskripsi Tugas:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(description),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schedule, color: AppColors.accent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Deadline: $deadline',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.info.withValues(alpha: 0.18)),
                ),
                child: Text(
                  'Status tugas Anda: $currentStatus',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 16),
              if (currentUser != null && tugasId.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          setModalState(() => isSubmitting = true);
                          try {
                            await firestoreService.updateStudentTaskStatus(
                              tugasId: tugasId,
                              studentId: currentUser.uid,
                              studentName: currentUser.name,
                              status: 'Dikumpulkan',
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Status tugas berhasil diubah menjadi Dikumpulkan.'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                            if (ctx.mounted) {
                              Navigator.of(ctx).pop();
                            }
                          } catch (e) {
                            setModalState(() => isSubmitting = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Gagal mengubah status tugas: $e'),
                                  backgroundColor: AppColors.danger,
                                ),
                              );
                            }
                          }
                        },
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.assignment_turned_in_outlined),
                  label: Text(isSubmitting ? 'Menyimpan...' : 'Tandai Dikumpulkan'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Tutup'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMaterialDetail(BuildContext context, Map<String, dynamic> item) {
    final title = (item['title'] ?? 'Materi Pembelajaran').toString();
    final mapel = (item['mapel'] ?? 'Umum').toString();
    final teacher = (item['teacherName'] ?? 'Guru Mapel').toString();
    final description = (item['description'] ?? 'Tidak ada deskripsi.').toString();
    final fileName = item['fileName']?.toString();
    final fileUrl = item['fileUrl']?.toString();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.roleStudent,
                  child: Icon(Icons.menu_book, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$mapel • $teacher',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Deskripsi Materi:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(description),
            if (fileName != null || fileUrl != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Lampiran Berkas:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.insert_drive_file, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        fileName ?? fileUrl ?? 'Berkas Materi',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Tutup'),
            ),
          ],
        ),
      ),
    );
  }
}

class _JadwalPresensiTab extends StatelessWidget {
  const _JadwalPresensiTab({
    required this.kelas,
    required this.studentId,
    required this.studentName,
    required this.nisn,
  });

  final String kelas;
  final String studentId;
  final String studentName;
  final String nisn;

  static const List<Map<String, String>> _scheduleList = _StudentDashboardState._scheduleList;

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.read<FirestoreService>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      children: [
        _SectionBanner(
          color: AppColors.secondary,
          title: 'Jadwal Hari Ini',
          subtitle: 'Kelas $kelas memiliki 3 sesi dan presensi 2/3 sudah tercatat.',
          icon: Icons.calendar_today,
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: studentId.isEmpty
              ? null
              : () async {
                  try {
                    await firestoreService.recordPresensi(
                      studentId: studentId,
                      studentName: studentName,
                      nisn: nisn,
                      kelas: kelas,
                      status: 'hadir',
                      recordedBy: studentId,
                      mapel: 'Absensi Mandiri',
                      type: 'mandiri',
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Absensi mandiri berhasil dikirim.'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Gagal mengirim absensi: $e'),
                          backgroundColor: AppColors.danger,
                        ),
                      );
                    }
                  }
                },
          icon: const Icon(Icons.how_to_reg_outlined),
          label: const Text('Absen Mandiri Hari Ini'),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
        ),
        const SizedBox(height: 16),
        const Text('Rekap Kehadiran Anda', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: studentId.isEmpty
              ? null
              : firestoreService.streamAbsensiByStudent(studentId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _DataLoadingCard(message: 'Mengambil rekap absensi...');
            }
            if (snapshot.hasError) {
              return _DataInfoCard(
                message: 'Gagal memuat rekap absensi: ${snapshot.error}',
                color: AppColors.danger,
                icon: Icons.error_outline,
              );
            }
            final records = snapshot.data ?? const <Map<String, dynamic>>[];
            if (records.isEmpty) {
              return const _DataInfoCard(
                message: 'Belum ada rekap absensi yang tersimpan.',
                color: AppColors.textSecondary,
                icon: Icons.event_busy_outlined,
              );
            }
            return Column(
              children: records.take(5).map((record) {
                final status = (record['status'] ?? '-').toString();
                final mapel = (record['mapel'] ?? 'Umum').toString();
                final date = (record['date'] ?? '').toString();
                final statusColor = switch (status) {
                  'hadir' => AppColors.success,
                  'izin' => AppColors.info,
                  'sakit' => AppColors.warning,
                  'alpha' => AppColors.danger,
                  _ => AppColors.textSecondary,
                };

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: statusColor,
                      child: const Icon(Icons.fact_check_outlined, color: Colors.white),
                    ),
                    title: Text(mapel, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(date),
                    trailing: Text(
                      status.toUpperCase(),
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 16),
        ..._scheduleList.map(
          (item) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: item['status'] == 'Belum Absen' ? AppColors.warning : AppColors.success,
                child: Icon(
                  item['status'] == 'Belum Absen' ? Icons.access_time : Icons.check,
                  color: Colors.white,
                ),
              ),
              title: Text(item['subject']!, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('${item['time']} • ${item['teacher']}'),
              trailing: Text(
                item['status']!,
                style: TextStyle(
                  color: item['status'] == 'Belum Absen' ? AppColors.warning : AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BookingBKTab extends StatelessWidget {
  const _BookingBKTab({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AppAuthProvider>();
    final firestoreService = context.read<FirestoreService>();
    final currentUser = authProvider.currentUser;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      children: [
        _SectionBanner(
          color: AppColors.roleBK,
          title: 'Layanan BK untuk $userName',
          subtitle: 'Kirim pengaduan atau konsultasi langsung ke Guru BK dan pantau tindak lanjutnya.',
          icon: Icons.support_agent,
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: currentUser == null
              ? null
              : () => _showReportDialog(
                    context,
                    firestoreService: firestoreService,
                    studentId: currentUser.uid,
                    studentName: currentUser.name,
                    kelas: currentUser.kelas ?? '-',
                  ),
          icon: const Icon(Icons.add_comment_outlined),
          label: const Text('Kirim Pengaduan ke Guru BK'),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.roleBK),
        ),
        const SizedBox(height: 16),
        const Text('Aduan & Tindak Lanjut', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: currentUser == null
              ? null
              : firestoreService.streamReportsByStudent(currentUser.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _DataLoadingCard(message: 'Memuat aduan BK Anda...');
            }
            if (snapshot.hasError) {
              return _DataInfoCard(
                message: 'Gagal memuat aduan BK: ${snapshot.error}',
                color: AppColors.danger,
                icon: Icons.error_outline,
              );
            }

            final reports = snapshot.data ?? const <Map<String, dynamic>>[];
            if (reports.isEmpty) {
              return const _DataInfoCard(
                message: 'Belum ada pengaduan yang Anda kirim ke Guru BK.',
                color: AppColors.textSecondary,
                icon: Icons.mark_chat_unread_outlined,
              );
            }

            return Column(
              children: reports.map((report) {
                final status = (report['status'] ?? 'Menunggu Tindak Lanjut').toString();
                final response = (report['response'] ?? '').toString();
                final statusColor = switch (status) {
                  'Selesai' => AppColors.success,
                  'Diproses' => AppColors.info,
                  _ => AppColors.warning,
                };

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: AppColors.roleBK,
                              child: Icon(Icons.support_agent, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (report['title'] ?? 'Pengaduan BK').toString(),
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    (report['category'] ?? 'Umum').toString(),
                                    style: const TextStyle(color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text((report['description'] ?? '').toString()),
                        if (response.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.info.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.info.withValues(alpha: 0.18)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tindak Lanjut Guru BK',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                Text(response),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Future<void> _showReportDialog(
    BuildContext context, {
    required FirestoreService firestoreService,
    required String studentId,
    required String studentName,
    required String kelas,
  }) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String selectedCategory = 'Akademik';
    bool isSubmitting = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kirim Pengaduan ke Guru BK',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Judul Pengaduan',
                    hintText: 'Contoh: Kesulitan belajar matematika',
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Judul wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  items: const [
                    DropdownMenuItem(value: 'Akademik', child: Text('Akademik')),
                    DropdownMenuItem(value: 'Sosial', child: Text('Sosial')),
                    DropdownMenuItem(value: 'Pribadi', child: Text('Pribadi')),
                    DropdownMenuItem(value: 'Pelanggaran', child: Text('Pelanggaran')),
                  ],
                  onChanged: isSubmitting
                      ? null
                      : (value) {
                          if (value != null) {
                            setModalState(() => selectedCategory = value);
                          }
                        },
                  decoration: const InputDecoration(labelText: 'Kategori Aduan'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descriptionController,
                  minLines: 4,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Isi Pengaduan',
                    hintText: 'Jelaskan masalah atau kebutuhan konseling Anda.',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Isi pengaduan wajib diisi'
                      : null,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }
                          setModalState(() => isSubmitting = true);
                          try {
                            await firestoreService.createStudentReport(
                              studentId: studentId,
                              studentName: studentName,
                              kelas: kelas,
                              category: selectedCategory,
                              title: titleController.text.trim(),
                              description: descriptionController.text.trim(),
                            );
                            if (ctx.mounted) {
                              Navigator.of(ctx).pop();
                            }
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Pengaduan berhasil dikirim ke Guru BK.'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          } catch (e) {
                            setModalState(() => isSubmitting = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Gagal mengirim pengaduan: $e'),
                                  backgroundColor: AppColors.danger,
                                ),
                              );
                            }
                          }
                        },
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.send_outlined),
                  label: Text(isSubmitting ? 'Mengirim...' : 'Kirim Pengaduan'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.roleBK),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    titleController.dispose();
    descriptionController.dispose();
  }
}

class _SectionBanner extends StatelessWidget {
  const _SectionBanner({
    required this.color,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final Color color;
  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DataLoadingCard extends StatelessWidget {
  const _DataLoadingCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2.2),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

class _DataInfoCard extends StatelessWidget {
  const _DataInfoCard({
    required this.message,
    required this.color,
    required this.icon,
  });

  final String message;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: color == AppColors.textSecondary ? AppColors.textSecondary : color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
