import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/firestore_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../teacher/screens/attendance_screen.dart';

class PiketDashboard extends StatefulWidget {
  const PiketDashboard({super.key});

  @override
  State<PiketDashboard> createState() => _PiketDashboardState();
}

class _PiketDashboardState extends State<PiketDashboard> {
  final TextEditingController _studentController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String _incidentType = 'Keterlambatan';
  String _filterType = 'Semua';
  final TextEditingController _dateController = TextEditingController(
    text: DateTime.now().toIso8601String().substring(0, 10),
  );
  bool _isSavingIncident = false;

  String get _selectedDate => _dateController.text.trim().isEmpty
      ? DateTime.now().toIso8601String().substring(0, 10)
      : _dateController.text.trim();

  @override
  void dispose() {
    _studentController.dispose();
    _notesController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _saveIncident() async {
    final currentUser = context.read<AppAuthProvider>().currentUser;
    if (_studentController.text.trim().isEmpty || _notesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama siswa dan keterangan wajib diisi.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isSavingIncident = true);
    try {
      await context.read<FirestoreService>().addIncidentLog(
            studentName: _studentController.text.trim(),
            incidentType: _incidentType,
            notes: _notesController.text.trim(),
            reportedById: currentUser?.uid ?? 'unknown-piket',
            reportedByName: currentUser?.name ?? 'Guru Piket',
        date: _selectedDate,
          );
      _studentController.clear();
      _notesController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Catatan kejadian berhasil disimpan.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan catatan: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingIncident = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AppAuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Guru Piket'),
        backgroundColor: AppColors.rolePiket,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => context.read<AppAuthProvider>().logout(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: AppColors.rolePiket.withValues(alpha: 0.08),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.rolePiket,
                      child: Icon(Icons.security, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Guru Piket',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text('NIP: ${user?.nisnOrNip ?? "-"}'),
                          Text(
                            'Role: ${user?.role.displayName}',
                            style: const TextStyle(color: AppColors.rolePiket, fontWeight: FontWeight.w600),
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
                color: AppColors.rolePiket.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Absensi Guru Piket',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Gunakan form absensi untuk mencatat kehadiran harian siswa tanpa QR Code.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const AttendanceScreen(
                            title: 'Absensi Guru Piket',
                            mapelLabel: 'Absensi Piket',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.rolePiket),
                    icon: const Icon(Icons.playlist_add_check_circle_outlined),
                    label: const Text('Buka Form Absensi Piket'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Catatan Kejadian Harian',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _studentController,
              decoration: const InputDecoration(
                labelText: 'Nama Siswa',
                hintText: 'Masukkan nama siswa',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _incidentType,
              items: const [
                DropdownMenuItem(value: 'Keterlambatan', child: Text('Keterlambatan')),
                DropdownMenuItem(value: 'Izin Pulang', child: Text('Izin Pulang')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _incidentType = value);
                }
              },
              decoration: const InputDecoration(
                labelText: 'Jenis Catatan',
                prefixIcon: Icon(Icons.fact_check_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              minLines: 3,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Keterangan',
                hintText: 'Contoh: datang terlambat 12 menit karena transportasi',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isSavingIncident ? null : _saveIncident,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.rolePiket),
              icon: _isSavingIncident
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_isSavingIncident ? 'Menyimpan...' : 'Simpan Catatan Harian'),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.rolePiket,
                side: const BorderSide(color: AppColors.rolePiket),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.campaign_outlined),
              label: const Text('Broadcast Urgensi (Push Notification)'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Log Kejadian Terbaru',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: 'Filter Tanggal',
                hintText: 'YYYY-MM-DD',
                prefixIcon: Icon(Icons.date_range_outlined),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _filterType,
              items: const [
                DropdownMenuItem(value: 'Semua', child: Text('Semua Catatan')),
                DropdownMenuItem(value: 'Keterlambatan', child: Text('Keterlambatan')),
                DropdownMenuItem(value: 'Izin Pulang', child: Text('Izin Pulang')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _filterType = value);
                }
              },
              decoration: const InputDecoration(
                labelText: 'Filter Catatan',
                prefixIcon: Icon(Icons.filter_alt_outlined),
              ),
            ),
            const SizedBox(height: 12),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: context.read<FirestoreService>().streamIncidentLogsByDate(_selectedDate),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text(
                    'Gagal memuat log kejadian: ${snapshot.error}',
                    style: const TextStyle(color: AppColors.danger),
                  );
                }
                final rawLogs = snapshot.data ?? const <Map<String, dynamic>>[];
                final logs = _filterType == 'Semua'
                    ? rawLogs
                    : rawLogs.where((item) => (item['incidentType'] ?? '').toString() == _filterType).toList();
                if (logs.isEmpty) {
                  return Text(
                    _filterType == 'Semua'
                        ? 'Belum ada catatan kejadian harian yang tersimpan.'
                        : 'Belum ada catatan dengan filter $_filterType.',
                    style: const TextStyle(color: AppColors.textSecondary),
                  );
                }
                return Column(
                  children: logs.take(6).map((item) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.rolePiket,
                          child: Icon(Icons.assignment_late_outlined, color: Colors.white),
                        ),
                        title: Text(
                          (item['studentName'] ?? 'Siswa').toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${(item['incidentType'] ?? '').toString()} • ${(item['notes'] ?? '').toString()}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
