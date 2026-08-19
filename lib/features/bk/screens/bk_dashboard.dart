import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/firestore_service.dart';
import '../../auth/providers/auth_provider.dart';

class BKDashboard extends StatelessWidget {
  const BKDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AppAuthProvider>();
    final user = authProvider.currentUser;
    final firestoreService = context.read<FirestoreService>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard Guru BK'),
          backgroundColor: AppColors.roleBK,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () => context.read<AppAuthProvider>().logout(),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Jadwal Konseling'),
              Tab(text: 'Tracking Kasus'),
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.roleBK.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.roleBK,
                    child: Icon(Icons.psychology, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.name ?? 'Guru BK', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('NIP: ${user?.nisnOrNip ?? '-'}', style: const TextStyle(color: AppColors.textSecondary)),
                        const Text(
                          'Fokus hari ini: pantau aduan siswa, ubah status, dan kirim tindak lanjut langsung.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: firestoreService.streamAllReports(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'Gagal memuat aduan masuk: ${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.danger),
                            ),
                          ),
                        );
                      }

                      final reports = snapshot.data ?? const <Map<String, dynamic>>[];
                      if (reports.isEmpty) {
                        return const Center(
                          child: Text(
                            'Belum ada aduan yang masuk dari siswa.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        );
                      }

                      return ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                        children: reports
                            .map(
                              (item) => _BKScheduleCard(
                                name: (item['studentName'] ?? 'Siswa').toString(),
                                topic: (item['category'] ?? 'Umum').toString(),
                                schedule: 'Status: ${(item['status'] ?? 'Menunggu Tindak Lanjut').toString()}',
                                status: (item['status'] ?? 'Menunggu Tindak Lanjut').toString(),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: firestoreService.streamAllReports(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'Gagal memuat tracking aduan: ${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.danger),
                            ),
                          ),
                        );
                      }

                      final reports = snapshot.data ?? const <Map<String, dynamic>>[];
                      if (reports.isEmpty) {
                        return const Center(
                          child: Text(
                            'Belum ada data aduan untuk ditindaklanjuti.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        );
                      }

                      return ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                        children: reports
                            .map(
                              (item) => _CaseTrackingCard(
                                report: item,
                                onRespond: () => _showBKResponseDialog(
                                  context,
                                  firestoreService: firestoreService,
                                  report: item,
                                  handledById: user?.uid ?? '',
                                  handledByName: user?.name ?? 'Guru BK',
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showBKResponseDialog(
    BuildContext context, {
    required FirestoreService firestoreService,
    required Map<String, dynamic> report,
    required String handledById,
    required String handledByName,
  }) async {
    final responseController = TextEditingController(
      text: (report['response'] ?? '').toString(),
    );
    final formKey = GlobalKey<FormState>();
    String selectedStatus = (report['status'] ?? 'Diproses').toString();
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
                Text(
                  'Tindak Lanjut: ${(report['title'] ?? 'Aduan Siswa').toString()}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedStatus,
                  items: const [
                    DropdownMenuItem(value: 'Menunggu Tindak Lanjut', child: Text('Menunggu Tindak Lanjut')),
                    DropdownMenuItem(value: 'Diproses', child: Text('Diproses')),
                    DropdownMenuItem(value: 'Selesai', child: Text('Selesai')),
                  ],
                  onChanged: isSubmitting
                      ? null
                      : (value) {
                          if (value != null) {
                            setModalState(() => selectedStatus = value);
                          }
                        },
                  decoration: const InputDecoration(labelText: 'Status Penanganan'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: responseController,
                  minLines: 4,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Respons / Tindak Lanjut',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Respons penanganan wajib diisi'
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
                            await firestoreService.updateReportResponse(
                              reportId: (report['id'] ?? '').toString(),
                              status: selectedStatus,
                              response: responseController.text.trim(),
                              handledById: handledById,
                              handledByName: handledByName,
                            );
                            if (ctx.mounted) {
                              Navigator.of(ctx).pop();
                            }
                          } catch (e) {
                            setModalState(() => isSubmitting = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Gagal menyimpan tindak lanjut: $e'),
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
                      : const Icon(Icons.save_outlined),
                  label: Text(isSubmitting ? 'Menyimpan...' : 'Simpan Tindak Lanjut'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.roleBK),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    responseController.dispose();
  }
}

class _BKScheduleCard extends StatelessWidget {
  const _BKScheduleCard({
    required this.name,
    required this.topic,
    required this.schedule,
    required this.status,
  });

  final String name;
  final String topic;
  final String schedule;
  final String status;

  @override
  Widget build(BuildContext context) {
    final Color color = switch (status) {
      'Disetujui' => AppColors.success,
      'Selesai' => AppColors.info,
      _ => AppColors.warning,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.14),
          child: Icon(Icons.event_note, color: color),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text('$topic • $schedule'),
        ),
        trailing: _MiniBadge(label: status, color: color),
      ),
    );
  }
}

class _CaseTrackingCard extends StatelessWidget {
  const _CaseTrackingCard({
    required this.report,
    required this.onRespond,
  });

  final Map<String, dynamic> report;
  final VoidCallback onRespond;

  @override
  Widget build(BuildContext context) {
    final name = (report['studentName'] ?? 'Siswa').toString();
    final category = (report['category'] ?? 'Umum').toString();
    final summary = (report['description'] ?? '').toString();
    final status = (report['status'] ?? 'Menunggu Tindak Lanjut').toString();
    final response = (report['response'] ?? '').toString();

    final Color categoryColor = switch (category) {
      'Akademik' => AppColors.roleStudent,
      'Sosial' => AppColors.secondary,
      'Pribadi' => AppColors.roleBK,
      _ => AppColors.danger,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
                _MiniBadge(label: category, color: categoryColor),
              ],
            ),
            const SizedBox(height: 10),
            Text(summary, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.timeline, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(status, style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
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
                child: Text(response),
              ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: onRespond,
                icon: const Icon(Icons.edit_note_outlined),
                label: const Text('Tindak Lanjut'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({required this.label, required this.color});

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
