import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/teacher_provider.dart';

class UploadMaterialScreen extends StatefulWidget {
  const UploadMaterialScreen({super.key});

  @override
  State<UploadMaterialScreen> createState() => _UploadMaterialScreenState();
}

class _UploadMaterialScreenState extends State<UploadMaterialScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _externalUrlController = TextEditingController();
  String? _selectedKelas;
  String _selectedMapel = 'Pemrograman Mobile';
  String? _selectedFileName;
  String? _selectedMimeType;
  Uint8List? _selectedFileBytes;

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
    _externalUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'mp4', 'mov', 'avi', 'ppt', 'pptx', 'doc', 'docx'],
    );

    if (!mounted || result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.single;
    if (file.bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal membaca file terpilih. Coba pilih file lain.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() {
      _selectedFileName = file.name;
      _selectedFileBytes = file.bytes;
      _selectedMimeType = file.extension != null ? _guessMimeType(file.extension!) : null;
    });
  }

  Future<void> _submitMaterial() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final externalUrl = _externalUrlController.text.trim();

    if ((_selectedFileBytes == null || _selectedFileName == null) &&
        externalUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih file PDF/Video atau isi tautan materi eksternal sebelum mengunggah.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final selectedKelas = _selectedKelas ??
        (context.read<TeacherProvider>().availableClasses.isNotEmpty
            ? context.read<TeacherProvider>().availableClasses.first
            : null);

    if (selectedKelas == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Belum ada kelas tersedia untuk materi ini.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final authProvider = context.read<AppAuthProvider>();
    final teacherProvider = context.read<TeacherProvider>();
    final currentUser = authProvider.currentUser;

    final success = await teacherProvider.submitMaterialDraft(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      kelas: selectedKelas,
      teacherId: currentUser?.uid ?? 'unknown-teacher',
      teacherName: currentUser?.name ?? 'Guru Mapel',
      mapel: _selectedMapel,
      fileName: _selectedFileName,
      fileBytes: _selectedFileBytes,
      externalUrl: externalUrl,
      mimeType: _selectedMimeType,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Materi berhasil disiapkan dan metadata telah dikirim.'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(teacherProvider.uploadError ?? 'Gagal mengunggah materi.'),
        backgroundColor: AppColors.danger,
      ),
    );
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
        title: const Text('Unggah Materi'),
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
                  color: AppColors.roleTeacher.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Form Publikasi Materi',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Gunakan formulir ini untuk unggah ke Firebase Storage atau pakai tautan file eksternal bila Storage belum aktif.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Materi',
                  hintText: 'Contoh: Firebase Authentication Dasar',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul materi wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                minLines: 4,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  hintText: 'Tuliskan ringkasan materi, tujuan pembelajaran, atau instruksi singkat.',
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Deskripsi materi wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (teacherProvider.isClassesLoading)
                const _TeacherInfoCard(
                  icon: Icons.sync,
                  message: 'Memuat daftar kelas dari Firestore...',
                )
              else if (teacherProvider.classesError != null)
                _TeacherInfoCard(
                  icon: Icons.error_outline,
                  message: teacherProvider.classesError!,
                  color: AppColors.danger,
                )
              else if (availableClasses.isEmpty)
                const _TeacherInfoCard(
                  icon: Icons.school_outlined,
                  message: 'Belum ada data kelas siswa di Firestore.',
                  color: AppColors.warning,
                )
              else
                DropdownButtonFormField<String>(
                  initialValue: selectedKelas,
                  items: availableClasses
                      .map((kelas) => DropdownMenuItem(value: kelas, child: Text(kelas)))
                      .toList(),
                  onChanged: teacherProvider.isUploading
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() => _selectedKelas = value);
                          }
                        },
                  decoration: const InputDecoration(
                    labelText: 'Kelas Target',
                  ),
                ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedMapel,
                items: _mapelOptions
                    .map((mapel) => DropdownMenuItem(value: mapel, child: Text(mapel)))
                    .toList(),
                onChanged: teacherProvider.isUploading
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() => _selectedMapel = value);
                        }
                      },
                decoration: const InputDecoration(
                  labelText: 'Mata Pelajaran',
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tautan Materi Eksternal',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Gunakan link Google Drive, OneDrive, atau URL file publik bila Firebase Storage belum tersedia.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _externalUrlController,
                      enabled: !teacherProvider.isUploading,
                      keyboardType: TextInputType.url,
                      decoration: const InputDecoration(
                        labelText: 'URL Materi (Opsional)',
                        hintText: 'https://drive.google.com/...',
                        prefixIcon: Icon(Icons.link_outlined),
                      ),
                      validator: (value) {
                        final trimmed = value?.trim() ?? '';
                        if (trimmed.isEmpty) {
                          return null;
                        }
                        final uri = Uri.tryParse(trimmed);
                        if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
                          return 'Masukkan URL yang valid';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Lampiran File', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(
                      _selectedFileName ?? 'Belum ada file dipilih. Bagian ini opsional jika Anda memakai tautan eksternal.',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    if (_selectedFileName != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline, color: AppColors.success),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _selectedFileName!,
                                style: const TextStyle(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: teacherProvider.isUploading ? null : _pickFile,
                      icon: const Icon(Icons.attach_file_outlined),
                      label: const Text('Pilih File (PDF/Video)'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: teacherProvider.isUploading ? null : _submitMaterial,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.roleTeacher),
                icon: teacherProvider.isUploading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.cloud_upload_outlined),
                label: Text(teacherProvider.isUploading ? 'Mengunggah...' : 'Unggah Materi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _guessMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'avi':
        return 'video/x-msvideo';
      case 'ppt':
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case 'doc':
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }
}

class _TeacherInfoCard extends StatelessWidget {
  const _TeacherInfoCard({
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