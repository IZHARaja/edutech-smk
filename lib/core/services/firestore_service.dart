import 'package:cloud_firestore/cloud_firestore.dart';

/// Service terpusat untuk operasi Firestore CRUD pada LMS EduTech SMK
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _attendanceCollection = 'attendance';

  // ==========================================
  // 0. USERS & KELAS
  // ==========================================

  /// Mengambil daftar kelas unik dari pengguna dengan role student.
  Future<List<String>> getStudentClassList() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .get();

      final classes = snapshot.docs
          .map((doc) => (doc.data()['kelas'] ?? '').toString().trim())
          .where((kelas) => kelas.isNotEmpty)
          .toSet()
          .toList()
        ..sort();

      return classes;
    } catch (e) {
      throw Exception('Gagal mengambil daftar kelas: $e');
    }
  }

  /// Mengambil daftar siswa berdasarkan kelas dari koleksi users.
  Future<List<Map<String, dynamic>>> getStudentsByClass(String kelas) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .where('kelas', isEqualTo: kelas)
          .get();

      final students = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'studentId': doc.id,
          'name': (data['name'] ?? 'Tanpa Nama').toString(),
          'nisn': (data['nisnOrNip'] ?? data['nisn'] ?? '-').toString(),
          'kelas': (data['kelas'] ?? kelas).toString(),
          'email': (data['email'] ?? '').toString(),
        };
      }).toList()
        ..sort(
          (a, b) => a['name']
              .toString()
              .toLowerCase()
              .compareTo(b['name'].toString().toLowerCase()),
        );

      return students;
    } catch (e) {
      throw Exception('Gagal mengambil daftar siswa kelas $kelas: $e');
    }
  }

  // ==========================================
  // 1. MATERI & TUGAS (Guru Mapel & Siswa)
  // ==========================================

  /// Mengambil daftar materi berdasarkan kelas atau mata pelajaran
  Stream<List<Map<String, dynamic>>> streamMateriList({String? kelas, String? mapel}) {
    Query query = _firestore.collection('materi');

    if (kelas != null && kelas.isNotEmpty) {
      query = query.where('kelas', isEqualTo: kelas);
    }
    if (mapel != null && mapel.isNotEmpty) {
      query = query.where('mapel', isEqualTo: mapel);
    }

    return query.snapshots().map((snapshot) {
      final items = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      items.sort((a, b) {
        final aTime = _extractComparableDate(a['createdAt']);
        final bTime = _extractComparableDate(b['createdAt']);
        return bTime.compareTo(aTime);
      });

      return items;
    });
  }

  /// Menambahkan materi baru oleh Guru Mapel
  Future<String> addMateri({
    required String title,
    required String description,
    required String mapel,
    required String kelas,
    required String teacherId,
    required String teacherName,
    String? fileUrl,
    String? fileName,
  }) async {
    try {
      final docRef = await _firestore.collection('materi').add({
        'title': title,
        'description': description,
        'mapel': mapel,
        'kelas': kelas,
        'teacherId': teacherId,
        'teacherName': teacherName,
        'fileUrl': fileUrl,
        'fileName': fileName,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Gagal menambahkan materi: $e');
    }
  }

  /// Memperbarui materi yang sudah ada
  Future<void> updateMateri({
    required String materiId,
    required String title,
    required String description,
    String? fileUrl,
    String? fileName,
  }) async {
    try {
      await _firestore.collection('materi').doc(materiId).update({
        'title': title,
        'description': description,
        'fileUrl': fileUrl,
        'fileName': fileName,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Gagal memperbarui materi: $e');
    }
  }

  /// Menghapus materi dari Firestore
  Future<void> deleteMateri(String materiId) async {
    try {
      await _firestore.collection('materi').doc(materiId).delete();
    } catch (e) {
      throw Exception('Gagal menghapus materi: $e');
    }
  }

  /// Mengambil daftar tugas berdasarkan kelas
  Stream<List<Map<String, dynamic>>> streamTugasList({String? kelas}) {
    Query query = _firestore.collection('tugas');

    if (kelas != null && kelas.isNotEmpty) {
      query = query.where('kelas', isEqualTo: kelas);
    }

    return query.snapshots().map((snapshot) {
      final items = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      items.sort((a, b) {
        final aTime = _extractComparableDate(a['deadline']);
        final bTime = _extractComparableDate(b['deadline']);
        return aTime.compareTo(bTime);
      });

      return items;
    });
  }

  DateTime _extractComparableDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  /// Memperbarui status tugas siswa atau publikasi tugas guru
  Future<void> updateTugas({
    required String tugasId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      await _firestore.collection('tugas').doc(tugasId).update({
        ...payload,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Gagal memperbarui tugas: $e');
    }
  }

  Future<void> updateStudentTaskStatus({
    required String tugasId,
    required String studentId,
    required String studentName,
    required String status,
  }) async {
    try {
      await _firestore.collection('tugas').doc(tugasId).set({
        'submissions': {
          studentId: {
            'studentName': studentName,
            'status': status,
            'updatedAt': FieldValue.serverTimestamp(),
          },
        },
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Gagal memperbarui status tugas siswa: $e');
    }
  }

  Future<String> addTugas({
    required String title,
    required String description,
    required String mapel,
    required String kelas,
    required String teacherId,
    required String teacherName,
    DateTime? deadline,
  }) async {
    try {
      final docRef = await _firestore.collection('tugas').add({
        'title': title,
        'description': description,
        'mapel': mapel,
        'kelas': kelas,
        'teacherId': teacherId,
        'teacherName': teacherName,
        'deadline': deadline != null ? Timestamp.fromDate(deadline) : null,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Gagal menambahkan tugas: $e');
    }
  }

  // ==========================================
  // 2. PRESENSI & ABSENSI (Guru Mapel, Wali Kelas, Piket, Siswa)
  // ==========================================

  /// Mencatat presensi siswa
  Future<void> recordPresensi({
    required String studentId,
    required String studentName,
    required String nisn,
    required String kelas,
    required String status, // 'hadir', 'izin', 'sakit', 'alpha'
    required String recordedBy, // UID guru / piket / sistem
    String? mapel,
    String? keterangan,
    String type = 'mapel', // 'mapel', 'gerbang_piket', 'harian'
  }) async {
    try {
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      final scope = (mapel ?? 'general')
          .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')
          .toLowerCase();
      final docId = '${studentId}_${type}_${todayStr}_$scope';

      await _firestore.collection(_attendanceCollection).doc(docId).set({
        'studentId': studentId,
        'studentName': studentName,
        'nisn': nisn,
        'kelas': kelas,
        'status': status,
        'type': type,
        'mapel': mapel,
        'keterangan': keterangan,
        'recordedBy': recordedBy,
        'timestamp': FieldValue.serverTimestamp(),
        'date': todayStr,
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Gagal mencatat presensi: $e');
    }
  }

  /// Stream absensi harian kelas untuk Wali Kelas / Guru Mapel
  Stream<List<Map<String, dynamic>>> streamAbsensiByKelas(String kelas, String dateStr) {
    return _firestore
        .collection(_attendanceCollection)
        .where('kelas', isEqualTo: kelas)
        .where('date', isEqualTo: dateStr)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  /// Stream riwayat absensi siswa untuk Siswa / Orang Tua
  Stream<List<Map<String, dynamic>>> streamAbsensiByStudent(String studentId) {
    return _firestore
        .collection(_attendanceCollection)
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();

          items.sort((a, b) {
            final aTime = _extractComparableDate(a['timestamp']);
            final bTime = _extractComparableDate(b['timestamp']);
            return bTime.compareTo(aTime);
          });

          return items;
        });
  }

  // ==========================================
  // 3. POIN PELANGGARAN & PRESTASI (Piket, BK, Wali Kelas)
  // ==========================================

  /// Menginput catatan pelanggaran baru
  Future<String> recordPelanggaran({
    required String studentId,
    required String studentName,
    required String nisn,
    required String kelas,
    required String judulPelanggaran,
    required String kategori, // 'Ringan', 'Sedang', 'Berat'
    required int poin,
    required String tindakan,
    required String reportedByUid,
    required String reportedByName,
    required String reportedByRole,
  }) async {
    try {
      final docRef = await _firestore.collection('pelanggaran').add({
        'studentId': studentId,
        'studentName': studentName,
        'nisn': nisn,
        'kelas': kelas,
        'judulPelanggaran': judulPelanggaran,
        'kategori': kategori,
        'poin': poin,
        'tindakan': tindakan,
        'reportedBy': {
          'uid': reportedByUid,
          'name': reportedByName,
          'role': reportedByRole,
        },
        'status': 'Terbuka', // 'Terbuka', 'Ditindaklanjuti', 'Selesai'
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Gagal mencatat pelanggaran: $e');
    }
  }

  /// Memperbarui status tindak lanjut pelanggaran
  Future<void> updatePelanggaranStatus({
    required String pelanggaranId,
    required String status,
    String? tindakLanjut,
  }) async {
    try {
      await _firestore.collection('pelanggaran').doc(pelanggaranId).update({
        'status': status,
        'tindakLanjut': tindakLanjut,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Gagal memperbarui status pelanggaran: $e');
    }
  }

  /// Stream daftar pelanggaran seorang siswa
  Stream<List<Map<String, dynamic>>> streamPelanggaranByStudent(String studentId) {
    return _firestore
        .collection('pelanggaran')
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  // ==========================================
  // 4. REPORTS / PENGADUAN BK
  // ==========================================

  Future<String> createStudentReport({
    required String studentId,
    required String studentName,
    required String kelas,
    required String category,
    required String title,
    required String description,
  }) async {
    try {
      final docRef = await _firestore.collection('reports').add({
        'studentId': studentId,
        'studentName': studentName,
        'kelas': kelas,
        'category': category,
        'title': title,
        'description': description,
        'status': 'Menunggu Tindak Lanjut',
        'response': '',
        'handledById': '',
        'handledByName': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Gagal mengirim pengaduan BK: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> streamReportsByStudent(String studentId) {
    return _firestore
        .collection('reports')
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snapshot) {
      final items = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      items.sort((a, b) {
        final aTime = _extractComparableDate(a['createdAt']);
        final bTime = _extractComparableDate(b['createdAt']);
        return bTime.compareTo(aTime);
      });

      return items;
    });
  }

  Stream<List<Map<String, dynamic>>> streamAllReports() {
    return _firestore.collection('reports').snapshots().map((snapshot) {
      final items = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      items.sort((a, b) {
        final aTime = _extractComparableDate(a['createdAt']);
        final bTime = _extractComparableDate(b['createdAt']);
        return bTime.compareTo(aTime);
      });

      return items;
    });
  }

  Stream<List<Map<String, dynamic>>> streamReportsByClass(String kelas) {
    return _firestore
        .collection('reports')
        .where('kelas', isEqualTo: kelas)
        .snapshots()
        .map((snapshot) {
      final items = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      items.sort((a, b) {
        final aTime = _extractComparableDate(a['createdAt']);
        final bTime = _extractComparableDate(b['createdAt']);
        return bTime.compareTo(aTime);
      });

      return items;
    });
  }

  Future<void> updateReportResponse({
    required String reportId,
    required String status,
    required String response,
    required String handledById,
    required String handledByName,
  }) async {
    try {
      await _firestore.collection('reports').doc(reportId).update({
        'status': status,
        'response': response,
        'handledById': handledById,
        'handledByName': handledByName,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Gagal memperbarui tindak lanjut BK: $e');
    }
  }

  // ==========================================
  // 5. INCIDENT LOGS GURU PIKET
  // ==========================================

  Future<String> addIncidentLog({
    required String studentName,
    required String incidentType,
    required String notes,
    required String reportedById,
    required String reportedByName,
    required String date,
  }) async {
    try {
      final docRef = await _firestore.collection('incident_logs').add({
        'studentName': studentName,
        'incidentType': incidentType,
        'notes': notes,
        'reportedById': reportedById,
        'reportedByName': reportedByName,
        'date': date,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Gagal menyimpan catatan kejadian: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> streamIncidentLogs() {
    return _firestore.collection('incident_logs').snapshots().map((snapshot) {
      final items = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      items.sort((a, b) {
        final aTime = _extractComparableDate(a['createdAt']);
        final bTime = _extractComparableDate(b['createdAt']);
        return bTime.compareTo(aTime);
      });

      return items;
    });
  }

  Stream<List<Map<String, dynamic>>> streamIncidentLogsByDate(String dateStr) {
    return _firestore
        .collection('incident_logs')
        .where('date', isEqualTo: dateStr)
        .snapshots()
        .map((snapshot) {
      final items = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      items.sort((a, b) {
        final aTime = _extractComparableDate(a['createdAt']);
        final bTime = _extractComparableDate(b['createdAt']);
        return bTime.compareTo(aTime);
      });

      return items;
    });
  }

  // ==========================================
  // 6. BOOKING & LAYANAN KONSELING BK
  // ==========================================

  /// Membuat pengajuan sesi konseling oleh Siswa
  Future<String> createBookingKonseling({
    required String studentId,
    required String studentName,
    required String kelas,
    required String topik,
    required String keterangan,
    required DateTime jadwalPengajuan,
    String jenisLayanan = 'Pribadi', // 'Pribadi', 'Sosial', 'Belajar', 'Karir'
  }) async {
    try {
      final docRef = await _firestore.collection('konseling').add({
        'studentId': studentId,
        'studentName': studentName,
        'kelas': kelas,
        'topik': topik,
        'keterangan': keterangan,
        'jenisLayanan': jenisLayanan,
        'jadwal': Timestamp.fromDate(jadwalPengajuan),
        'status': 'Menunggu Konfirmasi', // 'Menunggu Konfirmasi', 'Disetujui', 'Selesai', 'Ditolak'
        'catatanBK': '',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Gagal mengajukan booking konseling: $e');
    }
  }

  /// Stream daftar konseling siswa untuk Siswa
  Stream<List<Map<String, dynamic>>> streamKonselingByStudent(String studentId) {
    return _firestore
        .collection('konseling')
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  /// Stream semua permohonan konseling untuk Guru BK
  Stream<List<Map<String, dynamic>>> streamAllKonseling() {
    return _firestore
        .collection('konseling')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }
}
