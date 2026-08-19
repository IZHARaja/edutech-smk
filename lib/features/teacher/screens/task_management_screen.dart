import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/firestore_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/teacher_provider.dart';

class TaskManagementScreen extends StatefulWidget {
  const TaskManagementScreen({super.key});

  @override
  State<TaskManagementScreen> createState() => _TaskManagementScreenState();
}

class _TaskManagementScreenState extends State<TaskManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _deadlineController = TextEditingController();
  bool _isSaving = false;
  String? _selectedKelas;
  String _selectedMapel = 'Pemrograman Mobile';

  static const List<String> _mapelOptions = [
    'Pemrograman Mobile',
    'Matematika',
    'Bahasa Indonesia',
    'Produktif RPL',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeacherProvider>().loadAvailableClasses();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final teacherProvider = context.read<TeacherProvider>();
    final authProvider = context.read<AppAuthProvider>();
    final currentUser = authProvider.currentUser;
    final kelas = _selectedKelas ??
        (teacherProvider.availableClasses.isNotEmpty
            ? teacherProvider.availableClasses.first
            : null);

    if (kelas == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Belum ada kelas tersedia untuk tugas ini.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    DateTime? deadline;
    final deadlineText = _deadlineController.text.trim();
    if (deadlineText.isNotEmpty) {
      deadline = DateTime.tryParse(deadlineText);
    }

    setState(() => _isSaving = true);
    try {
      await context.read<FirestoreService>().addTugas(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            mapel: _selectedMapel,
            kelas: kelas,
            teacherId: currentUser?.uid ?? 'unknown-teacher',
            teacherName: currentUser?.name ?? 'Guru Mapel',
            deadline: deadline,
          );

      if (!mounted) {
        return;
      }
      _titleController.clear();
      _descriptionController.clear();
      _deadlineController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tugas/kuis berhasil dipublikasikan.'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuat tugas: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final teacherProvider = context.watch<TeacherProvider>();
    final availableClasses = teacherProvider.availableClasses;
    final selectedKelas = availableClasses.contains(_selectedKelas)
        ? _selectedKelas
        : (availableClasses.isNotEmpty ? availableClasses.first : null);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Tugas & Kuis'),
        backgroundColor: AppColors.roleTeacher,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Publikasikan Tugas atau Kuis',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Tugas yang Anda buat di sini akan langsung tampil pada dashboard siswa berdasarkan kelasnya.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Tugas / Kuis',
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Judul wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                minLines: 3,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  alignLabelWithHint: true,
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Deskripsi wajib diisi'
                    : null,
              ),
              const SizedBox(height: 12),
              if (teacherProvider.isClassesLoading)
                const Center(child: CircularProgressIndicator())
              else
                DropdownButtonFormField<String>(
                  initialValue: selectedKelas,
                  items: availableClasses
                      .map((kelas) => DropdownMenuItem(value: kelas, child: Text(kelas)))
                      .toList(),
                  onChanged: _isSaving
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() => _selectedKelas = value);
                          }
                        },
                  decoration: const InputDecoration(labelText: 'Kelas Target'),
                ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedMapel,
                items: _mapelOptions
                    .map((mapel) => DropdownMenuItem(value: mapel, child: Text(mapel)))
                    .toList(),
                onChanged: _isSaving
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() => _selectedMapel = value);
                        }
                      },
                decoration: const InputDecoration(labelText: 'Mata Pelajaran'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _deadlineController,
                decoration: const InputDecoration(
                  labelText: 'Deadline (Opsional)',
                  hintText: '2026-08-25 12:00:00',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveTask,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.assignment_turned_in_outlined),
                label: Text(_isSaving ? 'Menyimpan...' : 'Publikasikan Tugas'),
              ),
              const SizedBox(height: 24),
              const Text(
                'Tugas Aktif',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: context.read<FirestoreService>().streamTugasList(kelas: selectedKelas),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text(
                      'Gagal memuat tugas: ${snapshot.error}',
                      style: const TextStyle(color: AppColors.danger),
                    );
                  }
                  final items = snapshot.data ?? const <Map<String, dynamic>>[];
                  if (items.isEmpty) {
                    return const Text(
                      'Belum ada tugas aktif untuk kelas ini.',
                      style: TextStyle(color: AppColors.textSecondary),
                    );
                  }
                  return Column(
                    children: items.map((item) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.accent,
                            child: Icon(Icons.assignment, color: Colors.white),
                          ),
                          title: Text((item['title'] ?? 'Tugas').toString()),
                          subtitle: Text(
                            '${(item['mapel'] ?? '').toString()} • ${(item['kelas'] ?? '').toString()}',
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}