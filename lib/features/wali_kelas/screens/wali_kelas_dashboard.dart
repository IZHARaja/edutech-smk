import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../teacher/screens/attendance_screen.dart';
import '../providers/wali_kelas_provider.dart';
import '../../auth/providers/auth_provider.dart';

class WaliKelasDashboard extends StatefulWidget {
  const WaliKelasDashboard({super.key});

  @override
  State<WaliKelasDashboard> createState() => _WaliKelasDashboardState();
}

class _WaliKelasDashboardState extends State<WaliKelasDashboard> {
  String? _loadedKelas;
  final TextEditingController _dateController = TextEditingController(
    text: DateTime.now().toIso8601String().substring(0, 10),
  );

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final kelas = context.read<AppAuthProvider>().currentUser?.kelas;
    if (kelas != null && kelas.isNotEmpty && _loadedKelas != kelas) {
      _loadedKelas = kelas;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<WaliKelasProvider>().loadStudentsForWaliClass(kelas);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AppAuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Wali Kelas'),
        backgroundColor: AppColors.roleWaliKelas,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => context.read<AppAuthProvider>().logout(),
          ),
        ],
      ),
      body: Consumer<WaliKelasProvider>(
        builder: (context, waliProvider, _) {
          if (waliProvider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Memuat data perwalian dan alert system...'),
                ],
              ),
            );
          }

          if (waliProvider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  waliProvider.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.danger),
                ),
              ),
            );
          }

          final studentAlerts = waliProvider.studentAlerts;
          final attendanceSummary = waliProvider.attendanceSummary;
          final reports = waliProvider.filteredReports;
          final incidentSummary = waliProvider.incidentSummary;
          final incidentLogs = waliProvider.incidentLogs;
          final attendanceRecords = waliProvider.filteredAttendanceRecords;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                color: AppColors.roleWaliKelas.withValues(alpha: 0.08),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.roleWaliKelas,
                        child: Icon(Icons.supervisor_account, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? 'Wali Kelas',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text('Wali Kelas: ${user?.kelas ?? "-"} | NIP: ${user?.nisnOrNip ?? "-"}'),
                            Text(
                              'Role: ${user?.role.displayName}',
                              style: const TextStyle(color: AppColors.roleWaliKelas, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.roleWaliKelas.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ringkasan Perwalian',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Kelas ${user?.kelas ?? '-'} memiliki ${waliProvider.activeAlertsCount} siswa dengan alert aktif, ${waliProvider.pendingReportCount} aduan aktif, dan ${waliProvider.totalStudents} siswa terdaftar.',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _SummaryChip(label: 'Hadir', value: '${attendanceSummary['hadir'] ?? 0}', color: AppColors.success),
                        _SummaryChip(label: 'Izin', value: '${attendanceSummary['izin'] ?? 0}', color: AppColors.info),
                        _SummaryChip(label: 'Sakit', value: '${attendanceSummary['sakit'] ?? 0}', color: AppColors.warning),
                        _SummaryChip(label: 'Alpha', value: '${attendanceSummary['alpha'] ?? 0}', color: AppColors.danger),
                        _SummaryChip(label: 'Aduan Aktif', value: '${waliProvider.pendingReportCount}', color: AppColors.roleBK),
                        _SummaryChip(label: 'Aduan Selesai', value: '${waliProvider.completedReportCount}', color: AppColors.secondary),
                        _SummaryChip(label: 'Terlambat', value: '${incidentSummary['Keterlambatan'] ?? 0}', color: AppColors.rolePiket),
                        _SummaryChip(label: 'Izin Pulang', value: '${incidentSummary['Izin Pulang'] ?? 0}', color: AppColors.info),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _dateController,
                      decoration: const InputDecoration(
                        labelText: 'Filter Tanggal Rekap',
                        hintText: 'YYYY-MM-DD',
                        prefixIcon: Icon(Icons.date_range_outlined),
                      ),
                      onChanged: (value) {
                        final trimmed = value.trim();
                        if (trimmed.isNotEmpty) {
                          context.read<WaliKelasProvider>().setSelectedDate(trimmed);
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: () {
                        final kelas = user?.kelas;
                        if (kelas == null || kelas.isEmpty) {
                          return;
                        }
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => AttendanceScreen(
                              title: 'Absensi Wali Kelas',
                              mapelLabel: 'Rekap Wali Kelas',
                              fixedClass: kelas,
                              lockClassSelection: true,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        minimumSize: const Size(220, 46),
                      ),
                      icon: const Icon(Icons.how_to_reg_outlined),
                      label: const Text('Input Absensi Kelas'),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.roleWaliKelas,
                        minimumSize: const Size(220, 46),
                      ),
                      icon: const Icon(Icons.menu_book_outlined),
                      label: const Text('Buku Penghubung Digital'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Rekap Absensi Hari Ini',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: waliProvider.attendanceStatusFilter,
                items: const [
                  DropdownMenuItem(value: 'Semua', child: Text('Semua Status Absensi')),
                  DropdownMenuItem(value: 'hadir', child: Text('Hadir')),
                  DropdownMenuItem(value: 'izin', child: Text('Izin')),
                  DropdownMenuItem(value: 'sakit', child: Text('Sakit')),
                  DropdownMenuItem(value: 'alpha', child: Text('Alpha')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    context.read<WaliKelasProvider>().setAttendanceStatusFilter(value);
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Filter Status Absensi',
                  prefixIcon: Icon(Icons.filter_alt_outlined),
                ),
              ),
              const SizedBox(height: 12),
              if (attendanceRecords.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text(
                    'Belum ada data absensi kelas untuk filter ini.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              else
                ...attendanceRecords.take(4).map(
                  (record) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.secondary,
                        child: Icon(Icons.fact_check_outlined, color: Colors.white),
                      ),
                      title: Text(
                        (record['studentName'] ?? 'Siswa').toString(),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        '${(record['mapel'] ?? 'Umum').toString()} • ${(record['date'] ?? '').toString()}',
                      ),
                      trailing: Text(
                        (record['status'] ?? '').toString().toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _statusColor((record['status'] ?? '').toString()),
                        ),
                      ),
                    ),
                  ),
                ),
              const Text(
                'Aduan BK Terkait Kelas',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: waliProvider.reportStatusFilter,
                items: const [
                  DropdownMenuItem(value: 'Semua', child: Text('Semua Status Aduan')),
                  DropdownMenuItem(value: 'Menunggu Tindak Lanjut', child: Text('Menunggu Tindak Lanjut')),
                  DropdownMenuItem(value: 'Diproses', child: Text('Diproses')),
                  DropdownMenuItem(value: 'Selesai', child: Text('Selesai')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    context.read<WaliKelasProvider>().setReportStatusFilter(value);
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Filter Status Aduan BK',
                  prefixIcon: Icon(Icons.filter_list_alt),
                ),
              ),
              const SizedBox(height: 12),
              if (reports.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text(
                    'Belum ada aduan BK untuk filter ini.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              else
                ...reports.take(4).map(
                  (report) => Card(
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
                                      (report['studentName'] ?? 'Siswa').toString(),
                                      style: const TextStyle(fontWeight: FontWeight.w700),
                                    ),
                                    Text(
                                      (report['title'] ?? 'Aduan BK').toString(),
                                      style: const TextStyle(color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              _StatusBadge(
                                label: (report['status'] ?? 'Menunggu').toString(),
                                color: _reportStatusColor((report['status'] ?? '').toString()),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text((report['description'] ?? '').toString()),
                          if ((report['response'] ?? '').toString().isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.info.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text((report['response'] ?? '').toString()),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              const Text(
                'Catatan Guru Piket',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (incidentLogs.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text(
                    'Belum ada catatan kejadian dari Guru Piket.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              else
                ...incidentLogs.take(4).map(
                  (item) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _incidentColor((item['incidentType'] ?? '').toString()),
                        child: const Icon(Icons.assignment_late_outlined, color: Colors.white),
                      ),
                      title: Text(
                        (item['studentName'] ?? 'Siswa').toString(),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text((item['notes'] ?? '').toString()),
                      trailing: _StatusBadge(
                        label: (item['incidentType'] ?? 'Catatan').toString(),
                        color: _incidentColor((item['incidentType'] ?? '').toString()),
                      ),
                    ),
                  ),
                ),
              const Text(
                'Monitoring Daftar Siswa',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (studentAlerts.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'Belum ada siswa terdaftar pada kelas perwalian ini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              else
                ...studentAlerts.map(
                  (studentAlert) => _StudentMonitoringCard(item: studentAlert),
                ),
            ],
          );
        },
      ),
    );
  }
}

Color _statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'hadir':
      return AppColors.success;
    case 'izin':
      return AppColors.info;
    case 'sakit':
      return AppColors.warning;
    case 'alpha':
      return AppColors.danger;
    default:
      return AppColors.textSecondary;
  }
}

Color _reportStatusColor(String status) {
  switch (status) {
    case 'Selesai':
      return AppColors.success;
    case 'Diproses':
      return AppColors.info;
    default:
      return AppColors.warning;
  }
}

Color _incidentColor(String type) {
  switch (type) {
    case 'Keterlambatan':
      return AppColors.rolePiket;
    case 'Izin Pulang':
      return AppColors.info;
    default:
      return AppColors.textSecondary;
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _StudentMonitoringCard extends StatelessWidget {
  const _StudentMonitoringCard({required this.item});

  final WaliStudentAlertItem item;

  @override
  Widget build(BuildContext context) {
    final bool hasAlert = item.hasAlert;
    final Color accentColor = hasAlert ? AppColors.danger : AppColors.success;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: hasAlert ? AppColors.danger : AppColors.border,
          width: hasAlert ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: accentColor.withValues(alpha: 0.14),
                  child: Icon(Icons.person_outline, color: accentColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.student.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('NISN: ${item.student.nisnOrNip ?? '-'}', style: const TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                _StatusBadge(label: item.statusLabel, color: accentColor),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _MetricTile(label: 'Alpha', value: '${item.alphaCount} kali')),
                const SizedBox(width: 10),
                Expanded(child: _MetricTile(label: 'Tren Nilai', value: item.scoreTrendLabel)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: 'Rata-rata Sebelumnya',
                    value: item.previousAverage.toStringAsFixed(0),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricTile(
                    label: 'Drop Nilai',
                    value: '${item.scoreDropPercentage.toStringAsFixed(0)}%',
                  ),
                ),
              ],
            ),
            if (hasAlert) ...[
              const SizedBox(height: 12),
              ...item.alertReasons.map(
                (reason) => Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.danger.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppColors.danger),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          reason,
                          style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}
