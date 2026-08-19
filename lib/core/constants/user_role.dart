/// Enum untuk mendefinisikan 6 Role utama pada LMS EduTech SMK
enum UserRole {
  student,
  teacher,
  waliKelas,
  bk,
  piket,
  admin;

  /// Konversi dari String (Firestore) ke Enum UserRole
  static UserRole fromString(String? roleStr) {
    switch (roleStr?.toLowerCase().trim()) {
      case 'student':
      case 'siswa':
        return UserRole.student;
      case 'teacher':
      case 'guru_mapel':
      case 'guru':
        return UserRole.teacher;
      case 'wali_kelas':
      case 'walikelas':
        return UserRole.waliKelas;
      case 'bk':
      case 'guru_bk':
        return UserRole.bk;
      case 'piket':
      case 'guru_piket':
        return UserRole.piket;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.student;
    }
  }

  /// Konversi Enum ke String untuk disimpan ke Firestore
  String toValue() {
    switch (this) {
      case UserRole.student:
        return 'student';
      case UserRole.teacher:
        return 'teacher';
      case UserRole.waliKelas:
        return 'wali_kelas';
      case UserRole.bk:
        return 'bk';
      case UserRole.piket:
        return 'piket';
      case UserRole.admin:
        return 'admin';
    }
  }

  /// Nama tampilan role yang ramah pengguna
  String get displayName {
    switch (this) {
      case UserRole.student:
        return 'Siswa';
      case UserRole.teacher:
        return 'Guru Mata Pelajaran';
      case UserRole.waliKelas:
        return 'Wali Kelas';
      case UserRole.bk:
        return 'Guru Bimbingan Konseling (BK)';
      case UserRole.piket:
        return 'Guru Piket';
      case UserRole.admin:
        return 'Administrator';
    }
  }
}
