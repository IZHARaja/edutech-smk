# EduTech SMK — Platform LMS & Monitoring Disiplin Sekolah

[![Live Web Demo](https://img.shields.io/badge/Live%20Demo-Firebase%20Hosting-blue?style=for-the-badge&logo=firebase)](https://edutech-smk-dd479.web.app)
[![GitHub Repository](https://img.shields.io/badge/GitHub-Repository-181717?style=for-the-badge&logo=github)](https://github.com/IZHARaja/edutech-smk)
[![Flutter Version](https://img.shields.io/badge/Flutter-3.47.0-02569B?style=for-the-badge&logo=flutter)](https://flutter.dev)

> **EduTech SMK** adalah aplikasi Learning Management System (LMS) dan sistem monitoring disiplin terintegrasi untuk jenjang SMK berbasis **Flutter** dan **Google Firebase**. Aplikasi ini dikembangkan sebagai Final Project mata kuliah **Mobile Cross-Platform Development** menggunakan arsitektur *Feature-First Pattern* dan *Provider State Management*.

---

## 🌐 Akses Live Web & Repositori

- **🔗 Live Web URL**: [https://edutech-smk-dd479.web.app](https://edutech-smk-dd479.web.app)
- **💻 GitHub Repository**: [https://github.com/IZHARaja/edutech-smk](https://github.com/IZHARaja/edutech-smk)
- **🔥 Firebase Project ID**: `edutech-smk-dd479` (Region: `asia-southeast2` Jakarta)

---

## 👥 Tim Pengembang (Development Team)

Proyek ini dirancang dan dikembangkan secara kolaboratif oleh tim mahasiswa berikut:

| No | Nama | NIM | Peran Utama & Fokus Kontribusi |
|:---:|---|:---:|---|
| **1** | **IZHAR** | **105841109023** | **Project Leader & Core Full-Stack Architect**<br>• Perancangan arsitektur sistem (*Feature-First* & *Provider*)<br>• Integrasi Firebase (Auth, Cloud Firestore, Security Rules, Hosting)<br>• Core Auth & Automatic Role Router (6 peran)<br>• Modul **Siswa** (LMS viewer, penyerahan tugas, absensi mandiri, aduan BK)<br>• Modul **Guru Mapel** (Upload materi, manajemen tugas, input absensi)<br>• Database Seeder otomatis (30 siswa demo di 3 kelas) & Live Deployment |
| 2 | **MUH RAFLI** | 105841108723 | **Lead Feature Developer (Wali Kelas)**<br>• Dashboard pemantauan Wali Kelas terpusat<br>• *Smart Alert System* (deteksi Alpha > 3x dan penurunan nilai > 20%)<br>• Rekapitulasi absensi kelas harian & buku penghubung |
| 3 | **M Erwin Khusnaedy** | 105841120623 | **Backend & Feature Developer (Bimbingan Konseling)**<br>• Dashboard Guru BK (Aduan Masuk & Tracking Kasus)<br>• Sistem aduan konseling dua arah siswa-guru BK<br>• Formulir & alur respons tindak lanjut kasus |
| 4 | **NAWAT SAKTI AL'AGASI** | 105841108823 | **Feature Developer (Guru Piket)**<br>• Dashboard Guru Piket & absensi cepat tanpa QR<br>• Pencatatan kejadian harian (keterlambatan/izin pulang)<br>• Sistem filtering log kejadian berdasarkan tanggal & kategori |
| 5 | **Muh. Rizki Aqil Az-zikra Alimuddin** | 105841109623 | **UI/UX Specialist & QA Engineer**<br>• Desain responsif Portal Admin (Sidebar & Drawer layout)<br>• Desain sistem tema Material 3 (`AppTheme` & `AppColors`)<br>• Pengujian kualitas sistem (*Quality Assurance* & *Analyzer Testing*) |

📖 **Panduan Lengkap Peran & Naskah Presentasi Video 10 Menit**:  
👉 Silakan baca dokumen khusus: [TIM_DAN_PEMBAGIAN_PERAN.md](TIM_DAN_PEMBAGIAN_PERAN.md)

---

## 🛠️ Tech Stack

- Frontend: Flutter 3.47.0
- Backend: Firebase Authentication, Cloud Firestore, Firebase Hosting
- State Management: Provider (MultiProvider)
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
