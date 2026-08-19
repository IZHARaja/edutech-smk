# EduTech SMK

EduTech SMK adalah aplikasi LMS dan monitoring sekolah berbasis Flutter + Firebase untuk kebutuhan proyek akhir mata kuliah Mobile Cross-Platform Development. Aplikasi ini dirancang untuk mendukung banyak peran dalam satu codebase: siswa, guru mapel, wali kelas, guru BK, guru piket, dan admin.

## Live Demo

- Live web app: https://edutech-smk-dd479.web.app
- Firebase project: `edutech-smk-dd479`

## Tech Stack

- Frontend: Flutter 3.47
- Backend: Firebase Authentication, Cloud Firestore, Firebase Hosting
- State Management: Provider
- Architecture: Feature-First Pattern

## Fitur Utama yang Sudah Aktif

### Authentication & Role Routing

- Login Firebase Authentication berbasis email/password
- Routing dashboard otomatis berdasarkan role pengguna
- Seeder akun demo untuk seluruh role

### Siswa

- Melihat materi dari koleksi `materi`
- Melihat tugas/kuis dari koleksi `tugas`
- Menandai tugas sebagai `Dikumpulkan`
- Melihat detail materi dan detail tugas
- Absensi mandiri dan melihat rekap absensi pribadi
- Mengirim pengaduan langsung ke Guru BK
- Melihat status dan tindak lanjut aduan BK

### Guru Mapel

- Unggah materi
- Fallback materi via tautan eksternal bila Firebase Storage belum dipakai penuh
- Input absensi kelas
- Membuat tugas/kuis baru

### Wali Kelas

- Monitoring daftar siswa perwalian
- Alert system untuk simulasi alpha dan penurunan nilai
- Rekap absensi kelas berdasarkan tanggal
- Ringkasan aduan BK terkait kelas
- Ringkasan catatan Guru Piket

### Guru BK

- Membaca aduan masuk dari siswa
- Mengubah status penanganan aduan
- Memberi respons atau tindak lanjut aduan

### Guru Piket

- Input absensi tanpa QR code
- Menyimpan catatan kejadian harian ke Firestore
- Filter catatan berdasarkan tanggal dan jenis kejadian

## Struktur Project

```text
lib/
├── main.dart
├── firebase_options.dart
├── core/
│   ├── constants/
│   ├── services/
│   └── theme/
└── features/
		├── auth/
		├── student/
		├── teacher/
		├── wali_kelas/
		├── bk/
		├── piket/
		└── admin/
```

## Akun Demo

Semua akun memakai password yang sama:

```text
password123
```

Role utama:

- Siswa utama: `siswa@edutech.sch.id`
- Guru mapel: `guru@edutech.sch.id`
- Wali kelas XII RPL 1: `walikelas@edutech.sch.id`
- Wali kelas XI RPL 1: `walikelas2@edutech.sch.id`
- Guru BK: `bk@edutech.sch.id`
- Guru Piket: `piket@edutech.sch.id`
- Admin: `admin@edutech.sch.id`

Seeder juga membuat 30 akun siswa demo yang tersebar ke beberapa kelas, termasuk:

- `XII RPL 1`
- `XI RPL 1`
- `XII TKJ 1`

Contoh email siswa tambahan:

- `siswa02@edutech.sch.id`
- `siswa03@edutech.sch.id`
- ...
- `siswa30@edutech.sch.id`

## Cara Menjalankan Secara Lokal

### 1. Install dependency

```bash
flutter pub get
```

### 2. Jalankan aplikasi web

```bash
flutter run -d chrome
```

### 3. Generate akun demo

Di halaman login, klik tombol:

```text
Generate Demo Data
```

Tombol ini akan membuat akun demo di Firebase Authentication dan dokumen profile di koleksi `users`.

## Build Production Web

```bash
flutter build web
```

Output build akan berada di:

```text
build/web
```

## Firebase Rules & Hosting

Deploy Firestore rules:

```bash
firebase deploy --only firestore:rules --project edutech-smk-dd479
```

Deploy Hosting:

```bash
firebase deploy --only hosting --project edutech-smk-dd479
```

## Catatan Implementasi

- Koleksi Firestore utama yang dipakai saat ini:
	- `users`
	- `materi`
	- `tugas`
	- `attendance`
	- `reports`
	- `incident_logs`
	- `pelanggaran`
	- `konseling`
- Sistem unggah materi mendukung fallback URL eksternal jika bucket Firebase Storage belum digunakan penuh.
- Deployment Hosting aktif dan dapat diakses publik.

## Status Pengembangan

Yang sudah selesai:

- Authentication & role-based routing
- Dashboard multi-role dasar
- Absensi lintas peran
- Pengaduan BK dua arah
- Tugas/kuis dasar
- Rekap wali kelas
- Seeder multi-role dan multi-kelas
- Firebase Hosting live

Yang masih bisa dikembangkan:

- Penilaian/remedial tugas
- Filter tanggal lanjutan untuk BK
- Integrasi Storage penuh
- Notifikasi push FCM
- Admin portal yang lebih lengkap

## Repository

- GitHub: https://github.com/IZHARaja/edutech-smk
